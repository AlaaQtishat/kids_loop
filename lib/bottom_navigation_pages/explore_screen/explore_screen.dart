import 'package:flutter/material.dart';
import 'package:kids_loop/bottom_navigation_pages/explore_screen/filtered_products_screen.dart';

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

  final List<String> _ageGroups = [
    "Newborn (0-3m)",
    "Infant (3-12m)",
    "Toddler (1-3y)",
    "Kids (4-7y)",
    "Junior (8-12y)",
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
            const SizedBox(height: 30),

            _buildSectionTitle("Shop by Age"),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _ageGroups.map((age) {
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _navigateToFilter(context, "ageGroup", age),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Text(
                      age,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

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
