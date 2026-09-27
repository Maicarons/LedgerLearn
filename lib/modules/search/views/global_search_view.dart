import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/global_search_service.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../data/repositories/knowledge_repository.dart';
import '../../../data/repositories/voucher_repository.dart';

/// Global search across vouchers, accounts and knowledge.
class GlobalSearchView extends StatefulWidget {
  const GlobalSearchView({super.key});

  @override
  State<GlobalSearchView> createState() => _GlobalSearchViewState();
}

class _GlobalSearchViewState extends State<GlobalSearchView> {
  late final GlobalSearchService service;
  final controller = TextEditingController();
  SearchResult result = SearchResult.empty();
  String locale = 'zh_CN';

  @override
  void initState() {
    super.initState();
    service = GlobalSearchService(
      accountRepo: Get.find<AccountRepository>(),
      voucherRepo: Get.find<VoucherRepository>(),
      knowledgeRepo: Get.find<KnowledgeRepository>(),
    );
    locale = Get.locale?.toLanguageTag().replaceAll('-', '_') ?? 'zh_CN';
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _run(String q) {
    setState(() {
      result = service.search(q, locale: locale);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text('search_title'.tr)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'search_hint'.tr,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          controller.clear();
                          _run('');
                        },
                      ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: _run,
            ),
          ),
          if (controller.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'search_result_count'.trParams({'n': '${result.totalCount}'}),
                    style: TextStyle(color: colorScheme.outline, fontSize: 12),
                  ),
                ],
              ),
            ),
          Expanded(
            child: result.totalCount == 0
                ? Center(
                    child: Text(
                      controller.text.isEmpty
                          ? 'search_hint'.tr
                          : 'no_data'.tr,
                      style: TextStyle(color: colorScheme.outline),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (result.accounts.isNotEmpty) ...[
                        _SectionLabel('search_accounts'.tr),
                        ...result.accounts.map((h) => _HitTile(hit: h)),
                      ],
                      if (result.vouchers.isNotEmpty) ...[
                        _SectionLabel('search_vouchers'.tr),
                        ...result.vouchers.map((h) => _HitTile(hit: h)),
                      ],
                      if (result.knowledge.isNotEmpty) ...[
                        _SectionLabel('search_knowledge'.tr),
                        ...result.knowledge.map((h) => _HitTile(hit: h)),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(text,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary)),
    );
  }
}

class _HitTile extends StatelessWidget {
  final SearchHit hit;
  const _HitTile({required this.hit});

  @override
  Widget build(BuildContext context) {
    final icon = switch (hit.type) {
      SearchHitType.account => Icons.account_balance_outlined,
      SearchHitType.voucher => Icons.receipt_long_outlined,
      SearchHitType.knowledge => Icons.menu_book_outlined,
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(hit.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(hit.subtitle,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Get.toNamed(hit.route),
      ),
    );
  }
}
