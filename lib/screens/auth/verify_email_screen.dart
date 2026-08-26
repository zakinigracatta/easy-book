import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/user_model.dart';
import '../../providers/app_providers.dart';
import '../../services/navigation_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glass_card.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _isResending = false;
  bool _isChecking = false;

  Future<void> _handleResendEmail() async {
    if (_isResending) return;

    setState(() => _isResending = true);
    try {
      await ref.read(authProvider.notifier).resendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr('Verification email sent! Please check your inbox.'),
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr(
                'Unable to resend the verification email. Please try again.',
              ),
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr(
                'Unable to resend the verification email. Please try again.',
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _handleCheckVerification() async {
    if (_isChecking) return;

    setState(() => _isChecking = true);
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        if (mounted) context.go('/login');
        return;
      }

      await firebaseUser.reload();
      if (!mounted) return;

      final refreshedUser = FirebaseAuth.instance.currentUser;
      if (refreshedUser == null) {
        context.go('/login');
        return;
      }

      if (!refreshedUser.emailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr(
                'Email is not verified yet. Please check your inbox or spam folder.',
              ),
            ),
          ),
        );
        return;
      }

      UserModel? profile = ref.read(authProvider);
      if (profile == null) {
        try {
          profile = await ref.read(authServiceProvider).authStateChanges().first;
          if (profile != null) {
            ref.read(authProvider.notifier).setUser(profile);
          }
        } catch (_) {
          // Privileged destinations remain guarded by the router.
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('Email verified successfully!'))),
      );

      final role = profile?.role ?? UserRole.customer;
      if (role == UserRole.owner || role == UserRole.businessOwner) {
        NavigationService().clearPendingRoute();
        context.go('/owner-dashboard');
        return;
      }

      if (role == UserRole.admin) {
        NavigationService().clearPendingRoute();
        context.go('/admin-dashboard');
        return;
      }

      final pendingRoute = NavigationService().consumePendingRoute();
      context.go(
        pendingRoute != null && pendingRoute.isNotEmpty
            ? pendingRoute
            : '/home',
      );
    } on FirebaseAuthException catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr(
                'Unable to verify your email status. Please try again.',
              ),
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr(
                'Unable to verify your email status. Please try again.',
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Future<void> _handleLogout() async {
    NavigationService().clearPendingRoute();
    await ref.read(authProvider.notifier).logout();
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final email =
        FirebaseAuth.instance.currentUser?.email ?? context.tr('your email address');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleLogout();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('Verify Email Address')),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(Icons.logout_rounded),
              tooltip: context.tr('Logout'),
              onPressed: _handleLogout,
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                Icon(
                  Icons.mark_email_unread_rounded,
                  size: 80,
                  color: AppColors.primary,
                ),
                SizedBox(height: 20),
                Text(
                  context.tr('Verify Your Email'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  context.tr(
                    'We sent a verification link to:\n{email}',
                    params: {'email': email},
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 32),
                GlassCard(
                  child: Column(
                    children: [
                      Text(
                        context.tr(
                          'Please check your email inbox and click the verification link before proceeding.',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 24),
                      CustomButton(
                        text: context.tr("I've verified my email"),
                        isLoading: _isChecking,
                        onPressed: _isChecking ? null : _handleCheckVerification,
                      ),
                      SizedBox(height: 12),
                      CustomButton(
                        text: context.tr('Resend verification email'),
                        isLoading: _isResending,
                        isOutlined: true,
                        onPressed: _isResending ? null : _handleResendEmail,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                TextButton.icon(
                  onPressed: _handleLogout,
                  icon: Icon(
                    Icons.logout_rounded,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  label: Text(
                    context.tr('Logout / Use another account'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
