import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/responder_provider.dart';
import '../../models/emergency_model.dart';

/// Alert detail screen — expanded view of an incoming alert.
class AlertDetailScreen extends ConsumerWidget {
  const AlertDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emergencyId =
        ModalRoute.of(context)?.settings.arguments as String?;
    final responderState = ref.watch(responderNotifierProvider);

    if (emergencyId == null || emergencyId.isEmpty) {
      return Scaffold(
        backgroundColor: ErasTheme.backgroundDark,
        appBar: AppBar(title: const Text('Alert Details')),
        body: Center(
          child: Text(
            'No alert ID was provided.',
            style: ErasTheme.bodyLarge,
          ),
        ),
      );
    }

    final stream = ref.read(firestoreServiceProvider).streamEmergency(emergencyId);

    return Scaffold(
      backgroundColor: ErasTheme.backgroundDark,
      appBar: AppBar(title: const Text('Alert Details')),
      body: Stack(
        children: [
          const _AlertDetailBackdrop(),
          StreamBuilder<EmergencyModel?>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final emergency = snapshot.data;
              if (emergency == null) {
                return Center(
                  child: Text(
                    'Alert not found or no longer available.',
                    style: ErasTheme.bodyLarge,
                  ),
                );
              }

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(ErasTheme.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(ErasTheme.spacingLg),
                        decoration: BoxDecoration(
                          color: ErasTheme.surfaceElevated.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(ErasTheme.borderRadiusXl),
                          border: Border.all(
                            color: ErasTheme.sosRed.withOpacity(0.25),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: ErasTheme.sosRed.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(
                                      ErasTheme.borderRadiusMd,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.emergency,
                                    color: ErasTheme.sosRed,
                                  ),
                                ),
                                const SizedBox(width: ErasTheme.spacingSm),
                                Expanded(
                                  child: Text(
                                    '${emergency.type.label} Emergency',
                                    style: ErasTheme.titleLarge,
                                  ),
                                ),
                                _StatusPill(status: emergency.status),
                              ],
                            ),
                            const SizedBox(height: ErasTheme.spacingMd),
                            _DetailRow(
                              icon: Icons.person_outline,
                              label: 'Victim',
                              value: emergency.victimName,
                            ),
                            _DetailRow(
                              icon: Icons.place_outlined,
                              label: 'Location',
                              value: emergency.address ?? 'Location unavailable',
                            ),
                            _DetailRow(
                              icon: Icons.radar,
                              label: 'Search Radius',
                              value: emergency.searchRadiusLabel,
                            ),
                            _DetailRow(
                              icon: Icons.schedule,
                              label: 'Elapsed',
                              value: _elapsedLabel(emergency.elapsed),
                            ),
                            if ((emergency.description ?? '').isNotEmpty)
                              _DetailRow(
                                icon: Icons.notes_outlined,
                                label: 'Description',
                                value: emergency.description!,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: ErasTheme.spacingMd),
                      Container(
                        padding: const EdgeInsets.all(ErasTheme.spacingMd),
                        decoration: BoxDecoration(
                          color: ErasTheme.surfaceCard.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(ErasTheme.borderRadiusLg),
                          border: Border.all(color: ErasTheme.borderSubtle),
                        ),
                        child: Text(
                          'Accept to start navigation and connect with the victim in chat immediately.',
                          style: ErasTheme.bodyMedium.copyWith(
                            color: ErasTheme.textSecondary,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: ErasTheme.ghostButton,
                              onPressed: responderState.isAccepting
                                  ? null
                                  : () async {
                                      final user = ref.read(currentUserProvider).value;
                                      if (user == null) return;
                                      await ref
                                          .read(responderNotifierProvider.notifier)
                                          .declineEmergency(
                                            emergencyId: emergency.id,
                                            responderId: user.uid,
                                          );
                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                      }
                                    },
                              child: const Text('Decline'),
                            ),
                          ),
                          const SizedBox(width: ErasTheme.spacingSm),
                          Expanded(
                            child: ElevatedButton(
                              style: ErasTheme.acceptButton,
                              onPressed: responderState.isAccepting
                                  ? null
                                  : () async {
                                      final user = ref.read(currentUserProvider).value;
                                      if (user == null) return;

                                      final success = await ref
                                          .read(responderNotifierProvider.notifier)
                                          .acceptEmergency(
                                            emergencyId: emergency.id,
                                            responderId: user.uid,
                                            responderName: user.displayName,
                                          );

                                      if (success && context.mounted) {
                                        Navigator.of(context).pushReplacementNamed(
                                          AppRoutes.navigation,
                                          arguments: emergency.id,
                                        );
                                      }
                                    },
                              child: responderState.isAccepting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Accept Alert'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _elapsedLabel(Duration elapsed) {
    if (elapsed.inMinutes >= 1) {
      return '${elapsed.inMinutes} min ${elapsed.inSeconds % 60}s';
    }
    return '${elapsed.inSeconds}s';
  }
}

class _AlertDetailBackdrop extends StatelessWidget {
  const _AlertDetailBackdrop();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF1A1316),
            Color(0xFF0D0D0D),
            Color(0xFF121920),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final EmergencyStatus status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final isSearching = status == EmergencyStatus.searching;
    final color = isSearching ? ErasTheme.warningAmber : ErasTheme.successGreen;
    final text = isSearching ? 'Searching' : status.name;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(ErasTheme.borderRadiusFull),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        text,
        style: ErasTheme.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: ErasTheme.spacingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: ErasTheme.textTertiary),
          const SizedBox(width: 8),
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: ErasTheme.labelSmall,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: ErasTheme.bodyMedium.copyWith(color: ErasTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
