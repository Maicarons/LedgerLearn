import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/review_controller.dart';

/// Spaced-repetition review session UI.
class ReviewView extends GetView<ReviewController> {
  const ReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Get.put(ReviewController());

    return Scaffold(
      appBar: AppBar(title: Text('review_title'.tr)),
      body: GetBuilder<ReviewController>(
        builder: (c) {
          if (c.finished.value) {
            return _Summary(c: c);
          }
          final q = c.current;
          if (q == null) {
            return Center(child: Text('review_empty'.tr));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (c.index.value + 1) / c.total,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${c.index.value + 1} / ${c.total}',
                      style: TextStyle(color: colorScheme.outline)),
                ],
              ),
              const SizedBox(height: 12),
              // Card header
              Card(
                color: colorScheme.secondaryContainer.withValues(alpha: 0.35),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.cardTitle,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      if (c.cardCategory.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          c.cardCategory == 'accounting_practice'
                              ? 'knowledge_practice'.tr
                              : c.cardCategory == 'economic_law'
                                  ? 'knowledge_law'.tr
                                  : c.cardCategory == 'tax'
                                      ? 'knowledge_tax'.tr
                                      : c.cardCategory,
                          style: TextStyle(
                              fontSize: 12, color: colorScheme.outline),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(q.questionKey.tr,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              for (var i = 0; i < q.optionKeys.length; i++)
                _OptionTile(
                  label: q.optionKeys[i].tr,
                  selected: c.selected.value == i,
                  revealed: c.graded.value,
                  isAnswer: i == q.answerIndex,
                  onTap: () => c.select(i),
                ),
              const SizedBox(height: 16),
              if (!c.graded.value)
                FilledButton(
                  onPressed: c.selected.value == null
                      ? null
                      : () => c.reveal(),
                  child: Text('review_check'.tr),
                )
              else ...[
                Card(
                  color: c.isCorrect
                      ? colorScheme.tertiaryContainer
                      : colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.isCorrect
                              ? 'knowledge_quiz_correct'.tr
                              : 'knowledge_quiz_wrong'.tr,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 8),
                        Text(q.explainKey.tr),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text('review_grade_label'.tr,
                    style: TextStyle(color: colorScheme.outline)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          await c.applyGrade(0);
                          c.next();
                        },
                        child: Text('review_again'.tr),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          await c.applyGrade(1);
                          c.next();
                        },
                        child: Text('review_hard'.tr),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          await c.applyGrade(2);
                          c.next();
                        },
                        child: Text('review_good'.tr),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: () async {
                          await c.applyGrade(3);
                          c.next();
                        },
                        child: Text('review_easy'.tr),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final bool revealed;
  final bool isAnswer;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.selected,
    required this.revealed,
    required this.isAnswer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Color? bg;
    Color? border;
    if (revealed) {
      if (isAnswer) {
        bg = cs.tertiaryContainer;
        border = cs.tertiary;
      } else if (selected) {
        bg = cs.errorContainer;
        border = cs.error;
      }
    } else if (selected) {
      bg = cs.primaryContainer;
      border = cs.primary;
    }
    return Card(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: border ?? cs.outlineVariant, width: border != null ? 1.5 : 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Expanded(child: Text(label)),
              if (revealed && isAnswer)
                Icon(Icons.check_circle, color: cs.tertiary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final ReviewController c;
  const _Summary({required this.c});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.psychology_alt, size: 72, color: colorScheme.primary),
          const SizedBox(height: 16),
          Text('review_done_title'.tr,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'review_done_body'.trParams({'n': '${c.reviewed.value}'}),
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.outline),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: c.restart,
            child: Text('review_restart'.tr),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Get.back(),
            child: Text('back'.tr),
          ),
        ],
      ),
    );
  }
}
