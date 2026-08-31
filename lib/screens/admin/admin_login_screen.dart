import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/user_model.dart';
import '../../providers/app_providers.dart';
import '../../providers/locale_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/glass_card.dart';

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

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleAdminLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError(context.tr('Please enter admin email and password.'));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await ref
          .read(authProvider.notifier)
          .login(email, password, requestedRole: UserRole.admin);

      if (!mounted) return;

      // Verify admin role — this is the critical security check.
      if (!user.isAdmin) {
        await ref.read(authProvider.notifier).logout();
        if (mounted) {
          _showError(
            context.tr(
              'You do not have administrative privileges to access this portal.',
            ),
          );
        }
        return;
      }

      // Verify email is verified
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null && !firebaseUser.emailVerified) {
        await ref.read(authProvider.notifier).logout();
        if (mounted) {
          _showError(context.tr('Admin email address must be verified.'));
        }
        return;
      }

      if (mounted) {
        context.go('/admin/dashboard');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        final message = switch (e.code) {
          'role-mismatch' => context.tr(
              'This account does not have administrator access.',
            ),
          'invalid-credential' ||
          'wrong-password' ||
          'user-not-found' =>
            context.tr('Invalid admin email or password.'),
          'too-many-requests' => context.tr(
              'Too many sign-in attempts. Please wait and try again.',
            ),
          'network-request-failed' => context.tr(
              'Network connection failed. Check your connection and try again.',
            ),
          _ => e.message ??
              context.tr('Admin authentication failed. Please try again.'),
        };
        _showError(message);
      }
    } catch (_) {
      if (mounted) {
        _showError(
          context.tr(
            'Admin sign in is unavailable right now. Please try again.',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider) ?? Localizations.localeOf(context);
    if (locale.languageCode != 'ar' && locale.languageCode != 'en') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(localeProvider.notifier).setLocale(const Locale('en'));
      });
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: Text(context.tr('Admin Sign In')),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(
                    value: 'en',
                    label: Text(locale.languageCode == 'ar'
                        ? 'الإنجليزية'
                        : 'English')),
                const ButtonSegment(value: 'ar', label: Text('العربية')),
              ],
              selected: {locale.languageCode == 'ar' ? 'ar' : 'en'},
              onSelectionChanged: (value) => ref
                  .read(localeProvider.notifier)
                  .setLocale(Locale(value.first)),
              showSelectedIcon: false,
            ),
          ),
        ],
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
                context.tr('Admin Sign In'),
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
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),
              GlassCard(
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _emailController,
                      label: context.tr('Email Address'),
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
                      text: context.tr('Admin Sign In'),
                      isLoading: _isLoading,
                      backgroundColor: AppColors.error,
                      onPressed: _isLoading ? null : _handleAdminLogin,
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
