import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/business_model.dart';
import '../../providers/owner_providers.dart';
import '../../services/media_upload_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/business/business_image_picker.dart';
import '../../widgets/business_bottom_nav.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/glass_card.dart';
import 'business_location_picker_screen.dart';

class SalonManagementScreen extends ConsumerStatefulWidget {
  const SalonManagementScreen({super.key});

  @override
  ConsumerState<SalonManagementScreen> createState() =>
      _SalonManagementScreenState();
}

class _SalonManagementScreenState extends ConsumerState<SalonManagementScreen> {
  static const _amenityOptions = [
    'Wi-Fi',
    'Parking',
    'Valet Parking',
    'Card Payment',
    'Cash Payment',
    'Wheelchair Access',
    'Private Rooms',
    'Ladies Only',
    'Coffee & Drinks',
    'Prayer Area',
  ];

  final _formKey = GlobalKey<FormState>();
  final _media = MediaUploadService();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _logoUrlController = TextEditingController();

  final Set<String> _amenities = {};
  bool _acceptingBookings = true;
  bool _isLoading = false;
  bool _hydrated = false;
  double _latitude = 0;
  double _longitude = 0;
  double? _uploadProgress;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  void _hydrate(BusinessModel business) {
    if (_hydrated) return;
    _nameController.text = business.name;
    _categoryController.text = business.category;
    _descriptionController.text = business.description;
    _addressController.text = business.address;
    _phoneController.text = business.phone ?? '';
    _websiteController.text = business.website ?? '';
    _logoUrlController.text = business.imageUrl;
    _acceptingBookings = business.acceptingBookings;
    _latitude = business.latitude;
    _longitude = business.longitude;
    _amenities
      ..clear()
      ..addAll(business.amenities);
    _hydrated = true;
  }

