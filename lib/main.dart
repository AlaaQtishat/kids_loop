import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kids_loop/managers/theme_manager.dart';
import 'package:kids_loop/splash_screen.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeManager.applicationTheme,
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
