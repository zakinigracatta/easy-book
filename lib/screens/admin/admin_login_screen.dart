import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_colors.dart';
import '../../l10n/l10n.dart';
import '../../providers/app_providers.dart';

/// Admin Sign In screen — web only.
///
/// Uses real Firebase Authentication and verifies that the signed-in user
/// has an admin or super_admin role. If the role doesn't match, the user
/// is signed out and shown an error.
///
/// There is intentionally NO "Register" link. Admin accounts must be
/// provisioned internally (Firebase Console or secure Cloud Function).
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
      _showError(l10nOf(context).invalidCredentials);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await ref.read(authProvider.notifier).login(
            email,
            password,
          );

      if (!mounted) return;

      // Verify admin role — this is the critical security check.
      if (!user.isAdmin) {
        await ref.read(authProvider.notifier).logout();
        if (mounted) {
          _showError(l10nOf(context).accessDeniedMessage);
        }
        return;
      }

      // Verify email is verified
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null && !firebaseUser.emailVerified) {
        await ref.read(authProvider.notifier).logout();
        if (mounted) {
          _showError(l10nOf(context).adminEmailNotVerified);
        }
        return;
      }

      if (mounted) {
        context.go('/admin/dashboard');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _showError(e.message ?? l10nOf(context).invalidCredentials);
      }
    } catch (e) {
      if (mounted) {
        _showError(l10nOf(context).unexpectedError);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
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
        title: Text(l10n.adminSignIn),
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
              Text(l10n.adminSignIn,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(l10n.adminSignInSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 28),
              GlassCard(
                child: Column(
                  children: [
                    CustomTextField(
                        controller: _emailController,
                        label: l10n.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 16),
                    CustomTextField(
                        controller: _passwordController,
                        label: l10n.password,
                        obscureText: true,
                        prefixIcon: Icons.lock_outline),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: l10n.adminSignIn,
                      isLoading: _isLoading,
                      backgroundColor: AppColors.error,
                      onPressed: _handleAdminLogin,
                    ),
                  ],
                ),
              ),
              // Intentionally NO "Register as Admin" link here.
              // Admin accounts are provisioned internally only.
            ],
          ),
        ),
      ),
    );
  }
}
