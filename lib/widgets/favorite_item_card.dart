import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kids_loop/services/favorite_provider.dart';
import 'package:provider/provider.dart';
import 'package:kids_loop/managers/theme_manager.dart';
import '../feature_screens/product_details_screen.dart';

class FavoriteItemCard extends StatelessWidget {
  final String productId;

  const FavoriteItemCard({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final doc = snapshot.data!;
        if (!doc.exists) return const SizedBox.shrink();

        final data = doc.data() as Map<String, dynamic>;
        final String title = data['title'] ?? 'No Title';
        final String price = data['price']?.toString() ?? '0.0';
        final List images = data['images'] ?? [];
        final String imageUrl = images.isNotEmpty ? images[0] : "";
        final bool isSold = data['status'] == 'sold';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (!isSold) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductDetailsScreen(productData: data),
                  ),
                );
              }
            },
            child: Opacity(
              opacity: isSold ? 0.6 : 1.0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    _buildImageSection(imageUrl, isSold),
                    const SizedBox(width: 16),
                    _buildDetailsSection(title, price, isSold),
                    _buildDeleteButton(context, data, productId),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection(String imageUrl, bool isSold) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image),
                ),
        ),
        if (isSold)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "SOLD",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDetailsSection(String title, String price, bool isSold) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              decoration: isSold ? TextDecoration.lineThrough : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            "$price JOD",
            style: const TextStyle(
              color: ThemeManager.primaryYellow,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(
    BuildContext context,
    Map<String, dynamic> data,
    String productId,
  ) {
    return IconButton(
      icon: const Icon(Icons.favorite, color: Colors.redAccent),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                "Remove from Favorites?",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ThemeManager.primaryTeal,
                ),
              ),
              content: const Text(
                "Are you sure you want to remove this item from your favorites?",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeManager.errorRed,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      context.read<FavoritesProvider>().toggleFavorite(
                        data,
                        productId,
                      );
                    },
                    child: const Text("Yes"),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
