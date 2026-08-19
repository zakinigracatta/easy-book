import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/business/business_image_picker.dart';
import '../../providers/owner_providers.dart';
import '../../models/staff_model.dart';
import '../../services/media_upload_service.dart';

class AddEditEmployeeScreen extends ConsumerStatefulWidget {
  final StaffModel? initialStaff;

  const AddEditEmployeeScreen({super.key, this.initialStaff});

  @override
  ConsumerState<AddEditEmployeeScreen> createState() =>
      _AddEditEmployeeScreenState();
}

class _AddEditEmployeeScreenState extends ConsumerState<AddEditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _media = MediaUploadService();

  late final String _staffId;
  late final TextEditingController _nameController;
  late final TextEditingController _roleController;
  late final TextEditingController _experienceController;
  late final TextEditingController _avatarUrlController;
  late final TextEditingController _bioController;

  final List<String> _galleryUrls = [];
  bool _isActive = true;
  bool _isLoading = false;
  double? _uploadProgress;
  String _uploadLabel = '';

  @override
  void initState() {
    super.initState();
    final staff = widget.initialStaff;
    _staffId = staff?.id ?? 'st_${DateTime.now().millisecondsSinceEpoch}';
    _nameController = TextEditingController(text: staff?.name ?? '');
    _roleController = TextEditingController(text: staff?.roleTitle ?? '');
    _experienceController = TextEditingController(
      text: staff != null ? '${staff.experienceYears}' : '',
    );
    _avatarUrlController = TextEditingController(text: staff?.avatarUrl ?? '');
    _bioController = TextEditingController(text: staff?.bio ?? '');
    _galleryUrls.addAll(staff?.galleryUrls ?? const []);
    _isActive = staff?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _experienceController.dispose();
    _avatarUrlController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialStaff != null;

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.canPop()
              ? context.pop()
              : context.go('/employee-management');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Employee' : 'Add New Employee'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go('/employee-management'),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Employee Profile',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryDark,
                        ),
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _nameController,
                        label: 'Employee Full Name *',
                        prefixIcon: Icons.person_rounded,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Please enter employee name'
                                : null,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _roleController,
                        label: 'Job Title / Specialty *',
                        prefixIcon: Icons.badge_rounded,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Please enter job title'
                                : null,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _experienceController,
                        label: 'Years of Experience',
                        prefixIcon: Icons.workspace_premium_rounded,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _bioController,
                        label: 'Professional Bio',
                        prefixIcon: Icons.notes_rounded,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _isActive,
                        activeColor: AppColors.primary,
                        title: const Text(
                          'Active & Bookable',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryDark,
                          ),
                        ),
                        subtitle: const Text(
                          'Inactive employees will not be offered for new bookings.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMutedDark,
                          ),
                        ),
                        onChanged: (value) => setState(() => _isActive = value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Photos',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Use one clear profile photo and up to 8 portfolio photos.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMutedDark,
                        ),
                      ),
                      const SizedBox(height: 14),
                      BusinessImagePicker(
                        label: 'Main Profile Photo',
                        currentImageUrl: _avatarUrlController.text,
                        onPickImage: _pickAvatar,
                        onDeleteImage: _avatarUrlController.text.isEmpty
                            ? null
                            : _deleteAvatar,
                        isLoading:
                            _uploadProgress != null && _uploadLabel == 'Profile',
                      ),
                      if (_uploadProgress != null) ...[
                        const SizedBox(height: 10),
                        LinearProgressIndicator(value: _uploadProgress),
                        const SizedBox(height: 4),
                        Text(
                          '$_uploadLabel ${(100 * _uploadProgress!).round()}%',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMutedDark,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Portfolio Photos',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryDark,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed:
                                _galleryUrls.length >= 8 ? null : _pickGallery,
                            icon: const Icon(Icons.add_photo_alternate_rounded),
                            label: Text('${_galleryUrls.length}/8'),
                          ),
                        ],
                      ),
                      if (_galleryUrls.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.glassBgDark,
                            borderRadius: BorderRadius.circular(14),
                            border:
                                Border.all(color: AppColors.glassBorderDark),
                          ),
                          child: const Text(
                            'No portfolio photos yet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMutedDark,
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          height: 112,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _galleryUrls.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final url = _galleryUrls[index];
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      url,
                                      width: 100,
                                      height: 108,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: InkWell(
                                      onTap: () => _removeGalleryPhoto(url),
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Colors.black
                                              .withValues(alpha: 0.65),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close_rounded,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                if (isEditing) ...[
                  const SizedBox(height: 14),
                  GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.schedule_rounded,
                          color: AppColors.primaryLight),
                      title: const Text(
                        'Working Hours & Breaks',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryDark,
                        ),
                      ),
                      subtitle: const Text(
                        'Configure a different schedule for every day.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMutedDark,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push('/employee-schedule'),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                CustomButton(
                  text: isEditing ? 'Update Employee' : 'Add Employee to Team',
                  isLoading: _isLoading,
                  onPressed: _saveEmployee,
                ),
                const SizedBox(height: 24),
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

  Future<void> _pickAvatar() async {
    try {
      final businessId = await _businessId();
      setState(() {
        _uploadProgress = 0;
        _uploadLabel = 'Profile';
      });
      final url = await _media.pickAndUploadImage(
        storageFolder: 'businesses/$businessId/employees/$_staffId',
        onProgress: (progress) {
          if (mounted) setState(() => _uploadProgress = progress);
        },
      );
      if (url == null || !mounted) return;

      final oldUrl = _avatarUrlController.text;
      setState(() => _avatarUrlController.text = url);
      if (oldUrl.isNotEmpty && oldUrl != url) {
        await _media.deleteByUrl(oldUrl);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Photo upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploadProgress = null);
    }
  }

  Future<void> _pickGallery() async {
    final remaining = 8 - _galleryUrls.length;
    if (remaining <= 0) return;

    try {
      final businessId = await _businessId();
      setState(() {
        _uploadProgress = 0;
        _uploadLabel = 'Portfolio';
      });
      final urls = await _media.pickAndUploadMultipleImages(
        storageFolder: 'businesses/$businessId/employees/$_staffId',
        maxCount: remaining,
        onProgress: (current, total, progress) {
          if (mounted) {
            setState(() {
              _uploadLabel = 'Photo $current of $total';
              _uploadProgress = progress;
            });
          }
        },
      );
      if (urls.isNotEmpty && mounted) {
        setState(() => _galleryUrls.addAll(urls));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gallery upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploadProgress = null);
    }
  }

  Future<void> _deleteAvatar() async {
    final url = _avatarUrlController.text;
    setState(() => _avatarUrlController.clear());
    await _media.deleteByUrl(url);
  }

  Future<void> _removeGalleryPhoto(String url) async {
    setState(() => _galleryUrls.remove(url));
    try {
      await _media.deleteByUrl(url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not delete photo: $e')));
      }
    }
  }

  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final businessId = await _businessId();
      final expYears = int.tryParse(_experienceController.text.trim()) ?? 0;
      final existing = widget.initialStaff;

      final staff = existing == null
          ? StaffModel(
              id: _staffId,
              businessId: businessId,
              name: _nameController.text.trim(),
              roleTitle: _roleController.text.trim(),
              avatarUrl: _avatarUrlController.text.trim(),
              rating: 0,
              reviewCount: 0,
              experienceYears: expYears,
              isActive: _isActive,
              bio: _bioController.text.trim(),
              galleryUrls: List.of(_galleryUrls),
            )
          : existing.copyWith(
              name: _nameController.text.trim(),
              roleTitle: _roleController.text.trim(),
              avatarUrl: _avatarUrlController.text.trim(),
              experienceYears: expYears,
              isActive: _isActive,
              bio: _bioController.text.trim(),
              galleryUrls: List.of(_galleryUrls),
            );

      await ref.read(ownerEmployeesProvider.notifier).saveEmployee(staff);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existing != null
                ? 'Employee updated successfully.'
                : 'Employee added successfully.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      context.canPop()
          ? context.pop()
          : context.go('/employee-management');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save employee: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
