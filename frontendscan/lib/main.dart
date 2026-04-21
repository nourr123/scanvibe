import 'package:flutter/material.dart';

// Tes écrans existants
import 'Views/login.dart';
import 'Views/signup.dart';
import 'Views/scan_ocr.dart';
import 'Views/welcome.dart';
import 'Views/AboutPage.dart';
import 'Views/home_hub.dart';
import 'Views/manual_input_page.dart';
import 'Views/results.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final seed = const Color(0xFF0E4D47); // teal/vert profond
    return MaterialApp(
      title: 'ScanVibe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: const Color(0xFFEAF3F1),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      // Page d’accueil au démarrage
      initialRoute: '/welcome',
      routes: {
        // Auth
        '/': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/welcome': (context) => const WelcomePage(),
        '/home': (context) => const HomeHub(),

        // Actions
        '/scan_ocr': (context) => const ScanOCRPage(),
        '/manual': (context) => const ManualInputPage(),
        '/results': (context) => const ResultsPage(),

        // À propos
        '/about': (context) => const AboutPage(), // <-- corrige le nom de route
      },
    );
  }
}
