import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/business_bottom_nav.dart';

class SalonManagementScreen extends StatefulWidget {
  const SalonManagementScreen({super.key});

  @override
  State<SalonManagementScreen> createState() => _SalonManagementScreenState();
}

class _SalonManagementScreenState extends State<SalonManagementScreen> {
  final _nameController =
      TextEditingController(text: 'صالون إكزكيوتيف للحلاقة');
  final _addressController =
      TextEditingController(text: '142 شارع لاكجري، وسط نيويورك');
  final _phoneController = TextEditingController(text: '+1 (555) 987-6543');

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
          title: const Text('إدارة الصالون'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GlassCard(
                child: Column(
                  children: [
                    CustomTextField(
                        controller: _nameController,
                        label: 'اسم الصالون التجاري',
                        prefixIcon: Icons.storefront_rounded),
                    const SizedBox(height: 14),
                    CustomTextField(
                        controller: _addressController,
                        label: 'العنوان الكامل',
                        prefixIcon: Icons.location_on_rounded),
                    const SizedBox(height: 14),
                    CustomTextField(
                        controller: _phoneController,
                        label: 'هاتف الصالون',
                        prefixIcon: Icons.phone_rounded),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'تحديث معلومات الصالون',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('تم تحديث ملف الصالون!')));
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/owner-dashboard');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BusinessBottomNav(currentIndex: 4),
      ),
    );
  }
}
