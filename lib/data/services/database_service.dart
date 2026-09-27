import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';

import '../models/account.dart';
import '../models/knowledge_card.dart';
import '../models/voucher.dart';
import '../storage/local_store.dart';
import '../storage/sqlite_bootstrap.dart';
import 'remote_knowledge_service.dart';
import '../../app/config/preset_data.dart';

/// SQLite-backed book store with an in-memory cache for sync reads.
///
/// Public API stays synchronous (as before with GetStorage); every mutation
/// flushes to [LocalStore]. First launch migrates any legacy GetStorage data.
class DatabaseService {
  static const String _kindAccounts = 'account';
  static const String _kindVouchers = 'voucher';
  static const String _kindKnowledge = 'knowledge';

  static const String _knowledgeVersionKey = 'knowledge_version';
  static const String _viewedKnowledgeKey = 'viewed_knowledge';
  static const int _currentKnowledgeVersion = 2;

  final LocalStore store = LocalStore();

  // In-memory cache (source for sync getters).
  final List<Account> _accounts = [];
  final List<Voucher> _vouchers = [];
  final List<KnowledgeCard> _knowledge = [];
  List<String> _viewedKnowledge = [];

  Future<void> init({bool inMemory = false}) async {
    if (sqliteSupported) {
      await bootstrapSqlite();
      await store.init(inMemory: inMemory);
      await _migrateFromGetStorage();
    } else {
      // Web fallback: still use GetStorage via a thin shim below.
      await GetStorage.init();
    }
    await _loadKvCache();
    _initSettings();
    await _loadCache();
    await _seedIfEmpty();
  }

  // ==================== Cache load ====================

