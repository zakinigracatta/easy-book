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
import '../../services/media_upload_service.dart';
import 'business_location_picker_screen.dart';
import '../../l10n/l10n.dart';

class SalonManagementScreen extends ConsumerStatefulWidget {
  const SalonManagementScreen({super.key});

  @override
  ConsumerState<SalonManagementScreen> createState() =>
      _SalonManagementScreenState();
}

class _SalonManagementScreenState extends ConsumerState<SalonManagementScreen> {
  static const _amenityOptions = [
    'Wi-Fi',
    'parking',
    'valetParking',
    'cardPayment',
    'cashPayment',
    'wheelchairAccess',
    'privateRooms',
    'womenOnly',
    'coffeeAndDrinks',
    'prayerSpace',
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
          title: Text(l10nOf(context).manageBusiness),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go('/owner-dashboard'),
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
                    _buildManagementShortcuts(context),
                    const SizedBox(height: 18),
                    CustomButton(
                      text: l10nOf(context).saveBusinessProfile,
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
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10nOf(context).businessProfileLoadFailed('$error')),
            ),
          ),
        ),
        bottomNavigationBar: BusinessBottomNav(currentIndex: 4),
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
                  l10nOf(context).onlineBookingStatus,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _acceptingBookings
                      ? l10nOf(context).customersCanBookNow
                      : l10nOf(context).onlineBookingsPaused,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _acceptingBookings,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.success,
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
          _SectionTitle(
            icon: Icons.photo_camera_back_rounded,
            title: l10nOf(context).businessMainPhoto,
            subtitle: l10nOf(context).uploadCoverPhotoHelp,
          ),
          const SizedBox(height: 14),
          BusinessImagePicker(
            label: l10nOf(context).logoOrMainCover,
            currentImageUrl: _logoUrlController.text,
            onPickImage: () => _pickMainPhoto(business),
            onDeleteImage: _logoUrlController.text.isEmpty
                ? null
                : () => _deleteMainPhoto(),
          ),
          if (_uploadProgress != null) ...[
            const SizedBox(height: 10),
            LinearProgressIndicator(value: _uploadProgress),
            const SizedBox(height: 5),
            Text(
              l10nOf(context).uploadProgressPercent(
                (100 * _uploadProgress!).round(),
              ),
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.push('/owner-gallery'),
            icon: const Icon(Icons.collections_rounded),
            label: Text(l10nOf(context).manageMultipleBusinessPhotos),
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
          _SectionTitle(
            icon: Icons.storefront_rounded,
            title: l10nOf(context).businessDetails,
            subtitle: l10nOf(context).publicBusinessInfoHelp,
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: _nameController,
            label: l10nOf(context).businessNameRequiredLabel,
            prefixIcon: Icons.storefront_rounded,
            validator: (value) => value == null || value.trim().isEmpty
                ? l10nOf(context).enterBusinessName
                : null,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _categoryController,
            label: l10nOf(context).category,
            prefixIcon: Icons.category_rounded,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _phoneController,
            label: l10nOf(context).contactPhone,
            prefixIcon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _websiteController,
            label: l10nOf(context).websiteContactLink,
            prefixIcon: Icons.language_rounded,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _descriptionController,
            label: l10nOf(context).businessDescription,
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
          _SectionTitle(
            icon: Icons.location_on_rounded,
            title: l10nOf(context).businessLocation,
            subtitle: l10nOf(context).locationGoogleMapsHelp,
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: _addressController,
            label: l10nOf(context).fullAddress,
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
                  color: hasPin
                      ? AppColors.success
                      : Theme.of(context).colorScheme.outline,
                ),
                color: Theme.of(context).colorScheme.surfaceContainerLow,
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
                          hasPin
                              ? l10nOf(context).exactLocationSaved
                              : l10nOf(context).setExactLocation,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasPin
                              ? l10nOf(context).editSalonLocationHelp
                              : l10nOf(context).placeEntrancePinHelp,
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
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
          _SectionTitle(
            icon: Icons.auto_awesome_rounded,
            title: l10nOf(context).amenitiesAndFeatures,
            subtitle: l10nOf(context).selectAmenitiesHelp,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _amenityOptions.map((amenity) {
              final selected = _amenities.contains(amenity);
              return FilterChip(
                selected: selected,
                selectedColor: AppColors.success.withValues(alpha: 0.14),
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerLow,
                checkmarkColor: AppColors.success,
                side: BorderSide(
                  color: selected
                      ? AppColors.success.withValues(alpha: 0.55)
                      : Theme.of(context).colorScheme.outline,
                ),
                label: Text(
                  _amenityLabel(amenity),
                  style: TextStyle(
                    color: selected
                        ? AppColors.success
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                onSelected: (value) {
                  setState(() {
                    value
                        ? _amenities.add(amenity)
                        : _amenities.remove(amenity);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _amenityLabel(String amenity) {
    final l10n = l10nOf(context);
    return switch (amenity) {
      'Wi-Fi' => 'Wi-Fi',
      'parking' => l10n.parking,
      'valetParking' => l10n.valetParking,
      'cardPayment' => l10n.cardPayment,
      'cashPayment' => l10n.cashPayment,
      'wheelchairAccess' => l10n.wheelchairAccess,
      'privateRooms' => l10n.privateRooms,
      'womenOnly' => l10n.womenOnly,
      'coffeeAndDrinks' => l10n.coffeeAndDrinks,
      'prayerSpace' => l10n.prayerSpace,
      _ => amenity,
    };
  }

  Widget _buildManagementShortcuts(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.tune_rounded,
            title: l10nOf(context).additionalManagement,
            subtitle: l10nOf(context).manageCustomerSectionsHelp,
          ),
          const SizedBox(height: 12),
          _ManagementTile(
            icon: Icons.schedule_rounded,
            title: l10nOf(context).businessWorkingHours,
            onTap: () => context.push('/business-hours'),
          ),
          _ManagementTile(
            icon: Icons.people_alt_rounded,
            title: l10nOf(context).employeesAndHours,
            onTap: () => context.push('/employee-management'),
          ),
          _ManagementTile(
            icon: Icons.collections_rounded,
            title: l10nOf(context).businessPhotoGallery,
            onTap: () => context.push('/owner-gallery'),
          ),
          _ManagementTile(
            icon: Icons.reviews_rounded,
            title: l10nOf(context).customerReviews,
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(l10nOf(context).imageUploadFailedWithError('$e'))),
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(l10nOf(context).storageImageDeleteFailed('$e'))),
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
          content: Text(l10nOf(context).businessProfileUpdated),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10nOf(context).businessProfileUpdateFailed('$e')),
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
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded,
          color: Theme.of(context).colorScheme.onSurfaceVariant),
      onTap: onTap,
    );
  }
}
