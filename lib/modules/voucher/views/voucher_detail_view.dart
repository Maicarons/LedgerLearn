import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/repositories/voucher_repository.dart';
import '../../../data/repositories/account_repository.dart';
import '../controllers/voucher_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../../shared/utils/helpers.dart';

class VoucherDetailView extends StatelessWidget {
  const VoucherDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final id = Get.parameters['id']!;
    final voucherRepo = Get.find<VoucherRepository>();
    final accountRepo = Get.find<AccountRepository>();
    final voucher = voucherRepo.getById(id);
    final locale =
        Get.locale?.toLanguageTag().replaceAll('-', '_') ?? 'zh_CN';

    if (voucher == null) {
      return Scaffold(
        appBar: AppBar(title: Text('voucher_detail'.tr)),
        body: Center(child: Text('no_data'.tr)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('voucher_detail'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Get.toNamed('/vouchers/edit/${voucher.id}',
                arguments: {'voucher': voucher}),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              Get.defaultDialog(
                title: 'confirm_delete'.tr,
                middleText: '${'voucher_number'.tr}: ${voucher.id}',
                textConfirm: 'delete'.tr,
                textCancel: 'cancel'.tr,
                confirmTextColor: Colors.white,
                onConfirm: () async {
                  await voucherRepo.delete(voucher.id);
                  // Refresh controllers
                  if (Get.isRegistered<VoucherListController>()) {
                    Get.find<VoucherListController>().loadVouchers();
                  }
                  if (Get.isRegistered<HomeController>()) {
                    Get.find<HomeController>().refreshSummary();
                  }
                  Get.back();
                  Get.back();
                  Get.snackbar('success'.tr, 'voucher_delete_success'.tr,
                      snackPosition: SnackPosition.BOTTOM);
                },
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${'voucher_number'.tr}: ${voucher.id}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                            DateFormat('yyyy-MM-dd').format(voucher.date)),
                      ],
                    ),
                    const Divider(),
                    Text('${'voucher_summary'.tr}: ${voucher.summary}',
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('voucher_entries'.tr,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...voucher.entries.map((e) {
              final account = accountRepo.getById(e.accountId);
              final accountName = account?.getName(locale) ?? e.accountName;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: e.isDebit
                        ? Colors.blue.shade50
                        : Colors.red.shade50,
                    child: Text(
                      e.isDebit ? 'debit'.tr : 'credit'.tr,
                      style: TextStyle(
                          fontSize: 11,
                          color: e.isDebit ? Colors.blue : Colors.red),
                    ),
                  ),
                  title: Text('$accountName (${e.accountId})'),
                  trailing: Text(formatCurrency(e.amount, locale),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: e.isDebit ? Colors.blue : Colors.red,
                      )),
                ),
              );
            }),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text('voucher_debit_total'.tr,
                            style: const TextStyle(fontSize: 12)),
                        Text(formatCurrency(voucher.totalDebit, locale),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text('voucher_credit_total'.tr,
                            style: const TextStyle(fontSize: 12)),
                        Text(formatCurrency(voucher.totalCredit, locale),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
