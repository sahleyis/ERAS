import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../config/constants.dart';
import '../victim/waiting_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/demo_provider.dart';
import '../../providers/emergency_provider.dart';
import '../../widgets/emergency_type_card.dart';

/// First aid instructions for each emergency type.
const Map<EmergencyType, List<String>> _firstAidInstructions = {
  EmergencyType.cardiac: [
    'Call for help and ask someone to find an AED',
    'If unconscious, begin CPR: 30 chest compressions, 2 rescue breaths',
    'Push hard and fast in the center of the chest (2 inches deep)',
    'Rate: 100-120 compressions per minute',
    'If an AED arrives, follow voice prompts immediately',
    'Do NOT stop CPR until help arrives or person recovers',
  ],
  EmergencyType.trauma: [
    'Apply direct pressure to any bleeding wound with clean cloth',
    'Do NOT move the person if spinal injury is suspected',
    'Elevate injured limbs above heart level if possible',
    'If bone is visible, cover with moist clean cloth - do NOT push back',
    'Monitor breathing and consciousness continuously',
    'Keep the person warm and calm until help arrives',
  ],
  EmergencyType.respiratory: [
    'Help the person sit upright - do NOT lay them down',
    'Loosen any tight clothing around neck and chest',
    'If they have an inhaler, help them use it (2 puffs, wait 1 min)',
    'Encourage slow, deep breathing: in through nose, out through mouth',
    'If lips or fingertips turn blue, begin rescue breathing',
    'Stay with them and keep them calm until help arrives',
  ],
  EmergencyType.burn: [
    'Cool the burn under cool (NOT ice cold) running water for 20 minutes',
    'Remove clothing and jewelry near the burn (if not stuck)',
    'Do NOT pop blisters or apply butter/toothpaste',
    'Cover loosely with clean, non-fluffy material (cling film works)',
    'For chemical burns, flush with water for at least 20 minutes',
    'Give small sips of water if person is conscious',
  ],
  EmergencyType.choking: [
    'Encourage coughing if person can still breathe partially',
    'If they cannot speak/breathe: stand behind, give 5 back blows',
    'Back blows: heel of hand between shoulder blades',
    'If back blows fail: 5 abdominal thrusts (Heimlich maneuver)',
    'Fist above navel, grasp with other hand, thrust inward and upward',
    'Alternate 5 back blows and 5 thrusts until object is dislodged',
  ],
  EmergencyType.other: [
    'Assess the situation - ensure the area is safe for you',
    'Check if the person is conscious and breathing',
    'If unconscious but breathing - place in recovery position (on side)',
    'If not breathing - begin CPR immediately',
    'Look for medical alert jewelry or cards',
    'Keep the person warm and monitor until help arrives',
  ],
};

/// Emergency type selection + first aid instructions screen.
/// Alert has ALREADY been sent. This screen helps the victim
/// classify the emergency and provides life-saving guidance.
class EmergencyTypeScreen extends ConsumerStatefulWidget {
  const EmergencyTypeScreen({super.key});

  @override
  ConsumerState<EmergencyTypeScreen> createState() =>
      _EmergencyTypeScreenState();
}

