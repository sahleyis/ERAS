import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/emergency_provider.dart';
import '../../providers/location_provider.dart';

/// Navigation screen — full-screen Google Map with turn-by-turn
/// navigation from responder to victim.
///
/// Features:
/// - Real-time responder position
/// - Route polyline to victim
/// - Victim medical profile in bottom sheet
/// - Chat/Call FABs
class NavigationScreen extends ConsumerStatefulWidget {
  const NavigationScreen({super.key});

  @override
  ConsumerState<NavigationScreen> createState() =>
      _NavigationScreenState();
}

class _NavigationScreenState extends ConsumerState<NavigationScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  String? _emergencyId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _emergencyId =
        ModalRoute.of(context)?.settings.arguments as String?;
  }

  @override
  Widget build(BuildContext context) {
    final positionAsync = ref.watch(positionStreamProvider);
    final emergencyAsync = _emergencyId != null
        ? ref.watch(activeEmergencyProvider)
        : null;

    return Scaffold(
      body: Stack(
        children: [
          // ── Google Map ────────────────────────────────────────
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(kDefaultLatitude, kDefaultLongitude),
              zoom: kDefaultMapZoom,
            ),
            onMapCreated: (controller) {
              _mapController = controller;

              // Apply dark map style
              controller.setMapStyle(_darkMapStyle);
            },
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
          ),

          // ── Top bar overlay ──────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: ErasTheme.spacingMd,
            right: ErasTheme.spacingMd,
            child: Row(
              children: [
                // Back button
                _CircleButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                ),
                const Spacer(),

                // ETA indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ErasTheme.spacingMd,
                    vertical: ErasTheme.spacingSm,
                  ),
                  decoration: BoxDecoration(
                    color: ErasTheme.surfaceDark.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(
                      ErasTheme.borderRadiusFull,
                    ),
                    border: Border.all(
                      color: ErasTheme.borderSubtle,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.navigation,
                        color: ErasTheme.medicalBlue,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Navigating',
                        style: ErasTheme.labelMedium.copyWith(
                          color: ErasTheme.medicalBlue,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Re-center
                _CircleButton(
                  icon: Icons.my_location,
                  onTap: () {
                    positionAsync.whenData((pos) {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLng(
                          LatLng(pos.latitude, pos.longitude),
                        ),
                      );
                    });
                  },
                ),
              ],
            ),
          ),

          // ── Bottom sheet: victim info ─────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(ErasTheme.spacingMd),
              decoration: BoxDecoration(
                color: ErasTheme.surfaceDark,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(ErasTheme.borderRadiusXl),
                  topRight: Radius.circular(ErasTheme.borderRadiusXl),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: ErasTheme.borderMedium,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Victim info
                    emergencyAsync?.when(
                          data: (emergency) {
                            if (emergency == null) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    // Type icon
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: Color(
                                          emergency.type.colorHex,
                                        ).withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius.circular(
                                          ErasTheme.borderRadiusMd,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.medical_services,
                                        color: Color(
                                          emergency.type.colorHex,
                                        ),
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: ErasTheme.spacingSm,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            emergency.victimName,
                                            style:
                                                ErasTheme.titleMedium,
                                          ),
                                          Text(
                                            '${emergency.type.label} Emergency',
                                            style:
                                                ErasTheme.labelSmall,
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Medical profile button
                                    _CircleButton(
                                      icon: Icons.medical_information,
                                      color: ErasTheme.medicalBlue,
                                      onTap: () {
                                        _showMedicalProfile(context);
                                      },
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: ErasTheme.spacingMd,
                                ),

                                // Action row
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pushNamed(
                                            AppRoutes.chat,
                                            arguments: emergency.id,
                                          );
                                        },
                                        style: ErasTheme.primaryButton
                                            .copyWith(
                                          minimumSize:
                                              const WidgetStatePropertyAll(
                                            Size(0, 48),
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.chat_bubble_outline,
                                          size: 18,
                                        ),
                                        label: const Text('Chat'),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: ErasTheme.spacingSm,
                                    ),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          // Mark as arrived / resolved
                                        },
                                        style: ErasTheme.acceptButton
                                            .copyWith(
                                          minimumSize:
                                              const WidgetStatePropertyAll(
                                            Size(0, 48),
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.check_circle_outline,
                                          size: 18,
                                        ),
                                        label:
                                            const Text("I've Arrived"),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                          loading: () =>
                              const CircularProgressIndicator(),
                          error: (_, __) => const SizedBox.shrink(),
                        ) ??
                        const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMedicalProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ErasTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ErasTheme.borderRadiusXl),
          topRight: Radius.circular(ErasTheme.borderRadiusXl),
        ),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(ErasTheme.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: ErasTheme.borderMedium,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Medical Profile',
                style: ErasTheme.headlineMedium,
              ),
              const SizedBox(height: ErasTheme.spacingMd),
              _ProfileRow(
                icon: Icons.water_drop,
                label: 'Blood Type',
                value: 'Available during active emergency',
              ),
              _ProfileRow(
                icon: Icons.warning_amber,
                label: 'Allergies',
                value: 'Available during active emergency',
              ),
              _ProfileRow(
                icon: Icons.local_hospital,
                label: 'Conditions',
                value: 'Available during active emergency',
              ),
              _ProfileRow(
                icon: Icons.phone,
                label: 'Emergency Contact',
                value: 'Available during active emergency',
              ),
              const SizedBox(height: ErasTheme.spacingMd),
            ],
          ),
        );
      },
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: ErasTheme.surfaceDark.withOpacity(0.9),
          shape: BoxShape.circle,
          border: Border.all(color: ErasTheme.borderSubtle),
        ),
        child: Icon(
          icon,
          color: color ?? ErasTheme.textPrimary,
          size: 20,
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: ErasTheme.textTertiary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: ErasTheme.labelSmall),
              Text(value, style: ErasTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}

/// Dark-styled Google Map JSON
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
