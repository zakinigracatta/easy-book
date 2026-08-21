import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

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
        const Text(
          'Photo Gallery',
          style: TextStyle(
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
                        Container(color: AppColors.cardDark),
                    errorWidget: (context, url, err) => Container(
                      width: 160,
                      height: 120,
                      color: AppColors.cardDark,
                      child: const Icon(
                        Icons.photo_library_outlined,
                        color: AppColors.textMutedDark,
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
