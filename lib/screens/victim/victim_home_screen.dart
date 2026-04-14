import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/demo_provider.dart';
import '../../providers/emergency_provider.dart';
import '../../widgets/sos_button.dart';

/// Victim Home Screen - SOS triggers alert IMMEDIATELY,
/// then navigates to type selection + first aid instructions.
class VictimHomeScreen extends ConsumerWidget {
  const VictimHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDemo = ref.watch(isDemoModeProvider);
    final emergencyState = ref.watch(emergencyNotifierProvider);

    return Scaffold(
      backgroundColor: ErasTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ErasTheme.spacingMd,
                vertical: ErasTheme.spacingSm,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.roleSelection),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Back',
                  ),
                  const Spacer(),
                  if (isDemo)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ErasTheme.warningAmber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(ErasTheme.borderRadiusFull),
                        border: Border.all(
                          color: ErasTheme.warningAmber.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'DEMO',
                        style: ErasTheme.labelSmall.copyWith(
                          color: ErasTheme.warningAmber,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context)
                        .pushNamed(AppRoutes.medicalProfile),
                    icon: const Icon(Icons.person_outline),
                    tooltip: 'Medical Profile',
                  ),
                ],
              ),
            ),

            // Status indicator
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ErasTheme.spacingLg,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ErasTheme.spacingMd,
                  vertical: ErasTheme.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: ErasTheme.successGreen.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(ErasTheme.borderRadiusFull),
                  border: Border.all(
                    color: ErasTheme.successGreen.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                        color: ErasTheme.successGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'GPS Active \u2022 Ready',
                      style: ErasTheme.labelSmall.copyWith(
                        color: ErasTheme.successGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Main instruction
            Text(
              'Press SOS for help',
              style: ErasTheme.headlineMedium.copyWith(
                color: ErasTheme.textSecondary,
              ),
            ),
            const SizedBox(height: ErasTheme.spacingSm),
            Text(
              'Alert is sent IMMEDIATELY\nthen you select emergency type',
              style: ErasTheme.bodyMedium.copyWith(
                color: ErasTheme.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: ErasTheme.spacingXl),

            // SOS BUTTON - sends alert FIRST, then navigates to type selection
            SOSButton(
              isLoading: emergencyState.isCreating,
              onPressed: () {
                HapticFeedback.heavyImpact();

                if (isDemo) {
                  // Demo mode: skip Firestore, go straight to type selection
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Demo: SOS Alert sent! Searching for responders...'),
                      backgroundColor: ErasTheme.sosRed,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }

                // Navigate to emergency type + first aid instructions
                Navigator.of(context).pushNamed(AppRoutes.emergencyType);
              },
            ),

            const Spacer(),

            // Non-emergency messaging button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ErasTheme.spacingLg,
              ),
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context)
                    .pushNamed(AppRoutes.findResponder),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ErasTheme.medicalBlue,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ErasTheme.borderRadiusMd,
                    ),
                  ),
                  side: BorderSide(
                    color: ErasTheme.medicalBlue.withOpacity(0.4),
                  ),
                ),
                icon: const Icon(Icons.chat_bubble_outline, size: 20),
                label: Text(
                  'Ask a Responder (Non-Emergency)',
                  style: ErasTheme.labelLarge.copyWith(
                    color: ErasTheme.medicalBlue,
                  ),
                ),
              ),
            ),

            const SizedBox(height: ErasTheme.spacingSm),

            // Emergency numbers
            Padding(
              padding: const EdgeInsets.all(ErasTheme.spacingMd),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _QuickDial(label: 'Call 112', icon: Icons.phone, onTap: () {}),
                  _QuickDial(label: 'Call NEMA', icon: Icons.local_hospital, onTap: () {}),
                  _QuickDial(label: 'Ambulance', icon: Icons.directions_car, onTap: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickDial extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickDial({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: ErasTheme.surfaceCard,
              borderRadius: BorderRadius.circular(ErasTheme.borderRadiusMd),
              border: Border.all(color: ErasTheme.borderSubtle),
            ),
            child: Icon(icon, color: ErasTheme.textSecondary, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label, style: ErasTheme.labelSmall),
        ],
      ),
    );
  }
}
