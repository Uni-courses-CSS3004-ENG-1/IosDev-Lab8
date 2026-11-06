import 'package:flutter/material.dart';

import 'screens/catalog_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Catalog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F6F0),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF285448),
          primary: const Color(0xFF285448),
          surface: const Color(0xFFF8F6F0),
          onSurface: const Color(0xFF202D28),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8F6F0),
          foregroundColor: Color(0xFF202D28),
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          elevation: 0,
          titleSpacing: 20,
        ),
        dividerTheme: const DividerThemeData(color: Color(0xFFE5E6DD)),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF202D28),
          actionTextColor: const Color(0xFFCEE5A5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const CatalogScreen(),
    );
  }
}
