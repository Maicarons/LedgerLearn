import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/accounts_controller.dart';
import '../../../shared/utils/helpers.dart';

class AccountsView extends GetView<AccountsController> {
  const AccountsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AccountsController());
    final locale =
        Get.locale?.toLanguageTag().replaceAll('-', '_') ?? 'zh_CN';

    return Scaffold(
      appBar: AppBar(title: Text('accounts_title'.tr)),
      body: Column(
        children: [
          // Search and filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'search'.tr,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (v) {
                    controller.searchQuery.value = v;
                  },
                ),
                const SizedBox(height: 8),
                Obx(() => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'all'.tr,
                            selected: controller.selectedCategory.value == 'all',
                            onTap: () =>
                                controller.selectedCategory.value = 'all',
                          ),
                          _FilterChip(
                            label: 'category_asset'.tr,
                            selected: controller.selectedCategory.value == 'asset',
                            onTap: () =>
                                controller.selectedCategory.value = 'asset',
                          ),
                          _FilterChip(
                            label: 'category_liability'.tr,
                            selected:
                                controller.selectedCategory.value == 'liability',
                            onTap: () =>
                                controller.selectedCategory.value = 'liability',
                          ),
                          _FilterChip(
                            label: 'category_equity'.tr,
                            selected:
                                controller.selectedCategory.value == 'equity',
                            onTap: () =>
                                controller.selectedCategory.value = 'equity',
                          ),
                          _FilterChip(
                            label: 'category_cost'.tr,
                            selected:
                                controller.selectedCategory.value == 'cost',
                            onTap: () =>
                                controller.selectedCategory.value = 'cost',
                          ),
                          _FilterChip(
                            label: 'category_pl'.tr,
                            selected: controller.selectedCategory.value == 'pl',
                            onTap: () =>
                                controller.selectedCategory.value = 'pl',
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),

          // Account list
          Expanded(
            child: Obx(() {
              final grouped = controller.groupedAccounts;
              if (grouped.isEmpty) {
                return Center(
                  child: Text('no_data'.tr,
                      style: TextStyle(color: Colors.grey.shade500)),
                );
              }
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: grouped.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(entry.key.tr,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                    color: Theme.of(context).colorScheme.primary)),
                      ),
                      ...entry.value.map((account) {
                        final balance =
                            controller.accountRepo.getCurrentBalance(account.id);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 4),
                          child: ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: account.normallyDebit
                                  ? Colors.blue.shade50
                                  : Colors.red.shade50,
                              child: Text(account.id.substring(0, 2),
                                  style: const TextStyle(fontSize: 10)),
                            ),
                            title: Text(account.getName(locale),
                                style: const TextStyle(fontSize: 14)),
                            subtitle: Text(account.id,
                                style: const TextStyle(fontSize: 11)),
                            trailing: Text(
                              formatCurrency(balance, locale),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: balance >= 0
                                    ? Colors.green.shade700
                                    : Colors.red,
                              ),
                            ),
                            onTap: () => Get.toNamed(
                                '/accounts/detail/${account.id}'),
                          ),
                        );
                      }),
                    ],
                  );
                }).toList(),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
