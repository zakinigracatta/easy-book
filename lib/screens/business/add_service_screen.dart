import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/services-management');
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
                context.go('/services-management');
              }
            },
          ),
          title: const Text('Add New Service'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: GlassCard(
            child: Column(
              children: [
                CustomTextField(controller: _nameController, label: 'Service Name', prefixIcon: Icons.design_services_rounded),
                const SizedBox(height: 14),
                CustomTextField(controller: _priceController, label: 'Price (\$)', prefixIcon: Icons.attach_money_rounded),
                const SizedBox(height: 14),
                CustomTextField(controller: _durationController, label: 'Duration (e.g. 45 mins)', prefixIcon: Icons.timer_outlined),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Publish Service',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New service added!')));
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/services-management');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
