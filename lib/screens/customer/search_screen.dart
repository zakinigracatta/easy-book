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
        title: const Text('البحث والاستكشاف'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomTextField(
              controller: _searchController,
              label: 'ابحث عن صالونات أو خدمات أو مختصين',
              prefixIcon: Icons.search,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _searchTile(context, 'صالون إكزكيوتيف للحلاقة',
                    'صالون حلاقة • وسط المدينة', '/salon-details'),
                _searchTile(context, 'رويال سبا والعافية',
                    'مركز سبا • وسط المدينة', '/salon-details'),
                _searchTile(context, 'استوديو لاكجري للشعر',
                    'صبغ شعر • شمال المدينة', '/salon-details'),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 1),
    );
  }

  Widget _searchTile(
      BuildContext context, String title, String sub, String route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        onTap: () => context.push(route),
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.storefront_rounded)),
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(sub),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      ),
    );
  }
}
