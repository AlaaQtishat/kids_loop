import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kids_loop/managers/theme_manager.dart';
import 'package:provider/provider.dart';
import '../feature_screens/product_details_screen.dart';
import '../services/favorite_provider.dart';
import 'package:kids_loop/utilities/date_helper.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String productId;

  const ProductCard({super.key, required this.data, required this.productId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = data['title'] ?? 'No Title';
    final price = data['price']?.toString() ?? '0.00';
    final condition = data['condition'] ?? 'Unknown Condition';
    final category = data['category'];
    final ageGroup = data['ageGroup'];
    final location = data['location'] ?? 'Unknown Location';
    final timeAgo = DateHelper.getTimeAgo(data['createdAt']);
    final String sellerUid = data['userUid'] ?? '';

    final List<dynamic> images = data['images'] ?? [];
    final String mainImageUrl = images.isNotEmpty
        ? images[0]
        : "https://dummyimage.com/400x400/cccccc/000000&text=No+Image";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(productData: data),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (theme.brightness == Brightness.light)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(sellerUid)
                    .get(),
                builder: (context, userSnapshot) {
                  String sellerName = "Loading...";
                  String sellerImageUrl = "";

                  if (userSnapshot.connectionState == ConnectionState.done &&
                      userSnapshot.hasData &&
                      userSnapshot.data!.exists) {
                    final userData =
                        userSnapshot.data!.data() as Map<String, dynamic>;
                    sellerName = userData['full_name'] ?? "Unknown Seller";
                    sellerImageUrl = userData['photoUrl'] ?? "";
                  }

                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        backgroundImage: sellerImageUrl.isNotEmpty
                            ? NetworkImage(sellerImageUrl)
                            : null,
                        child: sellerImageUrl.isEmpty
                            ? Icon(
                                Icons.person,
                                color: theme.hintColor,
                                size: 20,
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(sellerName, style: theme.textTheme.titleSmall),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 10,
                                color: theme.hintColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                timeAgo,
                                style: TextStyle(
                                  color: theme.hintColor,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  );
                },
              ),
            ),
            Stack(
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    image: DecorationImage(
                      image: NetworkImage(mainImageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      condition,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Consumer<FavoritesProvider>(
                    builder: (context, favoritesProvider, child) {
                      final bool isFav = favoritesProvider.isFavorite(
                        productId,
                      );

                      return GestureDetector(
                        onTap: () {
                          favoritesProvider.toggleFavorite(data, productId);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                            color: isFav ? Colors.red : Colors.black87,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$price JD",
                        style: const TextStyle(
                          color: ThemeManager.primaryYellow,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        " $location",
                        style: TextStyle(color: theme.hintColor, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildSpecChip(theme, Icons.child_care, ageGroup),
                      const SizedBox(width: 8),
                      _buildSpecChip(theme, Icons.checkroom, category),
                      const SizedBox(width: 8),
                      _buildSpecChip(
                        theme,
                        data['gender'] == "Boy"
                            ? Icons.male
                            : data['gender'] == "Girl"
                            ? Icons.female
                            : Icons.all_inclusive,
                        data['gender'] ?? "neutral",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecChip(ThemeData theme, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: theme.hintColor),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
