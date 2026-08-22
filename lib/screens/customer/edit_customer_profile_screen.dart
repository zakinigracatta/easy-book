
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/customer_profile_provider.dart';
import '../../services/media_upload_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/glass_card.dart';

class EditCustomerProfileScreen extends ConsumerStatefulWidget {
  const EditCustomerProfileScreen({super.key});

  @override
  ConsumerState<EditCustomerProfileScreen> createState() =>
      _EditCustomerProfileScreenState();
}

class _EditCustomerProfileScreenState
    extends ConsumerState<EditCustomerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _picker = ImagePicker();
  final _media = MediaUploadService();

  bool _hydrated = false;
  bool _isSaving = false;
  bool _removeAvatar = false;
  XFile? _pendingImage;
  Uint8List? _pendingImageBytes;
  UserModel? _loadedUser;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _hydrate(UserModel user) {
    if (_hydrated) return;
    _loadedUser = user;
    _nameController.text = user.fullName;
    _phoneController.text = user.phone;
    _hydrated = true;
  }

  Future<void> _pickImage() async {
    if (_isSaving) return;
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 88,
        maxWidth: 1800,
        maxHeight: 1800,
        requestFullMetadata: false,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        throw StateError('The selected image is empty.');
      }
      if (bytes.length > MediaUploadService.maxImageBytes) {
        throw StateError('Image must be smaller than 5 MB.');
      }

      if (!mounted) return;
      setState(() {
        _pendingImage = file;
        _pendingImageBytes = bytes;
        _removeAvatar = false;
      });
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[PROFILE_EDIT] Image selection failed: $e');
        debugPrintStack(stackTrace: st);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not select image: ${_errorMessage(e)}')),
        );
      }
    }
  }

  void _markAvatarForRemoval() {
    if (_isSaving) return;
    setState(() {
      _pendingImage = null;
      _pendingImageBytes = null;
      _removeAvatar = true;
    });
  }

  Future<void> _save() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;
    final current = _loadedUser;
    if (current == null) return;

    setState(() => _isSaving = true);

    String? uploadedUrl;
    try {
      if (kDebugMode) {
        debugPrint('[PROFILE_EDIT] Saving uid=${current.id}, role=${current.role}');
      }

      final pending = _pendingImage;
      if (pending != null) {
        uploadedUrl = await _media.uploadXFile(
          pending,
          storageFolder: 'users/${current.id}/profile',
        );
      }

      final updated = await ref
          .read(customerProfileServiceProvider)
          .updateCurrentCustomerProfile(
            fullName: _nameController.text,
            phone: _phoneController.text,
            avatarUrl: uploadedUrl,
            clearAvatar: _removeAvatar,
          );

      // The database update succeeded. Only now is it safe to remove the
      // previous Storage object. Cleanup failure must not undo a valid profile.
      final oldUrl = current.avatarUrl;
      final shouldDeleteOld = oldUrl != null &&
          oldUrl.trim().isNotEmpty &&
          (_removeAvatar ||
              (uploadedUrl != null && uploadedUrl != oldUrl.trim()));
      if (shouldDeleteOld) {
        try {
          await _media.deleteByUrl(oldUrl);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[PROFILE_EDIT] Old avatar cleanup skipped: $e');
          }
        }
      }

      ref.read(authProvider.notifier).setUser(updated);
      ref.invalidate(customerProfileProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } catch (e, st) {
      // If upload succeeded but the canonical Firestore update failed, delete
      // only the newly uploaded object so the previous saved profile stays safe.
      if (uploadedUrl != null) {
        try {
          await _media.deleteByUrl(uploadedUrl);
        } catch (_) {}
      }

      if (kDebugMode) {
        debugPrint('[PROFILE_EDIT] Save failed: $e');
        debugPrintStack(stackTrace: st);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not update profile: ${_errorMessage(e)}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 8),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _errorMessage(Object error) {
    if (error is FirebaseException) {
      final message = error.message?.trim();
      return message == null || message.isEmpty
          ? '[${error.code}] Firebase request failed.'
          : '[${error.code}] $message';
    }
    return error.toString();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(customerProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => _ErrorState(
          message: 'Unable to load your profile: ${_errorMessage(error)}',
          onRetry: () => ref.invalidate(customerProfileProvider),
        ),
        data: (user) {
          if (user == null) {
            return _ErrorState(
              message: 'Please sign in again to edit your profile.',
              onRetry: () => context.go('/login'),
              buttonLabel: 'Sign In',
            );
          }

          // Personal profile fields are safe for every authenticated account.
          // Firestore rules still prevent changing the protected role/email.
          _hydrate(user);
          final visibleAvatarUrl = _removeAvatar ? null : user.avatarUrl;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _ProfileAvatar(
                          imageBytes: _pendingImageBytes,
                          imageUrl: visibleAvatarUrl,
                          radius: 52,
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _isSaving ? null : _pickImage,
                              icon: const Icon(Icons.photo_library_rounded),
                              label: Text(
                                user.avatarUrl?.isNotEmpty == true ||
                                        _pendingImage != null
                                    ? 'Change Photo'
                                    : 'Add Photo',
                              ),
                            ),
                            if (!_removeAvatar &&
                                (user.avatarUrl?.isNotEmpty == true ||
                                    _pendingImage != null))
                              TextButton.icon(
                                onPressed:
                                    _isSaving ? null : _markAvatarForRemoval,
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: AppColors.error,
                                ),
                                label: const Text(
                                  'Remove',
                                  style: TextStyle(color: AppColors.error),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          prefixIcon: Icons.person_outline_rounded,
                          maxLength: 60,
                          validator: (value) {
                            final clean = value?.trim() ?? '';
                            if (clean.isEmpty) return 'Full name is required';
                            if (clean.length > 60) {
                              return 'Full name must be 60 characters or less';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          maxLength: 25,
                          validator: (value) {
                            if ((value ?? '').trim().length > 25) {
                              return 'Phone number must be 25 characters or less';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          child: Text(user.email),
                        ),
                        const SizedBox(height: 6),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Email changes require a separate verified account flow and are intentionally disabled here.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMutedDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Save Profile',
                    isLoading: _isSaving,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.imageBytes,
    required this.imageUrl,
    required this.radius,
  });

  final Uint8List? imageBytes;
  final String? imageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 3),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageBytes != null
          ? Image.memory(imageBytes!, fit: BoxFit.cover)
          : imageUrl != null && imageUrl!.trim().isNotEmpty
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _AvatarPlaceholder(),
                )
              : const _AvatarPlaceholder(),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.glassBgDark,
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: 50,
          color: AppColors.primaryLight,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
    this.buttonLabel = 'Retry',
  });

  final String message;
  final VoidCallback onRetry;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 42,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: Text(buttonLabel)),
          ],
        ),
      ),
    );
  }
}
