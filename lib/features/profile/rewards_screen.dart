import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.canPop() ? context.pop() : context.go('/profile');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/profile'),
          ),
          title: const Text('Loyalty Rewards'),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.stars_outlined, size: 58),
                SizedBox(height: 16),
                Text(
                  'Rewards are not connected yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Points, tiers, and redeemable rewards will appear here after the loyalty backend is enabled.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
