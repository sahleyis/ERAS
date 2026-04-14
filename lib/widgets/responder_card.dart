import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../models/user_model.dart';
import 'verification_badge.dart';

/// Card widget displaying a responder's info during an active emergency.
class ResponderCard extends StatelessWidget {
  final UserModel responder;
  final double? distanceMeters;
  final double? etaMinutes;

  const ResponderCard({
    super.key,
    required this.responder,
    this.distanceMeters,
    this.etaMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final profile = responder.responderProfile;

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
          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: ErasTheme.medicalBlue.withOpacity(0.2),
            backgroundImage: responder.photoUrl != null
                ? NetworkImage(responder.photoUrl!)
                : null,
            child: responder.photoUrl == null
                ? Text(
                    responder.initials,
                    style: ErasTheme.titleMedium.copyWith(
                      color: ErasTheme.medicalBlue,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: ErasTheme.spacingSm),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + badge
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        responder.displayName,
                        style: ErasTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (profile != null) ...[
                      const SizedBox(width: 6),
                      VerificationBadge(
                        status: profile.verificationStatus,
                        size: 18,
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 2),

                // Specialization
                if (profile != null)
                  Row(
                    children: [
                      Icon(
                        Icons.medical_services_outlined,
                        size: 14,
                        color: ErasTheme.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        profile.specialization.label,
                        style: ErasTheme.labelSmall,
                      ),
                      if (profile.rating > 0) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.star,
                          size: 14,
                          color: ErasTheme.warningAmber,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          profile.rating.toStringAsFixed(1),
                          style: ErasTheme.labelSmall.copyWith(
                            color: ErasTheme.warningAmber,
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),

          // ETA
          if (etaMinutes != null)
            Column(
              children: [
                Text(
                  '${etaMinutes!.toInt()}',
                  style: ErasTheme.displayMedium.copyWith(
                    color: ErasTheme.successGreen,
                    fontSize: 28,
                  ),
                ),
                Text(
                  'min',
                  style: ErasTheme.labelSmall.copyWith(
                    color: ErasTheme.successGreen,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