class _EmergencyTypeScreenState
    extends ConsumerState<EmergencyTypeScreen> {
  EmergencyType? _selectedType;

  void _confirmAndSend() async {
    if (_selectedType == null) return;

    HapticFeedback.heavyImpact();

    final isDemo = ref.read(isDemoModeProvider);
    final demoUserState = ref.read(demoUserProvider);

    if (isDemo) {
      // Demo mode: set the type and go to waiting screen
      ref.read(selectedEmergencyTypeProvider.notifier).state = _selectedType;
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.waiting);
      return;
    }

    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    // Set the type for the waiting screen
    ref.read(selectedEmergencyTypeProvider.notifier).state = _selectedType;

    // Trigger the SOS with the selected type
    await ref.read(emergencyNotifierProvider.notifier).triggerSOS(
          victimId: user.uid,
          victimName: user.displayName,
          type: _selectedType!,
        );

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.waiting);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ErasTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Emergency Type'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Alert sent banner
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: ErasTheme.spacingMd,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: ErasTheme.spacingMd,
                vertical: ErasTheme.spacingSm,
              ),
              decoration: BoxDecoration(
                color: ErasTheme.sosRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ErasTheme.borderRadiusMd),
                border: Border.all(
                  color: ErasTheme.sosRed.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wifi_tethering, color: ErasTheme.sosRed, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ALERT SENT - Searching for responders',
                          style: ErasTheme.labelSmall.copyWith(
                            color: ErasTheme.sosRed,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Select emergency type below for specific first aid guidance',
                          style: ErasTheme.labelSmall.copyWith(
                            color: ErasTheme.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: ErasTheme.spacingSm),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ErasTheme.spacingMd,
              ),
              child: Text(
                'What kind of emergency?',
                style: ErasTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: ErasTheme.spacingSm),

            // Type grid + instructions in scrollable area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: ErasTheme.spacingMd,
                ),
                child: Column(
                  children: [
                    // Type grid
                    GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: ErasTheme.spacingSm,
                      crossAxisSpacing: ErasTheme.spacingSm,
                      childAspectRatio: 0.85,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: EmergencyType.values
                          .map(
                            (type) => EmergencyTypeCard(
                              type: type,
                              isSelected: _selectedType == type,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _selectedType = type);
                              },
                            ),
                          )
                          .toList(),
                    ),

                    const SizedBox(height: ErasTheme.spacingMd),

                    // First Aid Instructions (shown when type selected)
                    if (_selectedType != null) ...[
                      _FirstAidCard(type: _selectedType!),
                      const SizedBox(height: ErasTheme.spacingMd),
                    ],
                  ],
                ),
              ),
            ),

            // Confirm button
            Padding(
              padding: const EdgeInsets.all(ErasTheme.spacingMd),
              child: ElevatedButton(
                onPressed: _selectedType != null ? _confirmAndSend : null,
                style: ErasTheme.dangerButton.copyWith(
                  minimumSize: const WidgetStatePropertyAll(
                    Size(double.infinity, 64),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      _selectedType != null
                          ? 'CONFIRM ${_selectedType!.label.toUpperCase()} & CONTINUE'
                          : 'SELECT EMERGENCY TYPE',
                      style: ErasTheme.labelLarge.copyWith(
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
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

/// First aid instruction card for the selected emergency type.
class _FirstAidCard extends StatelessWidget {
  final EmergencyType type;

  const _FirstAidCard({required this.type});

  @override
  Widget build(BuildContext context) {
    final instructions = _firstAidInstructions[type] ?? [];
    final typeColor = Color(type.colorHex);

    return Container(
      padding: const EdgeInsets.all(ErasTheme.spacingMd),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(ErasTheme.borderRadiusLg),
        border: Border.all(
          color: typeColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.medical_information, color: typeColor, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${type.label} - First Aid Steps',
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
            'Follow these steps while waiting for a responder:',
            style: ErasTheme.labelSmall.copyWith(
              color: ErasTheme.textTertiary,
            ),
          ),

          const SizedBox(height: ErasTheme.spacingSm),

          // Instructions
          ...instructions.asMap().entries.map((entry) {
            final index = entry.key;
            final instruction = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step number
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: ErasTheme.labelSmall.copyWith(
                          color: typeColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      instruction,
                      style: ErasTheme.bodyMedium.copyWith(
                        color: ErasTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Emergency reminder
          const SizedBox(height: ErasTheme.spacingSm),
          Container(
            padding: const EdgeInsets.all(ErasTheme.spacingSm),
            decoration: BoxDecoration(
              color: ErasTheme.warningAmber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ErasTheme.borderRadiusSm),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber,
                  color: ErasTheme.warningAmber,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'A responder is on the way. Stay calm and follow the steps above.',
                    style: ErasTheme.labelSmall.copyWith(
                      color: ErasTheme.warningAmber,
                      fontWeight: FontWeight.w500,
                    ),
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
