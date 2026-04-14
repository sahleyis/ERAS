import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../config/localization.dart';
import '../providers/auth_provider.dart';
import '../providers/demo_provider.dart';
import '../widgets/language_picker.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDemo = ref.watch(isDemoModeProvider);
    final demoUserState = ref.watch(demoUserProvider);
    final lang = ref.watch(appLanguageProvider);

    final userName = isDemo
        ? (demoUserState?.displayName ?? 'Demo User')
        : ref.watch(currentUserProvider).whenOrNull(
              data: (user) => user?.displayName,
            ) ?? 'User';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(ErasTheme.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: ErasTheme.spacing2xl),

                    Text(
                      '${trStatic(lang, 'hello')}, $userName',
                      style: ErasTheme.headlineLarge,
                    ),
                    const SizedBox(height: ErasTheme.spacingXs),
                    Text(
                      trStatic(lang, 'how_use'),
                      style: ErasTheme.bodyMedium,
                    ),

                    if (isDemo) ...[
                      const SizedBox(height: ErasTheme.spacingSm),
                      Container(
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
                            const Icon(Icons.science_outlined,
                                color: ErasTheme.successGreen, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              trStatic(lang, 'demo_badge'),
                              style: ErasTheme.labelSmall.copyWith(
                                color: ErasTheme.successGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const Spacer(),

                    // Victim mode
                    _ModeCard(
                      title: trStatic(lang, 'need_help'),
                      subtitle: trStatic(lang, 'need_help_sub'),
                      icon: Icons.sos,
                      color: ErasTheme.sosRed,
                      onTap: () => Navigator.of(context)
                          .pushReplacementNamed(AppRoutes.victimHome),
                    ),

                    const SizedBox(height: ErasTheme.spacingMd),

                    // Responder mode
                    _ModeCard(
                      title: trStatic(lang, 'can_help'),
                      subtitle: trStatic(lang, 'can_help_sub'),
                      icon: Icons.medical_services,
                      color: ErasTheme.medicalBlue,
                      onTap: () => Navigator.of(context)
                          .pushReplacementNamed(AppRoutes.responderDashboard),
                    ),

                    const Spacer(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: () => Navigator.of(context)
                              .pushNamed(AppRoutes.medicalProfile),
                          icon: const Icon(Icons.person_outline, size: 18),
                          label: Text(trStatic(lang, 'medical_profile')),
                          style: TextButton.styleFrom(
                            foregroundColor: ErasTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: ErasTheme.spacingMd),
                        TextButton.icon(
                          onPressed: () {
                            ref.read(isDemoModeProvider.notifier).state = false;
                            ref.read(demoUserProvider.notifier).state = null;
                            if (!isDemo) {
                              ref.read(authNotifierProvider.notifier).signOut();
                            }
                            Navigator.of(context)
                                .pushReplacementNamed(AppRoutes.login);
                          },
                          icon: const Icon(Icons.logout, size: 18),
                          label: Text(trStatic(lang, 'sign_out')),
                          style: TextButton.styleFrom(
                            foregroundColor: ErasTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: ErasTheme.spacingSm),
                  ],
                ),
              ),
            ),

            // Language picker
            const LanguagePicker(),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(ErasTheme.spacingLg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(ErasTheme.borderRadiusXl),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius:
                    BorderRadius.circular(ErasTheme.borderRadiusLg),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: ErasTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ErasTheme.headlineMedium.copyWith(color: color),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: ErasTheme.bodyMedium),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
