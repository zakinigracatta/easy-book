import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/business_bottom_nav.dart';
import '../../widgets/business/business_image_picker.dart';
import '../../providers/owner_providers.dart';
import '../../models/business_model.dart';

class SalonManagementScreen extends ConsumerStatefulWidget {
  const SalonManagementScreen({super.key});

  @override
  ConsumerState<SalonManagementScreen> createState() =>
      _SalonManagementScreenState();
}

class _SalonManagementScreenState
    extends ConsumerState<SalonManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _websiteController;
  late TextEditingController _logoUrlController;

  bool _acceptingBookings = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final biz = ref.read(ownerBusinessProvider).value;
    _nameController =
        TextEditingController(text: biz?.name ?? 'Style Barber Lounge');
    _categoryController = TextEditingController(
        text: biz?.category ?? 'Barbershop & Spa Center');
    _descriptionController =
        TextEditingController(text: biz?.description ?? '');
    _addressController = TextEditingController(
        text: biz?.address ?? 'Marina Gate 2, Dubai Marina, UAE');
    _phoneController =
        TextEditingController(text: biz?.phone ?? '+971 4 399 1234');
    _websiteController = TextEditingController(
        text: biz?.website ?? 'https://stylebarber.ae');
    _logoUrlController =
        TextEditingController(text: biz?.imageUrl ?? '');

    _acceptingBookings = biz?.isActive ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final businessAsync = ref.watch(ownerBusinessProvider);

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
          title: const Text('Business Profile & Status'),
        ),
        body: businessAsync.when(
          data: (biz) => SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Business Status Card
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Accepting Online Bookings',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _acceptingBookings
                                  ? 'Currently OPEN to receive new customer bookings.'
                                  : 'TEMPORARILY CLOSED for new customer bookings.',
                              style: TextStyle(
                                fontSize: 11,
                                color: _acceptingBookings
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _acceptingBookings,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            setState(() => _acceptingBookings = val);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BusinessImagePicker(
                          label: 'Business Logo / Main Cover Image',
                          currentImageUrl: _logoUrlController.text,
                          onPickImage: () {
                            _logoUrlController.text =
                                'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&w=800&q=80';
                            setState(() {});
                          },
                          onDeleteImage: () {
                            _logoUrlController.clear();
                            setState(() {});
                          },
                        ),

                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _nameController,
                          label: 'Business Name *',
                          prefixIcon: Icons.storefront_rounded,
                          validator: (val) => val == null || val.isEmpty
                              ? 'Enter business name'
                              : null,
                        ),

                        const SizedBox(height: 14),

                        CustomTextField(
                          controller: _categoryController,
                          label: 'Category (e.g. Salon, Barber, Spa)',
                          prefixIcon: Icons.category_rounded,
                        ),

                        const SizedBox(height: 14),

                        CustomTextField(
                          controller: _phoneController,
                          label: 'Contact Phone Number',
                          prefixIcon: Icons.phone_rounded,
                        ),

                        const SizedBox(height: 14),

                        CustomTextField(
                          controller: _addressController,
                          label: 'Full Physical Address',
                          prefixIcon: Icons.location_on_rounded,
                        ),

                        const SizedBox(height: 14),

                        CustomTextField(
                          controller: _websiteController,
                          label: 'Website / Social Link',
                          prefixIcon: Icons.language_rounded,
                        ),

                        const SizedBox(height: 14),

                        CustomTextField(
                          controller: _descriptionController,
                          label: 'Business Description',
                          prefixIcon: Icons.notes_rounded,
                          maxLines: 3,
                        ),

                        const SizedBox(height: 24),

                        CustomButton(
                          text: 'Save Business Profile',
                          isLoading: _isLoading,
                          onPressed: () => _updateProfile(biz),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
          error: (_, __) => const SizedBox.shrink(),
        ),
        bottomNavigationBar: const BusinessBottomNav(currentIndex: 4),
      ),
    );
  }

  Future<void> _updateProfile(BusinessModel currentBiz) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final updated = BusinessModel(
        id: currentBiz.id,
        name: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        address: _addressController.text.trim(),
        rating: currentBiz.rating,
        reviewCount: currentBiz.reviewCount,
        imageUrl: _logoUrlController.text.trim(),
        isVerified: currentBiz.isVerified,
        description: _descriptionController.text.trim(),
        ownerId: currentBiz.ownerId,
        phone: _phoneController.text.trim(),
        website: _websiteController.text.trim(),
        galleryUrls: currentBiz.galleryUrls,
        isActive: _acceptingBookings,
        workingHours: currentBiz.workingHours,
      );

      await ref.read(ownerBusinessProvider.notifier).updateBusiness(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business profile updated!'),
            backgroundColor: AppColors.success,
          ),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/owner-dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update business profile: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
