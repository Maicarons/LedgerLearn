import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/database_service.dart';
import '../../../data/services/progress_service.dart';
import '../../../app/theme/app_theme.dart';
import '../../about/controllers/about_controller.dart';
import 'theme_controller.dart';

class SettingsController extends GetxController {
  final DatabaseService db = Get.find<DatabaseService>();
  final ThemeController themeCtrl = Get.find<ThemeController>();
  final ProgressService progress = Get.find<ProgressService>();

  final selectedLocale = ''.obs;

  @override
  void onInit() {
    super.onInit();
    selectedLocale.value = db.getLocale();
    // Defer: reload() writes Rx and may run while parent widgets are building.
    Future.microtask(progress.reload);
  }

  void switchLanguage(String locale) {
    selectedLocale.value = locale;
    db.setLocale(locale);
    Get.updateLocale(Locale(locale.split('_')[0], locale.split('_')[1]));
    // Keep About README / lists in sync with the new language.
    if (Get.isRegistered<AboutController>()) {
      Get.find<AboutController>().loadContent();
    }
  }

  void setThemeMode(ThemeMode mode) {
    themeCtrl.setThemeMode(mode);
    update();
  }

  void setColorScheme(AppColorScheme scheme) {
    themeCtrl.setColorScheme(scheme);
    update();
  }

  ThemeMode get currentThemeMode => themeCtrl.currentThemeMode;
  AppColorScheme get currentColorScheme => themeCtrl.currentScheme;

  Future<void> resetData() async {
    await db.resetAll();
    Future.microtask(progress.reload);
    Get.snackbar('success'.tr, 'settings_reset_success'.tr,
        snackPosition: SnackPosition.BOTTOM);
  }
}
