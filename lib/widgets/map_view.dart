import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../config/theme.dart';
import '../config/constants.dart';

/// Reusable Google Map view widget with dark styling.
class ErasMapView extends StatelessWidget {
  final LatLng? center;
  final Set<Marker>? markers;
  final Set<Polyline>? polylines;
  final double zoom;
  final void Function(GoogleMapController)? onMapCreated;
  final bool showMyLocation;

  const ErasMapView({
    super.key,
    this.center,
    this.markers,
    this.polylines,
    this.zoom = kDefaultMapZoom,
    this.onMapCreated,
    this.showMyLocation = true,
  });

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: center ??
            const LatLng(kDefaultLatitude, kDefaultLongitude),
        zoom: zoom,
      ),
      onMapCreated: (controller) {
        controller.setMapStyle(_darkMapStyle);
        onMapCreated?.call(controller);
      },
      markers: markers ?? {},
      polylines: polylines ?? {},
      myLocationEnabled: showMyLocation,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: true,
      buildingsEnabled: false,
      indoorViewEnabled: false,
    );
  }
}

const String _darkMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#212121"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},
  {"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#757575"}]},
  {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#181818"}]},
  {"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#2c2c2c"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},
  {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#373737"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},
  {"featureType":"road.highway.controlled_access","elementType":"geometry","stylers":[{"color":"#4e4e4e"}]},
  {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#2f3948"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#17263c"}]}
]
''';
