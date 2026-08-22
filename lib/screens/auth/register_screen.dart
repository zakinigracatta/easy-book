import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/app_providers.dart';
import '../../services/media_upload_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/glass_card.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _picker = ImagePicker();
  final _media = MediaUploadService();

  XFile? _pendingProfileImage;
  Uint8List? _profileImagePreview;
  bool _isLoading = false;
  double? _uploadProgress;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    if (_isLoading) return;
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
        _pendingProfileImage = file;
        _profileImagePreview = bytes;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not select image: $e')),
        );
      }
    }
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter name, email, and password.'),
        ),
      );
      return;
    }

    if (name.length > 60) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Full name must be 60 characters or less.'),
        ),
      );
      return;
    }

    if (email.length > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email address must be 100 characters or less.'),
        ),
      );
      return;
    }

    if (phone.length > 25) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number must be 25 characters or less.'),
        ),
      );
      return;
    }

    if (password.length > 128) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be 128 characters or less.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    var imageUploadFailed = false;

    try {
      final registeredUser =
          await ref.read(authProvider.notifier).registerCustomer(
                name: name,
                phone: phone,
                email: email,
                password: password,
                profileImageUrl: null,
              );

      final pendingImage = _pendingProfileImage;
      if (pendingImage != null) {
        try {
          if (mounted) setState(() => _uploadProgress = 0);
          final imageUrl = await _media.uploadXFile(
            pendingImage,
            storageFolder: 'users/${registeredUser.id}/profile',
            onProgress: (progress) {
              if (mounted) setState(() => _uploadProgress = progress);
            },
          );

          await FirebaseFirestore.instance
              .collection('users')
              .doc(registeredUser.id)
              .set({
            'avatar_url': imageUrl,
            'profile_image': imageUrl,
            'updated_at': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          final firebaseUser = FirebaseAuth.instance.currentUser;
          if (firebaseUser != null) {
            await firebaseUser.updatePhotoURL(imageUrl);
          }

          ref
              .read(authProvider.notifier)
              .setUser(registeredUser.copyWith(avatarUrl: imageUrl));
        } catch (_) {
          imageUploadFailed = true;
        } finally {
          if (mounted) setState(() => _uploadProgress = null);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              imageUploadFailed
                  ? 'Account created. The profile photo could not be uploaded; you can add it later.'
                  : 'Registration successful! Please verify your email.',
            ),
          ),
        );
        context.go('/verify-email');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.message ??
                  'Authentication failed. Please check your details.',
            ),
          ),
        );
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.message ?? 'Database error occurred during registration.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _uploadProgress = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/welcome');
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
                context.go('/welcome');
              }
            },
          ),
          title: const Text('Customer Registration'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 60,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Create Customer Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Register to book services. Saved in database with role "customer".',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMutedDark,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: _isLoading ? null : _pickProfileImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.glassBgDark,
                          backgroundImage: _profileImagePreview != null
                              ? MemoryImage(_profileImagePreview!)
                              : null,
                          child: _profileImagePreview == null
                              ? const Icon(
                                  Icons.person_rounded,
                                  size: 48,
                                  color: AppColors.textMutedDark,
                                )
                              : null,
                        ),
                        const Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: AppColors.primary,
                            radius: 16,
                            child: Icon(
                              Icons.camera_alt_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap the photo to choose an image from your phone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMutedDark,
                  ),
                ),
                if (_uploadProgress != null) ...[
                  const SizedBox(height: 10),
                  LinearProgressIndicator(value: _uploadProgress),
                  const SizedBox(height: 4),
                  Text(
                    'Uploading profile photo ${(100 * _uploadProgress!).round()}%',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMutedDark,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                GlassCard(
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        prefixIcon: Icons.person_outline,
                        maxLength: 60,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        maxLength: 25,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        maxLength: 100,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Password',
                        obscureText: true,
                        prefixIcon: Icons.lock_outline_rounded,
                        maxLength: 128,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Register & Go to Customer Home',
                        isLoading: _isLoading,
                        onPressed: _handleRegister,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: AppColors.textMutedDark),
                    ),
                    TextButton(
                      onPressed: () => context.push('/login'),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
