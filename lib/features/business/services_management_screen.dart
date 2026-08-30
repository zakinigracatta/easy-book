import 'package:flutter/material.dart';

class ServicesManagementScreen extends StatelessWidget {
  const ServicesManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Services & Catalog')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              title: Text('Luxury Haircut & Beard Sculpting',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('45 mins • \$65.00'),
              trailing: Icon(Icons.edit),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Hot Towel Royal Shave',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('30 mins • \$45.00'),
              trailing: Icon(Icons.edit),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Deep Tissue Massage & Spa',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('60 mins • \$110.00'),
              trailing: Icon(Icons.edit),
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
