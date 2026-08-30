import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminWebOnlyScreen extends StatelessWidget {
  const AdminWebOnlyScreen({super.key});

  @override
  Widget build(BuildContext context) => _AccessMessage(
        icon: Icons.language_rounded,
        title: 'بوابة الإدارة متاحة على الويب فقط',
        message:
            'لحماية أدوات الإدارة وتقديم تجربة مناسبة، افتح Easy Book من متصفح على جهاز كمبيوتر أو جهاز لوحي.',
        actionLabel: 'العودة',
        onPressed: () => context.go('/welcome'),
      );
}

class AdminForbiddenScreen extends StatelessWidget {
  const AdminForbiddenScreen({super.key});

  @override
  Widget build(BuildContext context) => _AccessMessage(
        icon: Icons.lock_outline_rounded,
        title: 'ليس لديك صلاحية الوصول',
        message: 'هذا القسم مخصص لحسابات إدارة Easy Book المعتمدة.',
        actionLabel: 'العودة للرئيسية',
        onPressed: () => context.go('/home'),
      );
}

class _AccessMessage extends StatelessWidget {
  const _AccessMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon,
                    size: 72, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 24),
                Text(title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
                const SizedBox(height: 12),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 28),
                FilledButton(onPressed: onPressed, child: Text(actionLabel)),
              ]),
            ),
          ),
        ),
      );
}
