import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../config/constants.dart';

/// GPS location service for tracking victim and responder positions.
class LocationService {
  StreamSubscription<Position>? _positionSubscription;
  Position? _lastKnownPosition;

  /// Last known position (cached).
  Position? get lastKnownPosition => _lastKnownPosition;

  /// Check and request location permissions.
  Future<bool> checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get current position as a one-shot request.
  Future<Position?> getCurrentPosition() async {
    final hasPermission = await checkPermissions();
    if (!hasPermission) return null;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      _lastKnownPosition = position;
      return position;
    } catch (e) {
      // Fallback to last known
      return await Geolocator.getLastKnownPosition();
    }
  }

  /// Stream continuous position updates.
  /// Useful for responders navigating to a victim.
  Stream<Position> streamPosition({
    double distanceFilter = kLocationDistanceFilter,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter.toInt(),
      ),
    ).map((position) {
      _lastKnownPosition = position;
      return position;
    });
  }

  /// Start a background position subscription.
  void startTracking({
    required void Function(Position position) onPosition,
    double distanceFilter = kLocationDistanceFilter,
  }) {
    _positionSubscription?.cancel();
    _positionSubscription = streamPosition(
      distanceFilter: distanceFilter,
    ).listen(onPosition);
  }

  /// Stop background position tracking.
  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  /// Calculate distance between two points in meters.
  double distanceBetween({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    return Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    );
  }

  /// Reverse geocode coordinates to a human-readable address.
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) return null;

      final place = placemarks.first;
      final parts = <String>[
        if (place.street != null && place.street!.isNotEmpty)
          place.street!,
        if (place.subLocality != null && place.subLocality!.isNotEmpty)
          place.subLocality!,
        if (place.locality != null && place.locality!.isNotEmpty)
          place.locality!,
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty)
          place.administrativeArea!,
      ];

      return parts.join(', ');
    } catch (e) {
      return null;
    }
  }

  /// Open the device's location settings page.
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Open the device's app settings page (for permissions).
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  /// Dispose resources.
  void dispose() {
    stopTracking();
  }
}
