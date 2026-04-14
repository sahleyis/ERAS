import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../config/constants.dart';
import '../../models/emergency_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/demo_provider.dart';
import '../../providers/responder_provider.dart';
import '../../widgets/alert_card.dart';
import '../../widgets/verification_badge.dart';

/// Demo alerts shown when Firebase has no data or in demo mode.
List<EmergencyModel> _demoAlerts() {
  final now = DateTime.now();
  return [
    EmergencyModel(
      id: 'demo-alert-1',
      victimId: 'demo-victim-1',
      victimName: 'Aisha Mohammed',
      type: EmergencyType.cardiac,
      status: EmergencyStatus.searching,
      location: const GeoPoint(6.5244, 3.3792),
      address: 'Lekki Phase 1, Lagos',
      createdAt: now.subtract(const Duration(seconds: 15)),
      currentSearchRadius: 500,
    ),
    EmergencyModel(
      id: 'demo-alert-2',
      victimId: 'demo-victim-2',
      victimName: 'Chukwu Obi',
      type: EmergencyType.trauma,
      status: EmergencyStatus.searching,
      location: const GeoPoint(6.4281, 3.4219),
      address: 'Victoria Island, Lagos',
      createdAt: now.subtract(const Duration(seconds: 45)),
      currentSearchRadius: 1000,
    ),
    EmergencyModel(
      id: 'demo-alert-3',
      victimId: 'demo-victim-3',
      victimName: 'Fatima Bello',
      type: EmergencyType.respiratory,
      status: EmergencyStatus.searching,
      location: const GeoPoint(6.5955, 3.3489),
      address: 'Ikeja GRA, Lagos',
      createdAt: now.subtract(const Duration(seconds: 90)),
      currentSearchRadius: 2000,
    ),
  ];
}

class ResponderDashboard extends ConsumerWidget {
  const ResponderDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDemo = ref.watch(isDemoModeProvider);
    final demoUserState = ref.watch(demoUserProvider);
    final responderState = ref.watch(responderNotifierProvider);

