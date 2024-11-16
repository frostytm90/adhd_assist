import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/home_page.dart';
import 'providers/task_provider.dart';
import 'providers/gamification_provider.dart';
import 'services/sound_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize providers
  final taskProvider = TaskProvider();
  await taskProvider.initHive();
  
  final gamificationProvider = GamificationProvider();
  await gamificationProvider.initHive();
  
  // Connect providers
  taskProvider.setGamificationProvider(gamificationProvider);
  
  // Initialize sound service
  final soundService = SoundService();
  await soundService.initialize();
  
  // Get initial theme mode
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkTheme') ?? false;
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<TaskProvider>.value(value: taskProvider),
        ChangeNotifierProvider<GamificationProvider>.value(value: gamificationProvider),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(isDarkMode: isDarkMode),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode;
  
  ThemeProvider({required bool isDarkMode}) : _isDarkMode = isDarkMode;
  
  bool get isDarkMode => _isDarkMode;
  
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', _isDarkMode);
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'ADHD Assistant',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const HomePage(),
        );
      },
    );
  }
}
