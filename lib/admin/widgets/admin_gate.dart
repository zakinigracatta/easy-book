import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../routing/admin_access.dart';
import '../screens/admin_access_screens.dart';

class AdminGate extends ConsumerWidget {
  const AdminGate({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (AdminAccess.evaluate(
      user: ref.watch(authProvider),
      isWeb: kIsWeb,
    )) {
      AdminAccessDecision.allow => child,
      AdminAccessDecision.webOnly => const AdminWebOnlyScreen(),
      AdminAccessDecision.forbidden => const AdminForbiddenScreen(),
      AdminAccessDecision.signIn => const _AdminSignInRequired(),
    };
  }
}

class _AdminSignInRequired extends StatelessWidget {
  const _AdminSignInRequired();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('يرجى تسجيل الدخول من بوابة الإدارة.')),
      );
}
