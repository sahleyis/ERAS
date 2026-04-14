import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import 'emergency_provider.dart';

/// Current device position (one-shot).
final currentPositionProvider = FutureProvider<Position?>((ref) async {
  final locationService = ref.read(locationServiceProvider);
  return locationService.getCurrentPosition();
});

/// Continuous position stream.
final positionStreamProvider = StreamProvider<Position>((ref) {
  final locationService = ref.read(locationServiceProvider);
  return locationService.streamPosition();
});

/// Whether location permission is granted.
final locationPermissionProvider = FutureProvider<bool>((ref) async {
  final locationService = ref.read(locationServiceProvider);
  return locationService.checkPermissions();
});
