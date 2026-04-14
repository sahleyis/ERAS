import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../config/theme.dart';
import '../config/constants.dart';

/// Reusable OpenStreetMap view widget (FREE - no API key needed).
class ErasMapView extends StatelessWidget {
  final LatLng? center;
  final List<Marker>? markers;
  final List<Polyline>? polylines;
  final double zoom;
  final MapController? mapController;
  final bool showMyLocation;

  const ErasMapView({
    super.key,
    this.center,
    this.markers,
    this.polylines,
    this.zoom = kDefaultMapZoom,
    this.mapController,
    this.showMyLocation = true,
  });

  @override
  Widget build(BuildContext context) {
    final mapCenter =
        center ?? LatLng(kDefaultLatitude, kDefaultLongitude);

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: mapCenter,
        initialZoom: zoom,
        maxZoom: 18,
        minZoom: 3,
        backgroundColor: const Color(0xFF212121),
      ),
      children: [
        // Dark tile layer (free, no key)
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.example.eras',
          retinaMode: true,
        ),

        // Polylines (routes)
        if (polylines != null && polylines!.isNotEmpty)
          PolylineLayer(polylines: polylines!),

        // Markers
        if (markers != null && markers!.isNotEmpty)
          MarkerLayer(markers: markers!),
      ],
    );
  }
}

/// Helper to create a standard victim marker.
Marker createVictimMarker(LatLng position) {
  return Marker(
    point: position,
    width: 50,
    height: 50,
    child: Container(
      decoration: BoxDecoration(
        color: ErasTheme.sosRed,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: ErasTheme.sosRed.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.sos,
        color: Colors.white,
        size: 24,
      ),
    ),
  );
}

/// Helper to create a responder marker.
Marker createResponderMarker(LatLng position, {String? label}) {
  return Marker(
    point: position,
    width: 50,
    height: 50,
    child: Container(
      decoration: BoxDecoration(
        color: ErasTheme.medicalBlue,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: ErasTheme.medicalBlue.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.medical_services,
        color: Colors.white,
        size: 24,
      ),
    ),
  );
}
