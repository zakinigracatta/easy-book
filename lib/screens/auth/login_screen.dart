import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/app_providers.dart';
import '../../services/navigation_service.dart';

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
        const SnackBar(content: Text('Please enter your email and password.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await ref.read(authProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
            requestedRole: _selectedRole,
          );

      if (mounted) {
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          await firebaseUser.reload();
          if (!mounted) return;
          final refreshedUser = FirebaseAuth.instance.currentUser;
          if (refreshedUser != null && !refreshedUser.emailVerified) {
            context.go('/verify-email');
            return;
          }
        }

        final pendingRoute = NavigationService().consumePendingRoute();
        if (user.role == UserRole.owner ||
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
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Authentication failed.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('An error occurred during sign in: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
        title: const Text('Sign In'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Welcome Back 👋',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Sign in to access your portal',
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
                          child: Text('Customer',
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
                          child: Text('Business Owner',
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
                      label: 'Email / Phone',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Password',
                      obscureText: true,
                      prefixIcon: Icons.lock_outline_rounded,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                              color: AppColors.textMutedDark,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Sign In',
                      isLoading: _isLoading,
                      backgroundColor: _selectedRole == UserRole.owner
                          ? AppColors.accent
                          : AppColors.primary,
                      onPressed: _handleLogin,
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
                      const Text('Register as Customer? ',
                          style: TextStyle(color: AppColors.textMutedDark)),
                      TextButton(
                        onPressed: () => context.push('/register'),
                        child: const Text('Customer Register'),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Register as Partner? ',
                          style: TextStyle(color: AppColors.textMutedDark)),
                      TextButton(
                        onPressed: () => context.push('/business-register'),
                        child: const Text('Owner Register',
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
