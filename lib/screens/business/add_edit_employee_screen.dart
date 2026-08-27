import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/l10n.dart';
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
    _galleryUrls.addAll(staff?.galleryUrls ?? []);
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
    final l10n = l10nOf(context);
    final isEditing = widget.initialStaff != null;

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.canPop() ? context.pop() : context.go('/employee-management');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? l10n.editEmployee : l10n.addNewEmployee),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go('/employee-management'),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GlassCard(
                  padding: EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.employeeProfile,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 14),
                      CustomTextField(
                        controller: _nameController,
                        label: l10n.employeeFullNameRequired,
                        prefixIcon: Icons.person_rounded,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? l10n.enterEmployeeName
                                : null,
                      ),
                      SizedBox(height: 12),
                      CustomTextField(
                        controller: _roleController,
                        label: l10n.jobTitleRequired,
                        prefixIcon: Icons.badge_rounded,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? l10n.enterJobTitle
                                : null,
                      ),
                      SizedBox(height: 12),
                      CustomTextField(
                        controller: _experienceController,
                        label: l10n.yearsOfExperience,
                        prefixIcon: Icons.workspace_premium_rounded,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 12),
                      CustomTextField(
                        controller: _bioController,
                        label: l10n.professionalBio,
                        prefixIcon: Icons.notes_rounded,
                        maxLines: 4,
                      ),
                      SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _isActive,
                        activeThumbColor: Colors.white,
                        activeTrackColor: AppColors.success,
                        title: Text(
                          l10n.activeAndBookable,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          l10n.inactiveEmployeeHelp,
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        onChanged: (value) => setState(() => _isActive = value),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14),
                GlassCard(
                  padding: EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.photos,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        l10n.employeePhotosHelp,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 14),
                      BusinessImagePicker(
                        label: l10n.mainProfilePhoto,
                        currentImageUrl: _avatarUrlController.text,
                        onPickImage: _pickAvatar,
                        onDeleteImage: _avatarUrlController.text.isEmpty
                            ? null
                            : _deleteAvatar,
                        isLoading: _uploadProgress != null &&
                            _uploadLabel == 'profile',
                      ),
                      if (_uploadProgress != null) ...[
                        SizedBox(height: 10),
                        LinearProgressIndicator(value: _uploadProgress),
                        SizedBox(height: 4),
                        Text(
                          l10n.uploadingPercent(
                              (100 * _uploadProgress!).round()),
                          style: TextStyle(
                            fontSize: 10,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.portfolioPhotos,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed:
                                _galleryUrls.length >= 8 ? null : _pickGallery,
                            icon: Icon(Icons.add_photo_alternate_rounded),
                            label: Text('${_galleryUrls.length}/8'),
                          ),
                        ],
                      ),
                      if (_galleryUrls.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Theme.of(context).colorScheme.outline),
                          ),
                          child: Text(
                            l10n.noPortfolioPhotos,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          height: 112,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _galleryUrls.length,
                            separatorBuilder: (_, __) => SizedBox(width: 8),
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
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Colors.black
                                              .withValues(alpha: 0.65),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
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
                  SizedBox(height: 14),
                  GlassCard(
                    padding: EdgeInsets.all(14),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.schedule_rounded,
                          color: AppColors.primaryLight),
                      title: Text(
                        l10n.workAndBreakHours,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        l10n.differentScheduleEachDay,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push('/employee-schedule'),
                    ),
                  ),
                ],
                SizedBox(height: 18),
                CustomButton(
                  text:
                      isEditing ? l10n.updateEmployee : l10n.addEmployeeToTeam,
                  isLoading: _isLoading,
                  onPressed: _saveEmployee,
                ),
                SizedBox(height: 24),
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
        _uploadLabel = 'profile';
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10nOf(context).imageUploadFailed(e.toString()))));
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
        _uploadLabel = 'portfolio';
      });
      final urls = await _media.pickAndUploadMultipleImages(
        storageFolder: 'businesses/$businessId/employees/$_staffId',
        maxCount: remaining,
        onProgress: (current, total, progress) {
          if (mounted) {
            setState(() {
              _uploadLabel = 'portfolio:$current/$total';
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text(l10nOf(context).portfolioUploadFailed(e.toString()))));
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10nOf(context).imageDeleteFailed(e.toString()))));
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
                ? l10nOf(context).employeeUpdatedSuccessfully
                : l10nOf(context).employeeAddedSuccessfully,
          ),
          backgroundColor: AppColors.success,
        ),
      );
      context.canPop() ? context.pop() : context.go('/employee-management');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10nOf(context).employeeSaveFailed(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
