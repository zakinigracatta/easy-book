import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _minSplashTimer;
  Timer? _profileTimeoutTimer;
  bool _navigationExecuted = false;
  bool _profileRecoveryRequired = false;

  @override
  void initState() {
    super.initState();

    if (kDebugMode) {
      debugPrint('[SPLASH] init');
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();

    _runStartupSequence();
  }

  Future<void> _runStartupSequence() async {
    if (kDebugMode) {
      debugPrint('[SPLASH] minimum 2s delay started');
    }

    final minDelayCompleter = Completer<void>();
    _minSplashTimer = Timer(const Duration(seconds: 2), () {
      if (!minDelayCompleter.isCompleted) {
        minDelayCompleter.complete();
      }
    });

    String destination = '/home';
    var needsProfileRecovery = false;

    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (kDebugMode) {
        debugPrint('[SPLASH] FirebaseAuth resolved');
        debugPrint('[SPLASH] Firebase user exists: ${firebaseUser != null}');
      }

      if (firebaseUser == null) {
        // Guest user path: do NOT wait for Firestore profile
        if (kDebugMode) {
          debugPrint('[SPLASH] destination resolved: guest');
        }
        destination = '/home';
      } else if (!firebaseUser.emailVerified) {
        if (kDebugMode) {
          debugPrint('[SPLASH] destination resolved: verify');
        }
        destination = '/verify-email';
      } else {
        // Authenticated user: resolve profile with a bounded timeout failsafe
        if (kDebugMode) {
          debugPrint('[SPLASH] profile resolution started');
        }

        UserModel? userModel = ref.read(authProvider);

        if (userModel == null) {
          if (kDebugMode) {
            debugPrint('[SPLASH] authProvider state: loading');
          }

          // Explicitly reload the profile so Retry still works after an
          // authStateChanges stream error. Bound the network wait so startup
          // can surface a recovery UI instead of hanging indefinitely.
          try {
            userModel = await ref
                .read(authProvider.notifier)
                .refreshCurrentProfile()
                .timeout(const Duration(seconds: 8));
          } catch (_) {
            if (kDebugMode) {
              debugPrint('[SPLASH] explicit profile refresh failed');
            }
          }

          if (userModel == null) {
            try {
              await _waitForProfile();
              userModel = ref.read(authProvider);
            } catch (_) {
              if (kDebugMode) {
                debugPrint('[SPLASH] profile resolution failed');
              }
            }
          }
        }

        if (userModel != null) {
          if (kDebugMode) {
            debugPrint('[SPLASH] authProvider state: data');
            debugPrint('[SPLASH] profile resolution completed');
          }

          if (userModel.role == UserRole.owner ||
              userModel.role == UserRole.businessOwner) {
            if (kDebugMode) {
              debugPrint('[SPLASH] destination resolved: owner');
            }
            destination = '/owner-dashboard';
          } else if (userModel.isAdmin) {
            if (kDebugMode) {
              debugPrint(
                  '[SPLASH] destination resolved: admin');
            }
            destination = kIsWeb ? '/admin/dashboard' : '/admin-web-only';
          } else {
            if (kDebugMode) {
              debugPrint('[SPLASH] destination resolved: customer');
            }
            destination = '/home';
          }
        } else {
          // A Firebase session exists, but its role/profile is unresolved.
          // Do not silently classify the account as a customer: that can send
          // owner/admin sessions to the wrong portal on a slow network.
          if (kDebugMode) {
            debugPrint('[SPLASH] profile resolution completed/failed');
            debugPrint('[SPLASH] destination resolved: auth recovery');
          }
          needsProfileRecovery = true;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SPLASH] profile resolution completed/failed');
        debugPrint('[SPLASH] startup resolution error: $e');
      }
      if (FirebaseAuth.instance.currentUser == null) {
        destination = '/home';
      } else {
        needsProfileRecovery = true;
      }
    }

    // Await the remainder of the minimum 2-second branding splash delay
    await minDelayCompleter.future;

    if (kDebugMode) {
      debugPrint('[SPLASH] minimum delay completed');
    }

    if (!mounted || _navigationExecuted) return;

    if (needsProfileRecovery) {
      setState(() => _profileRecoveryRequired = true);
      return;
    }

    _navigationExecuted = true;

    if (kDebugMode) {
      debugPrint('[SPLASH] navigation executed');
    }

    context.go(destination);
  }

  Future<void> _waitForProfile() async {
    if (ref.read(authProvider) != null) return;

    final completer = Completer<void>();
    ProviderSubscription<UserModel?>? subscription;

    _profileTimeoutTimer = Timer(const Duration(seconds: 3), () {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    subscription = ref.listenManual<UserModel?>(
      authProvider,
      (previous, next) {
        if (next != null && !completer.isCompleted) {
          completer.complete();
        }
      },
      fireImmediately: true,
    );

    await completer.future;
    _profileTimeoutTimer?.cancel();
    subscription.close();
  }

  @override
  void dispose() {
    _minSplashTimer?.cancel();
    _profileTimeoutTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_profileRecoveryRequired) {
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
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  margin: const EdgeInsets.all(24),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cloud_off_rounded,
                          size: 52,
                          color: Color(0xFF4F46E5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.tr('Unable to restore your account profile.'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.tr(
                            'Check your connection and retry. Your account has not been signed out.',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () {
                              setState(() {
                                _profileRecoveryRequired = false;
                                _navigationExecuted = false;
                              });
                              _runStartupSequence();
                            },
                            child: Text(context.tr('Retry')),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              if (!mounted) return;
                              context.go('/home');
                            },
                            child: Text(context.tr('Sign out')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
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
        ),
      ),
    );
  }
}
