import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kids_loop/managers/theme_manager.dart';
import 'package:kids_loop/bottom_navigation_pages/home_screen/product_details_screen.dart';

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
          "listing_options.$filterValue".tr(),
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
            return Center(
              child: Text(
                "${'filtered_products_screen.error'.tr()}${snapshot.error}",
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Icon(Icons.search_off, size: 80, color: theme.hintColor),

                  const SizedBox(height: 16),

                  Text(
                    "${'filtered_products_screen.no_items_found'.tr()} '${"listing_options.$filterValue".tr()}'",

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
              final String title =
                  data['title'] ?? 'filtered_products_screen.no_title'.tr();
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
                              "$price ${'filtered_products_screen.currency'.tr()}",
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
