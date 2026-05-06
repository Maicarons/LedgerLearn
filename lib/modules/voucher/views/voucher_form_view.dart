import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/voucher_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../../shared/widgets/account_picker.dart';
import '../../../shared/utils/helpers.dart';

class VoucherFormView extends GetView<VoucherFormController> {
  final bool isEdit;

  const VoucherFormView({super.key, this.isEdit = false});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VoucherFormController());
    if (isEdit) controller.isEdit.value = true;
    final colorScheme = Theme.of(context).colorScheme;
    final locale =
        Get.locale?.toLanguageTag().replaceAll('-', '_') ?? 'zh_CN';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'voucher_edit'.tr : 'voucher_new'.tr),
        actions: [
          TextButton.icon(
            onPressed: () async {
              final error = controller.validate();
              if (error != null) {
                Get.snackbar('warning'.tr, error,
                    snackPosition: SnackPosition.BOTTOM);
                return;
              }
              final voucher = await controller.save();
              if (voucher != null) {
                // Refresh the list controller if available
                if (Get.isRegistered<VoucherListController>()) {
                  Get.find<VoucherListController>().loadVouchers();
                }
                // Refresh home
                if (Get.isRegistered<HomeController>()) {
                  Get.find<HomeController>().refreshSummary();
                }
                Get.back();
                Get.snackbar('success'.tr, 'voucher_save_success'.tr,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green.shade50);

                // Show knowledge tip
                final knowledge = controller.getRandomKnowledge();
                if (knowledge != null) {
                  Get.defaultDialog(
                    title: 'voucher_knowledge_tip'.tr,
                    middleText: knowledge.getTitle(locale),
                    textConfirm: 'ok'.tr,
                    onConfirm: () => Get.back(),
                  );
                }
              }
            },
            icon: const Icon(Icons.save),
            label: Text('save'.tr),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date picker
                  Obx(() => InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: controller.date.value,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) controller.setDate(picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 20, color: Colors.grey),
                              const SizedBox(width: 12),
                              Text(
                                DateFormat('yyyy-MM-dd')
                                    .format(controller.date.value),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      )),

                  const SizedBox(height: 16),

                  // Summary
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'voucher_summary'.tr,
                      hintText: 'voucher_summary_hint'.tr,
                    ),
                    onChanged: (v) => controller.summary.value = v,
                    controller: TextEditingController(
                        text: controller.summary.value),
                  ),

                  const SizedBox(height: 16),

                  // Templates
                  Text('voucher_templates'.tr,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _TemplateChip(
                          label: 'voucher_template_cash_withdraw'.tr,
                          icon: Icons.money,
                          onTap: () => controller.applyTemplate(0),
                        ),
                        _TemplateChip(
                          label: 'voucher_template_purchase'.tr,
                          icon: Icons.shopping_cart,
                          onTap: () => controller.applyTemplate(1),
                        ),
                        _TemplateChip(
                          label: 'voucher_template_sales'.tr,
                          icon: Icons.sell,
                          onTap: () => controller.applyTemplate(2),
                        ),
                        _TemplateChip(
                          label: 'voucher_template_reimburse'.tr,
                          icon: Icons.flight,
                          onTap: () => controller.applyTemplate(3),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Entries
                  Text('voucher_entries'.tr,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),

                  Obx(() => Column(
                        children: List.generate(controller.entries.length,
                            (i) {
                          final entry = controller.entries[i];
                          return _EntryRow(
                            index: i,
                            entry: entry,
                            controller: controller,
                            colorScheme: colorScheme,
                          );
                        }),
                      )),

                  const SizedBox(height: 8),

                  OutlinedButton.icon(
                    onPressed: () => controller.addEntry(),
                    icon: const Icon(Icons.add),
                    label: Text('voucher_add_entry'.tr),
                  ),

                  const SizedBox(height: 24),

                  // Totals
                  Obx(() => Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('voucher_debit_total'.tr,
                                    style: const TextStyle(fontSize: 15)),
                                Text(
                                  formatCurrency(
                                      controller.totalDebit.value, locale),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('voucher_credit_total'.tr,
                                    style: const TextStyle(fontSize: 15)),
                                Text(
                                  formatCurrency(
                                      controller.totalCredit.value, locale),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(controller.isBalanced.value
                                    ? 'voucher_balanced'.tr
                                    : 'voucher_unbalanced'.tr),
                                Icon(
                                  controller.isBalanced.value
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: controller.isBalanced.value
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ],
                            ),
                            if (!controller.isBalanced.value)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'voucher_balance_rule'.tr,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplateChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _TemplateChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        onPressed: onTap,
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  final int index;
  final dynamic entry;
  final VoucherFormController controller;
  final ColorScheme colorScheme;

  const _EntryRow({
    required this.index,
    required this.entry,
    required this.controller,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Account picker
            Expanded(
              flex: 4,
              child: AccountPicker(
                selectedId: entry.accountId.isEmpty ? null : entry.accountId,
                onSelected: (account) =>
                    controller.setEntryAccount(index, account),
              ),
            ),
            const SizedBox(width: 8),

            // Debit/Credit toggle
            Expanded(
              flex: 2,
              child: SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: true,
                    label: Text('voucher_direction_debit'.tr,
                        style: const TextStyle(fontSize: 12)),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text('voucher_direction_credit'.tr,
                        style: const TextStyle(fontSize: 12)),
                  ),
                ],
                selected: {entry.isDebit},
                onSelectionChanged: (v) =>
                    controller.setEntryDirection(index, v.first),
              ),
            ),
            const SizedBox(width: 8),

            // Amount
            Expanded(
              flex: 3,
              child: TextField(
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'voucher_amount'.tr,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 10),
                ),
                onChanged: (v) => controller.setEntryAmount(
                    index, double.tryParse(v) ?? 0),
              ),
            ),
            const SizedBox(width: 4),

            // Remove
            IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red, size: 20),
              onPressed: () => controller.removeEntry(index),
            ),
          ],
        ),
      ),
    );
  }
}
