import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_providers.dart';

class GoogleMapsExplorerScreen extends ConsumerWidget {
  const GoogleMapsExplorerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          title: const Text('Interactive Map Explorer'),
        ),
        body: Stack(
          children: [
            Container(
              color: Colors.blueGrey.shade900,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_rounded, size: 80, color: AppColors.accent),
                    SizedBox(height: 16),
                    Text('Google Maps Explorer Live Feed',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Executive Barber Lounge',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    const Text('0.4 miles away • 4.9 ★ (328 reviews)',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textMutedDark)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        final isLoggedIn = ref.read(authProvider) != null;

                        if (isLoggedIn) {
                          context.push('/booking');
                        } else {
                          context.push('/login');
                        }
                      },
                      child: const Text('Book Nearby Salon'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
