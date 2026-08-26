import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../glass_card.dart';
import '../../l10n/app_localizations.dart';

class BusinessImagePicker extends StatelessWidget {
  final String? currentImageUrl;
  final String label;
  final VoidCallback onPickImage;
  final VoidCallback? onDeleteImage;
  final bool isLoading;

  const BusinessImagePicker({
    super.key,
    this.currentImageUrl,
    required this.label,
    required this.onPickImage,
    this.onDeleteImage,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = currentImageUrl != null && currentImageUrl!.isNotEmpty;

    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: isLoading ? null : onPickImage,
            child: Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Theme.of(context).dividerColor),
                image: hasImage
                    ? DecorationImage(
                        image: NetworkImage(currentImageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : !hasImage
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_a_photo_rounded,
                              size: 32,
                              color: AppColors.primaryLight,
                            ),
                            const SizedBox(height: 6),
                            Text(context.tr('Tap to upload image'),
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        )
                      : Container(
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor:
                                    Colors.black.withValues(alpha: 0.6),
                                child: IconButton(
                                  icon: const Icon(Icons.edit_rounded,
                                      size: 14, color: Colors.white),
                                  onPressed: onPickImage,
                                ),
                              ),
                              if (onDeleteImage != null) ...[
                                const SizedBox(width: 8),
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor:
                                      AppColors.error.withValues(alpha: 0.8),
                                  child: IconButton(
                                    icon: const Icon(Icons.delete_rounded,
                                        size: 14, color: Colors.white),
                                    onPressed: onDeleteImage,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
