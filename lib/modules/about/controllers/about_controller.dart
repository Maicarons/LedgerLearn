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
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final results = await Future.wait([
        rootBundle.loadString('README.md'),
        rootBundle.loadString('CHANGELOG.md'),
      ]);
      readmeContent.value = results[0];
      changelogContent.value = results[1];
    } catch (e) {
      readmeContent.value = 'Failed to load readme.';
      changelogContent.value = 'Failed to load changelog.';
    } finally {
      isLoading.value = false;
    }
  }
}
