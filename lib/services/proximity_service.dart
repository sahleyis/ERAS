import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import '../config/constants.dart';
import 'notification_service.dart';

/// Result emitted during the expanding search process.
class SearchStatus {
  final SearchState state;
  final double? currentRadiusKm;
  final int? respondersFound;
  final String? emergencyId;
  final String? responderId;
  final String? responderName;
  final String? errorMessage;

  const SearchStatus({
    required this.state,
    this.currentRadiusKm,
    this.respondersFound,
    this.emergencyId,
    this.responderId,
    this.responderName,
    this.errorMessage,
  });

  factory SearchStatus.searching({required double radius, int found = 0}) {
    return SearchStatus(
      state: SearchState.searching,
      currentRadiusKm: radius,
      respondersFound: found,
    );
  }

  factory SearchStatus.notifying({required double radius, required int count}) {
    return SearchStatus(
      state: SearchState.notifyingResponders,
      currentRadiusKm: radius,
      respondersFound: count,
    );
  }

  factory SearchStatus.waiting({required double radius}) {
    return SearchStatus(
      state: SearchState.waitingForAcceptance,
      currentRadiusKm: radius,
    );
  }

  factory SearchStatus.matched({
    required String emergencyId,
    String? responderId,
    String? responderName,
  }) {
    return SearchStatus(
      state: SearchState.matched,
      emergencyId: emergencyId,
      responderId: responderId,
      responderName: responderName,
    );
  }

  factory SearchStatus.expanding({required double newRadius}) {
    return SearchStatus(
      state: SearchState.expanding,
      currentRadiusKm: newRadius,
    );
  }

  factory SearchStatus.escalated() {
    return const SearchStatus(state: SearchState.escalated);
  }

  factory SearchStatus.error(String message) {
    return SearchStatus(
      state: SearchState.error,
      errorMessage: message,
    );
  }
}

enum SearchState {
  searching,
  notifyingResponders,
  waitingForAcceptance,
  expanding,
  matched,
  escalated,
  error,
}

