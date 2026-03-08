import 'package:flutter/material.dart';
import 'package:kids_loop/bottom_navigation_pages/profile_screen.dart';
import 'package:kids_loop/managers/theme_manager.dart';
import '../bottom_navigation_pages/add_product_screen.dart';
import '../bottom_navigation_pages/chat_screen.dart';
import '../bottom_navigation_pages/explore_screen.dart';
import '../bottom_navigation_pages/home_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const ExploreScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  final List<String> _screenTitles = ["Home", "Explore", "Chats", "My Profile"];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: _currentIndex == 0 ? false : true,
        title: _currentIndex == 0
            ? Image.asset(
                "assets/images/logo1.png",
                height: 60,
                fit: BoxFit.contain,
              )
            : Text(
                _screenTitles[_currentIndex],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: theme.primaryColor,
                ),
              ),
      ),

      body: _screens[_currentIndex],

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          );
        },
        backgroundColor: ThemeManager.primaryYellow,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shadowColor: Colors.black54,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: theme.cardColor,
        elevation: 20,
        child: SizedBox(
          height: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(icon: Icons.home_rounded, label: "Home", index: 0),
              _buildNavItem(
                icon: Icons.grid_view_rounded,
                label: "Explore",
                index: 1,
              ),
              const SizedBox(width: 40),
              _buildNavItem(
                icon: Icons.chat_bubble_rounded,
                label: "Chat",
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.person_rounded,
                label: "Profile",
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _currentIndex == index;
    final theme = Theme.of(context);

    final Color selectedColor = theme.primaryColor;
    final Color unselectedColor = Colors.grey.shade600;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? selectedColor : unselectedColor,
            size: 26,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? selectedColor : unselectedColor,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
