import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../models/emergency_model.dart';
import 'verification_badge.dart';

/// Alert card displayed on the Responder Dashboard
/// for incoming emergency alerts.
class AlertCard extends StatelessWidget {
  final EmergencyModel emergency;
  final double? distanceMeters;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final bool isAccepting;

  const AlertCard({
    super.key,
    required this.emergency,
    this.distanceMeters,
    required this.onAccept,
    required this.onDecline,
    this.isAccepting = false,
  });

  IconData _getTypeIcon() {
    switch (emergency.type) {
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

  String _formatDistance() {
    if (distanceMeters == null) return '';
    if (distanceMeters! < 1000) {
      return '${distanceMeters!.toInt()}m away';
    }
    return '${(distanceMeters! / 1000).toStringAsFixed(1)}km away';
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = Color(emergency.type.colorHex);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: ErasTheme.spacingMd,
        vertical: ErasTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: ErasTheme.surfaceCard,
        borderRadius:
            BorderRadius.circular(ErasTheme.borderRadiusLg),
        border: Border.all(
          color: typeColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: typeColor.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(ErasTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Type + Distance + Time
            Row(
              children: [
                // Type icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.15),
                    borderRadius:
                        BorderRadius.circular(ErasTheme.borderRadiusMd),
                  ),
                  child: Icon(
                    _getTypeIcon(),
                    color: typeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: ErasTheme.spacingSm),

                // Type label + distance
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${emergency.type.label} Emergency',
                        style: ErasTheme.titleMedium.copyWith(
                          color: typeColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (distanceMeters != null)
                        Text(
                          _formatDistance(),
                          style: ErasTheme.bodyMedium,
                        ),
                    ],
                  ),
                ),

                // Elapsed time
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: ErasTheme.sosRed.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(
                      ErasTheme.borderRadiusFull,
                    ),
                  ),
                  child: Text(
                    '${emergency.elapsed.inSeconds}s ago',
                    style: ErasTheme.labelSmall.copyWith(
                      color: ErasTheme.sosRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: ErasTheme.spacingSm),

            // Victim info
            Row(
              children: [
                const Icon(
                  Icons.person,
                  color: ErasTheme.textTertiary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  emergency.victimName.isNotEmpty
                      ? emergency.victimName
                      : 'Anonymous',
                  style: ErasTheme.bodyMedium,
                ),
                if (emergency.address != null) ...[
                  const SizedBox(width: ErasTheme.spacingMd),
                  const Icon(
                    Icons.location_on,
                    color: ErasTheme.textTertiary,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      emergency.address!,
                      style: ErasTheme.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: ErasTheme.spacingMd),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isAccepting ? null : onDecline,
                    style: ErasTheme.declineButton,
                    icon: const Icon(Icons.close, size: 20),
                    label: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: ErasTheme.spacingSm),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: isAccepting ? null : onAccept,
                    style: ErasTheme.acceptButton,
                    icon: isAccepting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.check, size: 20),
                    label: Text(isAccepting ? 'Accepting...' : 'Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
