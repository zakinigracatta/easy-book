import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/business_bottom_nav.dart';
import '../../widgets/business/owner_empty_state.dart';
import '../../providers/owner_providers.dart';
import '../../models/gallery_image_model.dart';

class OwnerGalleryScreen extends ConsumerStatefulWidget {
  const OwnerGalleryScreen({super.key});

  @override
  ConsumerState<OwnerGalleryScreen> createState() => _OwnerGalleryScreenState();
}

class _OwnerGalleryScreenState extends ConsumerState<OwnerGalleryScreen> {
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final galleryAsync = ref.watch(ownerGalleryProvider);

    final categories = [
      {'id': 'all', 'label': 'All Photos'},
      {'id': 'interior', 'label': 'Interior'},
      {'id': 'exterior', 'label': 'Exterior'},
      {'id': 'service', 'label': 'Service'},
      {'id': 'portfolio', 'label': 'Portfolio'},
      {'id': 'beforeAfter', 'label': 'Before & After'},
    ];

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/owner-dashboard');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/owner-dashboard');
              }
            },
          ),
          title: const Text('Business Photos & Gallery'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_a_photo_rounded),
              tooltip: 'Add Photo',
              onPressed: () => _showAddPhotoDialog(context),
            ),
          ],
        ),
        body: Column(
          children: [
            // Category Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: categories.map((c) {
                  final isSelected = _selectedCategory == c['id'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: isSelected,
                      label: Text(c['label']!),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color:
                            isSelected ? Colors.white : AppColors.textMutedDark,
                      ),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.cardDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.glassBorderDark,
                        ),
                      ),
                      onSelected: (_) {
                        setState(() => _selectedCategory = c['id']!);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            // Gallery Grid View
            Expanded(
              child: galleryAsync.when(
                data: (images) {
                  final filtered = _selectedCategory == 'all'
                      ? images
                      : images
                          .where((i) => i.category == _selectedCategory)
                          .toList();

                  if (filtered.isEmpty) {
                    return OwnerEmptyStateWidget(
                      icon: Icons.photo_library_rounded,
                      title: 'No Photos Yet',
                      description:
                          'Show customers what makes your business special.',
                      actionLabel: 'Add First Photo',
                      onActionTap: () => _showAddPhotoDialog(context),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final img = filtered[index];
                      return GlassCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(16)),
                                      image: DecorationImage(
                                        image: NetworkImage(img.imageUrl),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundColor:
                                          Colors.black.withValues(alpha: 0.6),
                                      child: IconButton(
                                        icon: const Icon(Icons.delete_rounded,
                                            size: 12, color: Colors.white),
                                        onPressed: () {
                                          ref
                                              .read(
                                                  ownerGalleryProvider.notifier)
                                              .deleteGalleryImage(img.id);
                                        },
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.black.withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        img.category.toUpperCase(),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (img.caption.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  img.caption,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textPrimaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary)),
                error: (_, __) => const OwnerEmptyStateWidget(
                  icon: Icons.error_outline_rounded,
                  title: 'Unable to Load Gallery',
                  description: 'Failed to retrieve business photos.',
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const BusinessBottomNav(currentIndex: 4),
      ),
    );
  }

  void _showAddPhotoDialog(BuildContext context) {
    final urlController = TextEditingController(
      text:
          'https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&w=800&q=80',
    );
    final captionController = TextEditingController();
    String category = 'portfolio';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.cardDark,
          title: const Text('Add Business Photo',
              style: TextStyle(color: AppColors.textPrimaryDark)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL',
                    prefixIcon: Icon(Icons.link_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(
                    labelText: 'Photo Category',
                    prefixIcon: Icon(Icons.category_rounded),
                  ),
                  dropdownColor: AppColors.cardDark,
                  items: const [
                    DropdownMenuItem(
                        value: 'interior', child: Text('Interior')),
                    DropdownMenuItem(
                        value: 'exterior', child: Text('Exterior')),
                    DropdownMenuItem(value: 'service', child: Text('Service')),
                    DropdownMenuItem(
                        value: 'portfolio', child: Text('Portfolio')),
                    DropdownMenuItem(
                        value: 'beforeAfter', child: Text('Before & After')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => category = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: captionController,
                  decoration: const InputDecoration(
                    labelText: 'Caption / Description',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textMutedDark)),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                final bizId = ref.read(currentBusinessIdProvider).value ?? '';
                final newImg = GalleryImageModel(
                  id: 'img_${DateTime.now().millisecondsSinceEpoch}',
                  businessId: bizId,
                  imageUrl: urlController.text.trim(),
                  category: category,
                  caption: captionController.text.trim(),
                );

                ref.read(ownerGalleryProvider.notifier).addGalleryImage(newImg);

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Photo added to gallery!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text('Upload Photo',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
