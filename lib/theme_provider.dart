import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isDynamic = false; // Add this line

  ThemeMode get themeMode => _themeMode;
  bool get isDynamic => _isDynamic; // And this getter

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  // Method to toggle the dynamic color setting
  void toggleDynamicColor() {
    _isDynamic = !_isDynamic;
    notifyListeners();
  }

  // Kept for any existing calls, but new implementation should use setThemeMode
  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setSystemTheme() {
    setThemeMode(ThemeMode.system);
  }
}
