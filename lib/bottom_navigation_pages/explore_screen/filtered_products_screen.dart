import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kids_loop/managers/theme_manager.dart';

import '../../feature_screens/product_details_screen.dart';

class FilteredProductsScreen extends StatelessWidget {
  final String filterField;
  final String filterValue;

  const FilteredProductsScreen({
    super.key,
    required this.filterField,
    required this.filterValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          filterValue,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: ThemeManager.primaryTeal,
          ),
        ),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("products")
            .where("status", isEqualTo: "available")
            .where(filterField, isEqualTo: filterValue)
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: ThemeManager.primaryTeal),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 80, color: theme.hintColor),
                  const SizedBox(height: 16),
                  Text(
                    "No items found for '$filterValue'",
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

          final products = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final doc = products[index];
              final data = doc.data() as Map<String, dynamic>;

              final String title = data['title'] ?? 'No Title';
              final String price = data['price']?.toString() ?? '0.0';
              final List images = data['images'] ?? [];
              final String imageUrl = images.isNotEmpty ? images[0] : "";

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailsScreen(productData: data),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                )
                              : Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(Icons.broken_image),
                                  ),
                                ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
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
                      ),
                    ],
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