/// EXPANDING SEARCH ALGORITHM
///
/// The core proximity matching engine for ERAS.
///
/// Algorithm:
///   1. Victim triggers SOS -> Emergency document created
///   2. System queries active responders within 500m
///   3. Push notifications sent to found responders
///   4. Wait 30 seconds for any responder to accept
///   5. If no acceptance -> expand radius to 1km
///   6. Repeat: 1km -> 2km -> 5km
///   7. If no responder found at 5km -> escalate
class ProximityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService;

  static const List<double> searchRadii = kSearchRadiiKm;
  static const Duration timeoutPerRadius = kRadiusTimeout;

  ProximityService({
    required NotificationService notificationService,
  }) : _notificationService = notificationService;

  /// Initiate the expanding search for an emergency.
  Stream<SearchStatus> initiateSearch({
    required String emergencyId,
    required double latitude,
    required double longitude,
  }) async* {
    final center = GeoFirePoint(GeoPoint(latitude, longitude));

    for (int i = 0; i < searchRadii.length; i++) {
      final radiusKm = searchRadii[i];
      final radiusMeters = radiusKm * 1000;

      // Step 1: Update emergency with current search radius
      await _firestore
          .collection(kEmergenciesCollection)
          .doc(emergencyId)
          .update({
        'currentSearchRadius': radiusMeters,
        'status': 'searching',
      });

      yield SearchStatus.searching(radius: radiusKm);

      // Step 2: Query active responders within radius
      final collectionRef = _firestore
          .collection(kResponderLocationsCollection);

      final nearbyDocs = await GeoCollectionReference(collectionRef)
          .fetchWithin(
            center: center,
            radiusInKm: radiusKm,
            field: 'position',
            geopointFrom: (data) =>
                (data['position'] as Map<String, dynamic>)['geopoint'] as GeoPoint,
            strictMode: true,
          );

      // Step 3: Filter out already-notified/declined
      final emergencyDoc = await _firestore
          .collection(kEmergenciesCollection)
          .doc(emergencyId)
          .get();

      final emergencyData = emergencyDoc.data() ?? {};
      final alreadyNotified =
          List<String>.from(emergencyData['notifiedResponders'] ?? []);
      final declined =
          List<String>.from(emergencyData['declinedResponders'] ?? []);

      final excludeSet = {...alreadyNotified, ...declined};

      final newResponders = nearbyDocs
          .where((doc) => !excludeSet.contains(doc.id))
          .where((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            return data?['isActive'] == true;
          })
          .toList();

      yield SearchStatus.searching(
        radius: radiusKm,
        found: newResponders.length,
      );

      // Step 4: Send push notifications
      if (newResponders.isNotEmpty) {
        yield SearchStatus.notifying(
          radius: radiusKm,
          count: newResponders.length,
        );

        final newIds = <String>[];
        for (final doc in newResponders) {
          final data = doc.data() as Map<String, dynamic>?;
          final token = data?['fcmToken'] as String?;
          if (token != null) {
            final distance = _calculateDistanceFromCenter(
              center: center,
              docData: data!,
            );

            await _notificationService.sendEmergencyAlert(
              token: token,
              emergencyId: emergencyId,
              emergencyType: emergencyData['type'] as String?,
              distance: distance,
            );

            await _notificationService.showEmergencyNotification(
              title: 'Emergency Alert',
              body:
                  '${emergencyData['type'] ?? 'Medical'} emergency - ${distance.toStringAsFixed(0)}m away',
              emergencyId: emergencyId,
              emergencyType: emergencyData['type'] as String? ?? 'other',
            );
          }
          newIds.add(doc.id);
        }

        // Track who was notified
        await _firestore
            .collection(kEmergenciesCollection)
            .doc(emergencyId)
            .update({
          'notifiedResponders': FieldValue.arrayUnion(newIds),
        });
      }

      // Step 5: Wait for acceptance
      yield SearchStatus.waiting(radius: radiusKm);

      final accepted = await _waitForAcceptance(
        emergencyId: emergencyId,
        timeout: timeoutPerRadius,
      );

      if (accepted) {
        final matchedDoc = await _firestore
            .collection(kEmergenciesCollection)
            .doc(emergencyId)
            .get();
        final matchedData = matchedDoc.data() ?? {};

        yield SearchStatus.matched(
          emergencyId: emergencyId,
          responderId: matchedData['responderId'] as String?,
          responderName: matchedData['responderName'] as String?,
        );
        return;
      }

      // Step 6: Expand to next radius
      if (i < searchRadii.length - 1) {
        yield SearchStatus.expanding(newRadius: searchRadii[i + 1]);
      }
    }

    // Step 7: No responder found - escalate
    await _firestore
        .collection(kEmergenciesCollection)
        .doc(emergencyId)
        .update({
      'status': 'escalated',
    });

    yield SearchStatus.escalated();
  }

  /// Listen for status change to 'matched'.
  Future<bool> _waitForAcceptance({
    required String emergencyId,
    required Duration timeout,
  }) async {
    final completer = Completer<bool>();
    Timer? timer;

    final subscription = _firestore
        .collection(kEmergenciesCollection)
        .doc(emergencyId)
        .snapshots()
        .listen((snapshot) {
      final status = snapshot.data()?['status'] as String?;
      if (status == 'matched') {
        timer?.cancel();
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      }
    });

    timer = Timer(timeout, () {
      subscription.cancel();
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });

    final result = await completer.future;
    subscription.cancel();
    timer?.cancel();
    return result;
  }

  /// Cancel an active search.
  Future<void> cancelSearch(String emergencyId) async {
    await _firestore
        .collection(kEmergenciesCollection)
        .doc(emergencyId)
        .update({
      'status': 'cancelled',
    });
  }

  /// Calculate distance in meters using Haversine formula.
  double _calculateDistanceFromCenter({
    required GeoFirePoint center,
    required Map<String, dynamic> docData,
  }) {
    try {
      final positionData =
          docData['position'] as Map<String, dynamic>?;
      if (positionData == null) return 0;

      final geopoint = positionData['geopoint'] as GeoPoint?;
      if (geopoint == null) return 0;

      return _haversineDistance(
        center.latitude,
        center.longitude,
        geopoint.latitude,
        geopoint.longitude,
      );
    } catch (e) {
      return 0;
    }
  }

  /// Haversine formula: returns distance in meters.
  static double _haversineDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    const earthRadius = 6371000.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degrees) => degrees * pi / 180;
}
