import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/business_bottom_nav.dart';

class BookingCalendarScreen extends StatelessWidget {
  const BookingCalendarScreen({super.key});

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
          title: const Text('Booking Calendar'),
        ),
        body: Column(
          children: [
            CalendarDatePicker(
              initialDate: DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 30)),
              lastDate: DateTime.now().add(const Duration(days: 90)),
              onDateChanged: (d) {},
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: const [
                  GlassCard(
                    child: ListTile(
                      title: Text('10:00 AM - Sarah Jenkins'),
                      subtitle: Text('Royal Haircut & Beard Sculpting • Marcus'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: const BusinessBottomNav(currentIndex: 1),
      ),
    );
  }
}
