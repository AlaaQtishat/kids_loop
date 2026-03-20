import 'package:flutter/material.dart';
import 'package:kids_loop/bottom_navigation_pages/explore_screen/filtered_products_screen.dart';
import 'package:kids_loop/managers/theme_manager.dart';
import 'package:kids_loop/utilities/listing_options.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ExploreScreen extends StatelessWidget {
  ExploreScreen({super.key});

  final List<Map<String, dynamic>> _categories = const [
    {"name": "Clothes", "icon": Icons.checkroom, "color": Colors.pinkAccent},
    {
      "name": "Shoes",
      "icon": Icons.roller_skating_rounded,
      "color": Colors.orangeAccent,
    },
    {"name": "Toys", "icon": Icons.toys, "color": Colors.blueAccent},
    {"name": "Gear", "icon": Icons.stroller, "color": Colors.purpleAccent},
  ];

  final List<Map<String, dynamic>> _ageGroupsData = [
    {
      "dbValue": "Newborn (0-3m)",
      "title": "Newborn",
      "subtitle": "0-3 months",
      "icon": FontAwesomeIcons.babyCarriage,
    },
    {
      "dbValue": "Infant (3-12m)",
      "title": "Infant",
      "subtitle": "3-12 months",
      "icon": FontAwesomeIcons.baby,
    },
    {
      "dbValue": "Toddler (1-3y)",
      "title": "Toddler",
      "subtitle": "1-3 years",
      "icon": FontAwesomeIcons.child,
    },
    {
      "dbValue": "Kids (4-7y)",
      "title": "Kids",
      "subtitle": "4-7 years",
      "icon": FontAwesomeIcons.basketball,
    },
    {
      "dbValue": "Junior (8-12y)",
      "title": "Junior",
      "subtitle": "8-12 years",
      "icon": FontAwesomeIcons.gamepad,
    },
  ];
  final List<Map<String, dynamic>> _genders = const [
    {"name": "Boy", "icon": Icons.male, "color": Colors.blue},
    {"name": "Girl", "icon": Icons.female, "color": Colors.pink},
    {"name": "Neutral", "icon": Icons.all_inclusive, "color": Colors.green},
  ];

  void _navigateToFilter(
    BuildContext context,
    String filterField,
    String filterValue,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilteredProductsScreen(
          filterField: filterField,
          filterValue: filterValue,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Shop by Category"),
            const SizedBox(height: 16),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  return GestureDetector(
                    onTap: () =>
                        _navigateToFilter(context, "category", cat["name"]),
                    child: Column(
                      children: [
                        Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            color: cat["color"].withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            cat["icon"],
                            color: cat["color"],
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cat["name"],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 15),
            Divider(),
            const SizedBox(height: 15),

            _buildSectionTitle("Shop by Age"),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _ageGroupsData.map((age) {
                double cardWidth =
                    (MediaQuery.of(context).size.width - 40 - 12) / 2;

                return InkWell(
                  borderRadius: BorderRadius.circular(16),

                  onTap: () =>
                      _navigateToFilter(context, "ageGroup", age["dbValue"]),
                  child: Container(
                    width: cardWidth,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.dividerColor.withOpacity(0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ThemeManager.primaryTeal.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: FaIcon(
                            age["icon"],
                            size: 20,
                            color: ThemeManager.primaryTeal,
                          ),
                        ),
                        const SizedBox(width: 10),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                age["title"],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                age["subtitle"],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.hintColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 15),
            Divider(),
            const SizedBox(height: 15),
            _buildSectionTitle("Shop by Gender"),
            const SizedBox(height: 16),
            Row(
              children: _genders.map((gender) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        _navigateToFilter(context, "gender", gender["name"]),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 100,
                      decoration: BoxDecoration(
                        color: gender["color"].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: gender["color"].withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            gender["icon"],
                            color: gender["color"],
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            gender["name"],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: gender["color"],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 15),
            Divider(),
            const SizedBox(height: 15),
            _buildSectionTitle("Shop by Location"),
            const SizedBox(height: 16),
            SizedBox(
              height: 45,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ListingOptions.locations.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final loc = ListingOptions.locations[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => _navigateToFilter(context, "location", loc),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: ThemeManager.primaryTeal.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: ThemeManager.primaryTeal,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            loc,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
    );
  }
}
