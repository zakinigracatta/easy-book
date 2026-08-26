import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class GallerySection extends StatelessWidget {
  final List<String> galleryUrls;

  const GallerySection({
    super.key,
    required this.galleryUrls,
  });

  @override
  Widget build(BuildContext context) {
    if (galleryUrls.isEmpty) return const SizedBox.shrink();

    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final thumbnailCacheWidth = (160 * devicePixelRatio)
        .round()
        .clamp(160, 640)
        .toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr('Photo Gallery'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: galleryUrls.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final url = galleryUrls[index];
              return RepaintBoundary(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CachedNetworkImage(
                    imageUrl: url,
                    width: 160,
                    height: 120,
                    fit: BoxFit.cover,
                    memCacheWidth: thumbnailCacheWidth,
                    maxWidthDiskCache: thumbnailCacheWidth,
                    fadeInDuration: const Duration(milliseconds: 100),
                    fadeOutDuration: Duration.zero,
                    placeholder: (context, url) =>
                        Container(color: Theme.of(context).colorScheme.surface),
                    errorWidget: (context, url, err) => Container(
                      width: 160,
                      height: 120,
                      color: Theme.of(context).colorScheme.surface,
                      child: Icon(
                        Icons.photo_library_outlined,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
