import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_colors.dart';

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key});

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
          title: const Text('الخطوة 4: تأكيد الحجز'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('صالون إكزكيوتيف للحلاقة',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('142 شارع لاكجري، نيويورك',
                        style: TextStyle(
                            color: AppColors.textMutedDark, fontSize: 12)),
                    const Divider(height: 24),
                    _row('الخدمة', 'قصة شعر ملكية وتشذيب اللحية'),
                    _row('المختص', 'ماركوس فانس'),
                    _row('التاريخ والوقت', 'غدًا الساعة 10:00 صباحًا'),
                    _row('المدة', '45 دقيقة'),
                    const Divider(height: 24),
                    _row('السعر الإجمالي', '\$65.00', isBold: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'المتابعة إلى الدفع',
                onPressed: () => context.push('/payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String title, String val, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: AppColors.textMutedDark)),
          Text(val,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                  fontSize: isBold ? 17 : 14,
                  color: isBold ? AppColors.primary : null)),
        ],
      ),
    );
  }
}
