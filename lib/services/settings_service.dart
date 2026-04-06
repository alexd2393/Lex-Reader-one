import 'package:flutter/material.dart';

class SettingsService extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  double _blueLightIntensity = 0.0; // 0.0 = desactivado, 1.0 = máximo

  ThemeMode get themeMode => _themeMode;
  double get blueLightIntensity => _blueLightIntensity;
  bool get blueLightEnabled => _blueLightIntensity > 0.0;

  void toggleDarkMode() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setBlueLightIntensity(double value) {
    _blueLightIntensity = value.clamp(0.0, 1.0);
    notifyListeners();
  }
}
