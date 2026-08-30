import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  final _nameController =
      TextEditingController(text: 'صالون إكزكيوتيف للحلاقة');
  final _addressController =
      TextEditingController(text: '142 Luxury Blvd, Downtown');
  final _descController = TextEditingController(
      text: 'Premium grooming experience for modern gentlemen.');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Business Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CustomTextField(controller: _nameController, label: 'Salon Name'),
            const SizedBox(height: 16),
            CustomTextField(controller: _addressController, label: 'Address'),
            const SizedBox(height: 16),
            CustomTextField(controller: _descController, label: 'Description'),
            const SizedBox(height: 28),
            CustomButton(
              text: 'Save Business Profile',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Profile updated successfully!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
