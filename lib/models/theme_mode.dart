import 'package:flutter/material.dart';
import 'package:pokepoke/helper/themeMode_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeNotifier extends ChangeNotifier {
  late ThemeMode _themeMode;

  ThemeModeNotifier(SharedPreferences prefs) {
    _init(prefs);
  }

  ThemeMode get mode => _themeMode;

  void _init(SharedPreferences prefs) async {
    _themeMode = await loadThemeMode(prefs);
    notifyListeners();
  }

  void update(ThemeMode nextMode) {
    _themeMode = nextMode;
    saveThemeMode(nextMode);
    notifyListeners();
  }
}
