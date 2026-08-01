import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/customer_bottom_nav.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search & Explore'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomTextField(
              controller: _searchController,
              label: 'Search Salons, Services or Stylists',
              prefixIcon: Icons.search,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _searchTile(context, 'Executive Barber Lounge', 'Barber Shop • Downtown', '/salon-details'),
                _searchTile(context, 'Royal Spa & Wellness', 'Spa Center • Midtown', '/salon-details'),
                _searchTile(context, 'Luxury Hair Studio', 'Hair Coloring • Uptown', '/salon-details'),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 1),
    );
  }

  Widget _searchTile(BuildContext context, String title, String sub, String route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        onTap: () => context.push(route),
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.storefront_rounded)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(sub),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      ),
    );
  }
}
