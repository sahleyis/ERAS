import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../config/constants.dart';
import '../../providers/demo_provider.dart';
import '../../providers/emergency_provider.dart';
import '../../services/proximity_service.dart';
import '../../widgets/pulse_animation.dart';

/// First aid instructions by type.
const Map<EmergencyType, List<String>> _firstAidSteps = {
  EmergencyType.cardiac: [
    'Begin CPR: 30 chest compressions, 2 rescue breaths',
    'Push hard and fast in the center of the chest (2 inches deep)',
    'Rate: 100-120 compressions per minute',
    'If an AED is available, follow its voice prompts',
    'Do NOT stop CPR until help arrives',
  ],
  EmergencyType.trauma: [
    'Apply direct pressure to any bleeding wound',
    'Do NOT move the person if spinal injury is suspected',
    'Elevate injured limbs above heart level',
    'Keep the person warm and calm',
  ],
  EmergencyType.respiratory: [
    'Help the person sit upright',
    'Loosen tight clothing around neck and chest',
    'If they have an inhaler, help them use it (2 puffs)',
    'Encourage slow, deep breathing: nose in, mouth out',
  ],
  EmergencyType.burn: [
    'Cool the burn under cool running water for 20 minutes',
    'Do NOT pop blisters or apply butter',
    'Cover loosely with clean material',
    'Give small sips of water if conscious',
  ],
  EmergencyType.choking: [
    'If they cannot speak: give 5 back blows',
    'If back blows fail: 5 abdominal thrusts (Heimlich)',
    'Fist above navel, thrust inward and upward',
    'Alternate until object is dislodged',
  ],
  EmergencyType.other: [
    'Ensure the area is safe',
    'Check if the person is conscious and breathing',
    'If unconscious but breathing, place on their side',
    'If not breathing, begin CPR immediately',
  ],
};

/// The selected emergency type passed from the type screen.
final selectedEmergencyTypeProvider =
    StateProvider<EmergencyType?>((ref) => null);

/// Waiting screen shown after SOS + type selection.
/// Shows "Help is on the way" with first aid instructions.
class WaitingScreen extends ConsumerStatefulWidget {
  const WaitingScreen({super.key});

