import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../config/constants.dart';
import '../../config/localization.dart';
import '../../providers/demo_provider.dart';

/// Demo nearby responders for preview.
class NearbyResponder {
  final String id;
  final String name;
  final Specialization specialization;
  final double distanceMeters;
  final double rating;
  final bool isOnline;

  const NearbyResponder({
    required this.id,
    required this.name,
    required this.specialization,
    required this.distanceMeters,
    required this.rating,
    required this.isOnline,
  });
}

final _demoResponders = [
  const NearbyResponder(
    id: 'resp-1',
    name: 'Dr. Amina Yusuf',
    specialization: Specialization.doctor,
    distanceMeters: 320,
    rating: 4.9,
    isOnline: true,
  ),
  const NearbyResponder(
    id: 'resp-2',
    name: 'Nurse Chidi Okafor',
    specialization: Specialization.nurse,
    distanceMeters: 780,
    rating: 4.7,
    isOnline: true,
  ),
  const NearbyResponder(
    id: 'resp-3',
    name: 'Binta Abdullahi',
    specialization: Specialization.firstAid,
    distanceMeters: 1200,
    rating: 4.5,
    isOnline: true,
  ),
  const NearbyResponder(
    id: 'resp-4',
    name: 'EMT Tunde Adeyemi',
    specialization: Specialization.paramedic,
    distanceMeters: 1800,
    rating: 4.8,
    isOnline: false,
  ),
];

/// Screen to find nearby responders for non-emergency messaging.
class FindResponderScreen extends ConsumerStatefulWidget {
  const FindResponderScreen({super.key});

  @override
  ConsumerState<FindResponderScreen> createState() =>
      _FindResponderScreenState();
}

class _FindResponderScreenState extends ConsumerState<FindResponderScreen>
    with SingleTickerProviderStateMixin {
  bool _isSearching = true;
  List<NearbyResponder> _found = [];

  @override
  void initState() {
    super.initState();
    _simulateSearch();
  }

  void _simulateSearch() async {
    // Simulate a proximity search
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _isSearching = false;
      _found = _demoResponders.where((r) => r.isOnline).toList();
    });
  }

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.toInt()}m away';
    return '${(meters / 1000).toStringAsFixed(1)}km away';
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(appLanguageProvider);
    final isDemo = ref.watch(isDemoModeProvider);

    return Scaffold(
      backgroundColor: ErasTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Find Nearby Responder'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Info banner
            Container(
              margin: const EdgeInsets.all(ErasTheme.spacingMd),
              padding: const EdgeInsets.all(ErasTheme.spacingMd),
              decoration: BoxDecoration(
                color: ErasTheme.medicalBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(ErasTheme.borderRadiusLg),
                border: Border.all(
                  color: ErasTheme.medicalBlue.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    color: ErasTheme.medicalBlue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Non-Emergency Messaging',
                          style: ErasTheme.titleMedium.copyWith(
                            color: ErasTheme.medicalBlue,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ask a medical question, get first aid advice, or consult a nearby professional.',
                          style: ErasTheme.bodyMedium.copyWith(
                            color: ErasTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (isDemo)
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: ErasTheme.spacingMd,
                ),
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
                    const Icon(Icons.science, color: ErasTheme.warningAmber, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'DEMO - Simulated nearby responders',
                      style: ErasTheme.labelSmall.copyWith(
                        color: ErasTheme.warningAmber,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: ErasTheme.spacingSm),

            // Search status or results
            if (_isSearching)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          color: ErasTheme.medicalBlue,
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: ErasTheme.spacingMd),
                      Text(
                        'Searching for nearby responders...',
                        style: ErasTheme.titleMedium.copyWith(
                          color: ErasTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: ErasTheme.spacingSm),
                      Text(
                        'Looking within 2km radius',
                        style: ErasTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: _found.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off,
                                color: ErasTheme.textTertiary, size: 64),
                            const SizedBox(height: ErasTheme.spacingMd),
                            Text(
                              'No responders nearby',
                              style: ErasTheme.titleLarge.copyWith(
                                color: ErasTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: ErasTheme.spacingXs),
                            Text(
                              'Try again later or expand your search',
                              style: ErasTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _found.length,
                        padding: const EdgeInsets.symmetric(
                          horizontal: ErasTheme.spacingMd,
                        ),
                        itemBuilder: (context, index) {
                          final resp = _found[index];
                          return _ResponderCard(
                            responder: resp,
                            distanceLabel: _formatDistance(resp.distanceMeters),
                            onMessage: () {
                              Navigator.of(context).pushNamed(
                                AppRoutes.messagingChat,
                                arguments: {
                                  'responderId': resp.id,
                                  'responderName': resp.name,
                                  'specialization': resp.specialization.label,
                                },
                              );
                            },
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ResponderCard extends StatelessWidget {
  final NearbyResponder responder;
  final String distanceLabel;
  final VoidCallback onMessage;

  const _ResponderCard({
    required this.responder,
    required this.distanceLabel,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: ErasTheme.spacingSm),
      padding: const EdgeInsets.all(ErasTheme.spacingMd),
      decoration: BoxDecoration(
        color: ErasTheme.surfaceCard,
        borderRadius: BorderRadius.circular(ErasTheme.borderRadiusLg),
        border: Border.all(color: ErasTheme.borderSubtle),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: ErasTheme.medicalBlue.withOpacity(0.15),
            child: Text(
              responder.name.split(' ').map((p) => p[0]).take(2).join(),
              style: ErasTheme.titleMedium.copyWith(
                color: ErasTheme.medicalBlue,
              ),
            ),
          ),
          const SizedBox(width: ErasTheme.spacingSm),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        responder.name,
                        style: ErasTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: responder.isOnline
                            ? ErasTheme.successGreen
                            : ErasTheme.textTertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${responder.specialization.label} \u2022 $distanceLabel',
                  style: ErasTheme.labelSmall,
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: ErasTheme.warningAmber, size: 14),
                    const SizedBox(width: 2),
                    Text(
                      responder.rating.toStringAsFixed(1),
                      style: ErasTheme.labelSmall.copyWith(
                        color: ErasTheme.warningAmber,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Message button
          ElevatedButton.icon(
            onPressed: onMessage,
            style: ElevatedButton.styleFrom(
              backgroundColor: ErasTheme.medicalBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ErasTheme.borderRadiusMd),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: ErasTheme.spacingMd,
                vertical: ErasTheme.spacingSm,
              ),
            ),
            icon: const Icon(Icons.message, size: 18),
            label: const Text('Chat'),
          ),
        ],
      ),
    );
  }
}
