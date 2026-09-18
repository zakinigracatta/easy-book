import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';

class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key, this.businessId});

  final String? businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = businessId?.trim() ?? '';
    final businessState = ref.watch(businessDetailProvider(id));

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.canPop() ? context.pop() : context.go('/home');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/home'),
          ),
          title: Text(context.tr('Salon Photo Gallery')),
        ),
        body: id.isEmpty
            ? _EmptyGallery(message: context.tr('Business no longer available'))
            : businessState.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) => _EmptyGallery(
                  message: context.tr('Could not load this business'),
                ),
                data: (business) {
                  final images = business?.galleryUrls
                          .where((url) => url.trim().isNotEmpty)
                          .toList() ??
                      const <String>[];
                  if (images.isEmpty) {
                    return _EmptyGallery(
                      message: context.tr('No gallery photos available yet.'),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: images.length,
                    itemBuilder: (context, index) => ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          alignment: Alignment.center,
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          child: const Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _EmptyGallery extends StatelessWidget {
  const _EmptyGallery({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.photo_library_outlined, size: 52),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}