  @override
  ConsumerState<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends ConsumerState<WaitingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  int _demoSeconds = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Demo mode: simulate search progress
    final isDemo = ref.read(isDemoModeProvider);
    if (isDemo) {
      _startDemoSimulation();
    }
  }

  void _startDemoSimulation() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      _tickDemo();
    });
  }

  void _tickDemo() {
    if (!mounted) return;
    setState(() => _demoSeconds++);
    if (_demoSeconds < 120) {
      Future.delayed(const Duration(seconds: 1), _tickDemo);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _getDemoRadius() {
    if (_demoSeconds < 10) return '0.5';
    if (_demoSeconds < 20) return '1.0';
    if (_demoSeconds < 30) return '2.0';
    return '5.0';
  }

  String _getDemoStatus() {
    if (_demoSeconds < 5) return 'Getting your location...';
    if (_demoSeconds < 10) return 'Searching within 500m...';
    if (_demoSeconds < 15) return 'Found 2 responders nearby';
    if (_demoSeconds < 20) return 'Notifying responders...';
    return 'Waiting for a responder to accept...';
  }

  @override
  Widget build(BuildContext context) {
    final isDemo = ref.watch(isDemoModeProvider);
    final emergencyType = ref.watch(selectedEmergencyTypeProvider);
    final state = ref.watch(emergencyNotifierProvider);

    // Navigate when matched (real mode)
    if (!isDemo && state.isMatched) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.match);
      });
    }

    final steps = _firstAidSteps[emergencyType] ??
        _firstAidSteps[EmergencyType.other]!;
    final typeColor = emergencyType != null
        ? Color(emergencyType.colorHex)
        : ErasTheme.medicalBlue;

    return Scaffold(
      backgroundColor: ErasTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.all(ErasTheme.spacingMd),
              child: Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      if (!isDemo) {
                        ref
                            .read(emergencyNotifierProvider.notifier)
                            .cancelEmergency();
                      }
                      Navigator.of(context).pushReplacementNamed(
                        AppRoutes.victimHome,
                      );
                    },
                    child: Text(
                      'Cancel',
                      style: ErasTheme.labelLarge.copyWith(
                        color: ErasTheme.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // "Help is on the way" header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ErasTheme.spacingLg,
              ),
              child: Column(
                children: [
                  // Animated pulse icon
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = 1.0 + (_pulseController.value * 0.15);
                      final opacity = 1.0 - (_pulseController.value * 0.3);
                      return Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: opacity,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: ErasTheme.successGreen.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: ErasTheme.successGreen.withOpacity(0.4),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.local_hospital,
                              color: ErasTheme.successGreen,
                              size: 36,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: ErasTheme.spacingMd),

                  Text(
                    'Help is on the way!',
                    style: ErasTheme.headlineLarge.copyWith(
                      color: ErasTheme.successGreen,
                    ),
                  ),

                  const SizedBox(height: ErasTheme.spacingSm),

                  // Search status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ErasTheme.spacingMd,
                      vertical: ErasTheme.spacingSm,
                    ),
                    decoration: BoxDecoration(
                      color: ErasTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(
                        ErasTheme.borderRadiusFull,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: ErasTheme.medicalBlue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isDemo
                              ? _getDemoStatus()
                              : 'Searching for nearby responders...',
                          style: ErasTheme.labelSmall.copyWith(
                            color: ErasTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (isDemo) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Search radius: ${_getDemoRadius()}km',
                      style: ErasTheme.labelSmall.copyWith(
                        color: ErasTheme.medicalBlue,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: ErasTheme.spacingLg),

            // First Aid Instructions
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: ErasTheme.spacingMd,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Instructions header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(ErasTheme.spacingMd),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(
                          ErasTheme.borderRadiusLg,
                        ),
                        border: Border.all(
                          color: typeColor.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.medical_information,
                                color: typeColor,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  emergencyType != null
                                      ? '${emergencyType.label} - First Aid'
                                      : 'First Aid Instructions',
                                  style: ErasTheme.titleMedium.copyWith(
                                    color: typeColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),
                          Text(
                            'Follow these steps while help is arriving:',
                            style: ErasTheme.labelSmall.copyWith(
                              color: ErasTheme.textTertiary,
                            ),
                          ),

                          const SizedBox(height: ErasTheme.spacingSm),

                          ...steps.asMap().entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: typeColor.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${entry.key + 1}',
                                        style:
                                            ErasTheme.labelSmall.copyWith(
                                          color: typeColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      entry.value,
                                      style: ErasTheme.bodyLarge.copyWith(
                                        color: ErasTheme.textPrimary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: ErasTheme.spacingMd),

                    // Reassurance card
                    Container(
                      padding: const EdgeInsets.all(ErasTheme.spacingMd),
                      decoration: BoxDecoration(
                        color: ErasTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(
                          ErasTheme.borderRadiusLg,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.shield,
                                color: ErasTheme.medicalBlue,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Your location has been shared',
                                style: ErasTheme.bodyMedium.copyWith(
                                  color: ErasTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Stay calm. A trained responder is being dispatched to your location. Keep your phone accessible.',
                            style: ErasTheme.bodyMedium.copyWith(
                              color: ErasTheme.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: ErasTheme.spacingMd),

                    // Emergency numbers
                    Container(
                      padding: const EdgeInsets.all(ErasTheme.spacingMd),
                      decoration: BoxDecoration(
                        color: ErasTheme.warningAmber.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(
                          ErasTheme.borderRadiusLg,
                        ),
                        border: Border.all(
                          color: ErasTheme.warningAmber.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            color: ErasTheme.warningAmber,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'You can also call 112 (Emergency) or 199 (Ambulance)',
                              style: ErasTheme.bodyMedium.copyWith(
                                color: ErasTheme.warningAmber,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: ErasTheme.spacingLg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
