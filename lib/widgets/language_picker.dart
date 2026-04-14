import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../config/localization.dart';

/// Compact language picker bar for the bottom of screens.
class LanguagePicker extends ConsumerWidget {
  const LanguagePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(appLanguageProvider);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ErasTheme.spacingSm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: ErasTheme.surfaceCard,
        border: Border(
          top: BorderSide(color: ErasTheme.borderSubtle),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.language,
            color: ErasTheme.textTertiary,
            size: 16,
          ),
          const SizedBox(width: 6),
          ...AppLanguage.values.map((lang) {
            final isSelected = current == lang;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: GestureDetector(
                onTap: () {
                  ref.read(appLanguageProvider.notifier).state = lang;
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ErasTheme.medicalBlue.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(ErasTheme.borderRadiusFull),
                    border: isSelected
                        ? Border.all(
                            color: ErasTheme.medicalBlue.withOpacity(0.4),
                          )
                        : null,
                  ),
                  child: Text(
                    lang.code.toUpperCase(),
                    style: ErasTheme.labelSmall.copyWith(
                      color: isSelected
                          ? ErasTheme.medicalBlue
                          : ErasTheme.textTertiary,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
