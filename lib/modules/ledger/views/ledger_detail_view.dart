import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/ledger_controller.dart';
import '../../../shared/utils/helpers.dart';
import '../../../data/services/export_service.dart';

class LedgerDetailView extends GetView<LedgerDetailController> {
  const LedgerDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LedgerDetailController());
    final locale =
        Get.locale?.toLanguageTag().replaceAll('-', '_') ?? 'zh_CN';

    return Scaffold(
      appBar: AppBar(
        title: Text(controller.account.getName(locale)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: '导出 CSV',
            onPressed: () async {
              final path = await ExportService.exportLedgerDetailCsv(
                accountName: controller.account.getName(locale),
                accountId: controller.account.id,
                entries: controller.entries,
                locale: locale,
              );
              if (path != null && context.mounted) {
                Get.snackbar('导出成功', '文件已保存', snackPosition: SnackPosition.BOTTOM);
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${'accounts_opening_balance'.tr}:',
                        style: const TextStyle(fontSize: 14)),
                    Text(
                        formatCurrency(
                            controller.openingBalance, locale),
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text('ledger_date'.tr,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600))),
                Expanded(
                    flex: 2,
                    child: Text('ledger_voucher_no'.tr,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600))),
                Expanded(
                    flex: 3,
                    child: Text('ledger_summary'.tr,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600))),
                Expanded(
                    child: Text('ledger_debit_amount'.tr,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600))),
                const SizedBox(width: 4),
                Expanded(
                    child: Text('ledger_credit_amount'.tr,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600))),
                const SizedBox(width: 4),
                Expanded(
                    child: Text('ledger_balance'.tr,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600))),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: Obx(() {
              if (controller.entries.isEmpty) {
                return Center(
                  child: Text('no_data'.tr,
                      style: TextStyle(color: Colors.grey.shade500)),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.entries.length,
                itemBuilder: (context, index) {
                  final e = controller.entries[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: Text(
                                DateFormat('MM-dd').format(e.date),
                                style: const TextStyle(fontSize: 12))),
                        Expanded(
                            flex: 2,
                            child: Text(e.voucherId,
                                style: const TextStyle(fontSize: 12))),
                        Expanded(
                            flex: 3,
                            child: Text(e.summary,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12))),
                        Expanded(
                            child: Text(
                                e.debit > 0
                                    ? formatCurrency(e.debit, locale)
                                    : '',
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 12))),
                        const SizedBox(width: 4),
                        Expanded(
                            child: Text(
                                e.credit > 0
                                    ? formatCurrency(e.credit, locale)
                                    : '',
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 12))),
                        const SizedBox(width: 4),
                        Expanded(
                            child: Text(
                                formatCurrency(e.balance, locale),
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: e.balance >= 0
                                        ? Colors.green.shade700
                                        : Colors.red))),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
