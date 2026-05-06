import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reports_controller.dart';
import '../../../shared/utils/helpers.dart';
import '../../../data/services/export_service.dart';

class TrialBalanceView extends GetView<TrialBalanceController> {
  const TrialBalanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TrialBalanceController());
    final locale =
        Get.locale?.toLanguageTag().replaceAll('-', '_') ?? 'zh_CN';
    final balanced = controller.isBalanced;
    final rows = controller.rows;

    return Scaffold(
      appBar: AppBar(
        title: Text('reports_trial_balance'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: '导出 CSV',
            onPressed: () async {
              final path = await ExportService.exportTrialBalanceCsv(rows, locale);
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
                middleText: 'reports_trial_balance_hint'.tr,
                textConfirm: 'ok'.tr,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: balanced ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    balanced ? Icons.check_circle : Icons.cancel,
                    color: balanced ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    balanced ? 'reports_balanced'.tr : 'reports_unbalanced'.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: balanced ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 12,
                headingRowHeight: 40,
                dataRowMinHeight: 28,
                dataRowMaxHeight: 40,
                columns: [
                  DataColumn(label: Text('reports_account'.tr)),
                  DataColumn(label: Text('reports_debit_current'.tr)),
                  DataColumn(label: Text('reports_credit_current'.tr)),
                  DataColumn(label: Text('reports_debit_ending'.tr)),
                  DataColumn(label: Text('reports_credit_ending'.tr)),
                ],
                rows: rows.map((row) {
                  return DataRow(
                    color: row.isTotal
                        ? WidgetStateProperty.all(Colors.grey.shade100)
                        : null,
                    cells: [
                      DataCell(SizedBox(
                        width: 100,
                        child: Text(
                          row.accountId == 'total'
                              ? row.accountName
                              : '${row.accountId} ${row.accountName}',
                          style: TextStyle(
                            fontWeight: row.isTotal
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                      DataCell(SizedBox(
                        width: 90,
                        child: Text(
                          row.debitCurrent > 0
                              ? formatCurrency(row.debitCurrent, locale)
                              : '',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontWeight: row.isTotal
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      )),
                      DataCell(SizedBox(
                        width: 90,
                        child: Text(
                          row.creditCurrent > 0
                              ? formatCurrency(row.creditCurrent, locale)
                              : '',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontWeight: row.isTotal
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      )),
                      DataCell(SizedBox(
                        width: 90,
                        child: Text(
                          row.debitEnding > 0
                              ? formatCurrency(row.debitEnding, locale)
                              : '',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontWeight: row.isTotal
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      )),
                      DataCell(SizedBox(
                        width: 90,
                        child: Text(
                          row.creditEnding > 0
                              ? formatCurrency(row.creditEnding, locale)
                              : '',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontWeight: row.isTotal
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
