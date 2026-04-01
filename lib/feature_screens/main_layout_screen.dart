import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kids_loop/bottom_navigation_pages/home_screen/home_screen.dart';
import 'package:kids_loop/feature_screens/chat_screen/chat_list_screen.dart';
import 'package:kids_loop/bottom_navigation_pages/favorites_screen.dart';
import 'package:kids_loop/bottom_navigation_pages/profile_screen/profile_screen.dart';
import 'package:kids_loop/managers/theme_manager.dart';
import 'package:kids_loop/services/favorite_provider.dart';
import 'package:kids_loop/services/notification_handler.dart';
import 'package:kids_loop/bottom_navigation_pages/add_product_screen.dart';
import 'package:kids_loop/bottom_navigation_pages/explore_screen/explore_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    ExploreScreen(),
    FavoritesScreen(),
    const ProfileScreen(),
  ];

  final List<String> _screenTitleKeys = [
    "main_layout.home",
    "main_layout.explore",
    "main_layout.favorites",
    "main_layout.profile_title",
  ];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesProvider>().fetchUserFavorites();
    });
    NotificationHandler.setup(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? ThemeManager.primaryTeal.withOpacity(0.15)
            : ThemeManager.backgroundGrey,
        toolbarHeight: 60.0,

        centerTitle: _currentIndex == 0 ? false : true,
        title: _currentIndex == 0
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    "assets/images/logo1.png",
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chat_rooms')
                        .where(
                          'users',
                          arrayContains: FirebaseAuth.instance.currentUser?.uid,
                        )
                        .snapshots(),
                    builder: (context, snapshot) {
                      bool hasUnread = false;

                      if (snapshot.hasData) {
                        final currentUserId =
                            FirebaseAuth.instance.currentUser?.uid;
                        for (var doc in snapshot.data!.docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          if (data['isRead'] == false &&
                              data['lastMessageSenderId'] != currentUserId) {
                            hasUnread = true;
                            break;
                          }
                        }
                      }

                      return Badge(
                        isLabelVisible: hasUnread,
                        backgroundColor: Colors.redAccent,
                        smallSize: 10,
                        offset: const Offset(2, -2),
                        child: IconButton(
                          icon: Icon(
                            Icons.forum_outlined,
                            color: ThemeManager.primaryTeal,
                            size: 32,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatListScreen(),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              )
            : Text(
                _screenTitleKeys[_currentIndex].tr(),
                style: TextStyle(
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
              _buildNavItem(
                icon: Icons.home_rounded,
                labelKey: "main_layout.home",
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.grid_view_rounded,
                labelKey: "main_layout.explore",
                index: 1,
              ),
              const SizedBox(width: 40),
              _buildNavItem(
                icon: Icons.favorite,
                labelKey: "main_layout.favorites",
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.person_rounded,
                labelKey: "main_layout.profile_nav",
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
    required String labelKey,
    required int index,
  }) {
    final bool isSelected = _currentIndex == index;
    final theme = Theme.of(context);

    final Color selectedColor = theme.primaryColor;
    final Color unselectedColor = Colors.grey.shade600;

    Widget iconWidget = Icon(
      icon,
      color: isSelected ? selectedColor : unselectedColor,
      size: 26,
    );

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          Text(
            labelKey.tr(),
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
