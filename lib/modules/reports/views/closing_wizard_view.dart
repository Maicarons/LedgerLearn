import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/utils/helpers.dart';
import '../controllers/closing_wizard_controller.dart';

class ClosingWizardView extends GetView<ClosingWizardController> {
  const ClosingWizardView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final c = Get.put(ClosingWizardController());

    return Scaffold(
      appBar: AppBar(title: Text('closing_title'.tr)),
      body: Obx(() {
        final step = c.step.value;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '${'closing_step'.tr} ${step.clamp(1, 3)} / 3',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: (step / 3).clamp(0, 1)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (step == 0) _intro(colorScheme),
                  if (step == 1) _revenueStep(c, colorScheme),
                  if (step == 2) _expenseStep(c, colorScheme),
                  if (step == 3) _profitStep(c, colorScheme),
                  if (step == 4) _done(c, colorScheme),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (step > 0 && step < 4)
                      OutlinedButton(
                        onPressed: c.prevStep,
                        child: Text('back'.tr),
                      ),
                    const Spacer(),
                    if (step < 4)
                      FilledButton(
                        onPressed: c.nextStep,
                        child: Text(step == 0 ? 'closing_start'.tr : 'next'.tr),
                      ),
                    if (step == 4)
                      FilledButton(
                        onPressed: () => Get.back(),
                        child: Text('close'.tr),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _intro(ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('closing_intro_title'.tr,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text('closing_intro_body'.tr),
            const SizedBox(height: 12),
            Text('closing_intro_steps'.tr,
                style: TextStyle(color: colorScheme.outline)),
          ],
        ),
      ),
    );
  }

  Widget _revenueStep(ClosingWizardController c, ColorScheme colorScheme) {
    final v = c.preview(1);
    return _stepCard(
      colorScheme,
      title: 'closing_step_revenue'.tr,
      body: 'closing_step_revenue_desc'.tr,
      lines: c.revenueItems
          .map((r) => '${r.name}  ${formatCurrency(r.amount, 'zh_CN')}')
          .toList(),
      voucher: v,
      onSave: () async {
        final id = await c.saveStep(1);
        if (id != null) {
          Get.snackbar('voucher_save_success'.tr, id);
        }
      },
    );
  }

  Widget _expenseStep(ClosingWizardController c, ColorScheme colorScheme) {
    final v = c.preview(2);
    return _stepCard(
      colorScheme,
      title: 'closing_step_expense'.tr,
      body: 'closing_step_expense_desc'.tr,
      lines: c.expenseItems
          .map((r) => '${r.name}  ${formatCurrency(r.amount, 'zh_CN')}')
          .toList(),
      voucher: v,
      onSave: () async {
        final id = await c.saveStep(2);
        if (id != null) {
          Get.snackbar('voucher_save_success'.tr, id);
        }
      },
    );
  }

  Widget _profitStep(ClosingWizardController c, ColorScheme colorScheme) {
    final v = c.preview(3);
    return _stepCard(
      colorScheme,
      title: 'closing_step_profit'.tr,
      body: c.netProfit >= 0
          ? 'closing_step_profit_desc'.trParams({
              'profit': formatCurrency(c.netProfit, 'zh_CN'),
            })
          : 'closing_step_loss_desc'.trParams({
              'loss': formatCurrency(c.netProfit.abs(), 'zh_CN'),
            }),
      lines: [
        'reports_net_profit'.tr + formatCurrency(c.netProfit, 'zh_CN'),
      ],
      voucher: v,
      onSave: () async {
        final id = await c.saveStep(3);
        if (id != null) {
          Get.snackbar('voucher_save_success'.tr, id);
        }
      },
    );
  }

  Widget _done(ClosingWizardController c, ColorScheme colorScheme) {
    return Card(
      color: colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('closing_done_title'.tr,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text('closing_done_body'.tr),
            if (c.savedIds.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...c.savedIds.map((id) => Text('• $id')),
            ],
          ],
        ),
      ),
    );
  }

  Widget _stepCard(
    ColorScheme colorScheme, {
    required String title,
    required String body,
    required List<String> lines,
    required dynamic voucher,
    required VoidCallback onSave,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(body),
            const SizedBox(height: 12),
            ...lines.map((l) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(l),
                )),
            if (voucher != null) ...[
              const Divider(height: 24),
              Text('voucher_entries'.tr,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              ...voucher.entries.map((e) => Text(
                    '${e.accountName}  ${e.isDebit ? 'D' : 'C'}  ${formatCurrency(e.amount, 'zh_CN')}',
                  )),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onSave,
                icon: const Icon(Icons.save_outlined),
                label: Text('save'.tr),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
