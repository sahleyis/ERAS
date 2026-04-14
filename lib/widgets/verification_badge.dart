import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/constants.dart';

/// Verification badge widget displaying responder credential status.
///
/// - Verified: Blue shield with checkmark
/// - Pending: Gray clock icon
/// - Rejected: Red X icon
class VerificationBadge extends StatelessWidget {
  final VerificationStatus status;
  final double size;
  final bool showLabel;

  const VerificationBadge({
    super.key,
    required this.status,
    this.size = 20,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (status) {
      VerificationStatus.verified => (
          Icons.verified,
          ErasTheme.verifiedColor,
          'Verified',
        ),
      VerificationStatus.pending => (
          Icons.schedule,
          ErasTheme.pendingColor,
          'Pending',
        ),
      VerificationStatus.rejected => (
          Icons.cancel,
          ErasTheme.rejectedColor,
          'Rejected',
        ),
    };

    final badge = Tooltip(
      message: '$label medical professional',
      child: Icon(
        icon,
        color: color,
        size: size,
      ),
    );

    if (!showLabel) return badge;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        badge,
        const SizedBox(width: 4),
        Text(
          label,
          style: ErasTheme.labelSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
