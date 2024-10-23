import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart'; // Import flutter_driver extension
import 'pages/home_page.dart';

void main() {
  enableFlutterDriverExtension(); // Enable Flutter Driver extension
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('Building MyApp widget...'); // Log for debugging
    return MaterialApp(
      key: const ValueKey('adhdAssistApp'), // Added key for automation testing
      title: 'ADHD Assist',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(), // Load the home page
    );
  }
}
