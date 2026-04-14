import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import '../config/constants.dart';
import '../models/emergency_model.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';
import 'auth_provider.dart';
import 'emergency_provider.dart';

/// Incoming alerts for the current responder.
final responderAlertsProvider =
    StreamProvider<List<EmergencyModel>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final firestore = ref.read(firestoreServiceProvider);

  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return firestore.streamResponderAlerts(user.uid);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

/// Responder dashboard state notifier.
class ResponderNotifier extends StateNotifier<ResponderState> {
  final FirestoreService _firestore;
  final LocationService _location;

  ResponderNotifier({
    required FirestoreService firestore,
    required LocationService location,
  })  : _firestore = firestore,
        _location = location,
        super(const ResponderState());

  /// Toggle active/available status.
  Future<void> toggleActive({
    required String responderId,
    required bool isActive,
  }) async {
    state = state.copyWith(isUpdating: true);

    try {
      if (isActive) {
        // Going active: get current position and start tracking
        final position = await _location.getCurrentPosition();
        if (position == null) {
          state = state.copyWith(
            isUpdating: false,
            error: 'Location required to go active',
          );
          return;
        }

        final geoPoint = GeoFirePoint(
          GeoPoint(position.latitude, position.longitude),
        );

        await _firestore.updateResponderLocation(
          responderId: responderId,
          isActive: true,
          position: geoPoint.data,
        );

        // Start continuous location tracking
        _location.startTracking(
          onPosition: (pos) async {
            final updatedPoint = GeoFirePoint(
              GeoPoint(pos.latitude, pos.longitude),
            );
            await _firestore.updateResponderLocation(
              responderId: responderId,
              isActive: true,
              position: updatedPoint.data,
            );
          },
        );
      } else {
        // Going inactive: stop tracking
        _location.stopTracking();
        await _firestore.toggleResponderActive(responderId, false);
      }

      state = state.copyWith(
        isActive: isActive,
        isUpdating: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Failed to update status: $e',
      );
    }
  }

  /// Direct state toggle for demo mode (no Firebase).
  void setActive(bool isActive) {
    state = state.copyWith(isActive: isActive);
  }

  /// Accept an incoming emergency.
  Future<bool> acceptEmergency({
    required String emergencyId,
    required String responderId,
    required String responderName,
  }) async {
    state = state.copyWith(isAccepting: true);

    try {
      final success = await _firestore.acceptEmergency(
        emergencyId: emergencyId,
        responderId: responderId,
        responderName: responderName,
      );

      state = state.copyWith(
        isAccepting: false,
        activeEmergencyId: success ? emergencyId : null,
      );

      return success;
    } catch (e) {
      state = state.copyWith(
        isAccepting: false,
        error: 'Failed to accept: $e',
      );
      return false;
    }
  }

  /// Decline an emergency alert.
  Future<void> declineEmergency({
    required String emergencyId,
    required String responderId,
  }) async {
    await _firestore.declineEmergency(
      emergencyId: emergencyId,
      responderId: responderId,
    );
  }

  /// Clear the active emergency assignment.
  void clearActiveEmergency() {
    state = state.copyWith(activeEmergencyId: null);
  }

  @override
  void dispose() {
    _location.stopTracking();
    super.dispose();
  }
}

/// Responder dashboard state.
class ResponderState {
  final bool isActive;
  final bool isUpdating;
  final bool isAccepting;
  final String? activeEmergencyId;
  final String? error;

  const ResponderState({
    this.isActive = false,
    this.isUpdating = false,
    this.isAccepting = false,
    this.activeEmergencyId,
    this.error,
  });

  ResponderState copyWith({
    bool? isActive,
    bool? isUpdating,
    bool? isAccepting,
    String? activeEmergencyId,
    String? error,
  }) {
    return ResponderState(
      isActive: isActive ?? this.isActive,
      isUpdating: isUpdating ?? this.isUpdating,
      isAccepting: isAccepting ?? this.isAccepting,
      activeEmergencyId: activeEmergencyId ?? this.activeEmergencyId,
      error: error,
    );
  }
}

final responderNotifierProvider =
    StateNotifierProvider<ResponderNotifier, ResponderState>((ref) {
  return ResponderNotifier(
    firestore: ref.read(firestoreServiceProvider),
    location: ref.read(locationServiceProvider),
  );
});
