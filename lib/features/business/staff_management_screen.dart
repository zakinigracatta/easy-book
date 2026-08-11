import 'package:flutter/material.dart';

class StaffManagementScreen extends StatelessWidget {
  const StaffManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff Management')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('MV')),
              title: Text('Marcus Vance',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Master Barber • Full Time'),
              trailing: Icon(Icons.edit_outlined),
            ),
          ),
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('ER')),
              title: Text('Elena Rostova',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Hair Color Specialist • Full Time'),
              trailing: Icon(Icons.edit_outlined),
            ),
          ),
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('DK')),
              title: Text('David Kim',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Spa Therapist • Part Time'),
              trailing: Icon(Icons.edit_outlined),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
