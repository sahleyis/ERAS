import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

/// Medical Profile editor screen.
/// Allows users to store/update blood type, allergies, chronic conditions,
/// and emergency contact info.
class MedicalProfileScreen extends ConsumerStatefulWidget {
  const MedicalProfileScreen({super.key});

  @override
  ConsumerState<MedicalProfileScreen> createState() =>
      _MedicalProfileScreenState();
}

class _MedicalProfileScreenState
    extends ConsumerState<MedicalProfileScreen> {
  String _bloodType = 'Unknown';
  final List<String> _allergies = [];
  final List<String> _conditions = [];
  final _allergyController = TextEditingController();
  final _conditionController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactRelationController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Load existing profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider).value;
      if (user != null) {
        setState(() {
          _bloodType = user.medicalProfile.bloodType;
          _allergies.addAll(user.medicalProfile.allergies);
          _conditions.addAll(user.medicalProfile.chronicConditions);
          _contactNameController.text =
              user.medicalProfile.emergencyContactName;
          _contactPhoneController.text =
              user.medicalProfile.emergencyContactPhone;
          _contactRelationController.text =
              user.medicalProfile.emergencyContactRelation;
        });
      }
    });
  }

  @override
  void dispose() {
    _allergyController.dispose();
    _conditionController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _contactRelationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null) return;

      final profile = MedicalProfile(
        bloodType: _bloodType,
        allergies: _allergies,
        chronicConditions: _conditions,
        emergencyContactName: _contactNameController.text.trim(),
        emergencyContactPhone: _contactPhoneController.text.trim(),
        emergencyContactRelation:
            _contactRelationController.text.trim(),
      );

      await ref
          .read(firestoreServiceProvider)
          .updateMedicalProfile(user.uid, profile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medical profile saved'),
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

  void _addAllergy() {
    final text = _allergyController.text.trim();
    if (text.isNotEmpty && !_allergies.contains(text)) {
      setState(() {
        _allergies.add(text);
        _allergyController.clear();
      });
    }
  }

  void _addCondition() {
    final text = _conditionController.text.trim();
    if (text.isNotEmpty && !_conditions.contains(text)) {
      setState(() {
        _conditions.add(text);
        _conditionController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Profile'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ErasTheme.medicalBlue,
                    ),
                  )
                : Text(
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
            // Info banner
            Container(
              padding: const EdgeInsets.all(ErasTheme.spacingMd),
              decoration: BoxDecoration(
                color: ErasTheme.medicalBlue.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(ErasTheme.borderRadiusMd),
                border: Border.all(
                  color: ErasTheme.medicalBlue.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lock_outline,
                    color: ErasTheme.medicalBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This information is encrypted and only visible to your assigned responder during an active emergency.',
                      style: ErasTheme.labelSmall.copyWith(
                        color: ErasTheme.medicalBlueLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: ErasTheme.spacingLg),

            // ── Blood Type ─────────────────────────────────────
            Text('Blood Type', style: ErasTheme.titleMedium),
            const SizedBox(height: ErasTheme.spacingSm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kBloodTypes.map((bt) {
                final isSelected = _bloodType == bt;
                return ChoiceChip(
                  label: Text(bt),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _bloodType = bt),
                  selectedColor: ErasTheme.sosRed.withOpacity(0.2),
                  labelStyle: ErasTheme.labelMedium.copyWith(
                    color: isSelected
                        ? ErasTheme.sosRed
                        : ErasTheme.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? ErasTheme.sosRed
                        : ErasTheme.borderSubtle,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: ErasTheme.spacingLg),

            // ── Allergies ──────────────────────────────────────
            Text('Allergies', style: ErasTheme.titleMedium),
            const SizedBox(height: ErasTheme.spacingSm),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _allergyController,
                    style: ErasTheme.bodyLarge,
                    decoration: ErasTheme.inputDecoration(
                      label: 'Add allergy',
                      hint: 'e.g. Penicillin',
                      prefixIcon: Icons.warning_amber,
                    ),
                    onSubmitted: (_) => _addAllergy(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addAllergy,
                  icon: const Icon(Icons.add_circle),
                  color: ErasTheme.medicalBlue,
                  iconSize: 32,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allergies
                  .map(
                    (a) => Chip(
                      label: Text(a),
                      onDeleted: () =>
                          setState(() => _allergies.remove(a)),
                      deleteIconColor: ErasTheme.sosRed,
                      backgroundColor: ErasTheme.warningAmber
                          .withOpacity(0.1),
                      side: BorderSide(
                        color: ErasTheme.warningAmber.withOpacity(0.3),
                      ),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: ErasTheme.spacingLg),

            // ── Chronic Conditions ─────────────────────────────
            Text('Chronic Conditions', style: ErasTheme.titleMedium),
            const SizedBox(height: ErasTheme.spacingSm),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _conditionController,
                    style: ErasTheme.bodyLarge,
                    decoration: ErasTheme.inputDecoration(
                      label: 'Add condition',
                      hint: 'e.g. Diabetes',
                      prefixIcon: Icons.local_hospital,
                    ),
                    onSubmitted: (_) => _addCondition(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addCondition,
                  icon: const Icon(Icons.add_circle),
                  color: ErasTheme.medicalBlue,
                  iconSize: 32,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _conditions
                  .map(
                    (c) => Chip(
                      label: Text(c),
                      onDeleted: () =>
                          setState(() => _conditions.remove(c)),
                      deleteIconColor: ErasTheme.sosRed,
                      backgroundColor: ErasTheme.medicalBlue
                          .withOpacity(0.1),
                      side: BorderSide(
                        color: ErasTheme.medicalBlue.withOpacity(0.3),
                      ),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: ErasTheme.spacingLg),

            // ── Emergency Contact ──────────────────────────────
            Text('Emergency Contact', style: ErasTheme.titleMedium),
            const SizedBox(height: ErasTheme.spacingSm),
            TextField(
              controller: _contactNameController,
              style: ErasTheme.bodyLarge,
              decoration: ErasTheme.inputDecoration(
                label: 'Contact Name',
                prefixIcon: Icons.person_outline,
              ),
            ),
            const SizedBox(height: ErasTheme.spacingSm),
            TextField(
              controller: _contactPhoneController,
              keyboardType: TextInputType.phone,
              style: ErasTheme.bodyLarge,
              decoration: ErasTheme.inputDecoration(
                label: 'Phone Number',
                hint: '+234...',
                prefixIcon: Icons.phone_outlined,
              ),
            ),
            const SizedBox(height: ErasTheme.spacingSm),
            TextField(
              controller: _contactRelationController,
              style: ErasTheme.bodyLarge,
              decoration: ErasTheme.inputDecoration(
                label: 'Relationship',
                hint: 'e.g. Spouse, Parent',
                prefixIcon: Icons.people_outline,
              ),
            ),

            const SizedBox(height: ErasTheme.spacingXl),

            // Save button
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ErasTheme.primaryButton,
              child: _isSaving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Save Medical Profile'),
            ),

            const SizedBox(height: ErasTheme.spacingLg),
          ],
        ),
      ),
    );
  }
}
