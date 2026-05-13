import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/accounts_controller.dart';
import '../../../data/repositories/knowledge_repository.dart';
import '../../../shared/utils/helpers.dart';

class AccountDetailView extends GetView<AccountDetailController> {
  const AccountDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AccountDetailController());
    final locale =
        Get.locale?.toLanguageTag().replaceAll('-', '_') ?? 'zh_CN';
    final knowledgeRepo = Get.find<KnowledgeRepository>();
    final relatedKnowledge =
        knowledgeRepo.getByAccount(controller.account.id);

    return Scaffold(
      appBar: AppBar(title: Text('accounts_detail'.tr)),
      body: Obx(() => SingleChildScrollView(
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
                          children: [
                            CircleAvatar(
                              backgroundColor: controller.account.normallyDebit
                                  ? Colors.blue.shade100
                                  : Colors.red.shade100,
                              child: Text(controller.account.id,
                                  style: const TextStyle(fontSize: 12)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      controller.account.getName(locale),
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                      '${controller.account.id} · ${controller.account.typeNameKey.tr}',
                                      style: TextStyle(
                                          color: Colors.grey.shade600)),
                                ],
                              ),
                            ),
                            Text(formatCurrency(
                                controller.currentBalance.value, locale),
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: controller.currentBalance.value >= 0
                                        ? Colors.green.shade700
                                        : Colors.red)),
                          ],
                        ),
                        if (controller.account.getExplanation(locale)
                            .isNotEmpty) ...[
                          const Divider(),
                          Text(controller.account.getExplanation(locale),
                              style: TextStyle(
                                  color: Colors.grey.shade700,
                                  height: 1.5)),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Period summary
                Text('current_period'.tr,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _SummaryRow(
                            label: 'accounts_opening_balance'.tr,
                            value: formatCurrency(
                                controller.account.openingBalance, locale)),
                        const Divider(),
                        _SummaryRow(
                            label: 'accounts_debit_total'.tr,
                            value: formatCurrency(
                                controller.debitTotal.value, locale),
                            valueColor: Colors.blue),
                        const Divider(),
                        _SummaryRow(
                            label: 'accounts_credit_total'.tr,
                            value: formatCurrency(
                                controller.creditTotal.value, locale),
                            valueColor: Colors.red),
                        const Divider(),
                        _SummaryRow(
                            label: 'accounts_ending_balance'.tr,
                            value: formatCurrency(
                                controller.currentBalance.value, locale),
                            bold: true),
                      ],
                    ),
                  ),
                ),

                // Related knowledge
                if (relatedKnowledge.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('accounts_related_knowledge'.tr,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...relatedKnowledge.map((k) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.lightbulb,
                              color: Colors.amber),
                          title: Text(k.title),
                          subtitle: Text(k.category == 'accounting_practice'
                              ? 'knowledge_practice'.tr
                              : 'knowledge_law'.tr),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () =>
                              Get.toNamed('/knowledge/detail/${k.id}'),
                        ),
                      )),
                ],

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        Get.toNamed('/ledger/detail/${controller.account.id}'),
                    icon: const Icon(Icons.book),
                    label: Text('ledger_detail_title'.tr),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 18 : 14,
              color: valueColor,
            )),
      ],
    );
  }
}
