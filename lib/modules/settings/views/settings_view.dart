import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../../../app/theme/app_theme.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('settings_title'.tr)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== Theme =====
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('theme_title'.tr,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  // Theme mode
                  Text('模式', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  Obx(() => SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.system,
                            icon: Icon(Icons.settings_suggest, size: 18),
                            label: Text('自动', style: TextStyle(fontSize: 12)),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            icon: Icon(Icons.light_mode, size: 18),
                            label: Text('浅色', style: TextStyle(fontSize: 12)),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            icon: Icon(Icons.dark_mode, size: 18),
                            label: Text('深色', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                        selected: {controller.currentThemeMode},
                        onSelectionChanged: (v) => controller.setThemeMode(v.first),
                      )),
                  const SizedBox(height: 16),

                  // Color scheme
                  Text('theme_color'.tr, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  Obx(() => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: AppColorScheme.values.map((scheme) {
                          final selected = controller.currentColorScheme == scheme;
                          return GestureDetector(
                            onTap: () => controller.setColorScheme(scheme),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: scheme.seedColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selected
                                      ? colorScheme.onSurface
                                      : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: selected
                                    ? [BoxShadow(color: scheme.seedColor.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 2))]
                                    : [],
                              ),
                              child: selected
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : null,
                            ),
                          );
                        }).toList(),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ===== Language =====
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('settings_language'.tr,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Obx(() => Column(
                        children: [
                          RadioListTile<String>(
                            title: Text('中文'),
                            subtitle: const Text('简体中文'),
                            value: 'zh_CN',
                            groupValue: controller.selectedLocale.value,
                            onChanged: (v) {
                              if (v != null) controller.switchLanguage(v);
                            },
                          ),
                          RadioListTile<String>(
                            title: const Text('English'),
                            subtitle: const Text('English'),
                            value: 'en_US',
                            groupValue: controller.selectedLocale.value,
                            onChanged: (v) {
                              if (v != null) controller.switchLanguage(v);
                            },
                          ),
                          RadioListTile<String>(
                            title: const Text('한국어'),
                            subtitle: const Text('한국어'),
                            value: 'ko_KR',
                            groupValue: controller.selectedLocale.value,
                            onChanged: (v) {
                              if (v != null) controller.switchLanguage(v);
                            },
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ===== Learning Progress =====
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('settings_progress'.tr,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Obx(() {
                    final count = controller.voucherCount.value;
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('voucher_title'.tr),
                            Text('$count 个凭证'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (count / 20).clamp(0.0, 1.0),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ===== Data Management =====
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('settings_data'.tr,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Get.defaultDialog(
                        title: 'settings_reset_data'.tr,
                        middleText: 'settings_reset_confirm'.tr,
                        textConfirm: 'confirm'.tr,
                        textCancel: 'cancel'.tr,
                        confirmTextColor: Colors.white,
                        onConfirm: () {
                          controller.resetData();
                          Get.back();
                        },
                      );
                    },
                    icon: const Icon(Icons.refresh, color: Colors.red),
                    label: Text('settings_reset_data'.tr,
                        style: const TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ===== About =====
          Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Get.toNamed('/about'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('settings_about'.tr,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text('LedgerLearn',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          Text('${'settings_version'.tr}: 1.0.0',
                              style: TextStyle(color: Colors.grey.shade600)),
                          const SizedBox(height: 4),
                          Text('about_view_details'.tr,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey.shade400),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
