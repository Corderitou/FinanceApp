import 'package:flutter/material.dart';

class TradingTheme {
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0B0E13), // Fondo oscuro premium
    appBarTheme: const AppBarTheme(
      color: Color(0xFF12161C), // AppBar más clara que el fondo
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: const MaterialColor(
        0xFF296DFF, // Azul brillante para acciones primarias
        <int, Color>{
          50: Color(0xFFE3EEFF),
          100: Color(0xFFBDD7FF),
          200: Color(0xFF91BDFF),
          300: Color(0xFF65A3FF),
          400: Color(0xFF4391FF),
          500: Color(0xFF296DFF),
          600: Color(0xFF1F57E0),
          700: Color(0xFF1745C7),
          800: Color(0xFF1137AE),
          900: Color(0xFF0C2A95),
        },
      ),
      brightness: Brightness.dark,
    ).copyWith(
      secondary: const Color(0xFFFFC107), // Amarillo para acciones importantes
      error: const Color(0xFFDC3545), // Rojo para errores
      surface: const Color(0xFF12161C), // Superficie para cards
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF296DFF), // Azul primario
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        elevation: 0,
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Color(0xFFB0B0B0),
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Color(0xFF909090),
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: Color(0xFF707070),
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      color: Color(0xFF12161C), // Color de superficie para cards
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Color(0xFF2A2E35), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(
          color: Color(0xFF296DFF),
          width: 2,
        ),
      ),
      filled: true,
      fillColor: Color(0xFF1A1F25),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF12161C),
      selectedItemColor: Color(0xFF296DFF),
      unselectedItemColor: Color(0xFF707070),
      elevation: 0,
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w600,
      ),
      type: BottomNavigationBarType.fixed,
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: Colors.white,
      unselectedLabelColor: Color(0xFF707070),
      indicator: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF296DFF),
            width: 2.0,
          ),
        ),
      ),
    ),
  );

  // Colores funcionales para datos financieros
  static const Color profitGreen = Color(0xFF0ECB81); // Verde para ganancias
  static const Color lossRed = Color(0xFFF6465D); // Rojo para pérdidas
  static const Color neutralGray = Color(0xFF707070); // Gris para neutro
  static const Color accentYellow = Color(0xFFFFC107); // Amarillo para acentos importantes
}