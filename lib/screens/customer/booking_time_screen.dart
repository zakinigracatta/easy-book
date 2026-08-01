import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_colors.dart';

class BookingTimeScreen extends StatefulWidget {
  const BookingTimeScreen({super.key});

  @override
  State<BookingTimeScreen> createState() => _BookingTimeScreenState();
}

class _BookingTimeScreenState extends State<BookingTimeScreen> {
  String _selectedSlot = '10:00 AM';
  final slots = ['09:00 AM', '10:00 AM', '11:30 AM', '01:00 PM', '02:30 PM', '04:00 PM', '05:30 PM', '07:00 PM'];

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
          title: const Text('Step 3: Select Time Slot'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: slots.length,
                  itemBuilder: (context, index) {
                    final s = slots[index];
                    final isSel = _selectedSlot == s;
                    return GlassCard(
                      onTap: () => setState(() => _selectedSlot = s),
                      borderColor: isSel ? AppColors.primary : null,
                      backgroundColor: isSel ? AppColors.primary.withValues(alpha: 0.2) : null,
                      child: Center(
                        child: Text(s, style: TextStyle(fontWeight: FontWeight.bold, color: isSel ? AppColors.primary : Colors.white)),
                      ),
                    );
                  },
                ),
              ),
              CustomButton(
                text: 'Next: Review Booking',
                onPressed: () => context.push('/booking-confirmation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
