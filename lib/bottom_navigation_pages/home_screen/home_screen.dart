import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kids_loop/managers/theme_manager.dart';
import 'package:kids_loop/widgets/product_card.dart';
import 'package:easy_localization/easy_localization.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 10)),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("products")
                      .where("status", isEqualTo: "available")
                      .orderBy("createdAt", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(top: 50.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: ThemeManager.primaryTeal,
                            ),
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                        child: Text(
                          "${'home_screen.home_error'.tr()}${snapshot.error}",
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 50.0),
                          child: Center(
                            child: Text(
                              "home_screen.home_no_items".tr(),
                              style: TextStyle(color: theme.hintColor),
                            ),
                          ),
                        ),
                      );
                    }

                    final allProducts = snapshot.data!.docs;
                    final filteredProducts = allProducts.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data['userUid'] != currentUserId;
                    }).toList();

                    if (filteredProducts.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 50.0),
                          child: Center(
                            child: Text(
                              "home_screen.home_no_other_items".tr(),
                              style: TextStyle(color: theme.hintColor),
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final doc = filteredProducts[index];
                        final productData = doc.data() as Map<String, dynamic>;

                        return ProductCard(
                          data: productData,
                          productId: doc.id,
                        );
                      }, childCount: filteredProducts.length),
                    );
                  },
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
