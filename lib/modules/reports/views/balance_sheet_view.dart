import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reports_controller.dart';
import '../../../shared/utils/helpers.dart';
import '../../../data/services/export_service.dart';

class BalanceSheetView extends GetView<BalanceSheetController> {
  const BalanceSheetView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BalanceSheetController());
    final locale =
        Get.locale?.toLanguageTag().replaceAll('-', '_') ?? 'zh_CN';

    return Scaffold(
      appBar: AppBar(
        title: Text('reports_balance_sheet'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'export_csv'.tr,
            onPressed: () async {
              final path = await ExportService.exportBalanceSheetCsv(
                totalAssets: controller.totalAssets,
                totalLiabilities: controller.totalLiabilities,
                totalEquity: controller.totalEquity,
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
                middleText: 'reports_balance_hint'.tr,
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
                      child: Text('reports_balance_sheet'.tr,
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
                        ],
                      ),
                    ),
                    const Divider(),
                    _buildSection('reports_assets'.tr, [
                      _buildRow('reports_total_assets'.tr,
                          controller.totalAssets,
                          prev: controller.prevTotalAssets(),
                          locale: locale),
                    ]),
                    const SizedBox(height: 24),
                    _buildSection('reports_liabilities'.tr, [
                      _buildRow('reports_liabilities'.tr,
                          controller.totalLiabilities,
                          prev: controller.prevTotalLiabilities(),
                          locale: locale),
                    ]),
                    const Divider(),
                    _buildSection('reports_equity'.tr, [
                      _buildRow('reports_equity'.tr,
                          controller.totalEquity,
                          prev: controller.prevTotalEquity(),
                          locale: locale),
                    ]),
                    const Divider(thickness: 2),
                    _buildRow('reports_total_liabilities_equity'.tr,
                        controller.totalLiabilitiesEquity,
                        prev: controller.prevTotalLiabilities() +
                            controller.prevTotalEquity(),
                        bold: true,
                        locale: locale),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue)),
        const SizedBox(height: 8),
        ...rows,
      ],
    );
  }

  Widget _buildRow(String label, double amount,
      {double prev = 0, bool bold = false, required String locale}) {
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
                    fontSize: bold ? 15 : 13)),
          ),
          Expanded(
            flex: 2,
            child: Text(formatCurrency(prev, locale),
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          ),
        ],
      ),
    );
  }
}
