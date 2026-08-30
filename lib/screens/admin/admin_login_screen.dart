import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_failure.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل البريد الإلكتروني وكلمة المرور.')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = await ref.read(authProvider.notifier).login(
            _emailController.text,
            _passwordController.text,
          );
      if (!user.isAdmin) {
        await ref.read(authProvider.notifier).logout();
        throw const AuthFailure(
          'role-mismatch',
          'هذا الحساب غير مخول للوصول إلى بوابة الإدارة.',
        );
      }
      if (mounted) context.go('/admin');
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: const Text('دخول بوابة الإدارة'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.admin_panel_settings_rounded,
                  size: 70, color: AppColors.error),
              const SizedBox(height: 16),
              const Text('تسجيل دخول المدير العام',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('إدارة المنصة والتحقق من الشركاء والتحويلات',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 28),
              GlassCard(
                child: Column(
                  children: [
                    CustomTextField(
                        controller: _emailController,
                        label: 'البريد الإلكتروني للمدير',
                        prefixIcon: Icons.email_outlined),
                    const SizedBox(height: 16),
                    CustomTextField(
                        controller: _passwordController,
                        label: 'كلمة المرور',
                        obscureText: true,
                        prefixIcon: Icons.lock_outline),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'دخول مركز الإدارة',
                      isLoading: _isLoading,
                      backgroundColor: AppColors.error,
                      onPressed: _login,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
