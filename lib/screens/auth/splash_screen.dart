import 'package:firebase_auth/firebase_auth.dart';
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
    Future<void>.microtask(_resolveStartupRoute);
  }

  Future<void> _resolveStartupRoute() async {
    final minimumSplash = Future<void>.delayed(const Duration(seconds: 2));

    String destination = '/home';
    try {
      final authService = ref.read(authServiceProvider);
      final profileFuture = authService.authStateChanges().first;

      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        await firebaseUser.reload();
      }

      final profile = await profileFuture;
      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser != null && !refreshedUser.emailVerified) {
        destination = '/verify-email';
      } else if (profile != null) {
        destination = switch (profile.role) {
          UserRole.owner || UserRole.businessOwner => '/owner-dashboard',
          UserRole.admin => '/admin-dashboard',
          UserRole.customer => '/home',
        };
      }
    } catch (_) {
      // Startup should never trap the user on a loading screen. Public home is
      // the safe fallback; protected routes still enforce authentication.
      destination = '/home';
    }

    await minimumSplash;
    if (mounted) context.go(destination);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF12002B),
              Color(0xFF3A0CA3),
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: 150,
            height: 150,
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.calendar_month_rounded,
                  size: 72,
                  color: Color(0xFF4F46E5),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
