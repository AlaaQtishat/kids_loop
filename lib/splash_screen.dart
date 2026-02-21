import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_screens/create_account_screen.dart';
import 'feature_screens/main_layout_screen.dart';
import 'managers/theme_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      _checkUserAndNavigate();
    });
  }

  void _checkUserAndNavigate() {
    final user = FirebaseAuth.instance.currentUser;
    if (context.mounted) {
      if (user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainLayoutScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const CreateAccountScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeManager.backgroundGrey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("images/logo2.png", height: 200, width: 200),

            const SizedBox(height: 16),

            Text(
              "They grow fast. Pass it on.",
              style: TextStyle(
                fontSize: 20,
                color: ThemeManager.primaryTeal,
                //letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 20),

            CircularProgressIndicator(color: ThemeManager.primaryYellow),
          ],
        ),
      ),
    );
  }
}
