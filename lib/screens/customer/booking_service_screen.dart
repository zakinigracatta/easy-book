import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_button.dart';

class BookingServiceScreen extends StatefulWidget {
  const BookingServiceScreen({super.key});

  @override
  State<BookingServiceScreen> createState() => _BookingServiceScreenState();
}

class _BookingServiceScreenState extends State<BookingServiceScreen> {
  String _selectedService = 'Royal Haircut & Beard Sculpting';

  @override
  Widget build(BuildContext context) {
    final services = [
      {'name': 'Royal Haircut & Beard Sculpting', 'price': '\$65.00', 'time': '45 mins'},
      {'name': 'Hot Towel Shave', 'price': '\$45.00', 'time': '30 mins'},
      {'name': 'Deep Facial Spa Treatment', 'price': '\$90.00', 'time': '60 mins'},
    ];

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
          title: const Text('Step 1: Select Service'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: services.map((s) {
                    final isSel = _selectedService == s['name'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        onTap: () => setState(() => _selectedService = s['name']!),
                        borderColor: isSel ? Theme.of(context).primaryColor : null,
                        child: ListTile(
                          title: Text(s['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(s['time']!),
                          trailing: Text(s['price']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).primaryColor)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              CustomButton(
                text: 'Next: Select Date',
                onPressed: () => context.push('/booking-date'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
