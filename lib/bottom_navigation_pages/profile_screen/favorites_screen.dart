import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kids_loop/managers/theme_manager.dart';
import 'package:kids_loop/widgets/favorite_item_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "My Favorites",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: ThemeManager.primaryTeal,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('favorites')
            .orderBy('addedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: ThemeManager.primaryTeal),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: theme.hintColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Your wishlist is empty",
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.hintColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          final favProducts = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favProducts.length,
            itemBuilder: (context, index) {
              return FavoriteItemCard(productId: favProducts[index].id);
            },
          );
        },
      ),
    );
  }
}
