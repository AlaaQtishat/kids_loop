import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kids_loop/bottom_navigation_pages/home_screen/product_details_screen.dart';
import 'package:kids_loop/managers/theme_manager.dart';
import 'edit_product_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  @override
  Widget build(BuildContext context) {
    final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "my_listings_screen.title".tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: ThemeManager.primaryTeal,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.primaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("products")
            .where("userUid", isEqualTo: currentUid)
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
                "${'my_listings_screen.error_prefix'.tr()}${snapshot.error}",
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("my_listings_screen.no_listings".tr()));
          }

          final myProducts = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: myProducts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final doc = myProducts[index];
              return _buildListTileProduct(doc);
            },
          );
        },
      ),
    );
  }

  Widget _buildListTileProduct(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final String title = data['title'] ?? "my_listings_screen.no_title".tr();
    final double price = (data['price'] ?? 0.0).toDouble();
    final List images = data['images'] ?? [];
    final String imageUrl = images.isNotEmpty ? images[0] : "";

    final String status = data['status'];
    final bool isSold = status == "sold";

    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),
                  child: SizedBox(
                    width: 110,
                    height: 110,
                    child: Opacity(
                      opacity: isSold ? 0.5 : 1.0,
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                            )
                          : Container(color: Colors.grey[200]),
                    ),
                  ),
                ),
                if (isSold)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "my_listings_screen.sold_badge".tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              decoration: isSold
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "$price ${'my_listings_screen.currency'.tr()}",
                            style: const TextStyle(
                              color: ThemeManager.primaryYellow,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      color: Theme.of(context).cardColor,
                      onSelected: (value) {
                        if (value == 'sold') {
                          _confirmStatusChange(doc.id, "sold");
                        } else if (value == 'available') {
                          _confirmStatusChange(doc.id, "available");
                        } else if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditProductScreen(productDoc: doc),
                            ),
                          );
                        } else if (value == 'delete') {
                          _confirmDelete(doc.id);
                        }
                      },
                      itemBuilder: (context) => [
                        if (!isSold)
                          PopupMenuItem(
                            value: 'sold',
                            child: Text("my_listings_screen.mark_sold".tr()),
                          ),

                        if (isSold)
                          PopupMenuItem(
                            value: 'available',
                            child: Text(
                              "my_listings_screen.mark_available".tr(),
                            ),
                          ),
                        PopupMenuItem(
                          value: 'edit',
                          child: Text("my_listings_screen.edit".tr()),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            "my_listings_screen.delete".tr(),
                            style: TextStyle(color: ThemeManager.errorRed),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(productData: data),
          ),
        );
      },
    );
  }

  void _confirmDelete(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "my_listings_screen.delete_title".tr(),
          style: TextStyle(
            color: ThemeManager.primaryTeal,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text("my_listings_screen.delete_content".tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "my_listings_screen.cancel".tr(),
              style: TextStyle(color: Colors.grey),
            ),
          ),

          SizedBox(
            width: 100,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeManager.errorRed,
              ),
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(
                      color: ThemeManager.primaryTeal,
                    ),
                  ),
                );

                try {
                  await FirebaseFirestore.instance
                      .collection("products")
                      .doc(docId)
                      .delete();

                  if (mounted) {
                    Navigator.pop(context);

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("my_listings_screen.delete_success".tr()),
                        backgroundColor: ThemeManager.errorRed,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "${'my_listings_screen.error_prefix'.tr()}$e",
                        ),
                      ),
                    );
                  }
                }
              },
              child: Text(
                "my_listings_screen.delete".tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmStatusChange(String docId, String newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          newStatus == "sold"
              ? "my_listings_screen.mark_sold_title".tr()
              : "my_listings_screen.make_available_title".tr(),
          style: TextStyle(
            color: ThemeManager.primaryTeal,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          newStatus == "sold"
              ? "my_listings_screen.mark_sold_content".tr()
              : "my_listings_screen.make_available_content".tr(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "my_listings_screen.cancel".tr(),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          SizedBox(
            width: 120,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeManager.primaryTeal,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(
                      color: ThemeManager.primaryTeal,
                    ),
                  ),
                );

                try {
                  await FirebaseFirestore.instance
                      .collection("products")
                      .doc(docId)
                      .update({"status": newStatus});

                  if (mounted) {
                    Navigator.pop(context);

                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "${'my_listings_screen.error_prefix'.tr()}$e",
                        ),
                        backgroundColor: ThemeManager.errorRed,
                      ),
                    );
                  }
                }
              },
              child: Text(
                "my_listings_screen.confirm".tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
