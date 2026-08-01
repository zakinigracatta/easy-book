import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/customer_bottom_nav.dart';
import '../../theme/app_colors.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookings = [
      {'salon': 'Executive Barber Lounge', 'service': 'Royal Haircut & Beard Trim', 'time': 'Tomorrow at 10:00 AM', 'status': 'Confirmed', 'price': '\$65.00'},
      {'salon': 'Royal Spa & Wellness', 'service': 'Deep Facial Massage', 'time': 'Aug 14 at 2:00 PM', 'status': 'Pending', 'price': '\$90.00'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 90),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final b = bookings[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: GlassCard(
              onTap: () => context.push('/booking-details'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(b['salon']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: b['status'] == 'Confirmed' ? AppColors.success.withValues(alpha: 0.2) : AppColors.warning.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(b['status']!, style: TextStyle(color: b['status'] == 'Confirmed' ? AppColors.success : AppColors.warning, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('${b['service']} • ${b['time']}'),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(b['price']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                      Row(
                        children: [
                          OutlinedButton(onPressed: () => context.push('/reschedule-booking'), child: const Text('Reschedule', style: TextStyle(fontSize: 11))),
                          const SizedBox(width: 8),
                          OutlinedButton(onPressed: () => context.push('/cancel-booking'), child: const Text('Cancel', style: TextStyle(fontSize: 11, color: AppColors.error))),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 2),
    );
  }
}
