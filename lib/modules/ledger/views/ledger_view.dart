import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ledger_controller.dart';
import '../../../shared/utils/helpers.dart';

class LedgerView extends GetView<LedgerController> {
  const LedgerView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LedgerController());
    final locale =
        Get.locale?.toLanguageTag().replaceAll('-', '_') ?? 'zh_CN';

    return Scaffold(
      appBar: AppBar(
        title: Text('ledger_title'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Get.defaultDialog(
                title: 'ledger_what_is'.tr,
                middleText: 'ledger_explanation'.tr,
                textConfirm: 'ok'.tr,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() => Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: controller.periodYear.value,
                        decoration: InputDecoration(
                          labelText: '年份',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        items: List.generate(
                            3,
                            (i) => DropdownMenuItem(
                                value: DateTime.now().year - i,
                                child:
                                    Text('${DateTime.now().year - i}'))),
                        onChanged: (v) {
                          if (v != null) {
                            controller.setPeriod(
                                v, controller.periodMonth.value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: controller.periodMonth.value,
                        decoration: InputDecoration(
                          labelText: '月份',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        items: List.generate(
                            12,
                            (i) => DropdownMenuItem(
                                value: i + 1,
                                child: Text('month_${i + 1}'.tr))),
                        onChanged: (v) {
                          if (v != null) {
                            controller.setPeriod(
                                controller.periodYear.value, v);
                          }
                        },
                      ),
                    ),
                  ],
                )),
          ),
          Expanded(
            child: Obx(() {
              final accounts = controller.accounts;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  final a = accounts[index];
                  final s = controller.getSummary(a.id);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () =>
                          Get.toNamed('/ledger/detail/${a.id}'),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(a.getName(locale),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                ),
                                Text(a.id,
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text('ledger_opening'.tr,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600)),
                                Text(
                                    formatCurrency(
                                        s.opening, locale),
                                    style: const TextStyle(
                                        fontSize: 12)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text('ledger_debit'.tr,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600)),
                                Text(
                                    formatCurrency(
                                        s.debit, locale),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text('ledger_credit'.tr,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600)),
                                Text(
                                    formatCurrency(
                                        s.credit, locale),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.red)),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text('ledger_ending'.tr,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12)),
                                Text(
                                    formatCurrency(
                                        s.ending, locale),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                              ],
                            ),
                          ],
                        ),
                      ),
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
