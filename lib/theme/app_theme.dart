import 'package:flutter/material.dart';

class AppTheme {
  // Paleta principal
  static const _primary = Color(0xFFE8A838);      // ámbar cálido
  static const _primaryDark = Color(0xFFD4902A);
  static const _bgDark = Color(0xFF111318);        // casi negro azulado
  static const _surfaceDark = Color(0xFF1C2030);
  static const _cardDark = Color(0xFF242840);
  static const _bgLight = Color(0xFFF5F3EE);       // blanco cálido
  static const _surfaceLight = Color(0xFFECE9E2);

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: _primary,
          secondary: _primaryDark,
          surface: _surfaceDark,
          onPrimary: Colors.black,
          onSurface: Color(0xFFE8E6E0),
        ),
        scaffoldBackgroundColor: _bgDark,
        cardColor: _cardDark,
        fontFamily: 'serif', // usa la serif del sistema (más cómodo para leer)
        appBarTheme: const AppBarTheme(
          backgroundColor: _bgDark,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFFE8E6E0),
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          iconTheme: IconThemeData(color: _primary),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: _surfaceDark,
          selectedItemColor: _primary,
          unselectedItemColor: Color(0xFF6B7080),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: _cardDark,
          selectedColor: _primary.withOpacity(0.25),
          labelStyle: const TextStyle(fontSize: 12),
        ),
        dividerColor: const Color(0xFF2A2F45),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFDDDBD5), height: 1.65),
          bodyMedium: TextStyle(color: Color(0xFFBBB9B3), height: 1.6),
          labelSmall: TextStyle(color: Color(0xFF8A8880), fontSize: 10),
        ),
      );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: _primaryDark,
          secondary: _primary,
          surface: _surfaceLight,
          onPrimary: Colors.white,
          onSurface: Color(0xFF1A1814),
        ),
        scaffoldBackgroundColor: _bgLight,
        cardColor: Colors.white,
        fontFamily: 'serif',
        appBarTheme: const AppBarTheme(
          backgroundColor: _bgLight,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFF1A1814),
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          iconTheme: IconThemeData(color: _primaryDark),
        ),
        dividerColor: const Color(0xFFDDDAD3),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF2A2820), height: 1.65),
          bodyMedium: TextStyle(color: Color(0xFF4A4840), height: 1.6),
          labelSmall: TextStyle(color: Color(0xFF8A8880), fontSize: 10),
        ),
      );
}
