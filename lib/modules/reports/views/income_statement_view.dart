import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reports_controller.dart';
import '../../../shared/utils/helpers.dart';
import '../../../data/services/export_service.dart';

class IncomeStatementView extends GetView<IncomeStatementController> {
  const IncomeStatementView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(IncomeStatementController());
    final locale =
        Get.locale?.toLanguageTag().replaceAll('-', '_') ?? 'zh_CN';

    return Scaffold(
      appBar: AppBar(
        title: Text('reports_income_statement'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'export_csv'.tr,
            onPressed: () async {
              final path = await ExportService.exportIncomeStatementCsv(
                revenues: controller.revenueItems
                    .where((i) => i.amount > 0)
                    .map((i) => MapEntry(i.name, i.amount))
                    .toList(),
                expenses: controller.expenseItems
                    .where((i) => i.amount > 0)
                    .map((i) => MapEntry(i.name, i.amount))
                    .toList(),
                totalRevenue: controller.totalRevenue,
                totalExpense: controller.totalExpense,
                netProfit: controller.netProfit,
                locale: locale,
              );
              if (path != null && context.mounted) {
                Get.snackbar('export_success'.tr, 'export_saved'.tr,
                    snackPosition: SnackPosition.BOTTOM);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Get.defaultDialog(
                title: 'reports_how_to_read'.tr,
                middleText: 'reports_income_hint'.tr,
                textConfirm: 'ok'.tr,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text('reports_income_statement'.tr,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                              flex: 3,
                              child: Text('reports_item'.tr,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600))),
                          Expanded(
                              flex: 2,
                              child: Text('reports_current_period'.tr,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600))),
                          Expanded(
                              flex: 2,
                              child: Text('reports_prev_period'.tr,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600))),
                          Expanded(
                              child: Text('reports_change'.tr,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600))),
                        ],
                      ),
                    ),
                    const Divider(),
                    ...controller.revenueItems
                        .where((i) => i.amount > 0 || i.prevAmount > 0)
                        .map((i) => _CompareRow(
                              label: i.name,
                              amount: i.amount,
                              prev: i.prevAmount,
                              locale: locale,
                            )),
                    const Divider(),
                    _CompareRow(
                        label: 'reports_revenue'.tr,
                        amount: controller.totalRevenue,
                        prev: controller.prevTotalRevenue,
                        locale: locale,
                        bold: true),
                    const SizedBox(height: 16),
                    ...controller.expenseItems
                        .where((i) => i.amount > 0 || i.prevAmount > 0)
                        .map((i) => _CompareRow(
                              label: i.name,
                              amount: i.amount,
                              prev: i.prevAmount,
                              locale: locale,
                            )),
                    const Divider(),
                    _CompareRow(
                        label: 'reports_expense'.tr,
                        amount: controller.totalExpense,
                        prev: controller.prevTotalExpense,
                        locale: locale,
                        bold: true),
                    const SizedBox(height: 16),
                    const Divider(thickness: 2),
                    _CompareRow(
                        label: 'reports_net_profit'.tr,
                        amount: controller.netProfit,
                        prev: controller.prevNetProfit,
                        locale: locale,
                        bold: true,
                        isProfit: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  final String label;
  final double amount;
  final double prev;
  final String locale;
  final bool bold;
  final bool isProfit;

  const _CompareRow({
    required this.label,
    required this.amount,
    required this.prev,
    required this.locale,
    this.bold = false,
    this.isProfit = false,
  });

  @override
  Widget build(BuildContext context) {
    final delta = amount - prev;
    final deltaColor = delta > 0
        ? Colors.green.shade700
        : delta < 0
            ? Colors.red.shade700
            : Colors.grey;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label,
                style: TextStyle(fontWeight: bold ? FontWeight.bold : null)),
          ),
          Expanded(
            flex: 2,
            child: Text(formatCurrency(amount, locale),
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : null,
                  fontSize: bold ? 15 : 13,
                  color: isProfit
                      ? (amount >= 0 ? Colors.green : Colors.red)
                      : null,
                )),
          ),
          Expanded(
            flex: 2,
            child: Text(formatCurrency(prev, locale),
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(
              delta == 0
                  ? '—'
                  : '${delta > 0 ? '+' : ''}${formatCurrency(delta, locale)}',
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: deltaColor),
            ),
          ),
        ],
      ),
    );
  }
}
