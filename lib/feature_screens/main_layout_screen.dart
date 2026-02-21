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
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: ThemeManager.backgroundGrey,
        actions: _currentIndex == 0
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    onPressed: () {},

                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: ThemeManager.primaryTeal,
                      size: 32,
                    ),
                  ),
                ),
              ]
            : null,
        centerTitle: _currentIndex == 0 ? false : true,
        title: _currentIndex == 0
            ? Image.asset("images/logo1.png", height: 60, fit: BoxFit.contain)
            : Text(
                _screenTitles[_currentIndex],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: ThemeManager.primaryTeal,
                ),
              ),
      ),

      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductScreen()),
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
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        surfaceTintColor: Colors.white,
        color: Colors.white,
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
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? ThemeManager.primaryTeal : Colors.grey,
            size: 26,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? ThemeManager.primaryTeal : Colors.grey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
