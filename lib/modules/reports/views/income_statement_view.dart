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
            tooltip: '导出 CSV',
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
                Get.snackbar('导出成功', '文件已保存', snackPosition: SnackPosition.BOTTOM);
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
                    const Center(
                      child: Text('利润表',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const Center(
                      child: Text('Income Statement',
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey)),
                    ),
                    const Divider(),
                    ...controller.revenueItems
                        .where((i) => i.amount > 0)
                        .map((i) => _TotalRow(
                              label: i.name,
                              amount: i.amount,
                              locale: locale,
                            )),
                    const Divider(),
                    _TotalRow(
                        label: 'reports_revenue'.tr,
                        amount: controller.totalRevenue,
                        locale: locale,
                        bold: true),
                    const SizedBox(height: 16),
                    ...controller.expenseItems
                        .where((i) => i.amount > 0)
                        .map((i) => _TotalRow(
                              label: i.name,
                              amount: i.amount,
                              locale: locale,
                            )),
                    const Divider(),
                    _TotalRow(
                        label: 'reports_expense'.tr,
                        amount: controller.totalExpense,
                        locale: locale,
                        bold: true),
                    const SizedBox(height: 16),
                    const Divider(thickness: 2),
                    _TotalRow(
                        label: 'reports_net_profit'.tr,
                        amount: controller.netProfit,
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

class _TotalRow extends StatelessWidget {
  final String label;
  final double amount;
  final String locale;
  final bool bold;
  final bool isProfit;

  const _TotalRow({
    required this.label,
    required this.amount,
    required this.locale,
    this.bold = false,
    this.isProfit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label,
              style: TextStyle(fontWeight: bold ? FontWeight.bold : null))),
          Text(formatCurrency(amount, locale),
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : null,
                fontSize: bold ? 16 : 14,
                color: isProfit
                    ? (amount >= 0 ? Colors.green : Colors.red)
                    : null,
              )),
        ],
      ),
    );
  }
}
