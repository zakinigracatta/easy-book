import 'package:flutter/material.dart';

class AdminPayoutsScreen extends StatelessWidget {
  const AdminPayoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Payouts')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.payments_outlined, size: 58),
              SizedBox(height: 16),
              Text(
                'Payout management is not connected yet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'No payout request can be approved until a trusted payment provider and payout backend are enabled.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
