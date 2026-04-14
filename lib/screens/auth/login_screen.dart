import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../config/localization.dart';
import '../../providers/auth_provider.dart';
import '../../providers/demo_provider.dart';
import '../../widgets/language_picker.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await ref.read(authNotifierProvider.notifier).signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.roleSelection);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${e.toString()}'),
          backgroundColor: ErasTheme.sosRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _continueAsGuest() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(authNotifierProvider.notifier).continueAsGuest();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.roleSelection);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Guest access failed: ${e.toString()}'),
          backgroundColor: ErasTheme.sosRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _enterDemoMode() {
    ref.read(isDemoModeProvider.notifier).state = true;
    ref.read(demoUserProvider.notifier).state = demoUser;
    Navigator.of(context).pushReplacementNamed(AppRoutes.roleSelection);
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(appLanguageProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(ErasTheme.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: ErasTheme.spacing2xl),

                    // Logo
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [ErasTheme.sosRed, ErasTheme.sosRedDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius:
                                  BorderRadius.circular(ErasTheme.borderRadiusXl),
                              boxShadow: [
                                BoxShadow(
                                  color: ErasTheme.sosRed.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.local_hospital,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: ErasTheme.spacingMd),
                          Text(trStatic(lang, 'app_name'),
                              style: ErasTheme.displayLarge),
                          const SizedBox(height: ErasTheme.spacingXs),
                          Text(trStatic(lang, 'app_subtitle'),
                              style: ErasTheme.bodyMedium),
                        ],
                      ),
                    ),

                    const SizedBox(height: ErasTheme.spacing2xl),

                    // Login form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: ErasTheme.bodyLarge,
                            decoration: ErasTheme.inputDecoration(
                              label: trStatic(lang, 'email'),
                              hint: 'you@example.com',
                              prefixIcon: Icons.email_outlined,
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return trStatic(lang, 'email_required');
                              }
                              if (!val.contains('@')) {
                                return trStatic(lang, 'email_invalid');
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: ErasTheme.spacingMd),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: ErasTheme.bodyLarge,
                            decoration: ErasTheme.inputDecoration(
                              label: trStatic(lang, 'password'),
                              hint: '--------',
                              prefixIcon: Icons.lock_outline,
                              suffix: GestureDetector(
                                onTap: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                child: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: ErasTheme.textTertiary,
                                  size: 20,
                                ),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return trStatic(lang, 'password_required');
                              }
                              if (val.length < 6) {
                                return trStatic(lang, 'password_short');
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: ErasTheme.spacingLg),

                          // Sign in button
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ErasTheme.primaryButton,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(trStatic(lang, 'sign_in')),
                          ),

                          const SizedBox(height: ErasTheme.spacingMd),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(trStatic(lang, 'no_account'),
                                  style: ErasTheme.bodyMedium),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => Navigator.of(context)
                                    .pushNamed(AppRoutes.register),
                                child: Text(
                                  trStatic(lang, 'sign_up'),
                                  style: ErasTheme.labelLarge.copyWith(
                                    color: ErasTheme.medicalBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: ErasTheme.spacingXl),

                          // Divider
                          Row(
                            children: [
                              const Expanded(
                                child:
                                    Divider(color: ErasTheme.borderSubtle)),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: ErasTheme.spacingMd),
                                child: Text(trStatic(lang, 'or'),
                                    style: ErasTheme.labelSmall),
                              ),
                              const Expanded(
                                child:
                                    Divider(color: ErasTheme.borderSubtle)),
                            ],
                          ),

                          const SizedBox(height: ErasTheme.spacingMd),

                          // Demo mode button
                          OutlinedButton.icon(
                            onPressed: _enterDemoMode,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ErasTheme.successGreen,
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    ErasTheme.borderRadiusMd),
                              ),
                              side: BorderSide(
                                color:
                                    ErasTheme.successGreen.withOpacity(0.5),
                                width: 1.5,
                              ),
                            ),
                            icon: const Icon(Icons.play_circle_outline,
                                size: 22),
                            label: Text(
                              trStatic(lang, 'demo_mode'),
                              style: ErasTheme.labelLarge.copyWith(
                                color: ErasTheme.successGreen,
                              ),
                            ),
                          ),

                          const SizedBox(height: ErasTheme.spacingSm),

                          OutlinedButton.icon(
                            onPressed: _isLoading ? null : _continueAsGuest,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ErasTheme.medicalBlue,
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  ErasTheme.borderRadiusMd,
                                ),
                              ),
                              side: BorderSide(
                                color: ErasTheme.medicalBlue.withOpacity(0.45),
                                width: 1.5,
                              ),
                            ),
                            icon: const Icon(Icons.person_outline, size: 22),
                            label: Text(
                              'Continue as Guest',
                              style: ErasTheme.labelLarge.copyWith(
                                color: ErasTheme.medicalBlue,
                              ),
                            ),
                          ),

                          const SizedBox(height: ErasTheme.spacingSm),

                          Text(
                            'Guest mode gives instant access without sign-up.',
                            style: ErasTheme.labelSmall.copyWith(
                              color: ErasTheme.textTertiary,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: ErasTheme.spacingXs),

                          Text(
                            trStatic(lang, 'demo_subtitle'),
                            style: ErasTheme.labelSmall.copyWith(
                              color: ErasTheme.textTertiary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Language picker at the very bottom
            const LanguagePicker(),
          ],
        ),
      ),
    );
  }
}
