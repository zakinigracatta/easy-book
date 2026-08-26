import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../services/auth_guard.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glass_card.dart';

class ServiceDetailsScreen extends StatelessWidget {
  ServiceDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.canPop() ? context.pop() : context.go('/home');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
          ),
          title: Text(context.tr('Service Information')),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr('Royal Haircut & Beard Sculpting'),
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        'AED 65.00 • 45 ${context.tr('minutes')}',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Divider(height: 24),
                    Text(
                      context.tr('Service Highlights:'),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      context.tr(
                        '• Precision hair consultation & custom styling\n• Hot towel facial wrap & beard oil conditioning\n• Scalp massage and premium hair wash finish',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              CustomButton(
                text: context.tr('Proceed to Booking'),
                onPressed: () async {
                  final allowed = await requireLogin(context);
                  if (allowed && context.mounted) {
                    context.push('/booking-service');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
