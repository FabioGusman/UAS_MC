import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/app_state.dart';
import 'services/hive_service.dart';
import 'screens/login_screen.dart';

void main() async {
  // Wajib ditambahkan karena kita menginisialisasi Hive secara asinkron
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi format tanggal bahasa Indonesia (lokal)
  await initializeDateFormatting('id', null);

  // Inisialisasi database lokal Hive
  await Hive.initFlutter();
  
  // Inisialisasi Box Hive untuk User, Workout, dan Progress
  await HiveService.init();

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const GymApp(),
    ),
  );
}

class GymApp extends StatelessWidget {
  const GymApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitSphere - Gym & Workout Tracker',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFFD700), // Amber Gold
        scaffoldBackgroundColor: const Color(0xFF121212), // Charcoal Black
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD700), // Amber Gold
          secondary: Color(0xFFFFA500), // Orange
          surface: Color(0xFF1E1E1E), // Dark Grey Cards
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E1E),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700),
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
          ),
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIconColor: const Color(0xFFFFD700),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
