import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

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
          title: const Text('مركز المساعدة والدعم'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            GlassCard(
              child: ListTile(
                leading: Icon(Icons.help_center_rounded),
                title: Text('الأسئلة الشائعة'),
                subtitle:
                    Text('كيفية إلغاء الحجوزات أو إعادة جدولتها أو دفعها'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
