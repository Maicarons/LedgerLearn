import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/widgets/account_picker.dart';
import '../../../shared/utils/helpers.dart';
import '../controllers/quiz_controller.dart';

/// Timed quiz session over weak scenarios.
class QuizView extends GetView<QuizController> {
  const QuizView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final c = Get.put(QuizController());

    return Scaffold(
      appBar: AppBar(title: Text('quiz_title'.tr)),
      body: Obx(() {
        if (c.finished.value) {
          return _Summary(c: c);
        }
        final s = c.current;
        if (s == null) {
          return Center(child: Text('no_data'.tr));
        }
        final attempt = c.currentResult.value;
        final entries = c.entries.toList();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Progress
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
                Text(
                  '${c.index.value + 1} / ${c.total}',
                  style: TextStyle(color: colorScheme.outline),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              color: colorScheme.secondaryContainer.withValues(alpha: 0.4),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.titleKey.tr,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(s.descriptionKey.tr),
                    if (s.amountYuan != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'practice_suggested_amount'.trParams({
                          'amount': formatCurrency(s.amountYuan!, 'zh_CN'),
                        }),
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('voucher_entries'.tr,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton.icon(
                  onPressed: c.applySuggestedAmount,
                  icon: const Icon(Icons.auto_fix_normal, size: 18),
                  label: Text('practice_fill_amount'.tr),
                ),
                TextButton.icon(
                  onPressed: c.addEntry,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text('voucher_add_entry'.tr),
                ),
              ],
            ),
            for (var i = 0; i < entries.length; i++)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      AccountPicker(
                        selectedId: entries[i].accountId.isEmpty
                            ? null
                            : entries[i].accountId,
                        onSelected: (a) => c.setAccount(i, a),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: SegmentedButton<bool>(
                              segments: [
                                ButtonSegment(
                                    value: true,
                                    label: Text('voucher_direction_debit'.tr)),
                                ButtonSegment(
                                    value: false,
                                    label:
                                        Text('voucher_direction_credit'.tr)),
                              ],
                              selected: {entries[i].isDebit},
                              onSelectionChanged: (s) =>
                                  c.setDirection(i, s.first),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 120,
                            child: TextFormField(
                              key: ValueKey(
                                  'qamt_$i-${entries[i].amountCents}-${entries[i].accountId}'),
                              initialValue: entries[i].amountCents == 0
                                  ? ''
                                  : entries[i].amount.toStringAsFixed(2),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: InputDecoration(
                                labelText: 'voucher_amount'.tr,
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: (v) =>
                                  c.setAmountYuan(i, double.tryParse(v) ?? 0),
                            ),
                          ),
                          if (entries.length > 2)
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => c.removeEntry(i),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            if (attempt == null)
              FilledButton(
                onPressed: () async {
                  await c.submitCurrent();
                },
                child: Text('practice_submit'.tr),
              )
            else
              FilledButton(
                onPressed: c.next,
                child: Text(c.hasNext ? 'quiz_next'.tr : 'quiz_finish'.tr),
              ),
            if (attempt != null) ...[
              const SizedBox(height: 16),
              Card(
                color: attempt.passed
                    ? colorScheme.tertiaryContainer
                    : colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            attempt.passed ? Icons.check_circle : Icons.error,
                            color: attempt.passed
                                ? colorScheme.onTertiaryContainer
                                : colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            attempt.passed
                                ? 'practice_passed'.tr
                                : 'practice_failed'.tr,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      if (attempt.problems.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ...attempt.problems.map((p) => Text('• ${p.tr}')),
                      ],
                      const SizedBox(height: 12),
                      Text('practice_explanation'.tr,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(s.explanationKey.tr),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }
}

class _Summary extends StatelessWidget {
  final QuizController c;
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
          Icon(Icons.emoji_events, size: 72, color: colorScheme.primary),
          const SizedBox(height: 16),
          Text('quiz_summary_title'.tr,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'quiz_summary_body'.trParams({
              'pass': '${c.passCount}',
              'total': '${c.total}',
            }),
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.outline),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () {
              c.restart();
            },
            child: Text('quiz_restart'.tr),
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
