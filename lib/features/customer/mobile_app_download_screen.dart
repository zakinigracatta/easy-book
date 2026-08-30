import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_text.dart';

class MobileAppDownloadScreen extends StatelessWidget {
  const MobileAppDownloadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          title: const Text('Download Mobile App'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GlassCard(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(Icons.phone_iphone_rounded, size: 70),
                    const SizedBox(height: 16),
                    const GradientText('Easy Book for iOS & Android',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const Text(
                        'Get push updates, instant booking reminders, and offline wallet passes.',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                            icon: const Icon(Icons.apple),
                            label: const Text('App Store'),
                            onPressed: () {}),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                            icon: const Icon(Icons.android),
                            label: const Text('Play Store'),
                            onPressed: () {}),
                      ],
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
