import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: JolusColors.primary,
        primary: JolusColors.primary,
        surface: JolusColors.background,
        onSurface: const Color(0xFF1A1B21),
      ),
      textTheme: GoogleFonts.manropeTextTheme(),
    );
  }
}
