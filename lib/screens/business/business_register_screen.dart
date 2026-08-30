import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../services/auth_failure.dart';

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

  String _selectedCategory = 'حلاقة';
  final String _businessImageUrl =
      'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&w=600&q=80';
  bool _isLoading = false;

  final List<String> _categories = [
    'حلاقة',
    'صالون شعر',
    'سبا واسترخاء',
    'أظافر وتجميل',
    'عناية بالبشرة والوجه',
  ];

  Future<void> _handleRegister() async {
    if (_businessNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إكمال جميع الحقول المطلوبة.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).registerBusinessOwner(
            businessName: _businessNameController.text.trim(),
            category: _selectedCategory,
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            location: _locationController.text.trim(),
            businessImageUrl: _businessImageUrl,
          );

      var verificationSent = true;
      try {
        await ref.read(authProvider.notifier).sendEmailVerification();
      } catch (error) {
        verificationSent = false;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم إنشاء الحساب، لكن تعذر إرسال رسالة التحقق: '
                '${authErrorMessage(error)}',
              ),
            ),
          );
        }
      }
      if (!mounted) return;
      if (verificationSent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تم إنشاء الحساب. يرجى التحقق من بريدك للمتابعة.')),
        );
      }
      context.go('/email-verification?sent=$verificationSent');
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authErrorMessage(error))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _locationController.dispose();
    super.dispose();
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
          title: const Text('تسجيل مالك النشاط'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.storefront_rounded,
                    size: 60, color: AppColors.accent),
                const SizedBox(height: 12),
                const Text(
                  'إنشاء حساب الشريك',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'سجّل صالونك أو السبا. سيُحفظ الحساب في قاعدة البيانات بصفة مالك.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: AppColors.textMutedDark, fontSize: 13),
                ),
                const SizedBox(height: 24),

                // Image Picker / Preview Widget
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.accent, width: 2),
                          image: DecorationImage(
                            image: NetworkImage(_businessImageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: AppColors.accent,
                          radius: 16,
                          child: const Icon(Icons.camera_alt_rounded,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        controller: _businessNameController,
                        label: 'اسم النشاط',
                        prefixIcon: Icons.storefront_rounded,
                      ),
                      const SizedBox(height: 14),

                      // Category Selection Dropdown
                      const Text('فئة النشاط',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryDark)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        dropdownColor: AppColors.cardDark,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.category_rounded, size: 20),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        items: _categories
                            .map((cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)))
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
                        label: 'رقم الهاتف',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _emailController,
                        label: 'بريد النشاط',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _passwordController,
                        label: 'كلمة المرور',
                        obscureText: true,
                        prefixIcon: Icons.lock_outline_rounded,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _locationController,
                        label: 'العنوان الفعلي / الموقع',
                        prefixIcon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'تسجيل النشاط والانتقال إلى لوحة التحكم',
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
                    const Text('مسجل بالفعل؟ ',
                        style: TextStyle(color: AppColors.textMutedDark)),
                    TextButton(
                      onPressed: () => context.push('/owner-login'),
                      child: const Text('تسجيل دخول الشريك',
                          style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold)),
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
