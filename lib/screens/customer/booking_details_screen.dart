import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../theme/app_colors.dart';

class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({super.key});

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
          title: const Text('تفاصيل الحجز ورمز QR'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GlassCard(
                child: Column(
                  children: [
                    const Icon(Icons.qr_code_2_rounded,
                        size: 140, color: AppColors.primary),
                    const SizedBox(height: 8),
                    const Text('مرجع الحجز: #BK-94821',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('امسح الرمز عند مكتب استقبال الصالون',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textMutedDark)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('صالون إكزكيوتيف للحلاقة',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 4),
                    Text('142 شارع لاكجري، نيويورك',
                        style: TextStyle(color: AppColors.textMutedDark)),
                    Divider(height: 24),
                    Text('الخدمة: قصة شعر ملكية وتشذيب اللحية'),
                    SizedBox(height: 4),
                    Text('الوقت: غدًا الساعة 10:00 ص'),
                    SizedBox(height: 4),
                    Text('الحالة: مؤكد',
                        style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold)),
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
