import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_text.dart';
import '../../l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  AboutScreen({super.key});

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
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          title: Text(context.tr('About Easy Book')),
        ),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              GlassCard(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.content_cut_rounded, size: 60),
                    SizedBox(height: 12),
                    GradientText(
                      'Easy Book v2.5',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(context.tr('Next-generation native Flutter reservation app for barbers, hair salons, spas and beauty clinics.'),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
