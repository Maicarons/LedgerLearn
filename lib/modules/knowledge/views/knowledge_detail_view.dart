import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../../../data/repositories/knowledge_repository.dart';
import '../../../data/repositories/account_repository.dart';

class KnowledgeDetailView extends StatelessWidget {
  const KnowledgeDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final id = Get.parameters['id']!;
    final knowledgeRepo = Get.find<KnowledgeRepository>();
    final accountRepo = Get.find<AccountRepository>();
    final card = knowledgeRepo.getById(id);
    final locale =
        Get.locale?.toLanguageTag().replaceAll('-', '_') ?? 'zh_CN';
    if (card == null) {
      return Scaffold(
        appBar: AppBar(title: Text('knowledge_detail'.tr)),
        body: Center(child: Text('no_data'.tr)),
      );
    }

    final relatedAccount = card.relatedAccountId != null
        ? accountRepo.getById(card.relatedAccountId!)
        : null;

    return Scaffold(
      appBar: AppBar(title: Text('knowledge_detail'.tr)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: _detailBgColor(card.category),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      _detailIcon(card.category),
                      color: _detailFgColor(card.category),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _categoryLabel(card.category),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            MarkdownBody(
              data: card.content,
              selectable: true,
            ),
            if (relatedAccount != null) ...[
              const SizedBox(height: 24),
              Text('knowledge_related_account'.tr,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(relatedAccount.id,
                        style: const TextStyle(fontSize: 12)),
                  ),
                  title: Text(relatedAccount.getName(locale)),
                  subtitle: Text(relatedAccount.typeNameKey.tr),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      Get.toNamed('/accounts/detail/${relatedAccount.id}'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _detailBgColor(String category) {
    switch (category) {
      case 'accounting_practice': return Colors.blue.shade50;
      case 'economic_law': return Colors.orange.shade50;
      case 'tax': return Colors.green.shade50;
      default: return Colors.grey.shade100;
    }
  }

  Color _detailFgColor(String category) {
    switch (category) {
      case 'accounting_practice': return Colors.blue;
      case 'economic_law': return Colors.orange;
      case 'tax': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _detailIcon(String category) {
    switch (category) {
      case 'accounting_practice': return Icons.calculate;
      case 'economic_law': return Icons.gavel;
      case 'tax': return Icons.receipt;
      default: return Icons.article;
    }
  }

  String _categoryLabel(String category) {
    switch (category) {
      case 'accounting_practice': return 'knowledge_practice'.tr;
      case 'economic_law': return 'knowledge_law'.tr;
      case 'tax': return 'knowledge_tax'.tr;
      default: return category;
    }
  }
}
