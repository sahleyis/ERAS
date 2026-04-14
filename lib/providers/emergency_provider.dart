import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/constants.dart';
import '../models/emergency_model.dart';
import '../services/firestore_service.dart';
import '../services/proximity_service.dart';
import '../services/notification_service.dart';
import '../services/location_service.dart';
import 'auth_provider.dart';

/// Provides the ProximityService.
final proximityServiceProvider = Provider<ProximityService>((ref) {
  return ProximityService(
    notificationService: NotificationService(),
  );
});

/// Provides the LocationService.
final locationServiceProvider = Provider<LocationService>((ref) {
  final service = LocationService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Active emergency for the current victim (if any).
final activeEmergencyProvider =
    StreamProvider<EmergencyModel?>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final firestore = ref.read(firestoreServiceProvider);

  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return firestore
          .streamVictimEmergencies(user.uid)
          .map((list) => list.isNotEmpty ? list.first : null);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

/// Emergency state notifier for creating and managing emergencies.
class EmergencyNotifier extends StateNotifier<EmergencyState> {
  final FirestoreService _firestore;
  final ProximityService _proximity;
  final LocationService _location;
  StreamSubscription? _searchSubscription;

  EmergencyNotifier({
    required FirestoreService firestore,
    required ProximityService proximity,
    required LocationService location,
  })  : _firestore = firestore,
        _proximity = proximity,
        _location = location,
        super(const EmergencyState());

  /// Trigger an SOS emergency.
  Future<void> triggerSOS({
    required String victimId,
    required String victimName,
    required EmergencyType type,
    String? description,
  }) async {
    state = state.copyWith(isCreating: true, error: null);

    try {
      // Get current location
      final position = await _location.getCurrentPosition();
      if (position == null) {
        state = state.copyWith(
          isCreating: false,
          error: 'Unable to get location. Please enable GPS.',
        );
        return;
      }

      // Reverse geocode for address
      final address = await _location.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Create emergency document
      final emergency = EmergencyModel(
        id: '',
        victimId: victimId,
        victimName: victimName,
        type: type,
        description: description,
        status: EmergencyStatus.searching,
        location: GeoPoint(position.latitude, position.longitude),
        address: address,
      );

      final emergencyId = await _firestore.createEmergency(emergency);

      state = state.copyWith(
        isCreating: false,
        activeEmergencyId: emergencyId,
        searchStatus: SearchStatus.searching(radius: kSearchRadiiKm[0]),
      );

      // Start the expanding search
      _startSearch(
        emergencyId: emergencyId,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: 'Failed to create emergency: $e',
      );
    }
  }

  /// Start the expanding search algorithm.
  void _startSearch({
    required String emergencyId,
    required double latitude,
    required double longitude,
  }) {
    _searchSubscription?.cancel();

    _searchSubscription = _proximity
        .initiateSearch(
      emergencyId: emergencyId,
      latitude: latitude,
      longitude: longitude,
    )
        .listen(
      (status) {
        state = state.copyWith(searchStatus: status);
      },
      onError: (e) {
        state = state.copyWith(
          searchStatus: SearchStatus.error(e.toString()),
        );
      },
    );
  }

  /// Cancel the current emergency.
  Future<void> cancelEmergency() async {
    _searchSubscription?.cancel();

    if (state.activeEmergencyId != null) {
      await _firestore.cancelEmergency(state.activeEmergencyId!);
    }

    state = const EmergencyState();
  }

  /// Resolve the current emergency.
  Future<void> resolveEmergency() async {
    if (state.activeEmergencyId != null) {
      await _firestore.resolveEmergency(state.activeEmergencyId!);
    }

    state = const EmergencyState();
  }

  @override
  void dispose() {
    _searchSubscription?.cancel();
    super.dispose();
  }
}

/// State for the emergency flow.
class EmergencyState {
  final bool isCreating;
  final String? activeEmergencyId;
  final SearchStatus? searchStatus;
  final String? error;

  const EmergencyState({
    this.isCreating = false,
    this.activeEmergencyId,
    this.searchStatus,
    this.error,
  });

  EmergencyState copyWith({
    bool? isCreating,
    String? activeEmergencyId,
    SearchStatus? searchStatus,
    String? error,
  }) {
    return EmergencyState(
      isCreating: isCreating ?? this.isCreating,
      activeEmergencyId:
          activeEmergencyId ?? this.activeEmergencyId,
      searchStatus: searchStatus ?? this.searchStatus,
      error: error,
    );
  }

  bool get isSearching =>
      searchStatus?.state == SearchState.searching ||
      searchStatus?.state == SearchState.notifyingResponders ||
      searchStatus?.state == SearchState.waitingForAcceptance ||
      searchStatus?.state == SearchState.expanding;

  bool get isMatched => searchStatus?.state == SearchState.matched;
  bool get isEscalated => searchStatus?.state == SearchState.escalated;
  bool get hasError => error != null;
}

final emergencyNotifierProvider =
    StateNotifierProvider<EmergencyNotifier, EmergencyState>((ref) {
  return EmergencyNotifier(
    firestore: ref.read(firestoreServiceProvider),
    proximity: ref.read(proximityServiceProvider),
    location: ref.read(locationServiceProvider),
  );
});
