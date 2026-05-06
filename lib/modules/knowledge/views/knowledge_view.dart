import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/knowledge_controller.dart';

class KnowledgeView extends GetView<KnowledgeController> {
  const KnowledgeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(KnowledgeController());
    final locale =
        Get.locale?.toLanguageTag().replaceAll('-', '_') ?? 'zh_CN';

    return Scaffold(
      appBar: AppBar(title: Text('knowledge_title'.tr)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'knowledge_search_hint'.tr,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (v) => controller.searchQuery.value = v,
                ),
                const SizedBox(height: 8),
                Obx(() => Row(
                      children: [
                        Expanded(
                          child: _CategoryButton(
                            label: 'all'.tr,
                            selected: controller.selectedCategory.value == 'all',
                            onTap: () =>
                                controller.selectedCategory.value = 'all',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _CategoryButton(
                            label: 'knowledge_practice'.tr,
                            selected: controller.selectedCategory.value ==
                                'accounting_practice',
                            onTap: () => controller.selectedCategory.value =
                                'accounting_practice',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _CategoryButton(
                            label: 'knowledge_law'.tr,
                            selected: controller.selectedCategory.value ==
                                'economic_law',
                            onTap: () => controller.selectedCategory.value =
                                'economic_law',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _CategoryButton(
                            label: 'knowledge_tax'.tr,
                            selected: controller.selectedCategory.value == 'tax',
                            onTap: () =>
                                controller.selectedCategory.value = 'tax',
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final cards = controller.filteredCards;
              if (cards.isEmpty) {
                return Center(child: Text('no_data'.tr));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _categoryBgColor(card.category),
                        child: Icon(
                          _categoryIcon(card.category),
                          color: _categoryFgColor(card.category),
                          size: 20,
                        ),
                      ),
                      title: Text(card.getTitle(locale),
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        card.category == 'accounting_practice'
                            ? 'knowledge_practice'.tr
                            : 'knowledge_law'.tr,
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          Get.toNamed('/knowledge/detail/${card.id}'),
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

Color _categoryBgColor(String category) {
  switch (category) {
    case 'accounting_practice':
      return Colors.blue.shade50;
    case 'economic_law':
      return Colors.orange.shade50;
    case 'tax':
      return Colors.green.shade50;
    default:
      return Colors.grey.shade100;
  }
}

Color _categoryFgColor(String category) {
  switch (category) {
    case 'accounting_practice':
      return Colors.blue;
    case 'economic_law':
      return Colors.orange;
    case 'tax':
      return Colors.green;
    default:
      return Colors.grey;
  }
}

IconData _categoryIcon(String category) {
  switch (category) {
    case 'accounting_practice':
      return Icons.calculate;
    case 'economic_law':
      return Icons.gavel;
    case 'tax':
      return Icons.receipt;
    default:
      return Icons.article;
  }
}

class _CategoryButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: selected
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.shade200,
        foregroundColor: selected ? Colors.white : Colors.black87,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
