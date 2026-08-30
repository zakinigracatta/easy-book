import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/app_providers.dart';
import '../../services/navigation_service.dart';
import '../../services/auth_failure.dart';
import '../../routes/role_routing.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.customer;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('يرجى إدخال البريد الإلكتروني وكلمة المرور.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final auth = ref.read(authProvider.notifier);
      final user = await auth.login(
        _emailController.text.trim(),
        _passwordController.text,
        requestedRole: _selectedRole,
      );

      final isVerified = await auth.isCurrentEmailVerified();
      if (!mounted) return;
      if (!isVerified) {
        context.go('/email-verification');
        return;
      }

      final pendingRoute = NavigationService().consumePendingRoute();
      if (user.isAdmin) {
        NavigationService().clearPendingRoute();
        context.go(RoleRouting.homeFor(user));
      } else if (user.role == UserRole.owner ||
          user.role == UserRole.businessOwner) {
        NavigationService().clearPendingRoute();
        context.go('/owner-dashboard');
      } else if (pendingRoute != null && pendingRoute.isNotEmpty) {
        if (context.canPop()) {
          context.pop(true);
        } else {
          context.go(pendingRoute);
        }
      } else {
        if (context.canPop()) {
          context.pop(true);
        } else {
          context.go('/home');
        }
      }
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
        title: const Text('تسجيل الدخول'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('مرحبًا بعودتك 👋',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('سجّل الدخول للوصول إلى بوابتك',
                  style: TextStyle(color: AppColors.textMutedDark)),
              const SizedBox(height: 24),

              // Role Toggle Segment
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedRole = UserRole.customer),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedRole == UserRole.customer
                              ? AppColors.primary
                              : AppColors.cardDark,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: _selectedRole == UserRole.customer
                                  ? AppColors.primary
                                  : AppColors.glassBorderDark),
                        ),
                        child: const Center(
                          child: Text('عميل',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedRole = UserRole.owner),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedRole == UserRole.owner
                              ? AppColors.accent
                              : AppColors.cardDark,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: _selectedRole == UserRole.owner
                                  ? AppColors.accent
                                  : AppColors.glassBorderDark),
                        ),
                        child: const Center(
                          child: Text('مالك صالون',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              GlassCard(
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _emailController,
                      label: 'البريد الإلكتروني / الهاتف',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _passwordController,
                      label: 'كلمة المرور',
                      obscureText: true,
                      prefixIcon: Icons.lock_outline_rounded,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'تسجيل الدخول',
                      isLoading: _isLoading,
                      backgroundColor: _selectedRole == UserRole.owner
                          ? AppColors.accent
                          : AppColors.primary,
                      onPressed: _handleLogin,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        child: const Text('نسيت كلمة المرور؟'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('التسجيل كعميل؟ ',
                          style: TextStyle(color: AppColors.textMutedDark)),
                      TextButton(
                        onPressed: () => context.push('/register'),
                        child: const Text('تسجيل عميل'),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('التسجيل كشريك؟ ',
                          style: TextStyle(color: AppColors.textMutedDark)),
                      TextButton(
                        onPressed: () => context.push('/business-register'),
                        child: const Text('تسجيل مالك صالون',
                            style: TextStyle(color: AppColors.accent)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
