import 'package:flutter/material.dart';

class BusinessApprovalScreen extends StatefulWidget {
  const BusinessApprovalScreen({super.key});

  @override
  State<BusinessApprovalScreen> createState() => _BusinessApprovalScreenState();
}

class _BusinessApprovalScreenState extends State<BusinessApprovalScreen> {
  final List<Map<String, String>> _pending = [
    {
      'name': 'Crown Grooming Lounge',
      'category': 'Barber Shop',
      'address': '77 Park Ave'
    },
    {
      'name': 'Zenith Wellness Spa',
      'category': 'سبا ومساج',
      'address': '12 Ocean View'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Business Approvals')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pending.length,
        itemBuilder: (context, index) {
          final item = _pending[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['name']!,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17)),
                  const SizedBox(height: 4),
                  Text('${item['category']} • ${item['address']}',
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () =>
                            setState(() => _pending.removeAt(index)),
                        child: const Text('رفض'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          setState(() => _pending.removeAt(index));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Business approved successfully!')),
                          );
                        },
                        child: const Text('موافقة'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
