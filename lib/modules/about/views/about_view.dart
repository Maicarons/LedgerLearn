import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import '../controllers/about_controller.dart';

class AboutView extends GetView<AboutController> {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AboutController());
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('about_title'.tr)),
      body: Column(
        children: [
          // App info header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: colorScheme.primaryContainer,
                  ),
                  child: Icon(
                    Icons.account_balance_rounded,
                    size: 32,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LedgerLearn',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${'settings_version'.tr}: ${controller.version}',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        '${'about_license'.tr}: GPL-3.0',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tabbed readme / changelog
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      tabAlignment: TabAlignment.fill,
                      tabs: [
                        Tab(text: 'about_readme'.tr),
                        Tab(text: 'about_changelog'.tr),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          Markdown(
                            data: controller.readmeContent.value,
                            selectable: true,
                          ),
                          Markdown(
                            data: controller.changelogContent.value,
                            selectable: true,
                            padding: const EdgeInsets.all(16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
