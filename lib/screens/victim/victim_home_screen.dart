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
      body: Stack(
        children: [
          const _VictimBackdrop(),
          SafeArea(
            child: Column(
              children: [
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
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: ErasTheme.warningAmber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              ErasTheme.borderRadiusFull,
                            ),
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ErasTheme.spacingLg,
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: ErasTheme.spacingMd,
                          vertical: ErasTheme.spacingSm,
                        ),
                        decoration: BoxDecoration(
                          color: ErasTheme.successGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            ErasTheme.borderRadiusFull,
                          ),
                          border: Border.all(
                            color: ErasTheme.successGreen.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: ErasTheme.successGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'GPS Active • Ready',
                              style: ErasTheme.labelSmall.copyWith(
                                color: ErasTheme.successGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: ErasTheme.spacingMd),
                      Text(
                        'Emergency Assist',
                        style: ErasTheme.displayMedium.copyWith(
                          fontSize: 30,
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: ErasTheme.spacingSm),
                      Text(
                        'Press SOS now. Your alert is sent instantly, then you pick emergency type.',
                        style: ErasTheme.bodyLarge.copyWith(
                          color: ErasTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: ErasTheme.spacingMd,
                  ),
                  padding: const EdgeInsets.all(ErasTheme.spacingLg),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(ErasTheme.borderRadiusXl),
                    border: Border.all(
                      color: ErasTheme.sosRed.withOpacity(0.22),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        ErasTheme.sosRed.withOpacity(0.08),
                        ErasTheme.surfaceCard.withOpacity(0.8),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      SOSButton(
                        isLoading: emergencyState.isCreating,
                        onPressed: () {
                          HapticFeedback.heavyImpact();

                          if (isDemo) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Demo: SOS Alert sent! Searching for responders...'),
                                backgroundColor: ErasTheme.sosRed,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }

                          Navigator.of(context).pushNamed(AppRoutes.emergencyType);
                        },
                      ),
                      const SizedBox(height: ErasTheme.spacingMd),
                      Text(
                        'Tap once to trigger emergency flow',
                        style: ErasTheme.labelMedium.copyWith(
                          color: ErasTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ErasTheme.spacingLg,
                  ),
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context)
                        .pushNamed(AppRoutes.findResponder),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ErasTheme.medicalBlue,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ErasTheme.borderRadiusMd,
                        ),
                      ),
                      side: BorderSide(
                        color: ErasTheme.medicalBlue.withOpacity(0.45),
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
                Padding(
                  padding: const EdgeInsets.all(ErasTheme.spacingMd),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      _QuickDial(label: 'Call 112', icon: Icons.phone),
                      _QuickDial(label: 'Call NEMA', icon: Icons.local_hospital),
                      _QuickDial(label: 'Ambulance', icon: Icons.directions_car),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VictimBackdrop extends StatelessWidget {
  const _VictimBackdrop();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF151A20),
            Color(0xFF0D0D0D),
            Color(0xFF110F12),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            left: -80,
            child: _GlowBlob(
              size: 260,
              color: ErasTheme.medicalBlue.withOpacity(0.16),
            ),
          ),
          Positioned(
            bottom: 130,
            right: -80,
            child: _GlowBlob(
              size: 280,
              color: ErasTheme.sosRed.withOpacity(0.13),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 95,
              spreadRadius: 32,
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

  const _QuickDial({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: ErasTheme.surfaceCard.withOpacity(0.85),
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
