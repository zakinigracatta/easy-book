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
import '../../l10n/app_localizations.dart';

class OwnerGalleryScreen extends ConsumerStatefulWidget {
  OwnerGalleryScreen({super.key});

  @override
  ConsumerState<OwnerGalleryScreen> createState() => _OwnerGalleryScreenState();
}

class _OwnerGalleryScreenState extends ConsumerState<OwnerGalleryScreen> {
  static const _categories = [
    ('all', 'All Photos'),
    ('interior', 'Interior'),
    ('exterior', 'Exterior'),
    ('service', 'Service'),
    ('portfolio', 'Portfolio'),
    ('beforeAfter', 'Before & After'),
    ('other', 'Other'),
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
          title: Text(context.tr('Business Photos & Gallery')),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/owner-dashboard'),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.add_a_photo_rounded),
              tooltip: 'Upload Photos',
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
                  final isSelected = _selectedCategory == entry.$1;
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: isSelected,
                      label: Text(entry.$2),
                      selectedColor: AppColors.primary,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = entry.$1),
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
                      title: 'No Photos Yet',
                      description:
                          'Upload real photos so customers can see your space and work.',
                      actionLabel: 'Upload Photos',
                      onActionTap: _showUploadDialog,
                    );
                  }

                  return GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
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
                  title: 'Unable to Load Gallery',
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
                    tooltip: 'Delete photo',
                    onPressed: () => _confirmDelete(image),
                    icon: Icon(Icons.delete_outline_rounded, size: 18),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
          title: Text(context.tr('Upload Business Photos')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: category,
                decoration: InputDecoration(
                  labelText: 'Photo category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _categories
                    .where((entry) => entry.$1 != 'all')
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry.$1,
                        child: Text(entry.$2),
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
                  labelText: 'Caption (optional)',
                  prefixIcon: Icon(Icons.notes_rounded),
                  helperText: 'The caption will be applied to this upload batch.',
                ),
              ),
              SizedBox(height: 12),
              Text(context.tr('You can select up to 10 photos at once.'),
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
              child: Text(context.tr('Cancel')),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(
                dialogContext,
                (category: category, caption: captionController.text.trim()),
              ),
              icon: Icon(Icons.photo_library_outlined),
              label: Text(context.tr('Choose Photos')),
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
        _uploadStatus = 'Choose photos from your device…';
      });

      final urls = await _media.pickAndUploadMultipleImages(
        storageFolder: 'businesses/$businessId/gallery/$batchId',
        maxCount: 10,
        onProgress: (current, total, progress) {
          if (!mounted) return;
          setState(() {
            _uploadProgress = progress;
            _uploadStatus =
                'Uploading photo $current of $total • ${(progress * 100).round()}%';
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
            content: Text('${urls.length} photo(s) uploaded successfully.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo upload failed: $e'),
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
            title: Text(context.tr('Delete photo?')),
            content: Text(context.tr('This will permanently remove the photo from the business gallery.'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.tr('Cancel')),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(context.tr('Delete')),
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
          SnackBar(content: Text('Could not delete photo: $e')),
        );
      }
    }
  }

  String _categoryLabel(String id) {
    for (final entry in _categories) {
      if (entry.$1 == id) return entry.$2;
    }
    return 'Other';
  }
}
