import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/user_model.dart';
import '../../providers/app_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final results = await Future.wait<Object?>([
        Future<void>.delayed(const Duration(milliseconds: 900)),
        ref.read(authProvider.notifier).restoreSession(),
      ]);
      final user = results[1] as UserModel?;
      if (!mounted) return;

      if (user == null) {
        context.go('/welcome');
        return;
      }

      final isVerified =
          await ref.read(authProvider.notifier).isCurrentEmailVerified();
      if (!mounted) return;
      if (!isVerified) {
        context.go('/email-verification');
      } else if (user.isAdmin) {
        context.go('/admin');
      } else if (user.role == UserRole.owner ||
          user.role == UserRole.businessOwner) {
        context.go('/owner-dashboard');
      } else {
        context.go('/home');
      }
    } catch (_) {
      if (mounted) context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [Color(0xff12002B), Color(0xff3A0CA3)]
                : const [Color(0xFFF7F8FC), Color(0xFFEDE9FE)],
          ),
        ),
        child: Center(
          child: Container(
            width: 150,
            height: 150,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.26 : 0.10),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset('assets/logo.png', fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}
