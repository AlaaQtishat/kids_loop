import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kids_loop/managers/theme_manager.dart';
import 'package:kids_loop/utilities/date_helper.dart';
import 'package:kids_loop/feature_screens/chat_screen/chat_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> productData;

  const ProductDetailsScreen({super.key, required this.productData});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _currentImageIndex = 0;
  late Future<DocumentSnapshot> _sellerFuture;
  @override
  void initState() {
    super.initState();

    final String sellerUid = widget.productData['userUid'] ?? '';
    _sellerFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(sellerUid)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = widget.productData;

    final List<dynamic> images = data['images'] ?? [];
    final String title =
        data['title'] ?? 'product_details_screen.no_title'.tr();
    final String price = data['price']?.toString() ?? '0.0';

    final rawLocation = data['location'];
    final String location = rawLocation != null
        ? "listing_options.$rawLocation".tr()
        : 'product_details_screen.unknown_location'.tr();

    final rawCondition = data['condition'];
    final String condition = rawCondition != null
        ? "listing_options.$rawCondition".tr()
        : 'product_details_screen.unknown'.tr();

    final rawAgeGroup = data['ageGroup'];
    final String ageGroup = rawAgeGroup != null
        ? "listing_options.$rawAgeGroup".tr()
        : 'product_details_screen.unknown'.tr();

    final rawCategory = data['category'];
    final String category = rawCategory != null
        ? "listing_options.$rawCategory".tr()
        : 'product_details_screen.unknown'.tr();

    final String description =
        data['description'] ?? 'product_details_screen.no_description'.tr();
    final String sellerUid = data['userUid'] ?? '';
    final timeAgo = DateHelper.getTimeAgo(data['createdAt']);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 350,
                pinned: true,
                backgroundColor: ThemeManager.primaryTeal,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.cardColor.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      images.isNotEmpty
                          ? PageView.builder(
                              itemCount: images.length,
                              onPageChanged: (index) =>
                                  setState(() => _currentImageIndex = index),
                              itemBuilder: (context, index) {
                                return Image.network(
                                  images[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 50,
                                        ),
                                      ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                ),
                              ),
                            ),

                      if (images.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: images.asMap().entries.map((entry) {
                              return Container(
                                width: _currentImageIndex == entry.key
                                    ? 12.0
                                    : 8.0,
                                height: 8.0,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: _currentImageIndex == entry.key
                                      ? ThemeManager.primaryYellow
                                      : Colors.white.withOpacity(0.5),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            "$price ${'product_details_screen.currency_jd'.tr()}",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: ThemeManager.primaryYellow,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: theme.hintColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            location,
                            style: TextStyle(color: theme.hintColor),
                          ),
                          const Spacer(),
                          Text(
                            timeAgo,
                            style: TextStyle(
                              color: theme.hintColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          _buildSpecItem(
                            context,
                            Icons.star_outline,
                            "product_details_screen.condition_label".tr(),
                            condition,
                          ),
                          _buildSpecItem(
                            context,
                            Icons.child_care,
                            "product_details_screen.age_label".tr(),
                            ageGroup,
                          ),
                          _buildSpecItem(
                            context,
                            Icons.category,
                            "product_details_screen.category_label".tr(),
                            category,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      Text(
                        "product_details_screen.description_label".tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(
                            0.8,
                          ),
                          height: 1.5,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 24),
                      Divider(thickness: 1, color: theme.dividerColor),
                      const SizedBox(height: 24),

                      Text(
                        "product_details_screen.sold_by".tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),

                      FutureBuilder<DocumentSnapshot>(
                        future: _sellerFuture,
                        builder: (context, snapshot) {
                          String sName = "product_details_screen.loading".tr();
                          String sPhone = "product_details_screen.loading".tr();
                          String sImage = "";

                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.hasData &&
                              snapshot.data!.exists) {
                            final sellerData =
                                snapshot.data!.data() as Map<String, dynamic>;
                            sName =
                                sellerData['full_name'] ??
                                "product_details_screen.unknown_seller".tr();
                            sPhone =
                                sellerData['phone_number'] ??
                                sellerData['phone'] ??
                                "product_details_screen.no_phone".tr();
                            sImage = sellerData['photoUrl'] ?? "";
                          }

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.dividerColor),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor:
                                      theme.colorScheme.surfaceContainerHighest,
                                  backgroundImage: sImage.isNotEmpty
                                      ? NetworkImage(sImage)
                                      : null,
                                  child: sImage.isEmpty
                                      ? Icon(
                                          Icons.person,
                                          color: theme.hintColor,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.phone,
                                            size: 14,
                                            color: ThemeManager.primaryTeal,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            sPhone,
                                            style: TextStyle(
                                              color: theme.hintColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: FutureBuilder<DocumentSnapshot>(
                    future: _sellerFuture,
                    builder: (context, snapshot) {
                      String fullName = "product_details_screen.seller".tr();
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData &&
                          snapshot.data!.exists) {
                        final sData =
                            snapshot.data!.data() as Map<String, dynamic>;
                        fullName =
                            sData['name'] ??
                            sData['full_name'] ??
                            "product_details_screen.seller".tr();
                        fullName = fullName.split(' ')[0];
                      }

                      return ElevatedButton.icon(
                        onPressed: () {
                          final String sellerId =
                              widget.productData['userUid'] ?? '';
                          final String sellerName =
                              widget.productData['sellerName'] ??
                              'product_details_screen.seller'.tr();

                          final String currentUserId =
                              FirebaseAuth.instance.currentUser!.uid;

                          if (sellerId == currentUserId) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "product_details_screen.cannot_chat_with_self"
                                      .tr(),
                                ),
                              ),
                            );
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                receiverId: sellerId,
                                receiverName: sellerName,
                                productData: widget.productData,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: Text(
                          "product_details_screen.chat_with".tr(
                            namedArgs: {'name': fullName},
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeManager.primaryTeal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: ThemeManager.primaryTeal, size: 20),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, color: theme.hintColor)),
            const SizedBox(height: 2),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
