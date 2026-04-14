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
    final currentUser = ref.watch(currentUserProvider).value;
    final isGuestUser = !isDemo && (currentUser?.isGuest ?? false);

    final userName = isDemo
        ? (demoUserState?.displayName ?? 'Demo User')
      : (currentUser?.displayName ?? 'User');

    return Scaffold(
      body: Stack(
        children: [
          const _RoleSelectionBackdrop(),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(ErasTheme.spacingLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: ErasTheme.spacingMd),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ErasTheme.spacingMd,
                            vertical: ErasTheme.spacingSm,
                          ),
                          decoration: BoxDecoration(
                            color: ErasTheme.surfaceElevated.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(
                              ErasTheme.borderRadiusFull,
                            ),
                            border: Border.all(
                              color: ErasTheme.borderSubtle.withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.health_and_safety_outlined,
                                color: ErasTheme.medicalBlueLight,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Emergency Response Control',
                                style: ErasTheme.labelSmall.copyWith(
                                  color: ErasTheme.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: ErasTheme.spacingLg),
                        Text(
                          '${trStatic(lang, 'hello')},\n$userName',
                          style: ErasTheme.displayMedium.copyWith(height: 1.12),
                        ),
                        const SizedBox(height: ErasTheme.spacingSm),
                        Text(
                          trStatic(lang, 'how_use'),
                          style: ErasTheme.bodyLarge.copyWith(
                            color: ErasTheme.textSecondary,
                          ),
                        ),
                        if (isDemo) ...[
                          const SizedBox(height: ErasTheme.spacingMd),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: ErasTheme.spacingMd,
                              vertical: ErasTheme.spacingSm,
                            ),
                            decoration: BoxDecoration(
                              color: ErasTheme.successGreen.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(
                                ErasTheme.borderRadiusFull,
                              ),
                              border: Border.all(
                                color: ErasTheme.successGreen.withOpacity(0.35),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.science_outlined,
                                  color: ErasTheme.successGreen,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  trStatic(lang, 'demo_badge'),
                                  style: ErasTheme.labelSmall.copyWith(
                                    color: ErasTheme.successGreen,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (isGuestUser) ...[
                          const SizedBox(height: ErasTheme.spacingMd),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: ErasTheme.spacingMd,
                              vertical: ErasTheme.spacingSm,
                            ),
                            decoration: BoxDecoration(
                              color: ErasTheme.medicalBlue.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(
                                ErasTheme.borderRadiusFull,
                              ),
                              border: Border.all(
                                color: ErasTheme.medicalBlue.withOpacity(0.35),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.person_outline,
                                  color: ErasTheme.medicalBlue,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Guest Session Active',
                                  style: ErasTheme.labelSmall.copyWith(
                                    color: ErasTheme.medicalBlue,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: ErasTheme.spacingXl),
                        _ModeCard(
                          title: trStatic(lang, 'need_help'),
                          subtitle: trStatic(lang, 'need_help_sub'),
                          icon: Icons.sos,
                          color: ErasTheme.sosRed,
                          onTap: () => Navigator.of(context)
                              .pushReplacementNamed(AppRoutes.victimHome),
                        ),
                        const SizedBox(height: ErasTheme.spacingMd),
                        _ModeCard(
                          title: trStatic(lang, 'can_help'),
                          subtitle: isGuestUser
                              ? 'Create an account to respond to emergencies'
                              : trStatic(lang, 'can_help_sub'),
                          icon: Icons.medical_services,
                          color: ErasTheme.medicalBlue,
                          isEnabled: !isGuestUser,
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
                const LanguagePicker(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleSelectionBackdrop extends StatelessWidget {
  const _RoleSelectionBackdrop();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF111722),
            Color(0xFF0D0D0D),
            Color(0xFF121416),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -70,
            child: _BlurOrb(
              size: 220,
              color: ErasTheme.medicalBlue.withOpacity(0.2),
            ),
          ),
          Positioned(
            bottom: 90,
            left: -80,
            child: _BlurOrb(
              size: 260,
              color: ErasTheme.sosRed.withOpacity(0.16),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurOrb({required this.size, required this.color});

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
              blurRadius: 90,
              spreadRadius: 35,
            ),
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
  final bool isEnabled;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.isEnabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isEnabled ? color : ErasTheme.textTertiary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(ErasTheme.borderRadiusXl),
        onTap: isEnabled ? onTap : null,
        child: Ink(
          padding: const EdgeInsets.all(ErasTheme.spacingLg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cardColor.withOpacity(0.16),
                cardColor.withOpacity(0.06),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(ErasTheme.borderRadiusXl),
            border: Border.all(
              color: cardColor.withOpacity(0.4),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: cardColor.withOpacity(0.14),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(ErasTheme.borderRadiusLg),
                  border: Border.all(color: cardColor.withOpacity(0.35)),
                ),
                child: Icon(icon, color: cardColor, size: 32),
              ),
              const SizedBox(width: ErasTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: ErasTheme.headlineMedium.copyWith(color: cardColor),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: ErasTheme.bodyMedium),
                  ],
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: cardColor,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
