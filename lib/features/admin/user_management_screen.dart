import 'package:flutter/material.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('AV')),
              title: Text('Alex Vance',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Role: Customer • Status: Active'),
              trailing: Icon(Icons.more_vert),
            ),
          ),
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('MV')),
              title: Text('Marcus Vance',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Role: Business Owner • Status: Active'),
              trailing: Icon(Icons.more_vert),
            ),
          ),
        ],
      ),
    );
  }
}
