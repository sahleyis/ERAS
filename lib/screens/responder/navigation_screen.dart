import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/emergency_provider.dart';
import '../../providers/demo_provider.dart';
import '../../widgets/map_view.dart';

/// Navigation screen using OpenStreetMap (FREE, no API key).
class NavigationScreen extends ConsumerStatefulWidget {
  const NavigationScreen({super.key});

  @override
  ConsumerState<NavigationScreen> createState() =>
      _NavigationScreenState();
}

class _NavigationScreenState extends ConsumerState<NavigationScreen> {
  final MapController _mapController = MapController();
  String? _emergencyId;

  // Demo victim location (Lagos)
  final _demoVictimLocation = const LatLng(6.5244, 3.3792);
  final _demoResponderLocation = const LatLng(6.5280, 3.3750);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _emergencyId =
        ModalRoute.of(context)?.settings.arguments as String?;
  }

  @override
  Widget build(BuildContext context) {
    final isDemo = ref.watch(isDemoModeProvider);

    // Build markers
    final markers = <Marker>[
      createVictimMarker(_demoVictimLocation),
      createResponderMarker(_demoResponderLocation),
    ];

    // Build route polyline
    final polylines = <Polyline>[
      Polyline(
        points: [
          _demoResponderLocation,
          LatLng(6.5260, 3.3770),
          _demoVictimLocation,
        ],
        color: ErasTheme.medicalBlue,
        strokeWidth: 4,
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _demoVictimLocation,
              initialZoom: 15,
              backgroundColor: const Color(0xFF212121),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.eras',
              ),
              PolylineLayer(polylines: polylines),
              MarkerLayer(markers: markers),
            ],
          ),

          // Top bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: ErasTheme.spacingMd,
            right: ErasTheme.spacingMd,
            child: Row(
              children: [
                _CircleButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ErasTheme.spacingMd,
                    vertical: ErasTheme.spacingSm,
                  ),
                  decoration: BoxDecoration(
                    color: ErasTheme.surfaceDark.withOpacity(0.9),
                    borderRadius:
                        BorderRadius.circular(ErasTheme.borderRadiusFull),
                    border: Border.all(color: ErasTheme.borderSubtle),
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
                        isDemo ? 'Demo Navigation' : 'Navigating',
                        style: ErasTheme.labelMedium.copyWith(
                          color: ErasTheme.medicalBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                _CircleButton(
                  icon: Icons.my_location,
                  onTap: () {
                    _mapController.move(_demoResponderLocation, 15);
                  },
                ),
              ],
            ),
          ),

          // Demo banner
          if (isDemo)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: ErasTheme.spacingMd,
              right: ErasTheme.spacingMd,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ErasTheme.spacingMd,
                  vertical: ErasTheme.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: ErasTheme.warningAmber.withOpacity(0.15),
                  borderRadius:
                      BorderRadius.circular(ErasTheme.borderRadiusMd),
                  border: Border.all(
                    color: ErasTheme.warningAmber.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.science,
                        color: ErasTheme.warningAmber, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'DEMO - Simulated navigation',
                      style: ErasTheme.labelSmall.copyWith(
                        color: ErasTheme.warningAmber,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom sheet
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
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: ErasTheme.borderMedium,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    _buildVictimInfo(),
                    const SizedBox(height: ErasTheme.spacingMd),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVictimInfo() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: ErasTheme.sosRed.withOpacity(0.15),
            borderRadius:
                BorderRadius.circular(ErasTheme.borderRadiusMd),
          ),
          child: const Icon(
            Icons.medical_services,
            color: ErasTheme.sosRed,
            size: 22,
          ),
        ),
        const SizedBox(width: ErasTheme.spacingSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Aisha Mohammed', style: ErasTheme.titleMedium),
              Text(
                'Cardiac Emergency \u2022 320m away',
                style: ErasTheme.labelSmall,
              ),
            ],
          ),
        ),
        _CircleButton(
          icon: Icons.medical_information,
          color: ErasTheme.medicalBlue,
          onTap: () => _showMedicalProfile(context),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed(
                AppRoutes.chat,
                arguments: _emergencyId ?? 'demo',
              );
            },
            style: ErasTheme.primaryButton.copyWith(
              minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
            ),
            icon: const Icon(Icons.chat_bubble_outline, size: 18),
            label: const Text('Chat'),
          ),
        ),
        const SizedBox(width: ErasTheme.spacingSm),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Marked as arrived!'),
                  backgroundColor: ErasTheme.successGreen,
                ),
              );
            },
            style: ErasTheme.acceptButton.copyWith(
              minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
            ),
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text("I've Arrived"),
          ),
        ),
      ],
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
              Text('Medical Profile', style: ErasTheme.headlineMedium),
              const SizedBox(height: ErasTheme.spacingMd),
              _ProfileRow(
                icon: Icons.water_drop,
                label: 'Blood Type',
                value: 'O+ (Demo)',
              ),
              _ProfileRow(
                icon: Icons.warning_amber,
                label: 'Allergies',
                value: 'Penicillin (Demo)',
              ),
              _ProfileRow(
                icon: Icons.local_hospital,
                label: 'Conditions',
                value: 'Asthma (Demo)',
              ),
              _ProfileRow(
                icon: Icons.phone,
                label: 'Emergency Contact',
                value: '+234 801 234 5678 (Demo)',
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