  Future<void> _loadCache() async {
    if (!store.isOpen) return;
    _accounts
      ..clear()
      ..addAll((await store.listDocuments(_kindAccounts))
          .map((e) => Account.fromJson(e)));
    _vouchers
      ..clear()
      ..addAll(
        (await store.listDocuments(_kindVouchers))
            .map((e) => Voucher.fromJson(e))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date)),
      );
    _knowledge
      ..clear()
      ..addAll((await store.listDocuments(_kindKnowledge))
          .map((e) => KnowledgeCard.fromJson(e)));
    _viewedKnowledge = (await store.readJson<List>(_viewedKnowledgeKey))
            ?.cast<String>() ??
        [];
  }

  // ==================== Migration ====================

  Future<void> _migrateFromGetStorage() async {
    if (!store.isOpen) return;
    // Already seeded?
    if ((await store.listDocuments(_kindAccounts)).isNotEmpty) return;
    if (await store.getString('migrated_from_getstorage') == '1') return;

    try {
      await GetStorage.init();
      final box = GetStorage();

      // Simple KV keys.
      const kvKeys = [
        'locale',
        'themeMode',
        'colorScheme',
        'defaultPeriod',
        'knowledge_version',
        'viewed_knowledge',
        'practice_attempts',
        'practice_passed',
        'learning_streak',
        'learning_last_day',
        'learning_today_done',
        'knowledge_quiz_score',
        'knowledge_srs',
        'review_session_count',
      ];
      for (final k in kvKeys) {
        final v = box.read(k);
        if (v != null) {
          await store.writeJson(k, v);
        }
      }

      // Documents.
      final accounts = box.read<List>('accounts');
      if (accounts != null) {
        await store.replaceAllDocuments(
          _kindAccounts,
          [
            for (final a in accounts)
              (
                id: (a['id'] ?? '').toString(),
                json: Map<String, dynamic>.from(a as Map),
                sortKey: null,
              ),
          ],
        );
      }
      final vouchers = box.read<List>('vouchers');
      if (vouchers != null) {
        await store.replaceAllDocuments(
          _kindVouchers,
          [
            for (final v in vouchers)
              (
                id: (v['id'] ?? '').toString(),
                json: Map<String, dynamic>.from(v as Map),
                sortKey: (v['date'] ?? '').toString(),
              ),
          ],
        );
      }
      final knowledge = box.read<List>('knowledge_cards');
      if (knowledge != null) {
        await store.replaceAllDocuments(
          _kindKnowledge,
          [
            for (final k in knowledge)
              (
                id: (k['id'] ?? '').toString(),
                json: Map<String, dynamic>.from(k as Map),
                sortKey: null,
              ),
          ],
        );
      }

      await store.setString('migrated_from_getstorage', '1');
    } catch (_) {
      // Fresh install or GetStorage unavailable 鈥?proceed with empty SQLite.
    }
  }

  // ==================== Seed / settings ====================

  void _initSettings() {
    if (_readKvString('locale') == null) {
      _kvCache['locale'] = 'zh_CN';
      _writeKvString('locale', 'zh_CN');
    }
    if (_readKvString('defaultPeriod') == null) {
      final now = DateTime.now();
      final p = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      _kvCache['defaultPeriod'] = p;
      _writeKvString('defaultPeriod', p);
    }
  }

  Future<void> _seedIfEmpty() async {
    if (store.isOpen) {
      if (_accounts.isEmpty) {
        await store.replaceAllDocuments(
          _kindAccounts,
          [
            for (final a in presetAccounts)
              (id: a.id, json: a.toJson(), sortKey: a.id),
          ],
        );
        _accounts
          ..clear()
          ..addAll(presetAccounts);
      }

      final savedVersion =
          (await store.readJson<int>(_knowledgeVersionKey)) ?? 0;
      if (_knowledge.isEmpty || savedVersion < _currentKnowledgeVersion) {
        await _refreshKnowledge();
        await store.writeJson(_knowledgeVersionKey, _currentKnowledgeVersion);
      }

      if (_vouchers.isEmpty) {
        // Ensure table exists with empty list (no-op for documents).
        await store.replaceAllDocuments(_kindVouchers, const []);
      }
    } else {
      // Web / GetStorage fallback seeding.
      final box = GetStorage();
      if (box.read('accounts') == null) {
        box.write(
            'accounts', presetAccounts.map((a) => a.toJson()).toList());
      }
      final savedVersion = box.read(_knowledgeVersionKey) ?? 0;
      if (box.read('knowledge_cards') == null ||
          savedVersion < _currentKnowledgeVersion) {
        await _refreshKnowledge();
        box.write(_knowledgeVersionKey, _currentKnowledgeVersion);
      }
      if (box.read('vouchers') == null) {
        box.write('vouchers', <Map<String, dynamic>>[]);
      }
      _loadCacheFromBox(box);
    }
  }

  void _loadCacheFromBox(GetStorage box) {
    final accounts = box.read<List>('accounts');
    if (accounts != null) {
      _accounts
        ..clear()
        ..addAll(accounts
            .map((e) => Account.fromJson(Map<String, dynamic>.from(e as Map))));
    }
    final vouchers = box.read<List>('vouchers');
    if (vouchers != null) {
      _vouchers
        ..clear()
        ..addAll(
          vouchers
              .map((e) => Voucher.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date)),
        );
    }
    final knowledge = box.read<List>('knowledge_cards');
    if (knowledge != null) {
      _knowledge
        ..clear()
        ..addAll(knowledge.map(
            (e) => KnowledgeCard.fromJson(Map<String, dynamic>.from(e as Map))));
    }
    _viewedKnowledge =
        (box.read<List>(_viewedKnowledgeKey) ?? []).cast<String>();
  }

  Future<bool> _refreshKnowledge() async {
    final locale = getLocale();
    final remoteService = RemoteKnowledgeService();

    final remoteCards = await remoteService.fetchKnowledgeCards(locale);
    if (remoteCards != null && remoteCards.isNotEmpty) {
      await _saveKnowledge(remoteCards);
      return true;
    }

    final localCards = await _loadKnowledgeFromAsset(locale) ??
        await _loadKnowledgeFromAsset('zh_CN');
    if (localCards != null && localCards.isNotEmpty) {
      await _saveKnowledge(localCards);
      return true;
    }

    await _saveKnowledge([]);
    return false;
  }

  Future<void> _saveKnowledge(List<KnowledgeCard> cards) async {
    _knowledge
      ..clear()
      ..addAll(cards);
    if (store.isOpen) {
      await store.replaceAllDocuments(
        _kindKnowledge,
        [for (final c in cards) (id: c.id, json: c.toJson(), sortKey: null)],
      );
    } else {
      GetStorage().write('knowledge_cards', cards.map((c) => c.toJson()).toList());
    }
  }

  Future<List<KnowledgeCard>?> _loadKnowledgeFromAsset(String locale) async {
    final assetPath = 'knowledge_card/${locale.replaceAll('_', '-')}.json';
    try {
      final jsonStr = await rootBundle.loadString(assetPath);
      final List<dynamic> data = json.decode(jsonStr);
      return data
          .map((e) => KnowledgeCard.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<bool> refreshKnowledge() => _refreshKnowledge();

  // ==================== Accounts ====================

  List<Account> getAccounts() => List.unmodifiable(_accounts);

  Account? getAccount(String id) {
    for (final a in _accounts) {
      if (a.id == id) return a;
    }
    return null;
  }

  Future<void> saveAccounts(List<Account> accounts) async {
    _accounts
      ..clear()
      ..addAll(accounts);
    if (store.isOpen) {
      await store.replaceAllDocuments(
        _kindAccounts,
        [for (final a in accounts) (id: a.id, json: a.toJson(), sortKey: a.id)],
      );
    } else {
      GetStorage().write('accounts', accounts.map((a) => a.toJson()).toList());
    }
  }

  Future<void> addAccount(Account account) async {
    _accounts.add(account);
    if (store.isOpen) {
      await store.putDocument(_kindAccounts, account.id, account.toJson(),
          sortKey: account.id);
    } else {
      GetStorage().write('accounts', _accounts.map((a) => a.toJson()).toList());
    }
  }

  Future<void> updateAccount(Account account) async {
    final index = _accounts.indexWhere((a) => a.id == account.id);
    if (index != -1) {
      _accounts[index] = account;
      if (store.isOpen) {
        await store.putDocument(_kindAccounts, account.id, account.toJson(),
            sortKey: account.id);
      } else {
        GetStorage().write('accounts', _accounts.map((a) => a.toJson()).toList());
      }
    }
  }

  // ==================== Vouchers ====================

  List<Voucher> getVouchers({int? year, int? month}) {
    var vouchers = _vouchers.toList();
    if (year != null) {
      vouchers = vouchers.where((v) => v.year == year).toList();
    }
    if (month != null) {
      vouchers = vouchers.where((v) => v.month == month).toList();
    }
    vouchers.sort((a, b) => b.date.compareTo(a.date));
    return vouchers;
  }

  Voucher? getVoucher(String id) {
    for (final v in _vouchers) {
      if (v.id == id) return v;
    }
    return null;
  }

  Future<void> saveVoucher(Voucher voucher) async {
    final index = _vouchers.indexWhere((v) => v.id == voucher.id);
    if (index != -1) {
      _vouchers[index] = voucher;
    } else {
      _vouchers.add(voucher);
    }
    _vouchers.sort((a, b) => b.date.compareTo(a.date));
    if (store.isOpen) {
      await store.putDocument(
        _kindVouchers,
        voucher.id,
        voucher.toJson(),
        sortKey: voucher.date.toIso8601String(),
      );
    } else {
      GetStorage().write('vouchers', _vouchers.map((v) => v.toJson()).toList());
    }
  }

  Future<void> deleteVoucher(String id) async {
    _vouchers.removeWhere((v) => v.id == id);
    if (store.isOpen) {
      await store.deleteDocument(_kindVouchers, id);
    } else {
      GetStorage().write('vouchers', _vouchers.map((v) => v.toJson()).toList());
    }
  }

  String generateVoucherId(int year, int month) {
    final vouchers = getVouchers(year: year, month: month);
    final prefix = '$year${month.toString().padLeft(2, '0')}';
    final maxSeq = vouchers
        .where((v) => v.id.startsWith(prefix))
        .map((v) => int.tryParse(v.id.substring(6)) ?? 0)
        .fold<int>(0, (max, n) => n > max ? n : max);
    return '$prefix${(maxSeq + 1).toString().padLeft(4, '0')}';
  }

  // ==================== Knowledge ====================

  List<KnowledgeCard> getKnowledgeCards() => List.unmodifiable(_knowledge);

  // ==================== Learning Progress ====================

  List<String> getViewedKnowledgeIds() => List.unmodifiable(_viewedKnowledge);

  Future<void> addViewedKnowledge(String id) async {
    if (_viewedKnowledge.contains(id)) return;
    _viewedKnowledge.add(id);
    await _writeKvJson(_viewedKnowledgeKey, _viewedKnowledge);
  }

  Future<void> restoreViewedKnowledge(List<String> ids) async {
    _viewedKnowledge = List.of(ids);
    await _writeKvJson(_viewedKnowledgeKey, _viewedKnowledge);
  }

  Future<void> restoreVouchers(List<Voucher> vouchers) async {
    _vouchers
      ..clear()
      ..addAll(vouchers)
      ..sort((a, b) => b.date.compareTo(a.date));
    if (store.isOpen) {
      await store.replaceAllDocuments(
        _kindVouchers,
        [
          for (final v in vouchers)
            (id: v.id, json: v.toJson(), sortKey: v.date.toIso8601String())
        ],
      );
    } else {
      GetStorage().write('vouchers', _vouchers.map((v) => v.toJson()).toList());
    }
  }

  // ==================== Settings ====================

  String getLocale() => _readKvString('locale') ?? 'zh_CN';

  Future<void> setLocale(String locale) async {
    await _writeKvString('locale', locale);
    await _refreshKnowledge();
  }

  String getDefaultPeriod() =>
      _readKvString('defaultPeriod') ?? '${DateTime.now().year}-01';

  Future<void> setDefaultPeriod(String period) async {
    await _writeKvString('defaultPeriod', period);
  }

  String getColorScheme() => _readKvString('colorScheme') ?? 'blue';

  Future<void> setColorScheme(String scheme) async {
    await _writeKvString('colorScheme', scheme);
  }

  String getThemeMode() => _readKvString('themeMode') ?? 'system';

  Future<void> setThemeMode(String mode) async {
    await _writeKvString('themeMode', mode);
  }

  // ---- KV helpers (SQLite primary, GetStorage mirror for web) ----

  final Map<String, Object?> _kvCache = {};
  bool _kvLoaded = false;

  Future<void> _loadKvCache() async {
    if (_kvLoaded) return;
    if (store.isOpen) {
      // Pull known keys + everything from kv table via raw query.
      final rows = await store.db.query('kv');
      for (final r in rows) {
        final k = r['key'] as String;
        final raw = r['value'] as String;
        try {
          _kvCache[k] = json.decode(raw);
        } catch (_) {
          _kvCache[k] = raw;
        }
      }
    }
    _kvLoaded = true;
  }

  /// Generic KV read (used by Practice / Streak / Review services).
  T? readKv<T>(String key) {
    if (_kvCache.containsKey(key)) return _kvCache[key] as T?;
    // Fallback: GetStorage (web / pre-migration).
    try {
      return GetStorage().read<T>(key);
    } catch (_) {
      return null;
    }
  }

  /// Generic KV write (SQLite + optional GetStorage mirror).
  Future<void> writeKv(String key, Object? value) async {
    _kvCache[key] = value;
    if (store.isOpen) {
      await store.writeJson(key, value);
    } else {
      GetStorage().write(key, value);
    }
  }

  Future<void> removeKv(String key) async {
    _kvCache.remove(key);
    if (store.isOpen) {
      await store.removeKey(key);
    } else {
      GetStorage().remove(key);
    }
  }

  Future<void> _writeKvString(String key, String value) async {
    _kvCache[key] = value;
    if (store.isOpen) {
      await store.setString(key, value);
    } else {
      GetStorage().write(key, value);
    }
  }

  String? _readKvString(String key) {
    final v = _kvCache[key];
    if (v != null) return v.toString();
    try {
      return GetStorage().read(key)?.toString();
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeKvJson(String key, Object? value) =>
      writeKv(key, value);

  // ==================== Reset ====================

  Future<void> resetAll() async {
    await saveAccounts(presetAccounts);
    await restoreVouchers([]);
    await restoreViewedKnowledge([]);
    await _writeKvJson('practice_attempts', <Map<String, dynamic>>[]);
    await _writeKvJson('practice_passed', <String>[]);
    await _refreshKnowledge();
  }
}