    return Scaffold(
      backgroundColor: ErasTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(ErasTheme.spacingMd),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.roleSelection),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Spacer(),
                  Text('Responder', style: ErasTheme.titleLarge),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context)
                        .pushNamed(AppRoutes.responderProfile),
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
            ),

            // Active Status Toggle
            _buildProfileCard(
              context, ref, isDemo, demoUserState, responderState,
            ),

            const SizedBox(height: ErasTheme.spacingMd),

            // Section Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ErasTheme.spacingLg,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications_active_outlined,
                    color: ErasTheme.sosRed,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text('Incoming Alerts', style: ErasTheme.titleMedium),
                ],
              ),
            ),

            const SizedBox(height: ErasTheme.spacingSm),

            // Alert List
            Expanded(
              child: _buildAlertList(context, ref, isDemo, responderState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    WidgetRef ref,
    bool isDemo,
    dynamic demoUserState,
    ResponderState responderState,
  ) {
    if (isDemo && demoUserState != null) {
      final user = demoUserState;
      final profile = user.responderProfile;
      return _ProfileCardContent(
        displayName: user.displayName,
        initials: user.initials,
        specialization: profile?.specialization.label ?? 'First Aid',
        verificationStatus: profile?.verificationStatus ?? VerificationStatus.pending,
        totalResponses: profile?.totalResponses ?? 0,
        rating: profile?.rating ?? 0,
        isActive: responderState.isActive,
        isUpdating: responderState.isUpdating,
        onToggle: (val) {
          ref.read(responderNotifierProvider.notifier).setActive(val);
        },
      );
    }

    final userAsync = ref.watch(currentUserProvider);
    return userAsync.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        final profile = user.responderProfile;

        return _ProfileCardContent(
          displayName: user.displayName,
          initials: user.initials,
          specialization: profile?.specialization.label ?? 'First Aid',
          verificationStatus: profile?.verificationStatus ?? VerificationStatus.pending,
          totalResponses: profile?.totalResponses ?? 0,
          rating: profile?.rating ?? 0,
          isActive: responderState.isActive,
          isUpdating: responderState.isUpdating,
          onToggle: (val) {
            ref.read(responderNotifierProvider.notifier).toggleActive(
              responderId: user.uid,
              isActive: val,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildAlertList(
    BuildContext context,
    WidgetRef ref,
    bool isDemo,
    ResponderState responderState,
  ) {
    if (!responderState.isActive) {
      return _buildIdle(
        icon: Icons.power_settings_new,
        title: 'You are offline',
        subtitle: 'Toggle Active to start receiving emergency alerts',
      );
    }

    // In demo mode, show fake alerts
    if (isDemo) {
      final alerts = _demoAlerts();
      return Column(
        children: [
          // Demo banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: ErasTheme.spacingMd),
            padding: const EdgeInsets.symmetric(
              horizontal: ErasTheme.spacingMd,
              vertical: ErasTheme.spacingSm,
            ),
            decoration: BoxDecoration(
              color: ErasTheme.warningAmber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ErasTheme.borderRadiusMd),
              border: Border.all(
                color: ErasTheme.warningAmber.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.science, color: ErasTheme.warningAmber, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'DEMO MODE - These are simulated alerts for preview',
                    style: ErasTheme.labelSmall.copyWith(
                      color: ErasTheme.warningAmber,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ErasTheme.spacingSm),
          Expanded(
            child: ListView.builder(
              itemCount: alerts.length,
              padding: const EdgeInsets.only(bottom: ErasTheme.spacingLg),
              itemBuilder: (context, index) {
                final alert = alerts[index];
                final distances = [320.0, 850.0, 1800.0];
                return AlertCard(
                  emergency: alert,
                  distanceMeters: distances[index],
                  isAccepting: responderState.isAccepting,
                  onAccept: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Demo: Alert accepted - navigating to victim'),
                        backgroundColor: ErasTheme.successGreen,
                      ),
                    );
                    Navigator.of(context).pushNamed(
                      AppRoutes.navigation,
                      arguments: alert.id,
                    );
                  },
                  onDecline: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Demo: Alert declined'),
                        backgroundColor: ErasTheme.surfaceElevated,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      );
    }

    // Real Firestore alerts
    final alertsAsync = ref.watch(responderAlertsProvider);
    return alertsAsync.when(
      data: (alerts) {
        if (alerts.isEmpty) {
          return _buildIdle(
            icon: Icons.shield_outlined,
            title: 'No active alerts',
            subtitle: "You're online - waiting for nearby emergencies",
          );
        }

        return ListView.builder(
          itemCount: alerts.length,
          padding: const EdgeInsets.only(bottom: ErasTheme.spacingLg),
          itemBuilder: (context, index) {
            final alert = alerts[index];
            final user = ref.read(currentUserProvider).value;

            return AlertCard(
              emergency: alert,
              isAccepting: responderState.isAccepting,
              onAccept: () async {
                if (user == null) return;
                final success = await ref
                    .read(responderNotifierProvider.notifier)
                    .acceptEmergency(
                      emergencyId: alert.id,
                      responderId: user.uid,
                      responderName: user.displayName,
                    );

                if (success && context.mounted) {
                  Navigator.of(context).pushNamed(
                    AppRoutes.navigation,
                    arguments: alert.id,
                  );
                }
              },
              onDecline: () {
                if (user == null) return;
                ref.read(responderNotifierProvider.notifier).declineEmergency(
                  emergencyId: alert.id,
                  responderId: user.uid,
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Error loading alerts: $e', style: ErasTheme.bodyMedium),
      ),
    );
  }

  Widget _buildIdle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: ErasTheme.textTertiary, size: 64),
          const SizedBox(height: ErasTheme.spacingMd),
          Text(
            title,
            style: ErasTheme.titleLarge.copyWith(color: ErasTheme.textSecondary),
          ),
          const SizedBox(height: ErasTheme.spacingXs),
          Text(
            subtitle,
            style: ErasTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProfileCardContent extends StatelessWidget {
  final String displayName;
  final String initials;
  final String specialization;
  final VerificationStatus verificationStatus;
  final int totalResponses;
  final double rating;
  final bool isActive;
  final bool isUpdating;
  final void Function(bool) onToggle;

  const _ProfileCardContent({
    required this.displayName,
    required this.initials,
    required this.specialization,
    required this.verificationStatus,
    required this.totalResponses,
    required this.rating,
    required this.isActive,
    required this.isUpdating,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: ErasTheme.spacingMd),
      padding: const EdgeInsets.all(ErasTheme.spacingMd),
      decoration: BoxDecoration(
        color: isActive
            ? ErasTheme.successGreen.withOpacity(0.1)
            : ErasTheme.surfaceCard,
        borderRadius: BorderRadius.circular(ErasTheme.borderRadiusLg),
        border: Border.all(
          color: isActive
              ? ErasTheme.successGreen.withOpacity(0.3)
              : ErasTheme.borderSubtle,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: ErasTheme.medicalBlue.withOpacity(0.2),
                child: Text(
                  initials,
                  style: ErasTheme.titleMedium.copyWith(
                    color: ErasTheme.medicalBlue,
                  ),
                ),
              ),
              const SizedBox(width: ErasTheme.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            style: ErasTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        VerificationBadge(
                          status: verificationStatus,
                          size: 18,
                        ),
                      ],
                    ),
                    Text(specialization, style: ErasTheme.labelSmall),
                  ],
                ),
              ),
              Column(
                children: [
                  Switch(
                    value: isActive,
                    onChanged: isUpdating ? null : onToggle,
                  ),
                  Text(
                    isActive ? 'ACTIVE' : 'OFFLINE',
                    style: ErasTheme.statusText.copyWith(
                      color: isActive
                          ? ErasTheme.successGreen
                          : ErasTheme.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: ErasTheme.spacingSm),
          const Divider(),
          const SizedBox(height: ErasTheme.spacingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(label: 'Responses', value: totalResponses.toString()),
              _StatItem(
                label: 'Rating',
                value: rating > 0 ? rating.toStringAsFixed(1) : '-',
              ),
              _StatItem(
                label: 'Status',
                value: verificationStatus.name.toUpperCase(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: ErasTheme.titleMedium.copyWith(color: ErasTheme.textPrimary)),
        Text(label, style: ErasTheme.labelSmall),
      ],
    );
  }
}
