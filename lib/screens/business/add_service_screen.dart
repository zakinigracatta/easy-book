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

  final List<int> _durationOptions = [15, 20, 30, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    final s = widget.initialService;
    _nameController = TextEditingController(text: s?.name ?? '');
    _categoryController =
        TextEditingController(text: s?.categoryName ?? 'Hair Services');
    _descriptionController = TextEditingController(text: s?.description ?? '');
    _priceController =
        TextEditingController(text: s != null ? '${s.price}' : '');
    _discountController = TextEditingController(
        text: s?.discountPrice != null ? '${s!.discountPrice}' : '');
    _imageUrlController = TextEditingController(text: s?.imageUrl ?? '');

    _selectedDurationMinutes = s?.durationMinutes ?? 30;
    _isActive = s?.isActive ?? true;
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
                        value:
                            _durationOptions.contains(_selectedDurationMinutes)
                                ? _selectedDurationMinutes
                                : 30,
                        decoration: InputDecoration(
                          labelText: 'Service Duration *',
                          labelStyle:
                              const TextStyle(color: AppColors.textMutedDark),
                          prefixIcon: const Icon(Icons.timer_outlined,
                              color: AppColors.primaryLight),
                          filled: true,
                          fillColor: AppColors.bgDark,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: AppColors.glassBorderDark),
                          ),
                        ),
                        dropdownColor: AppColors.cardDark,
                        items: _durationOptions.map((mins) {
                          return DropdownMenuItem(
                            value: mins,
                            child: Text(
                              '$mins minutes',
                              style: const TextStyle(
                                  color: AppColors.textPrimaryDark,
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
                        label: 'Service Image',
                        currentImageUrl: _imageUrlController.text,
                        onPickImage: () {
                          _imageUrlController.text =
                              'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&w=800&q=80';
                          setState(() {});
                        },
                        onDeleteImage: () {
                          _imageUrlController.clear();
                          setState(() {});
                        },
                      ),

                      const SizedBox(height: 16),

                      // Availability Switch
                      SwitchListTile(
                        value: _isActive,
                        activeColor: AppColors.primary,
                        title: const Text(
                          'Available for Booking',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryDark,
                          ),
                        ),
                        subtitle: const Text(
                          'Disable to temporarily stop accepting new bookings for this service.',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textMutedDark),
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

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final price = double.parse(_priceController.text.trim());
      final discountPrice = _discountController.text.trim().isNotEmpty
          ? double.tryParse(_discountController.text.trim())
          : null;

      final bizId = ref.read(currentBusinessIdProvider).value ?? '';

      final service = ServiceModel(
        id: widget.initialService?.id ??
            'srv_${DateTime.now().millisecondsSinceEpoch}',
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.initialService != null
                ? 'Service updated successfully!'
                : 'New service created!'),
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
            content: Text('Failed to save service: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
