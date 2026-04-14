import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  UserRole _selectedRole = UserRole.victim;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authNotifierProvider.notifier).register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            displayName: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            role: _selectedRole,
          );

      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed(AppRoutes.roleSelection);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: ${e.toString()}'),
          backgroundColor: ErasTheme.sosRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(ErasTheme.spacingLg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Join ERAS',
                  style: ErasTheme.headlineLarge,
                ),
                const SizedBox(height: ErasTheme.spacingXs),
                Text(
                  'Create your account to get help or help others.',
                  style: ErasTheme.bodyMedium,
                ),

                const SizedBox(height: ErasTheme.spacingLg),

                // Full Name
                TextFormField(
                  controller: _nameController,
                  style: ErasTheme.bodyLarge,
                  textCapitalization: TextCapitalization.words,
                  decoration: ErasTheme.inputDecoration(
                    label: 'Full Name',
                    prefixIcon: Icons.person_outline,
                  ),
                  validator: (val) => (val == null || val.trim().isEmpty)
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: ErasTheme.spacingMd),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: ErasTheme.bodyLarge,
                  decoration: ErasTheme.inputDecoration(
                    label: 'Email',
                    prefixIcon: Icons.email_outlined,
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Email is required';
                    if (!val.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: ErasTheme.spacingMd),

                // Phone
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: ErasTheme.bodyLarge,
                  decoration: ErasTheme.inputDecoration(
                    label: 'Phone Number',
                    hint: '+234...',
                    prefixIcon: Icons.phone_outlined,
                  ),
                  validator: (val) => (val == null || val.trim().isEmpty)
                      ? 'Phone number is required'
                      : null,
                ),
                const SizedBox(height: ErasTheme.spacingMd),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: ErasTheme.bodyLarge,
                  decoration: ErasTheme.inputDecoration(
                    label: 'Password',
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
                      return 'Password is required';
                    }
                    if (val.length < 6) {
                      return 'Password must be 6+ characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: ErasTheme.spacingLg),

                // Role selection
                Text('I want to:', style: ErasTheme.titleMedium),
                const SizedBox(height: ErasTheme.spacingSm),

                _RoleOption(
                  title: 'Get Help',
                  subtitle: 'I need emergency assistance',
                  icon: Icons.sos,
                  color: ErasTheme.sosRed,
                  isSelected: _selectedRole == UserRole.victim,
                  onTap: () =>
                      setState(() => _selectedRole = UserRole.victim),
                ),
                const SizedBox(height: ErasTheme.spacingSm),

                _RoleOption(
                  title: 'Help Others',
                  subtitle: 'I am a medical professional / first aider',
                  icon: Icons.medical_services,
                  color: ErasTheme.medicalBlue,
                  isSelected: _selectedRole == UserRole.responder,
                  onTap: () =>
                      setState(() => _selectedRole = UserRole.responder),
                ),
                const SizedBox(height: ErasTheme.spacingSm),

                _RoleOption(
                  title: 'Both',
                  subtitle: 'I want both capabilities',
                  icon: Icons.swap_horiz,
                  color: ErasTheme.successGreen,
                  isSelected: _selectedRole == UserRole.both,
                  onTap: () =>
                      setState(() => _selectedRole = UserRole.both),
                ),

                const SizedBox(height: ErasTheme.spacingLg),

                // Register button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
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
                      : const Text('Create Account'),
                ),

                const SizedBox(height: ErasTheme.spacingMd),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: ErasTheme.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Sign In',
                        style: ErasTheme.labelLarge.copyWith(
                          color: ErasTheme.medicalBlue,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: ErasTheme.spacingLg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: kAnimationMedium,
        padding: const EdgeInsets.all(ErasTheme.spacingMd),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : ErasTheme.surfaceCard,
          borderRadius:
              BorderRadius.circular(ErasTheme.borderRadiusMd),
          border: Border.all(
            color: isSelected ? color : ErasTheme.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(isSelected ? 0.2 : 0.1),
                borderRadius:
                    BorderRadius.circular(ErasTheme.borderRadiusSm),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: ErasTheme.spacingSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: ErasTheme.labelLarge),
                  Text(subtitle, style: ErasTheme.labelSmall),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }
}
