import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../l10n/l10n.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/business/business_image_picker.dart';
import '../../providers/owner_providers.dart';
import '../../models/service_model.dart';
import '../../services/media_upload_service.dart';

class AddServiceScreen extends ConsumerStatefulWidget {
  final ServiceModel? initialService;

  const AddServiceScreen({super.key, this.initialService});

  @override
  ConsumerState<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends ConsumerState<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _media = MediaUploadService();
  late final String _serviceId;
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _discountController;
  late TextEditingController _imageUrlController;

  int _selectedDurationMinutes = 30;
  bool _isActive = true;
  bool _isLoading = false;
  double? _uploadProgress;

  final List<int> _durationOptions = [15, 20, 30, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    final s = widget.initialService;
    _serviceId = s?.id ?? 'srv_${DateTime.now().millisecondsSinceEpoch}';
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
  void dispose() {
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
    final l10n = l10nOf(context);
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
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/services-management');
              }
            },
          ),
          title: Text(isEditing ? l10n.editService : l10n.addNewService),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GlassCard(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        controller: _nameController,
                        label: l10n.serviceNameRequiredLabel,
                        prefixIcon: Icons.design_services_rounded,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return l10n.enterServiceName;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 14),
                      CustomTextField(
                        controller: _categoryController,
                        label: l10n.serviceCategoryHint,
                        prefixIcon: Icons.category_rounded,
                      ),
                      SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _priceController,
                              label: l10n.priceAedRequired,
                              prefixIcon: Icons.payments_rounded,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              validator: (val) {
                                if (val == null ||
                                    double.tryParse(val) == null) {
                                  return l10n.enterValidPrice;
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              controller: _discountController,
                              label: l10n.discountPrice,
                              prefixIcon: Icons.discount_rounded,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14),
                      DropdownButtonFormField<int>(
                        initialValue:
                            _durationOptions.contains(_selectedDurationMinutes)
                                ? _selectedDurationMinutes
                                : 30,
                        decoration: InputDecoration(
                          labelText: l10n.serviceDurationRequired,
                          labelStyle: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                          prefixIcon: Icon(Icons.timer_outlined,
                              color: AppColors.primaryLight),
                          filled: true,
                          fillColor: Theme.of(context).scaffoldBackgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outline),
                          ),
                        ),
                        dropdownColor: Theme.of(context).colorScheme.surface,
                        items: _durationOptions.map((mins) {
                          return DropdownMenuItem(
                            value: mins,
                            child: Text(
                              l10n.minutesCount(mins),
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
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
                      SizedBox(height: 14),
                      CustomTextField(
                        controller: _descriptionController,
                        label: l10n.description,
                        prefixIcon: Icons.notes_rounded,
                        maxLines: 3,
                      ),
                      SizedBox(height: 16),
                      BusinessImagePicker(
                        label: l10n.serviceImage,
                        currentImageUrl: _imageUrlController.text,
                        onPickImage: _pickServiceImage,
                        onDeleteImage: _imageUrlController.text.isEmpty
                            ? null
                            : _deleteServiceImage,
                        isLoading: _uploadProgress != null,
                      ),
                      if (_uploadProgress != null) ...[
                        SizedBox(height: 8),
                        LinearProgressIndicator(value: _uploadProgress),
                        SizedBox(height: 4),
                        Text(
                          l10n.uploadingPercent(
                            (100 * _uploadProgress!).round(),
                          ),
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      SizedBox(height: 16),
                      SwitchListTile(
                        value: _isActive,
                        activeThumbColor: Colors.white,
                        activeTrackColor: AppColors.success,
                        title: Text(
                          l10n.availableForBooking,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          l10n.serviceAvailabilityHelp,
                          style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                        ),
                        onChanged: (val) => setState(() => _isActive = val),
                      ),
                      SizedBox(height: 24),
                      CustomButton(
                        text: isEditing
                            ? l10n.updateService
                            : l10n.saveAndPublishService,
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

  Future<String> _businessId() async {
    final id = await ref.read(currentBusinessIdProvider.future);
    if (id.isEmpty) throw StateError('Business ID is not available.');
    return id;
  }

  Future<void> _pickServiceImage() async {
    try {
      final businessId = await _businessId();
      setState(() => _uploadProgress = 0);
      final url = await _media.pickAndUploadImage(
        storageFolder: 'businesses/$businessId/services/$_serviceId',
        onProgress: (progress) {
          if (mounted) setState(() => _uploadProgress = progress);
        },
      );
      if (url == null || !mounted) return;

      final oldUrl = _imageUrlController.text.trim();
      setState(() => _imageUrlController.text = url);
      if (oldUrl.isNotEmpty && oldUrl != url) {
        await _media.deleteByUrl(oldUrl);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10nOf(context).imageUploadFailed(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadProgress = null);
    }
  }

  Future<void> _deleteServiceImage() async {
    final url = _imageUrlController.text.trim();
    setState(() => _imageUrlController.clear());
    try {
      await _media.deleteByUrl(url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10nOf(context).imageDeleteFailed(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
      final bizId = await _businessId();

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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.initialService != null
                ? l10nOf(context).serviceUpdatedSuccessfully
                : l10nOf(context).serviceCreatedSuccessfully),
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
            content: Text(l10nOf(context).serviceSaveFailed(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
