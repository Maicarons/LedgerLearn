import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/utils/helpers.dart';
import '../controllers/year_end_controller.dart';

/// Guided year-end closing workbench (损益结转 → 利润分配 → 盈余公积).
class YearEndClosingView extends GetView<YearEndClosingController> {
  const YearEndClosingView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final c = Get.put(YearEndClosingController());
    final locale =
        Get.locale?.toLanguageTag().replaceAll('-', '_') ?? 'zh_CN';

    return Scaffold(
      appBar: AppBar(
        title: Text('yearend_title'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Get.defaultDialog(
                title: 'reports_how_to_read'.tr,
                middleText: 'yearend_hint'.tr,
                textConfirm: 'ok'.tr,
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        final step = c.step.value;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Year picker
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18),
                    const SizedBox(width: 10),
                    Text('yearend_year'.tr),
                    const Spacer(),
                    DropdownButton<int>(
                      value: c.year.value,
                      underline: const SizedBox(),
                      items: [
                        for (var y = DateTime.now().year;
                            y >= DateTime.now().year - 3;
                            y--)
                          DropdownMenuItem(value: y, child: Text('$y')),
                      ],
                      onChanged: (v) {
                        if (v != null) c.setYear(v);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Stepper
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('yearend_progress'.tr,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    _StepBar(current: step),
                    const SizedBox(height: 16),
                    if (step == 0) ...[
                      Text('yearend_intro'.tr),
                      const SizedBox(height: 8),
                      Text(
                        '${'yearend_net_profit'.tr}: '
                        '${formatCurrency(c.netProfit, locale)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: c.netProfit >= 0
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ] else if (step >= 1 && step <= 4) ...[
                      _StepBody(c: c, step: step, locale: locale),
                    ] else ...[
                      Icon(Icons.emoji_events,
                          size: 56, color: colorScheme.primary),
                      const SizedBox(height: 12),
                      Text('yearend_done'.tr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        '${'yearend_net_profit'.tr}: '
                        '${formatCurrency(c.netProfit, locale)}\n'
                        '${'yearend_surplus'.tr}: '
                        '${formatCurrency(c.surplusReserve, locale)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colorScheme.outline),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: c.prevStep,
                      child: Text('back'.tr),
                    ),
                  ),
                if (step > 0) const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: step >= 5 ? null : c.nextStep,
                    child: Text(step >= 5 ? 'ok'.tr : 'next'.tr),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class _StepBar extends StatelessWidget {
  final int current;
  const _StepBar({required this.current});

  @override
  Widget build(BuildContext context) {
    final labels = [
      'yearend_step_intro',
      'yearend_step_revenue',
      'yearend_step_expense',
      'yearend_step_profit',
      'yearend_step_reserve',
      'yearend_step_done',
    ];
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                color: i <= current
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          CircleAvatar(
            radius: 12,
            backgroundColor: i <= current
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Text(
              '${i + 1}',
              style: TextStyle(
                fontSize: 10,
                color: i <= current
                    ? Colors.white
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _StepBody extends StatelessWidget {
  final YearEndClosingController c;
  final int step;
  final String locale;
  const _StepBody({required this.c, required this.step, required this.locale});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final v = c.preview(step);
    if (v == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text('yearend_skip_reserve'.tr,
            style: TextStyle(color: colorScheme.outline)),
      );
    }
    final saved = c.isStepSaved(step);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ['',
            'yearend_step_revenue',
            'yearend_step_expense',
            'yearend_step_profit',
            'yearend_step_reserve',
          ][step].tr,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 8),
        Text(v.summary, style: TextStyle(color: colorScheme.outline)),
        const SizedBox(height: 8),
        for (final e in v.entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${e.isDebit ? '借' : '贷'}  ${e.accountName}',
                    style: TextStyle(
                      color: e.isDebit ? colorScheme.primary : Colors.red.shade700,
                    ),
                  ),
                ),
                Text(formatCurrency(e.amount, locale)),
              ],
            ),
          ),
        const Divider(height: 20),
        Row(
          children: [
            Expanded(
              child: saved
                  ? Chip(
                      avatar: const Icon(Icons.check, size: 16),
                      label: Text('yearend_saved'.tr),
                    )
                  : FilledButton.tonal(
                      onPressed: () async {
                        final id = await c.saveStep(step);
                        if (id != null) {
                          Get.snackbar('success'.tr, 'yearend_saved'.tr,
                              snackPosition: SnackPosition.BOTTOM);
                        }
                      },
                      child: Text('yearend_save_step'.tr),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
