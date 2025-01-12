import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:homeautomation/pages/auth_page.dart';
import 'package:homeautomation/pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure proper initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
    );
  }
}
