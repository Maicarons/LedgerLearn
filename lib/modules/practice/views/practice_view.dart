import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/practice.dart';
import '../../../data/services/practice_service.dart';
import '../controllers/practice_controller.dart';
import 'quiz_view.dart';
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
          IconButton(
            tooltip: 'quiz_title'.tr,
            icon: const Icon(Icons.quiz_outlined),
            onPressed: () {
              Get.to(() => const QuizView());
            },
          ),
        ],
      ),
      body: Obx(() {
        final passed = c.passedIds.toSet();
        final next = c.nextRecommended;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Overall progress + next recommended
            Card(
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
                    if (next != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${'practice_next_up'.tr}: ${next.titleKey.tr}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          FilledButton.tonal(
                            onPressed: () async {
                              await Get.toNamed('/practice/${next.id}');
                              c.reload();
                            },
                            child: Text('practice_solve'.tr),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Get.to(() => const QuizView()),
                            icon: const Icon(Icons.quiz_outlined, size: 18),
                            label: Text('quiz_start'.tr),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Get.to(() => const WrongBookView()),
                            icon: const Icon(Icons.bookmark_remove_outlined,
                                size: 18),
                            label: Text('practice_wrong_book'.tr),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Chapters
            for (final ch in practiceChapters) ...[
              _ChapterTile(chapter: ch, controller: c),
            ],
          ],
        );
      }),
    );
  }
}

class _ChapterTile extends StatelessWidget {
  final PracticeChapter chapter;
  final PracticeController controller;

  const _ChapterTile({required this.chapter, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final unlocked = controller.isChapterUnlocked(chapter.id);
    final progress = controller.chapterProgress(chapter.id);
    final items = controller.chapterScenarios(chapter.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        initiallyExpanded: unlocked && progress < 1,
        leading: CircleAvatar(
          backgroundColor: !unlocked
              ? colorScheme.surfaceContainerHighest
              : progress >= 1
                  ? colorScheme.tertiaryContainer
                  : colorScheme.primaryContainer,
          child: Icon(
            !unlocked
                ? Icons.lock_outline
                : progress >= 1
                    ? Icons.check
                    : Icons.menu_book_outlined,
            color: !unlocked
                ? colorScheme.outline
                : progress >= 1
                    ? colorScheme.onTertiaryContainer
                    : colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          chapter.titleKey.tr,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: unlocked ? null : colorScheme.outline,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              unlocked
                  ? chapter.subtitleKey.tr
                  : 'chapter_locked'.tr,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 12,
                  color: unlocked ? colorScheme.outline : colorScheme.error),
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
          ],
        ),
        children: [
          if (chapter.knowledgeIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final id in chapter.knowledgeIds)
                    ActionChip(
                      avatar: const Icon(Icons.menu_book_outlined, size: 16),
                      label: Text('chapter_read_knowledge'.tr),
                      onPressed: () => Get.toNamed('/knowledge/detail/$id'),
                    ),
                ],
              ),
            ),
          if (!unlocked)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text('chapter_locked_hint'.tr,
                  style: TextStyle(color: colorScheme.outline, fontSize: 12)),
            )
          else
            ...items.map((s) {
              final stars = controller.starsOf(s.id);
              final done = controller.passedIds.contains(s.id);
              return ListTile(
                dense: true,
                leading: Icon(
                  done ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: done ? colorScheme.tertiary : colorScheme.outline,
                ),
                title: Text(s.titleKey.tr),
                subtitle: Text(
                  s.descriptionKey.tr,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: _Stars(count: stars),
                onTap: () async {
                  await Get.toNamed('/practice/${s.id}');
                  controller.reload();
                },
              );
            }),
        ],
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  final int count;
  const _Stars({required this.count});

  @override
  Widget build(BuildContext context) {
    final color = Colors.amber.shade700;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Icon(
          i < count ? Icons.star : Icons.star_border,
          size: 16,
          color: i < count ? color : Colors.grey.shade400,
        );
      }),
    );
  }
}
