import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/account.dart';
import '../../data/repositories/account_repository.dart';

class AccountPicker extends StatelessWidget {
  final String? selectedId;
  final ValueChanged<Account> onSelected;

  const AccountPicker({
    super.key,
    this.selectedId,
    required this.onSelected,
  });

  void _showPicker(BuildContext context) {
    final repo = Get.find<AccountRepository>();
    final locale = Get.locale?.toLanguageTag().replaceAll('-', '_') ?? 'zh_CN';
    final accounts = repo.getAll();
    final searchCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (ctx, scrollController) {
            return StatefulBuilder(
              builder: (ctx, setState) {
                final query = searchCtrl.text.toLowerCase();
                final filtered = query.isEmpty
                    ? accounts
                    : accounts.where((a) {
                        return a.getName(locale).toLowerCase().contains(query) ||
                            a.id.contains(query);
                      }).toList();

                final Map<String, List<Account>> grouped = {};
                for (final a in filtered) {
                  final cat = a.categoryKey.tr;
                  grouped.putIfAbsent(cat, () => []);
                  grouped[cat]!.add(a);
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'voucher_search_account'.tr,
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        children: grouped.entries.map((entry) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Text(
                                  entry.key,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                ),
                              ),
                              ...entry.value.map((a) => ListTile(
                                    leading: CircleAvatar(
                                      radius: 18,
                                      child: Text(
                                        a.id.substring(0, 2),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    title: Text(a.getName(locale)),
                                    subtitle: Text(
                                      '${a.id} · ${a.typeNameKey.tr}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    trailing: a.normallyDebit
                                        ? Text('debit'.tr,
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              fontSize: 12,
                                            ))
                                        : Text('credit'.tr,
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 12,
                                            )),
                                    selected: a.id == selectedId,
                                    onTap: () {
                                      onSelected(a);
                                      Navigator.pop(ctx);
                                    },
                                  )),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = Get.find<AccountRepository>();
    final locale = Get.locale?.toLanguageTag().replaceAll('-', '_') ?? 'zh_CN';
    final account =
        selectedId != null ? repo.getById(selectedId!) : null;

    return InkWell(
      onTap: () => _showPicker(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: account != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${account.id} ${account.getName(locale)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          account.typeNameKey.tr,
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    )
                  : Text(
                      'voucher_select_account'.tr,
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey.shade500),
                    ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
