import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/business/business_image_picker.dart';
import '../../providers/owner_providers.dart';
import '../../models/service_model.dart';
import '../../l10n/app_localizations.dart';
import '../../services/media_upload_service.dart';

class AddServiceScreen extends ConsumerStatefulWidget {
  final ServiceModel? initialService;

  const AddServiceScreen({super.key, this.initialService});

  @override
  ConsumerState<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends ConsumerState<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _discountController;
  late TextEditingController _imageUrlController;

  int _selectedDurationMinutes = 30;
  bool _isActive = true;
  bool _isLoading = false;
  bool _isUploadingImage = false;
  late final String _serviceId;
  late final String _persistedImageUrl;
  final Set<String> _stagedImageUrls = <String>{};
  final _media = MediaUploadService();

  final List<int> _durationOptions = [15, 20, 30, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    final s = widget.initialService;
    _serviceId =
        s?.id ?? 'srv_${DateTime.now().millisecondsSinceEpoch}';
    _nameController = TextEditingController(text: s?.name ?? '');
    _categoryController =
        TextEditingController(text: s?.categoryName ?? 'Hair Services');
    _descriptionController = TextEditingController(text: s?.description ?? '');
    _priceController =
        TextEditingController(text: s != null ? '${s.price}' : '');
    _discountController = TextEditingController(
        text: s?.discountPrice != null ? '${s!.discountPrice}' : '');
    _persistedImageUrl = (s?.imageUrl ?? '').trim();
    _imageUrlController = TextEditingController(text: _persistedImageUrl);

    _selectedDurationMinutes = s?.durationMinutes ?? 30;
    _isActive = s?.isActive ?? true;
  }

  @override
  void dispose() {
    for (final url in _stagedImageUrls) {
      unawaited(_media.deleteByUrl(url));
    }
    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialService != null;

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/services-management');
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
                context.go('/services-management');
              }
            },
          ),
          title: Text(isEditing ? 'Edit Service' : 'Add New Service'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service Name Field
                      CustomTextField(
                        controller: _nameController,
                        label: 'Service Name *',
                        prefixIcon: Icons.design_services_rounded,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter service name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 14),

                      // Category Field
                      CustomTextField(
                        controller: _categoryController,
                        label: 'Category (e.g. Hair, Beard, Facial, Massage)',
                        prefixIcon: Icons.category_rounded,
                      ),

                      const SizedBox(height: 14),

                      // Price & Discount Price Fields
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _priceController,
                              label: 'Price (AED) *',
                              prefixIcon: Icons.payments_rounded,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (val) {
                                if (val == null ||
                                    double.tryParse(val) == null) {
                                  return 'Enter valid price';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              controller: _discountController,
                              label: 'Discount Price',
                              prefixIcon: Icons.discount_rounded,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Duration Dropdown in minutes
                      DropdownButtonFormField<int>(
                        initialValue:
                            _durationOptions.contains(_selectedDurationMinutes)
                                ? _selectedDurationMinutes
                                : 30,
                        decoration: InputDecoration(
                          labelText: 'Service Duration *',
                          labelStyle:
                              TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          prefixIcon: const Icon(Icons.timer_outlined,
                              color: AppColors.primaryLight),
                          filled: true,
                          fillColor: Theme.of(context).scaffoldBackgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                                color: Theme.of(context).dividerColor),
                          ),
                        ),
                        dropdownColor: Theme.of(context).colorScheme.surface,
                        items: _durationOptions.map((mins) {
                          return DropdownMenuItem(
                            value: mins,
                            child: Text(
                              "$mins ${context.tr('minutes')}",
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedDurationMinutes = val);
                          }
                        },
                      ),

                      const SizedBox(height: 14),

                      // Description Field
                      CustomTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        prefixIcon: Icons.notes_rounded,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 16),

                      // Image URL Picker Widget
                      BusinessImagePicker(
                        label: context.tr('Service Image'),
                        currentImageUrl: _imageUrlController.text,
                        isLoading: _isUploadingImage,
                        onPickImage: _pickServiceImage,
                        onDeleteImage: _deleteServiceImage,
                      ),

                      const SizedBox(height: 16),

                      // Availability Switch
                      SwitchListTile(
                        value: _isActive,
                        activeThumbColor: AppColors.primary,
                        title: Text(context.tr('Available for Booking'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(context.tr('Disable to temporarily stop accepting new bookings for this service.'),
                          style: TextStyle(
                              fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        onChanged: (val) => setState(() => _isActive = val),
                      ),

                      const SizedBox(height: 24),

                      // Save / Submit Button
                      CustomButton(
                        text: isEditing
                            ? 'Update Service'
                            : 'Save & Publish Service',
                        isLoading: _isLoading,
                        onPressed: _saveService,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickServiceImage() async {
    if (_isUploadingImage) return;
    setState(() => _isUploadingImage = true);
    try {
      final businessId = await ref.read(currentBusinessIdProvider.future);
      if (businessId.isEmpty) {
        throw StateError('Business ID is not available.');
      }

      final url = await _media.pickAndUploadImage(
        storageFolder: 'businesses/$businessId/services/$_serviceId',
      );
      if (url == null || !mounted) return;

      final previous = _imageUrlController.text.trim();
      _stagedImageUrls.add(url);
      _imageUrlController.text = url;
      setState(() {});

      if (previous.isNotEmpty &&
          previous != url &&
          _stagedImageUrls.remove(previous)) {
        await _media.deleteByUrl(previous);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr('Photo upload failed. Please try again.'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _deleteServiceImage() async {
    final current = _imageUrlController.text.trim();
    if (current.isEmpty) return;
    setState(() {
      _isUploadingImage = true;
      _imageUrlController.clear();
    });
    try {
      if (_stagedImageUrls.remove(current)) {
        await _media.deleteByUrl(current);
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final price = double.parse(_priceController.text.trim());
      final discountPrice = _discountController.text.trim().isNotEmpty
          ? double.tryParse(_discountController.text.trim())
          : null;

      final bizId = await ref.read(currentBusinessIdProvider.future);
      if (bizId.isEmpty) {
        throw StateError('No business is linked to this owner account.');
      }

      final service = ServiceModel(
        id: _serviceId,
        salonId: bizId,
        name: _nameController.text.trim(),
        price: price,
        discountPrice: discountPrice,
        duration: '$_selectedDurationMinutes min',
        durationMinutes: _selectedDurationMinutes,
        description: _descriptionController.text.trim(),
        categoryName: _categoryController.text.trim().isNotEmpty
            ? _categoryController.text.trim()
            : 'Services',
        imageUrl: _imageUrlController.text.trim(),
        isActive: _isActive,
        isBookable: _isActive,
      );

      await ref.read(ownerServicesProvider.notifier).saveService(service);

      final savedImageUrl = service.imageUrl?.trim() ?? '';
      _stagedImageUrls.remove(savedImageUrl);
      if (_persistedImageUrl.isNotEmpty &&
          _persistedImageUrl != savedImageUrl) {
        try {
          await _media.deleteByUrl(_persistedImageUrl);
        } catch (_) {
          // The database already points at the new image. Old-file cleanup is
          // best-effort and must not turn a successful save into a failure.
        }
      }
      for (final orphan in List<String>.of(_stagedImageUrls)) {
        try {
          await _media.deleteByUrl(orphan);
        } finally {
          _stagedImageUrls.remove(orphan);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr(
              widget.initialService != null
                  ? 'Service updated successfully!'
                  : 'New service created!',
            )),
            backgroundColor: AppColors.success,
          ),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/services-management');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('Unable to save service. Please try again.')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
