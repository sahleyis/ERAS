import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../models/emergency_model.dart';

/// Alert detail screen — expanded view of an incoming alert.
class AlertDetailScreen extends ConsumerWidget {
  const AlertDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emergencyId =
        ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      backgroundColor: ErasTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Alert Details'),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(ErasTheme.spacingLg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_active,
                  size: 80,
                  color: ErasTheme.sosRed,
                ),
                const SizedBox(height: ErasTheme.spacingMd),
                Text(
                  'Emergency Alert',
                  style: ErasTheme.headlineLarge,
                ),
                const SizedBox(height: ErasTheme.spacingSm),
                Text(
                  'Emergency ID: ${emergencyId ?? "Unknown"}',
                  style: ErasTheme.bodyMedium,
                ),
                const SizedBox(height: ErasTheme.spacingXl),
                Text(
                  'Full alert details with map preview,\nvictim information, and route options.',
                  style: ErasTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
