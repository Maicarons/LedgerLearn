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
                    const Divider(),
                    _buildSection('reports_assets'.tr, [
                      _buildRow('reports_current_assets'.tr,
                          controller.totalAssets,
                          locale: locale),
                    ]),
                    const Divider(thickness: 2),
                    _buildRow('reports_total_assets'.tr,
                        controller.totalAssets,
                        bold: true,
                        locale: locale),
                    const SizedBox(height: 24),
                    _buildSection('reports_liabilities'.tr, [
                      _buildRow('reports_current_liabilities'.tr,
                          controller.totalLiabilities,
                          locale: locale),
                    ]),
                    const Divider(),
                    _buildSection('reports_equity'.tr, [
                      _buildRow('reports_equity'.tr,
                          controller.totalEquity,
                          locale: locale),
                    ]),
                    const Divider(thickness: 2),
                    _buildRow('reports_total_liabilities_equity'.tr,
                        controller.totalLiabilitiesEquity,
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
      {bool bold = false, required String locale}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : null)),
          Text(formatCurrency(amount, locale),
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : null,
                fontSize: bold ? 16 : 14,
              )),
        ],
      ),
    );
  }
}
