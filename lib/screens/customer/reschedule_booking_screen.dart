import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_button.dart';

class RescheduleBookingScreen extends StatefulWidget {
  const RescheduleBookingScreen({super.key});

  @override
  State<RescheduleBookingScreen> createState() => _RescheduleBookingScreenState();
}

class _RescheduleBookingScreenState extends State<RescheduleBookingScreen> {
  DateTime _newDate = DateTime.now().add(const Duration(days: 3));

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/my-bookings');
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
                context.go('/my-bookings');
              }
            },
          ),
          title: const Text('Reschedule Booking'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CalendarDatePicker(
                initialDate: _newDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 60)),
                onDateChanged: (d) => setState(() => _newDate = d),
              ),
              const Spacer(),
              CustomButton(
                text: 'Save New Date & Time',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment rescheduled!')));
                  context.go('/my-bookings');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
