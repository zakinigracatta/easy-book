import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_providers.dart';
import '../../widgets/empty_state.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final businessesAsync = ref.watch(businessesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Salons')),
      body: businessesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (businesses) {
          final favBusinesses = businesses.where((b) => favorites.contains(b.id)).toList();
          if (favBusinesses.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.favorite_border,
              title: 'No Favorites Yet',
              message: 'Tap the heart icon on any salon to save it here for quick access.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favBusinesses.length,
            itemBuilder: (context, index) {
              final b = favBusinesses[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: () => context.go('/salon/${b.id}'),
                  title: Text(b.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(b.address),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      final updated = Set<String>.from(favorites)..remove(b.id);
                      ref.read(favoritesProvider.notifier).state = updated;
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
