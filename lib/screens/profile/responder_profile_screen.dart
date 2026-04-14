import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../widgets/verification_badge.dart';

/// Responder Profile screen — for medical credentialing.
class ResponderProfileScreen extends ConsumerStatefulWidget {
  const ResponderProfileScreen({super.key});

  @override
  ConsumerState<ResponderProfileScreen> createState() =>
      _ResponderProfileScreenState();
}

class _ResponderProfileScreenState
    extends ConsumerState<ResponderProfileScreen> {
  Specialization _specialization = Specialization.firstAid;
  final _licenseController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider).value;
      if (user?.responderProfile != null) {
        setState(() {
          _specialization =
              user!.responderProfile!.specialization;
          _licenseController.text =
              user.responderProfile!.licenseNumber;
        });
      }
    });
  }

  @override
  void dispose() {
    _licenseController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null) return;

      final existing = user.responderProfile;
      final profile = (existing ?? ResponderProfile()).copyWith(
        specialization: _specialization,
        licenseNumber: _licenseController.text.trim(),
      );

      await ref
          .read(firestoreServiceProvider)
          .updateResponderProfile(user.uid, profile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Responder profile saved'),
            backgroundColor: ErasTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: ErasTheme.sosRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Responder Profile'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: Text(
              'Save',
              style: ErasTheme.labelLarge.copyWith(
                color: ErasTheme.medicalBlue,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ErasTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Verification status
            userAsync.when(
              data: (user) {
                final profile = user?.responderProfile;
                if (profile == null) return const SizedBox.shrink();

                return Container(
                  padding: const EdgeInsets.all(ErasTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: ErasTheme.surfaceCard,
                    borderRadius:
                        BorderRadius.circular(ErasTheme.borderRadiusLg),
                    border: Border.all(color: ErasTheme.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      VerificationBadge(
                        status: profile.verificationStatus,
                        size: 32,
                      ),
                      const SizedBox(width: ErasTheme.spacingSm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Verification Status',
                              style: ErasTheme.titleMedium,
                            ),
                            Text(
                              profile.verificationStatus ==
                                      VerificationStatus.verified
                                  ? 'Your credentials have been verified'
                                  : profile.verificationStatus ==
                                          VerificationStatus.pending
                                      ? 'Awaiting admin review'
                                      : 'Verification rejected - please update',
                              style: ErasTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: ErasTheme.spacingLg),

            // Specialization
            Text('Medical Specialization', style: ErasTheme.titleMedium),
            const SizedBox(height: ErasTheme.spacingSm),
            ...Specialization.values.map((spec) {
              final isSelected = _specialization == spec;
              return Padding(
                padding:
                    const EdgeInsets.only(bottom: ErasTheme.spacingSm),
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _specialization = spec),
                  child: Container(
                    padding: const EdgeInsets.all(ErasTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? ErasTheme.medicalBlue.withOpacity(0.1)
                          : ErasTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(
                        ErasTheme.borderRadiusMd,
                      ),
                      border: Border.all(
                        color: isSelected
                            ? ErasTheme.medicalBlue
                            : ErasTheme.borderSubtle,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${spec.label} (${spec.abbreviation})',
                          style: ErasTheme.bodyLarge.copyWith(
                            color: isSelected
                                ? ErasTheme.medicalBlue
                                : ErasTheme.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: ErasTheme.medicalBlue,
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: ErasTheme.spacingLg),

            // License number
            Text('License / Certificate Number',
                style: ErasTheme.titleMedium),
            const SizedBox(height: ErasTheme.spacingSm),
            TextField(
              controller: _licenseController,
              style: ErasTheme.bodyLarge,
              decoration: ErasTheme.inputDecoration(
                label: 'License Number',
                hint: 'e.g. MDCN/2024/12345',
                prefixIcon: Icons.badge_outlined,
              ),
            ),

            const SizedBox(height: ErasTheme.spacingXl),

            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ErasTheme.primaryButton,
              child: const Text('Save Profile'),
            ),

            const SizedBox(height: ErasTheme.spacingLg),
          ],
        ),
      ),
    );
  }
}

// Extension to add copyWith to ResponderProfile
extension ResponderProfileCopy on ResponderProfile {
  ResponderProfile copyWith({
    Specialization? specialization,
    String? licenseNumber,
  }) {
    return ResponderProfile(
      specialization: specialization ?? this.specialization,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      verificationStatus: verificationStatus,
      verifiedAt: verifiedAt,
      verifiedBy: verifiedBy,
      isActive: isActive,
      rating: rating,
      totalResponses: totalResponses,
    );
  }
}
