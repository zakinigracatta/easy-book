import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/bottom_nav_bar.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              onTap: () => context.go('/chat-detail/b1'),
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF6C3EF4),
                child: Text('EB',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              title: const Text('Executive Barber Lounge',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text(
                  'Yes! Master Barber Marcus Vance has an opening...'),
              trailing: const Text('10m ago',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }
}
