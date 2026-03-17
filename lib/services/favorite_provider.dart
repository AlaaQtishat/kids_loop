import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoritesProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Set<String> _favoriteIds = {};

  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> fetchUserFavorites() async {
    final uid = currentUid;
    if (uid == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('favorites')
          .get();

      _favoriteIds.clear();
      for (var doc in snapshot.docs) {
        _favoriteIds.add(doc.id);
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching favorites: $e");
    }
  }

  bool isFavorite(String productId) {
    return _favoriteIds.contains(productId);
  }

  Future<void> toggleFavorite(
    Map<String, dynamic> productData,
    String productId,
  ) async {
    final uid = currentUid;
    if (uid == null) return;

    final isExist = _favoriteIds.contains(productId);

    if (isExist) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
    notifyListeners();

    try {
      final docRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('favorites')
          .doc(productId);

      if (isExist) {
        await docRef.delete();
      } else {
        await docRef.set({
          ...productData,
          'addedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      if (isExist) {
        _favoriteIds.add(productId);
      } else {
        _favoriteIds.remove(productId);
      }
      notifyListeners();
      debugPrint("Error toggling favorite: $e");
    }
  }

  void clearFavoritesLocally() {
    _favoriteIds.clear();
    notifyListeners();
  }
}
