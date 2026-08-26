import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/user_model.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/glass_card.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAdminLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Please enter admin email and password.')),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).login(
            email,
            password,
            requestedRole: UserRole.admin,
          );

      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) await firebaseUser.reload();
      if (!mounted) return;

      final refreshedUser = FirebaseAuth.instance.currentUser;
      if (refreshedUser == null) {
        throw FirebaseAuthException(code: 'no-current-user');
      }

      if (!refreshedUser.emailVerified) {
        context.go('/verify-email');
        return;
      }

      context.go('/admin-dashboard');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final message = switch (e.code) {
        'role-mismatch' =>
          context.tr('This account does not have administrator access.'),
        'invalid-credential' || 'wrong-password' || 'user-not-found' =>
          context.tr('Invalid admin email or password.'),
        'too-many-requests' => context.tr(
            'Too many sign-in attempts. Please wait and try again.',
          ),
        'network-request-failed' => context.tr(
            'Network connection failed. Check your connection and try again.',
          ),
        _ => context.tr('Admin authentication failed. Please try again.'),
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'Admin sign in is unavailable right now. Please try again.',
            ),
          ),
        ),
      );
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
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: Text(context.tr('Admin Portal Login')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.admin_panel_settings_rounded,
                size: 70,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('Super Admin Sign In'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr(
                  'Platform management, partner verification & payouts',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 28),
              GlassCard(
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _emailController,
                      label: context.tr('Admin Email'),
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _passwordController,
                      label: context.tr('Password'),
                      obscureText: true,
                      prefixIcon: Icons.lock_outline,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: context.tr('Enter Admin Center'),
                      backgroundColor: AppColors.error,
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _handleAdminLogin,
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
