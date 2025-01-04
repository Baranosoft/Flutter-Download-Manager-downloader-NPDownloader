import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_data.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  AppTheme _currentTheme = appThemes[0];

  bool get isDarkMode => _isDarkMode;
  AppTheme get currentTheme => _currentTheme;

  ThemeData get themeData {
    final colorScheme = _isDarkMode
        ? ColorScheme(
            brightness: Brightness.dark,
            primary: _currentTheme.darkPrimary,
            secondary: _currentTheme.darkSecondary,
            tertiary: _currentTheme.darkTertiary,
            surface: _currentTheme.darkSurface,
            onPrimary: _currentTheme.darkOnPrimary,
            onSecondary: _currentTheme.darkOnSecondary,
            onTertiary: _currentTheme.darkOnTertiary,
            onSurface: _currentTheme.darkOnSurface,
            primaryContainer: _currentTheme.darkPrimaryContainer,
            secondaryContainer: _currentTheme.darkSecondaryContainer,
            tertiaryContainer: _currentTheme.darkTertiaryContainer,
            onPrimaryContainer: _currentTheme.darkOnPrimaryContainer,
            onSecondaryContainer: _currentTheme.darkOnSecondaryContainer,
            onTertiaryContainer: _currentTheme.darkOnTertiaryContainer,
            surfaceDim: _currentTheme.darkSurfaceDim,
            surfaceBright: _currentTheme.darkSurfaceBright,
            surfaceContainerLowest: _currentTheme.darkSurfaceContainerLowest,
            surfaceContainerLow: _currentTheme.darkSurfaceContainerLow,
            surfaceContainer: _currentTheme.darkSurfaceContainer,
            surfaceContainerHigh: _currentTheme.darkSurfaceContainerHigh,
            surfaceContainerHighest: _currentTheme.darkSurfaceContainerHighest,
            onSurfaceVariant: _currentTheme.darkOnSurfaceVar,
            outline: _currentTheme.darkOutline,
            outlineVariant: _currentTheme.darkOutlineVariant,
            inverseSurface: _currentTheme.darkInverseSurface,
            onInverseSurface: _currentTheme.darkInverseOnSurface,
            inversePrimary: _currentTheme.darkInversePrimary,
            primaryFixedDim: _currentTheme.darkSvgColor,
            error: const Color(0xffffb4ab),
            onError: const Color(0xff690005),
            errorContainer: const Color(0xff93000a),
            onErrorContainer: const Color(0xffffdad6),
            scrim: Colors.black,
            shadow: Colors.black
          )
        : ColorScheme(
            brightness: Brightness.light,
            primary: _currentTheme.lightPrimary,
            secondary: _currentTheme.lightSecondary,
            tertiary: _currentTheme.lightTertiary,
            surface: _currentTheme.lightSurface,
            onPrimary: _currentTheme.lightOnPrimary,
            onSecondary: _currentTheme.lightOnSecondary,
            onTertiary: _currentTheme.lightOnTertiary,
            onSurface: _currentTheme.lightOnSurface,
            primaryContainer: _currentTheme.lightPrimaryContainer,
            secondaryContainer: _currentTheme.lightSecondaryContainer,
            tertiaryContainer: _currentTheme.lightTertiaryContainer,
            onPrimaryContainer: _currentTheme.lightOnPrimaryContainer,
            onSecondaryContainer: _currentTheme.lightOnSecondaryContainer,
            onTertiaryContainer: _currentTheme.lightOnTertiaryContainer,
            surfaceDim: _currentTheme.lightSurfaceDim,
            surfaceBright: _currentTheme.lightSurfaceBright,
            surfaceContainerLowest: _currentTheme.lightSurfaceContainerLowest,
            surfaceContainerLow: _currentTheme.lightSurfaceContainerLow,
            surfaceContainer: _currentTheme.lightSurfaceContainer,
            surfaceContainerHigh: _currentTheme.lightSurfaceContainerHigh,
            surfaceContainerHighest: _currentTheme.lightSurfaceContainerHighest,
            onSurfaceVariant: _currentTheme.lightOnSurfaceVar,
            outline: _currentTheme.lightOutline,
            outlineVariant: _currentTheme.lightOutlineVariant,
            inverseSurface: _currentTheme.lightInverseSurface,
            onInverseSurface: _currentTheme.lightInverseOnSurface,
            inversePrimary: _currentTheme.lightInversePrimary,
            primaryFixedDim: _currentTheme.lightSvgColor,
            error: const Color(0xffba1a1a),
            onError: Colors.white,
            errorContainer: const Color(0xffffdad6),
            onErrorContainer: const Color(0xff410002),
            scrim: Colors.black,
            shadow: Colors.black
          );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme
    );
  }

  void toggleDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    await _savePreferences();
  }

  void setTheme(int index) async {
    _currentTheme = appThemes[index];
    notifyListeners();
    await _savePreferences();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setInt('themeIndex', appThemes.indexOf(_currentTheme));
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    final themeIndex = prefs.getInt('themeIndex') ?? 0;
    _currentTheme = appThemes[themeIndex];
    notifyListeners();
  }


}
