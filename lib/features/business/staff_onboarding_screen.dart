import 'package:flutter/material.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class StaffOnboardingScreen extends StatefulWidget {
  const StaffOnboardingScreen({super.key});

  @override
  State<StaffOnboardingScreen> createState() => _StaffOnboardingScreenState();
}

class _StaffOnboardingScreenState extends State<StaffOnboardingScreen> {
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  final _commissionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _commissionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة موظف')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: GlassCard(
          child: Column(
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'اسم الموظف',
                prefixIcon: Icons.person,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _roleController,
                label: 'المسمى الوظيفي (مثال: حلاق محترف)',
                prefixIcon: Icons.badge,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _commissionController,
                label: 'نسبة العمولة (%)',
                prefixIcon: Icons.percent,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'حفظ ملف المختص',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
