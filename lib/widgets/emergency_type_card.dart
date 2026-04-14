import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/constants.dart';

/// Card widget for selecting emergency type during SOS flow.
class EmergencyTypeCard extends StatelessWidget {
  final EmergencyType type;
  final bool isSelected;
  final VoidCallback onTap;

  const EmergencyTypeCard({
    super.key,
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getIcon() {
    switch (type) {
      case EmergencyType.cardiac:
        return Icons.favorite;
      case EmergencyType.trauma:
        return Icons.local_hospital;
      case EmergencyType.respiratory:
        return Icons.air;
      case EmergencyType.burn:
        return Icons.whatshot;
      case EmergencyType.choking:
        return Icons.warning_rounded;
      case EmergencyType.other:
        return Icons.medical_services;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(type.colorHex);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: ErasTheme.spacingSm == 8
            ? kAnimationMedium
            : const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(ErasTheme.spacingMd),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : ErasTheme.surfaceCard,
          borderRadius: BorderRadius.circular(ErasTheme.borderRadiusLg),
          border: Border.all(
            color: isSelected ? color : ErasTheme.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(isSelected ? 0.25 : 0.1),
                borderRadius:
                    BorderRadius.circular(ErasTheme.borderRadiusMd),
              ),
              child: Icon(
                _getIcon(),
                color: isSelected ? color : color.withOpacity(0.7),
                size: 28,
              ),
            ),
            const SizedBox(height: ErasTheme.spacingSm),

            // Label
            Text(
              type.label,
              style: ErasTheme.emergencyTypeLabel.copyWith(
                color: isSelected
                    ? ErasTheme.textPrimary
                    : ErasTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 4),

            // Description
            Text(
              type.description,
              style: ErasTheme.labelSmall.copyWith(
                color: ErasTheme.textTertiary,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
