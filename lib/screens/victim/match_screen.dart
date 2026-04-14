import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/emergency_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../widgets/responder_card.dart';

/// Match screen — shown when a responder has accepted the emergency.
/// Displays responder info, ETA, and communication options.
class MatchScreen extends ConsumerWidget {
  const MatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(emergencyNotifierProvider);
    final activeEmergency = ref.watch(activeEmergencyProvider);

    return Scaffold(
      backgroundColor: ErasTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: ErasTheme.spacingLg),

            // Success header
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: ErasTheme.spacingLg),
              padding: const EdgeInsets.all(ErasTheme.spacingLg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ErasTheme.successGreen.withOpacity(0.15),
                    ErasTheme.successGreen.withOpacity(0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius:
                    BorderRadius.circular(ErasTheme.borderRadiusXl),
                border: Border.all(
                  color: ErasTheme.successGreen.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: ErasTheme.successGreen.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: ErasTheme.successGreen,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: ErasTheme.spacingMd),
                  Text(
                    'Help is on the way!',
                    style: ErasTheme.headlineLarge.copyWith(
                      color: ErasTheme.successGreen,
                    ),
                  ),
                  const SizedBox(height: ErasTheme.spacingXs),
                  Text(
                    'A verified responder has accepted your alert',
                    style: ErasTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: ErasTheme.spacingLg),

            // Responder info card
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ErasTheme.spacingMd,
              ),
              child: activeEmergency.when(
                data: (emergency) {
                  if (emergency == null) {
                    return const SizedBox.shrink();
                  }
                  // Display basic responder info from emergency data
                  return Container(
                    padding: const EdgeInsets.all(ErasTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: ErasTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(
                        ErasTheme.borderRadiusLg,
                      ),
                      border: Border.all(color: ErasTheme.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor:
                              ErasTheme.medicalBlue.withOpacity(0.2),
                          child: const Icon(
                            Icons.person,
                            color: ErasTheme.medicalBlue,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: ErasTheme.spacingSm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                emergency.responderName ?? 'Responder',
                                style: ErasTheme.titleMedium,
                              ),
                              Text(
                                'Medical Professional',
                                style: ErasTheme.labelSmall,
                              ),
                            ],
                          ),
                        ),
                        if (emergency.responderEta != null)
                          Column(
                            children: [
                              Text(
                                '${emergency.responderEta!.toInt()}',
                                style: ErasTheme.displayMedium.copyWith(
                                  color: ErasTheme.successGreen,
                                  fontSize: 28,
                                ),
                              ),
                              Text(
                                'min ETA',
                                style: ErasTheme.labelSmall.copyWith(
                                  color: ErasTheme.successGreen,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            const Spacer(),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(ErasTheme.spacingMd),
              child: Column(
                children: [
                  // Chat with responder
                  ElevatedButton.icon(
                    onPressed: () {
                      if (state.activeEmergencyId != null) {
                        Navigator.of(context).pushNamed(
                          AppRoutes.chat,
                          arguments: state.activeEmergencyId,
                        );
                      }
                    },
                    style: ErasTheme.primaryButton,
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Chat with Responder'),
                  ),

                  const SizedBox(height: ErasTheme.spacingSm),

                  // End emergency
                  OutlinedButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('End Emergency?'),
                          content: const Text(
                            'Are you sure you want to mark this emergency as resolved?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('No'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ErasTheme.dangerButton.copyWith(
                                minimumSize: const WidgetStatePropertyAll(
                                  Size(100, 44),
                                ),
                              ),
                              child: const Text('Yes, End'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await ref
                            .read(emergencyNotifierProvider.notifier)
                            .resolveEmergency();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed(
                            AppRoutes.victimHome,
                          );
                        }
                      }
                    },
                    style: ErasTheme.ghostButton,
                    child: const Text('End Emergency'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
