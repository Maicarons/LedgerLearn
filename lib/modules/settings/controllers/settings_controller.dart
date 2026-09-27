import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/backup_service.dart';
import '../../../data/services/csv_import_service.dart';
import '../../../data/services/database_service.dart';
import '../../../data/services/practice_service.dart';
import '../../../data/services/progress_service.dart';
import '../../../app/theme/app_theme.dart';
import '../../about/controllers/about_controller.dart';
import '../../home/controllers/home_controller.dart';
import 'theme_controller.dart';

class SettingsController extends GetxController {
  final DatabaseService db = Get.find<DatabaseService>();
  final ThemeController themeCtrl = Get.find<ThemeController>();
  final ProgressService progress = Get.find<ProgressService>();
  final PracticeService practice = Get.find<PracticeService>();

  late final BackupService backup = BackupService(db, practice);
  late final CsvImportService csvImport = CsvImportService(
    accountRepo: Get.find(),
    voucherRepo: Get.find(),
  );

  final selectedLocale = ''.obs;
  final isBusy = false.obs;

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

  /// Export the full ledger book to a JSON file. Returns the file path.
  Future<String?> exportBackup() async {
    isBusy.value = true;
    try {
      final path = await backup.exportToFile();
      if (path != null) {
        Get.snackbar('success'.tr, '${'backup_export_success'.tr}\n$path',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 5));
      } else {
        Get.snackbar('error'.tr, 'backup_export_failed'.tr,
            snackPosition: SnackPosition.BOTTOM);
      }
      return path;
    } finally {
      isBusy.value = false;
    }
  }

  /// Restore the book from a pasted or loaded JSON document.
  Future<bool> importBackup(String jsonText) async {
    isBusy.value = true;
    try {
      await backup.restoreFromJson(jsonText);
      Future.microtask(progress.reload);
      // Keep theme/locale UI in sync with restored settings.
      selectedLocale.value = db.getLocale();
      themeCtrl.reloadFromStorage();
      if (Get.isRegistered<AboutController>()) {
        Get.find<AboutController>().loadContent();
      }
      Get.snackbar('success'.tr, 'backup_import_success'.tr,
          snackPosition: SnackPosition.BOTTOM);
      return true;
    } on FormatException catch (e) {
      final msg = e.message.toString();
      Get.snackbar('error'.tr, msg.tr,
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (_) {
      Get.snackbar('error'.tr, 'backup_invalid'.tr,
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isBusy.value = false;
    }
  }

  /// Import vouchers from pasted CSV text.
  Future<bool> importCsvVouchers(String csvText) async {
    isBusy.value = true;
    try {
      final result = await csvImport.import(csvText, locale: db.getLocale());
      if (result.created.isEmpty) {
        final err = result.errors.isNotEmpty
            ? result.errors.first
            : 'csv_import_empty';
        Get.snackbar('error'.tr, err.tr,
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }
      Future.microtask(progress.reload);
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().refreshSummary();
      }
      Get.snackbar('success'.tr,
          '${'csv_import_success'.trParams({'n': '${result.created.length}'})}'
          '${result.errors.isEmpty ? '' : '\n${result.errors.length} ${'csv_import_errors'.tr}'}',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4));
      return true;
    } catch (_) {
      Get.snackbar('error'.tr, 'csv_bad_header'.tr,
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isBusy.value = false;
    }
  }
}
