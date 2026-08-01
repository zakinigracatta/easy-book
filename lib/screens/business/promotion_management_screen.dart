import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';

class PromotionManagementScreen extends StatelessWidget {
  const PromotionManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/owner-dashboard');
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
                context.go('/owner-dashboard');
              }
            },
          ),
          title: const Text('Promotions & Discounts'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            GlassCard(
              child: ListTile(
                title: Text('SUMMER30 - 30% OFF'),
                subtitle: Text('Valid on Skincare & Spa • 42 Uses'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
