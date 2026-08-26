import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../glass_card.dart';

class OwnerEmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const OwnerEmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                context.tr(title),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr(description),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: mutedColor,
                  height: 1.4,
                ),
              ),
              if (actionLabel != null && onActionTap != null) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: onActionTap,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(context.tr(actionLabel!)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
