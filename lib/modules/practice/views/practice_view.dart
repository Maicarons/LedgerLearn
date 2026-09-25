import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/practice_controller.dart';
import 'wrong_book_view.dart';

class PracticeView extends GetView<PracticeController> {
  const PracticeView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final c = Get.put(PracticeController());

    return Scaffold(
      appBar: AppBar(
        title: Text('practice_title'.tr),
        actions: [
          IconButton(
            tooltip: 'practice_wrong_book'.tr,
            icon: const Icon(Icons.bookmark_remove_outlined),
            onPressed: () => Get.to(() => const WrongBookView()),
          ),
        ],
      ),
      body: Obx(() {
        final passed = c.passedIds.toSet();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('practice_progress'.tr,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: c.progress,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${passed.length} / ${c.scenarios.length}',
                        style: TextStyle(color: colorScheme.outline),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: c.scenarios.length,
                itemBuilder: (context, i) {
                  final s = c.scenarios[i];
                  final done = passed.contains(s.id);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: done
                            ? colorScheme.tertiaryContainer
                            : colorScheme.primaryContainer,
                        child: Icon(
                          done ? Icons.check : Icons.edit_note,
                          color: done
                              ? colorScheme.onTertiaryContainer
                              : colorScheme.onPrimaryContainer,
                        ),
                      ),
                      title: Text(s.titleKey.tr),
                      subtitle: Text(
                        s.descriptionKey.tr,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await Get.toNamed('/practice/${s.id}');
                        c.reload();
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
