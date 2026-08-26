import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'glass_card.dart';
import '../core/constants/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final routes = ['/home', '/search', '/bookings', '/chat-list', '/profile'];

    return Container(
      margin: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        borderRadius: 25,
        child: BottomNavigationBar(
          currentIndex: currentIndex < routes.length ? currentIndex : 0,
          elevation: 0,
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          onTap: (index) {
            if (index < routes.length) {
              context.go(routes[index]);
            }
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.search_rounded), label: 'Search'),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_rounded), label: 'Bookings'),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline_rounded), label: 'Chat'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final String currentPath;

  const BottomNavBar({
    super.key,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    int index = 0;
    if (currentPath == '/search') index = 1;
    if (currentPath == '/bookings') index = 2;
    if (currentPath == '/chat-list') index = 3;
    if (currentPath == '/profile') index = 4;

    return CustomBottomNavBar(currentIndex: index);
  }
}
