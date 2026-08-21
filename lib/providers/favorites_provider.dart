import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';

class FavoritesRepository {
  FavoritesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> setFavorite({
    required String userId,
    required String businessId,
    required bool isFavorite,
  }) async {
    final normalizedUserId = userId.trim();
    final normalizedBusinessId = businessId.trim();

    if (normalizedUserId.isEmpty || normalizedBusinessId.isEmpty) {
      throw ArgumentError('A valid user and business are required.');
    }

    final favoriteRef = _firestore
        .collection('users')
        .doc(normalizedUserId)
        .collection('favorites')
        .doc(normalizedBusinessId);

    if (isFavorite) {
      await favoriteRef.set({
        'businessId': normalizedBusinessId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await favoriteRef.delete();
    }
  }
}

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository();
});

/// Real-time favorite business IDs for the currently signed-in customer.
/// Guests intentionally receive an empty set.
final savedFavoritesProvider = StreamProvider<Set<String>>((ref) {
  final user = ref.watch(authProvider);
  if (user == null || user.id.trim().isEmpty) {
    return Stream.value(<String>{});
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.id)
      .collection('favorites')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => doc.id)
            .where((id) => id.trim().isNotEmpty)
            .toSet(),
      );
});
