import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/config/app_version.dart';

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
                  Text('theme_mode'.tr,
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  Obx(() => SegmentedButton<ThemeMode>(
                        segments: [
                          ButtonSegment(
                            value: ThemeMode.system,
                            icon: const Icon(Icons.settings_suggest, size: 18),
                            label: Text('theme_mode_system'.tr,
                                style: const TextStyle(fontSize: 12)),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            icon: const Icon(Icons.light_mode, size: 18),
                            label: Text('theme_mode_light'.tr,
                                style: const TextStyle(fontSize: 12)),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            icon: const Icon(Icons.dark_mode, size: 18),
                            label: Text('theme_mode_dark'.tr,
                                style: const TextStyle(fontSize: 12)),
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
                  Obx(() => RadioGroup<String>(
                        groupValue: controller.selectedLocale.value,
                        onChanged: (v) {
                          if (v != null) controller.switchLanguage(v);
                        },
                        child: Column(
                          children: [
                            RadioListTile<String>(
                              title: Text('settings_language_zh'.tr),
                              subtitle: const Text('zh_CN'),
                              value: 'zh_CN',
                            ),
                            RadioListTile<String>(
                              title: Text('settings_language_en'.tr),
                              subtitle: const Text('en_US'),
                              value: 'en_US',
                            ),
                            RadioListTile<String>(
                              title: Text('settings_language_ko'.tr),
                              subtitle: const Text('ko_KR'),
                              value: 'ko_KR',
                            ),
                            RadioListTile<String>(
                              title: Text('settings_language_ja'.tr),
                              subtitle: const Text('ja_JP'),
                              value: 'ja_JP',
                            ),
                            RadioListTile<String>(
                              title: Text('settings_language_vi'.tr),
                              subtitle: const Text('vi_VN'),
                              value: 'vi_VN',
                            ),
                            RadioListTile<String>(
                              title: Text('settings_language_th'.tr),
                              subtitle: const Text('th_TH'),
                              value: 'th_TH',
                            ),
                          ],
                        ),
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
                    final vCount = controller.progress.voucherCount.value;
                    final kCount =
                        controller.progress.knowledgeReadCount.value;
                    final achievements =
                        controller.progress.unlockedAchievements;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('voucher_title'.tr),
                            Text('settings_progress_vouchers'
                                .trParams({'count': '$vCount'})),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (vCount / 20).clamp(0.0, 1.0),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('settings_progress_knowledge'.tr),
                            Text('$kCount'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('achievements'.tr,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        if (achievements.isEmpty)
                          Text('no_data'.tr,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500))
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: achievements
                                .map((a) => Tooltip(
                                      message: a.descKey.tr,
                                      child: Chip(
                                        avatar: Icon(a.icon,
                                            color: a.color, size: 18),
                                        label: Text(a.titleKey.tr,
                                            style: const TextStyle(
                                                fontSize: 12)),
                                        backgroundColor:
                                            a.color.withValues(alpha: 0.08),
                                        side: BorderSide(
                                            color: a.color
                                                .withValues(alpha: 0.3)),
                                      ),
                                    ))
                                .toList(),
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
                          Text('${'settings_version'.tr}: $appVersion',
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