  @override
  Widget build(BuildContext context) {
    final businessAsync = ref.watch(ownerBusinessProvider);

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.canPop() ? context.pop() : context.go('/owner-dashboard');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('Business Management')),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/owner-dashboard'),
          ),
        ),
        body: businessAsync.when(
          data: (business) {
            _hydrate(business);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusCard(),
                    const SizedBox(height: 14),
                    _buildMediaCard(business),
                    const SizedBox(height: 14),
                    _buildProfileCard(),
                    const SizedBox(height: 14),
                    _buildLocationCard(),
                    const SizedBox(height: 14),
                    _buildAmenitiesCard(),
                    const SizedBox(height: 14),
                    _buildManagementShortcuts(),
                    const SizedBox(height: 18),
                    CustomButton(
                      text: 'Save Business Profile',
                      isLoading: _isLoading,
                      onPressed: () => _updateProfile(business),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (_, __) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                context.tr('Unable to load business profile. Please try again.'),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        bottomNavigationBar: const BusinessBottomNav(currentIndex: 4),
      ),
    );
  }

  Widget _buildStatusCard() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: (_acceptingBookings ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _acceptingBookings
                  ? Icons.event_available_rounded
                  : Icons.event_busy_rounded,
              color: _acceptingBookings ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('Online Booking Status'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  context.tr(
                    _acceptingBookings
                        ? 'Customers can currently book your business.'
                        : 'New online bookings are temporarily paused.',
                  ),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMutedDark,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _acceptingBookings,
            activeThumbColor: AppColors.primary,
            onChanged: (value) => setState(() => _acceptingBookings = value),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaCard(BusinessModel business) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.photo_camera_back_rounded,
            title: 'Main Business Photo',
            subtitle: 'Upload a real cover image from the device.',
          ),
          const SizedBox(height: 14),
          BusinessImagePicker(
            label: context.tr('Logo / Main Cover Image'),
            currentImageUrl: _logoUrlController.text,
            onPickImage: () => _pickMainPhoto(business),
            onDeleteImage:
                _logoUrlController.text.isEmpty ? null : _deleteMainPhoto,
          ),
          if (_uploadProgress != null) ...[
            const SizedBox(height: 10),
            LinearProgressIndicator(value: _uploadProgress),
            const SizedBox(height: 5),
            Text(
              '${context.tr('Uploading')} ${(100 * _uploadProgress!).round()}%',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMutedDark,
              ),
            ),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.push('/owner-gallery'),
            icon: const Icon(Icons.collections_rounded),
            label: Text(context.tr('Manage Multiple Business Photos')),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.storefront_rounded,
            title: 'Business Details',
            subtitle: 'Information customers see on your public profile.',
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: _nameController,
            label: 'Business Name *',
            prefixIcon: Icons.storefront_rounded,
            validator: (value) => value == null || value.trim().isEmpty
                ? context.tr('Enter business name')
                : null,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _categoryController,
            label: 'Category',
            prefixIcon: Icons.category_rounded,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _phoneController,
            label: 'Contact Phone Number',
            prefixIcon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _websiteController,
            label: 'Website / Social Link',
            prefixIcon: Icons.language_rounded,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _descriptionController,
            label: 'Business Description',
            prefixIcon: Icons.notes_rounded,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    final hasPin = _latitude != 0 || _longitude != 0;
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.location_on_rounded,
            title: 'Business Location',
            subtitle: 'Save the address and pin the exact entrance on Google Maps.',
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: _addressController,
            label: 'Full Address',
            prefixIcon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _openLocationPicker,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hasPin ? AppColors.success : AppColors.glassBorderDark,
                ),
                color: AppColors.glassBgDark,
              ),
              child: Row(
                children: [
                  Icon(
                    hasPin
                        ? Icons.pin_drop_rounded
                        : Icons.add_location_alt_rounded,
                    color: hasPin ? AppColors.success : AppColors.primaryLight,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr(
                            hasPin
                                ? 'Precise location saved'
                                : 'Set precise location',
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.tr(
                            hasPin
                                ? 'Tap to adjust the salon pin on Google Maps.'
                                : 'Open the map and place the pin on the exact entrance.',
                          ),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMutedDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMutedDark,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesCard() {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.auto_awesome_rounded,
            title: 'Amenities & Features',
            subtitle: 'Select the facilities available at your business.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _amenityOptions.map((amenity) {
              final selected = _amenities.contains(amenity);
              return FilterChip(
                selected: selected,
                label: Text(context.tr(amenity)),
                avatar: selected
                    ? const Icon(Icons.check_rounded, size: 16)
                    : null,
                onSelected: (value) {
                  setState(() {
                    value ? _amenities.add(amenity) : _amenities.remove(amenity);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementShortcuts() {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.tune_rounded,
            title: 'More Management',
            subtitle: 'Manage the parts customers interact with most.',
          ),
          const SizedBox(height: 12),
          _ManagementTile(
            icon: Icons.schedule_rounded,
            title: 'Business Working Hours',
            onTap: () => context.push('/business-hours'),
          ),
          _ManagementTile(
            icon: Icons.people_alt_rounded,
            title: 'Employees & Their Hours',
            onTap: () => context.push('/employee-management'),
          ),
          _ManagementTile(
            icon: Icons.collections_rounded,
            title: 'Business Photo Gallery',
            onTap: () => context.push('/owner-gallery'),
          ),
          _ManagementTile(
            icon: Icons.reviews_rounded,
            title: 'Customer Reviews',
            onTap: () => context.push('/owner-reviews'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickMainPhoto(BusinessModel business) async {
    try {
      setState(() => _uploadProgress = 0);
      final url = await _media.pickAndUploadImage(
        storageFolder: 'businesses/${business.id}/profile',
        onProgress: (progress) {
          if (mounted) setState(() => _uploadProgress = progress);
        },
      );
      if (url == null || !mounted) return;
      final oldUrl = _logoUrlController.text;
      setState(() => _logoUrlController.text = url);
      if (oldUrl.isNotEmpty && oldUrl != url) {
        await _media.deleteByUrl(oldUrl);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('Image upload failed.'))),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadProgress = null);
    }
  }

  Future<void> _deleteMainPhoto() async {
    final url = _logoUrlController.text;
    setState(() => _logoUrlController.clear());
    try {
      await _media.deleteByUrl(url);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('Could not remove image.'))),
        );
      }
    }
  }

  Future<void> _openLocationPicker() async {
    final result = await Navigator.of(context).push<BusinessLocationSelection>(
      MaterialPageRoute(
        builder: (_) => BusinessLocationPickerScreen(
          initialLatitude: _latitude,
          initialLongitude: _longitude,
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _latitude = result.latitude;
      _longitude = result.longitude;
    });
  }

  Future<void> _updateProfile(BusinessModel current) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final updated = current.copyWith(
        name: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        address: _addressController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: _logoUrlController.text.trim(),
        phone: _phoneController.text.trim(),
        website: _websiteController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        amenities: _amenities.toList(),
        acceptingBookings: _acceptingBookings,
      );

      await ref.read(ownerBusinessProvider.notifier).updateBusiness(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Business profile updated.')),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr('Failed to update business profile. Please try again.'),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryLight, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr(title),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                context.tr(subtitle),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMutedDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ManagementTile extends StatelessWidget {
  const _ManagementTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primaryLight),
      title: Text(
        context.tr(title),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryDark,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textMutedDark,
      ),
      onTap: onTap,
    );
  }
}
