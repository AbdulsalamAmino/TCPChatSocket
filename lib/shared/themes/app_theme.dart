import 'package:flutter/material.dart';

/// Application theme configuration
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData.light(useMaterial3: true);
  }

  static ThemeData get darkTheme {
    return ThemeData.dark(useMaterial3: true);
  }
} 