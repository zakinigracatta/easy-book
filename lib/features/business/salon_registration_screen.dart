import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class SalonRegistrationScreen extends StatefulWidget {
  const SalonRegistrationScreen({super.key});

  @override
  State<SalonRegistrationScreen> createState() => _SalonRegistrationScreenState();
}

class _SalonRegistrationScreenState extends State<SalonRegistrationScreen> {
  int _step = 1;
  final _businessName = TextEditingController();
  final _address = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Salon Registration (Step $_step of 3)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_step == 1) ...[
                const Text('Business Basic Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                CustomTextField(label: 'Salon / Business Name', controller: _businessName, prefixIcon: Icons.storefront_rounded),
                const SizedBox(height: 16),
                CustomTextField(label: 'Full Street Address', controller: _address, prefixIcon: Icons.location_on_outlined),
              ] else if (_step == 2) ...[
                const Text('Services & Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const ChoiceChip(label: Text('Barber Shop'), selected: true),
                const ChoiceChip(label: Text('Hair Salon'), selected: false),
                const ChoiceChip(label: Text('Spa & Wellness'), selected: false),
              ] else ...[
                const Text('Verification & Documents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Trade License (PDF)'),
                  onPressed: () {},
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_step > 1)
                    OutlinedButton(onPressed: () => setState(() => _step--), child: const Text('Back')),
                  CustomButton(
                    text: _step == 3 ? 'Complete Registration' : 'Next Step',
                    onPressed: () {
                      if (_step < 3) {
                        setState(() => _step++);
                      } else {
                        context.go('/salon-success');
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
