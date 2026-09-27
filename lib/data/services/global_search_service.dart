import '../models/account.dart';
import '../models/knowledge_card.dart';
import '../models/voucher.dart';
import '../repositories/account_repository.dart';
import '../repositories/knowledge_repository.dart';
import '../repositories/voucher_repository.dart';
import '../../app/i18n/translations.dart';

/// Unified search across vouchers, accounts and knowledge cards.
class GlobalSearchService {
  final AccountRepository accountRepo;
  final VoucherRepository voucherRepo;
  final KnowledgeRepository knowledgeRepo;

  GlobalSearchService({
    required this.accountRepo,
    required this.voucherRepo,
    required this.knowledgeRepo,
  });

  /// Full-text-ish search. [query] is matched case-insensitively
  /// against names, codes, summaries and card titles/content.
  SearchResult search(String query, {String locale = 'zh_CN', int limit = 50}) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return SearchResult.empty();

    final accounts = <SearchHit>[];
    final vouchers = <SearchHit>[];
    final knowledge = <SearchHit>[];

    for (final a in accountRepo.getAll()) {
      if (accounts.length >= limit) break;
      if (_matchAccount(a, q, locale)) {
        accounts.add(SearchHit(
          type: SearchHitType.account,
          id: a.id,
          title: '${a.id} ${a.getName(locale)}',
          subtitle: LedgerLearnTranslations.tr(a.typeNameKey, locale),
          route: '/accounts/detail/${a.id}',
        ));
      }
    }

    for (final v in voucherRepo.getAll()) {
      if (vouchers.length >= limit) break;
      if (_matchVoucher(v, q, locale)) {
        vouchers.add(SearchHit(
          type: SearchHitType.voucher,
          id: v.id,
          title: '${v.id} · ${v.summary}',
          subtitle:
              '${v.date.year}-${v.date.month.toString().padLeft(2, '0')}-${v.date.day.toString().padLeft(2, '0')}',
          route: '/vouchers/detail/${v.id}',
        ));
      }
    }

    for (final k in knowledgeRepo.getAll()) {
      if (knowledge.length >= limit) break;
      if (_matchKnowledge(k, q)) {
        knowledge.add(SearchHit(
          type: SearchHitType.knowledge,
          id: k.id,
          title: k.title,
          subtitle: k.category,
          route: '/knowledge/detail/${k.id}',
        ));
      }
    }

    return SearchResult(
      accounts: accounts,
      vouchers: vouchers,
      knowledge: knowledge,
      query: query,
    );
  }

  bool _matchAccount(Account a, String q, String locale) {
    return a.id.toLowerCase().contains(q) ||
        a.nameZh.toLowerCase().contains(q) ||
        a.nameEn.toLowerCase().contains(q) ||
        a.nameKo.toLowerCase().contains(q) ||
        a.getName(locale).toLowerCase().contains(q);
  }

  bool _matchVoucher(Voucher v, String q, String locale) {
    if (v.id.toLowerCase().contains(q)) return true;
    if (v.summary.toLowerCase().contains(q)) return true;
    for (final e in v.entries) {
      if (e.accountId.toLowerCase().contains(q)) return true;
      if (e.accountName.toLowerCase().contains(q)) return true;
    }
    return false;
  }

  bool _matchKnowledge(KnowledgeCard k, String q) {
    return k.title.toLowerCase().contains(q) ||
        k.content.toLowerCase().contains(q) ||
        (k.relatedAccountId ?? '').toLowerCase().contains(q) ||
        (k.relatedSubject ?? '').toLowerCase().contains(q);
  }
}

enum SearchHitType { account, voucher, knowledge }

class SearchHit {
  final SearchHitType type;
  final String id;
  final String title;
  final String subtitle;
  final String route;
  SearchHit({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.route,
  });
}

class SearchResult {
  final String query;
  final List<SearchHit> accounts;
  final List<SearchHit> vouchers;
  final List<SearchHit> knowledge;

  SearchResult({
    required this.query,
    required this.accounts,
    required this.vouchers,
    required this.knowledge,
  });

  factory SearchResult.empty() => SearchResult(
        query: '',
        accounts: [],
        vouchers: [],
        knowledge: [],
      );

  int get totalCount => accounts.length + vouchers.length + knowledge.length;

  List<SearchHit> get all => [...accounts, ...vouchers, ...knowledge];
}
