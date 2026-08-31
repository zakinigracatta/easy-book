import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/user_model.dart';
import '../../providers/app_providers.dart';
import '../../providers/locale_provider.dart';
import '../../features/admin/admin_portal_shell.dart';

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
    final isArabic = locale.languageCode == 'ar';
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth >= 900;
            final form = _AdminLoginForm(
              emailController: _emailController,
              passwordController: _passwordController,
              isLoading: _isLoading,
              onSubmit: _handleAdminLogin,
            );
            return Stack(
              children: [
                if (desktop)
                  Row(
                    children: [
                      const Expanded(flex: 11, child: _AdminBrandPanel()),
                      Expanded(
                        flex: 9,
                        child: Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 64,
                              vertical: 72,
                            ),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 470),
                              child: form,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 92, 22, 32),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 470),
                        child: form,
                      ),
                    ),
                  ),
                PositionedDirectional(
                  top: 20,
                  start: 20,
                  child: _TopIconButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: adminText(context, 'Back', 'رجوع'),
                    onPressed: () =>
                        context.canPop() ? context.pop() : context.go('/home'),
                  ),
                ),
                PositionedDirectional(
                  top: 20,
                  end: 20,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(color: Color(0x140F172A), blurRadius: 18),
                      ],
                    ),
                    child: Row(
                      children: [
                        _LocaleButton(
                          label: isArabic ? 'الإنجليزية' : 'English',
                          selected: !isArabic,
                          onTap: () => ref
                              .read(localeProvider.notifier)
                              .setLocale(const Locale('en')),
                        ),
                        _LocaleButton(
                          label: 'العربية',
                          selected: isArabic,
                          onTap: () => ref
                              .read(localeProvider.notifier)
                              .setLocale(const Locale('ar')),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AdminBrandPanel extends StatelessWidget {
  const _AdminBrandPanel();

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(56),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F1D40), Color(0xFF1D4ED8)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.auto_stories_rounded,
                  color: Color(0xFF1D4ED8), size: 31),
            ),
            const Spacer(),
            Text(
              adminText(context, 'Easy Book', 'إيزي بوك'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w800,
                letterSpacing: -.8,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              adminText(
                context,
                'A secure workspace to manage partners, approvals and platform operations.',
                'مساحة عمل آمنة لإدارة الشركاء والاعتمادات وعمليات المنصة.',
              ),
              style: const TextStyle(
                color: Color(0xFFD7E3FF),
                fontSize: 18,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 42),
            Row(
              children: [
                const Icon(Icons.verified_user_outlined,
                    color: Color(0xFF93C5FD)),
                const SizedBox(width: 10),
                Text(
                  adminText(context, 'Protected administrator access',
                      'دخول محمي للمسؤولين'),
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      );
}

class _AdminLoginForm extends StatelessWidget {
  const _AdminLoginForm({
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onSubmit,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            adminText(context, 'Welcome back', 'مرحبًا بعودتك'),
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            adminText(context, 'Sign in to continue to the Admin Portal.',
                'سجّل الدخول للمتابعة إلى بوابة الإدارة.'),
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 36),
          _LoginField(
            controller: emailController,
            label: adminText(context, 'Email address', 'البريد الإلكتروني'),
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 18),
          _LoginField(
            controller: passwordController,
            label: adminText(context, 'Password', 'كلمة المرور'),
            icon: Icons.lock_outline_rounded,
            obscureText: true,
            onSubmitted: (_) => isLoading ? null : onSubmit(),
          ),
          const SizedBox(height: 26),
          SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: isLoading ? null : onSubmit,
              icon: isLoading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.login_rounded),
              label: Text(
                adminText(context, 'Sign in securely', 'تسجيل الدخول الآمن'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1D4ED8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_rounded,
                  size: 15, color: Color(0xFF94A3B8)),
              const SizedBox(width: 7),
              Text(
                adminText(context, 'Authorized administrators only',
                    'للمسؤولين المصرّح لهم فقط'),
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      );
}

class _LoginField extends StatelessWidget {
  const _LoginField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        onSubmitted: onSubmitted,
        style: const TextStyle(color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 19),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
          ),
        ),
      );
}

class _LocaleButton extends StatelessWidget {
  const _LocaleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF1D4ED8) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF475569),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
}

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          boxShadow: const [
            BoxShadow(color: Color(0x140F172A), blurRadius: 18),
          ],
        ),
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: Icon(icon, color: const Color(0xFF334155)),
        ),
      );
}
