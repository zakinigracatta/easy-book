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

class BusinessRegisterScreen extends ConsumerStatefulWidget {
  const BusinessRegisterScreen({super.key});

  @override
  ConsumerState<BusinessRegisterScreen> createState() =>
      _BusinessRegisterScreenState();
}

class _BusinessRegisterScreenState
    extends ConsumerState<BusinessRegisterScreen> {
  final _businessNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _locationController = TextEditingController();
  final _picker = ImagePicker();
  final _media = MediaUploadService();

  String _selectedCategory = 'Barber';
  XFile? _pendingBusinessImage;
  Uint8List? _businessImagePreview;
  bool _isLoading = false;
  double? _uploadProgress;

  final List<String> _categories = [
    'Barber',
    'Hair Salon',
    'Spa & Relax',
    'Nails & Beauty',
    'Skin & Facial',
  ];

  @override
  void dispose() {
    _businessNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickBusinessImage() async {
    if (_isLoading) return;
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 88,
        maxWidth: 2200,
        maxHeight: 2200,
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
        _pendingBusinessImage = file;
        _businessImagePreview = bytes;
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
    if (_businessNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    var imageUploadFailed = false;

    try {
      final registeredUser =
          await ref.read(authProvider.notifier).registerBusinessOwner(
                businessName: _businessNameController.text.trim(),
                category: _selectedCategory,
                phone: _phoneController.text.trim(),
                email: _emailController.text.trim(),
                password: _passwordController.text,
                location: _locationController.text.trim(),
                businessImageUrl: null,
              );

      final pendingImage = _pendingBusinessImage;
      if (pendingImage != null) {
        try {
          if (mounted) setState(() => _uploadProgress = 0);
          final imageUrl = await _media.uploadXFile(
            pendingImage,
            storageFolder: 'businesses/${registeredUser.id}/profile',
            onProgress: (progress) {
              if (mounted) setState(() => _uploadProgress = progress);
            },
          );

          final firestore = FirebaseFirestore.instance;
          await firestore.collection('businesses').doc(registeredUser.id).set({
            'image_url': imageUrl,
            'updated_at': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          await firestore.collection('users').doc(registeredUser.id).set({
            'business_image_url': imageUrl,
            'updated_at': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          ref
              .read(authProvider.notifier)
              .setUser(registeredUser.copyWith(businessImageUrl: imageUrl));
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
                  ? 'Account created. The business photo could not be uploaded; you can add it from Business Management.'
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
              e.message ?? 'Authentication failed. Please check details.',
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
          title: const Text('Register Business Owner'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.storefront_rounded,
                  size: 60,
                  color: AppColors.accent,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Partner Account Creation',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Register your salon or spa. Saved in database with role "owner".',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMutedDark,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: _isLoading ? null : _pickBusinessImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: AppColors.glassBgDark,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.accent,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: _businessImagePreview != null
                                ? Image.memory(
                                    _businessImagePreview!,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(
                                    Icons.add_business_rounded,
                                    size: 42,
                                    color: AppColors.textMutedDark,
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: AppColors.accent,
                            radius: 16,
                            child: const Icon(
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
                    'Uploading business photo ${(100 * _uploadProgress!).round()}%',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        controller: _businessNameController,
                        label: 'Business Name',
                        prefixIcon: Icons.storefront_rounded,
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Business Category',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        dropdownColor: AppColors.cardDark,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.category_rounded, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        items: _categories
                            .map(
                              (cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedCategory = val);
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _emailController,
                        label: 'Business Email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Password',
                        obscureText: true,
                        prefixIcon: Icons.lock_outline_rounded,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _locationController,
                        label: 'Physical Address / Location',
                        prefixIcon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Register Business & Go to Dashboard',
                        backgroundColor: AppColors.accent,
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
                      'Already registered? ',
                      style: TextStyle(color: AppColors.textMutedDark),
                    ),
                    TextButton(
                      onPressed: () => context.push('/owner-login'),
                      child: const Text(
                        'Partner Sign In',
                        style: TextStyle(
                          color: AppColors.accent,
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
