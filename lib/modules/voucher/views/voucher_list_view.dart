import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/voucher_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../../data/services/export_service.dart';

class VoucherListView extends GetView<VoucherListController> {
  const VoucherListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VoucherListController());
    final colorScheme = Theme.of(context).colorScheme;
    final locale =
        Get.locale?.toLanguageTag().replaceAll('-', '_') ?? 'zh_CN';

    return Scaffold(
      appBar: AppBar(
        title: Text('voucher_title'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: '导出 CSV',
            onPressed: () async {
              final path = await ExportService.exportVoucherListCsv(
                  controller.vouchers, locale);
              if (path != null && context.mounted) {
                Get.snackbar('导出成功', '文件已保存',
                    snackPosition: SnackPosition.BOTTOM);
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Get.toNamed('/vouchers/new');
          controller.loadVouchers();
          // Refresh home controller
          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().refreshSummary();
          }
        },
        icon: const Icon(Icons.add),
        label: Text('voucher_new'.tr),
      ),
      body: Column(
        children: [
          // Month filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() => Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: controller.filterYear.value,
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
                                child: Text(
                                    '${DateTime.now().year - i}'))),
                        onChanged: (v) {
                          if (v != null) {
                            controller.setFilter(v, controller.filterMonth.value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: controller.filterMonth.value,
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
                            controller.setFilter(controller.filterYear.value, v);
                          }
                        },
                      ),
                    ),
                  ],
                )),
          ),

          // Voucher list
          Expanded(
            child: Obx(() {
              if (controller.vouchers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long,
                          size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('no_data'.tr,
                          style: TextStyle(color: Colors.grey.shade500)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.vouchers.length,
                itemBuilder: (context, index) {
                  final v = controller.vouchers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: v.isBalanced
                            ? colorScheme.primaryContainer
                            : Colors.orange.shade100,
                        child: Icon(
                          v.isBalanced ? Icons.check : Icons.warning,
                          color: v.isBalanced
                              ? colorScheme.primary
                              : Colors.orange,
                          size: 20,
                        ),
                      ),
                      title: Text(v.summary, maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        '${v.id} · ${DateFormat('yyyy-MM-dd').format(v.date)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Text(
                        v.totalDebit.toStringAsFixed(2),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      onTap: () => Get.toNamed('/vouchers/detail/${v.id}'),
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
