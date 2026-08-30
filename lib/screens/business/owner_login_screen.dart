import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/user_model.dart';
import '../../providers/app_providers.dart';
import '../../services/auth_failure.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/glass_card.dart';

class OwnerLoginScreen extends ConsumerStatefulWidget {
  const OwnerLoginScreen({super.key});

  @override
  ConsumerState<OwnerLoginScreen> createState() => _OwnerLoginScreenState();
}

class _OwnerLoginScreenState extends ConsumerState<OwnerLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('يرجى إدخال البريد الإلكتروني وكلمة المرور.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final auth = ref.read(authProvider.notifier);
      await auth.login(
        _emailController.text.trim(),
        _passwordController.text,
        requestedRole: UserRole.owner,
      );
      final isVerified = await auth.isCurrentEmailVerified();
      if (!mounted) return;
      if (!isVerified) {
        context.go('/email-verification');
        return;
      }
      context.go('/owner-dashboard');
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
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/welcome'),
        ),
        title: const Text('دخول بوابة الأعمال'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.storefront_rounded,
                  size: 70, color: AppColors.accent),
              const SizedBox(height: 16),
              const Text('تسجيل دخول شريك الصالون',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('إدارة المواعيد وجداول الموظفين والمبيعات',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 28),
              GlassCard(
                child: Column(
                  children: [
                    CustomTextField(
                        controller: _emailController,
                        label: 'بريد الصالون',
                        prefixIcon: Icons.email_outlined),
                    const SizedBox(height: 16),
                    CustomTextField(
                        controller: _passwordController,
                        label: 'كلمة المرور',
                        obscureText: true,
                        prefixIcon: Icons.lock_outline),
                    const SizedBox(height: 24),
                    CustomButton(
                        text: 'فتح لوحة تحكم الشريك',
                        backgroundColor: AppColors.accent,
                        isLoading: _isLoading,
                        onPressed: _handleLogin),
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
