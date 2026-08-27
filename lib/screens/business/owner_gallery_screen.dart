import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/business_bottom_nav.dart';
import '../../widgets/business/owner_empty_state.dart';
import '../../providers/owner_providers.dart';
import '../../models/gallery_image_model.dart';
import '../../services/media_upload_service.dart';
import '../../l10n/l10n.dart';

class OwnerGalleryScreen extends ConsumerStatefulWidget {
  const OwnerGalleryScreen({super.key});

  @override
  ConsumerState<OwnerGalleryScreen> createState() => _OwnerGalleryScreenState();
}

class _OwnerGalleryScreenState extends ConsumerState<OwnerGalleryScreen> {
  static const _categories = [
    'all',
    'interior',
    'exterior',
    'service',
    'portfolio',
    'beforeAfter',
    'other',
  ];

  final _media = MediaUploadService();
  String _selectedCategory = 'all';
  double? _uploadProgress;
  String _uploadStatus = '';

  @override
  Widget build(BuildContext context) {
    final galleryAsync = ref.watch(ownerGalleryProvider);

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.canPop() ? context.pop() : context.go('/owner-dashboard');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10nOf(context).businessGallery),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go('/owner-dashboard'),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.add_a_photo_rounded),
              tooltip: l10nOf(context).uploadPhotos,
              onPressed: _uploadProgress == null ? _showUploadDialog : null,
            ),
          ],
        ),
        body: Column(
          children: [
            if (_uploadProgress != null)
              Container(
                padding: EdgeInsets.fromLTRB(16, 10, 16, 8),
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(value: _uploadProgress),
                    SizedBox(height: 5),
                    Text(
                      _uploadStatus,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: _categories.map((entry) {
                  final isSelected = _selectedCategory == entry;
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ChoiceChip(
                      selected: isSelected,
                      label: Text(_categoryLabel(entry)),
                      selectedColor: AppColors.primary,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = entry),
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: galleryAsync.when(
                data: (images) {
                  final filtered = _selectedCategory == 'all'
                      ? images
                      : images
                          .where((image) => image.category == _selectedCategory)
                          .toList();

                  if (filtered.isEmpty) {
                    return OwnerEmptyStateWidget(
                      icon: Icons.photo_library_rounded,
                      title: l10nOf(context).noPhotosYet,
                      description: l10nOf(context).uploadRealPhotosHint,
                      actionLabel: l10nOf(context).uploadPhotos,
                      onActionTap: _showUploadDialog,
                    );
                  }

                  return GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) =>
                        _buildPhotoCard(filtered[index]),
                  );
                },
                loading: () => Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (error, _) => OwnerEmptyStateWidget(
                  icon: Icons.error_outline_rounded,
                  title: l10nOf(context).galleryLoadFailed,
                  description: error.toString(),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BusinessBottomNav(currentIndex: 4),
      ),
    );
  }

  Widget _buildPhotoCard(GalleryImageModel image) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    image.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton.filledTonal(
                    tooltip: l10nOf(context).deletePhoto,
                    onPressed: () => _confirmDelete(image),
                    icon: Icon(Icons.delete_outline_rounded, size: 18),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      _categoryLabel(image.category),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (image.caption.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(9),
              child: Text(
                image.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showUploadDialog() async {
    String category = 'portfolio';
    final captionController = TextEditingController();

    final result = await showDialog<({String category, String caption})>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10nOf(context).uploadBusinessPhotos),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: InputDecoration(
                  labelText: l10nOf(context).photoCategory,
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _categories
                    .where((entry) => entry != 'all')
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry,
                        child: Text(_categoryLabel(entry)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setDialogState(() => category = value);
                },
              ),
              SizedBox(height: 12),
              TextField(
                controller: captionController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l10nOf(context).photoDescriptionOptional,
                  prefixIcon: Icon(Icons.notes_rounded),
                  helperText: l10nOf(context).photoDescriptionBatchHelp,
                ),
              ),
              SizedBox(height: 12),
              Text(
                l10nOf(context).photoSelectionLimit,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10nOf(context).cancel),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(
                dialogContext,
                (category: category, caption: captionController.text.trim()),
              ),
              icon: Icon(Icons.photo_library_outlined),
              label: Text(l10nOf(context).choosePhotos),
            ),
          ],
        ),
      ),
    );
    captionController.dispose();

    if (result == null || !mounted) return;
    await _uploadPhotos(result.category, result.caption);
  }

  Future<void> _uploadPhotos(String category, String caption) async {
    try {
      final businessId = await ref.read(currentBusinessIdProvider.future);
      if (businessId.isEmpty) throw StateError('Business ID is not available.');

      final batchId = 'gallery_${DateTime.now().millisecondsSinceEpoch}';
      setState(() {
        _uploadProgress = 0;
        _uploadStatus = l10nOf(context).choosePhotosFromDevice;
      });

      final urls = await _media.pickAndUploadMultipleImages(
        storageFolder: 'businesses/$businessId/gallery/$batchId',
        maxCount: 10,
        onProgress: (current, total, progress) {
          if (!mounted) return;
          setState(() {
            _uploadProgress = progress;
            _uploadStatus = l10nOf(context).uploadingPhotoProgress(
              current,
              total,
              (progress * 100).round(),
            );
          });
        },
      );

      for (var i = 0; i < urls.length; i++) {
        final image = GalleryImageModel(
          id: '${batchId}_$i',
          businessId: businessId,
          imageUrl: urls[i],
          category: category,
          caption: caption,
          sortOrder: DateTime.now().millisecondsSinceEpoch + i,
        );
        await ref.read(ownerGalleryProvider.notifier).addGalleryImage(image);
      }

      if (urls.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10nOf(context).photosUploaded(urls.length)),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10nOf(context).photosUploadFailed('$e')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _uploadProgress = null;
          _uploadStatus = '';
        });
      }
    }
  }

  Future<void> _confirmDelete(GalleryImageModel image) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10nOf(context).deletePhotoQuestion),
            content: Text(
              l10nOf(context).deletePhotoConfirmation,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10nOf(context).cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10nOf(context).delete),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;

    try {
      await _media.deleteByUrl(image.imageUrl);
      await ref
          .read(ownerGalleryProvider.notifier)
          .deleteGalleryImage(image.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10nOf(context).photoDeleteFailed('$e'))),
        );
      }
    }
  }

  String _categoryLabel(String id) {
    final l10n = l10nOf(context);
    return switch (id) {
      'all' => l10n.allPhotos,
      'interior' => l10n.interior,
      'exterior' => l10n.exterior,
      'service' => l10n.services,
      'portfolio' => l10n.portfolio,
      'beforeAfter' => l10n.beforeAndAfter,
      _ => l10n.other,
    };
  }
}
