import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../app/config/app_version.dart';

class AboutController extends GetxController {
  final readmeContent = ''.obs;
  final changelogContent = ''.obs;
  final isLoading = true.obs;

  String get version => appVersion;
  String get versionWithCode => '$appVersion+$appVersionCode';

  @override
  void onInit() {
    super.onInit();
    loadContent();
  }

  /// Pick README asset by current UI language.
  static String readmeAssetForLocale(String locale) {
    switch (locale) {
      case 'en_US':
        return 'README_en.md';
      case 'ko_KR':
        return 'README_ko.md';
      case 'zh_CN':
      case 'zh_TW':
      default:
        return 'README.md';
    }
  }

  String get _locale =>
      Get.locale?.toLanguageTag().replaceAll('-', '_') ?? 'zh_CN';

  Future<void> loadContent() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        rootBundle.loadString(readmeAssetForLocale(_locale)),
        rootBundle.loadString('CHANGELOG.md'),
      ]);
      readmeContent.value = results[0];
      changelogContent.value = results[1];
    } catch (_) {
      try {
        readmeContent.value = await rootBundle.loadString('README.md');
      } catch (__) {
        readmeContent.value = 'Failed to load readme.';
      }
      try {
        changelogContent.value = await rootBundle.loadString('CHANGELOG.md');
      } catch (__) {
        changelogContent.value = 'Failed to load changelog.';
      }
    } finally {
      isLoading.value = false;
    }
  }
}
