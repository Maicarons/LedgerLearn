import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../data/services/database_service.dart';

class ThemeController extends GetxController {
  final DatabaseService db = Get.find<DatabaseService>();

  final colorScheme = AppColorScheme.blue.obs;
  final themeMode = ThemeMode.system.obs;

  AppColorScheme get currentScheme => colorScheme.value;
  ThemeMode get currentThemeMode => themeMode.value;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  void _load() {
    final savedScheme = db.getColorScheme();
    colorScheme.value = AppColorScheme.values.firstWhere(
      (s) => s.name == savedScheme,
      orElse: () => AppColorScheme.blue,
    );

    final savedMode = db.getThemeMode();
    themeMode.value = _parseThemeMode(savedMode);
  }

  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  ThemeData get lightTheme => AppTheme.light(colorScheme.value);
  ThemeData get darkTheme => AppTheme.dark(colorScheme.value);

  void setColorScheme(AppColorScheme scheme) {
    colorScheme.value = scheme;
    db.setColorScheme(scheme.name);
    Get.forceAppUpdate();
  }

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    db.setThemeMode(mode.name);
    Get.forceAppUpdate();
  }
}
