import 'package:flutter/material.dart';
import '../../widgets/glass_card.dart';
import '../../core/constants/app_colors.dart';

class SalonInventoryScreen extends StatelessWidget {
  const SalonInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inventory = [
      {
        'name': 'Organic Argan Shampoo 500ml',
        'stock': 24,
        'min': 10,
        'price': '\$18.00'
      },
      {
        'name': 'Matte Hair Clay 100g',
        'stock': 4,
        'min': 8,
        'price': '\$22.00'
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Salon Inventory & Stock')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: inventory.length,
        itemBuilder: (context, index) {
          final item = inventory[index];
          final isLow = (item['stock'] as int) < (item['min'] as int);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              child: ListTile(
                title: Text(item['name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    'In Stock: ${item['stock']} units • Price: ${item['price']}'),
                trailing: isLow
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Text('LOW STOCK',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      )
                    : const Icon(Icons.check_circle, color: AppColors.success),
              ),
            ),
          );
        },
      ),
    );
  }
}
