import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ledgerlearn/data/services/remote_knowledge_service.dart';
import '../models/account.dart';
import '../models/voucher.dart';
import '../models/knowledge_card.dart';
import '../../app/config/preset_data.dart';

class DatabaseService {
  static const String _accountsKey = 'accounts';
  static const String _vouchersKey = 'vouchers';
  static const String _knowledgeKey = 'knowledge_cards';
  static const String _knowledgeVersionKey = 'knowledge_version';
  static const int _currentKnowledgeVersion = 2;
  final GetStorage _box = GetStorage();

  Future<void> init() async {
    await GetStorage.init();
    _initSettings();
    await _seedIfEmpty();
  }

  void _initSettings() {
    if (_box.read('locale') == null) {
      _box.write('locale', 'zh_CN');
    }
    if (_box.read('defaultPeriod') == null) {
      final now = DateTime.now();
      _box.write('defaultPeriod', '${now.year}-${now.month.toString().padLeft(2, '0')}');
    }
  }

  Future<void> _seedIfEmpty() async {
    // Accounts — always from embedded preset
    final existingAccounts = _box.read(_accountsKey);
    if (existingAccounts == null) {
      await _box.write(
          _accountsKey,
          presetAccounts.map((a) => a.toJson()).toList());
    }

    // Knowledge — seed if empty or old format needs migration
    final savedVersion = _box.read(_knowledgeVersionKey) ?? 0;
    if (_box.read(_knowledgeKey) == null ||
        savedVersion < _currentKnowledgeVersion) {
      await _refreshKnowledge();
      await _box.write(_knowledgeVersionKey, _currentKnowledgeVersion);
    }

    if (_box.read(_vouchersKey) == null) {
      await _box.write(_vouchersKey, <Map<String, dynamic>>[]);
    }
  }

  /// Try to fetch knowledge cards from remote server for the current locale.
  /// On success, overwrite local storage with remote data.
  /// On failure, load from bundled local JSON asset.
  Future<bool> _refreshKnowledge() async {
    final locale = getLocale();
    final remoteService = RemoteKnowledgeService();

    // 1. Try remote first (for latest updates without app update)
    final remoteCards = await remoteService.fetchKnowledgeCards(locale);
    if (remoteCards != null && remoteCards.isNotEmpty) {
      await _box.write(
          _knowledgeKey,
          remoteCards.map((k) => k.toJson()).toList());
      return true;
    }

    // 2. Remote failed — fallback to local JSON asset
    final localCards = await _loadKnowledgeFromAsset(locale) ??
        await _loadKnowledgeFromAsset('zh_CN');
    if (localCards != null && localCards.isNotEmpty) {
      await _box.write(
          _knowledgeKey,
          localCards.map((k) => k.toJson()).toList());
      return true;
    }

    await _box.write(_knowledgeKey, <Map<String, dynamic>>[]);
    return false;
  }

  /// Public method: reload knowledge cards from local asset.
  Future<bool> refreshKnowledge() async {
    return _refreshKnowledge();
  }

  /// Load knowledge cards from a JSON asset file for the given locale.
  Future<List<KnowledgeCard>?> _loadKnowledgeFromAsset(String locale) async {
    // Convert 'zh_CN' → 'zh-CN' for asset path
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

  // ==================== Accounts ====================

  List<Account> getAccounts() {
    final data = _box.read<List>(_accountsKey);
    if (data == null) return [];
    return data.map((e) => Account.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Account? getAccount(String id) {
    final accounts = getAccounts();
    try {
      return accounts.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveAccounts(List<Account> accounts) async {
    await _box.write(
        _accountsKey,
        accounts.map((a) => a.toJson()).toList());
  }

  Future<void> addAccount(Account account) async {
    final accounts = getAccounts();
    accounts.add(account);
    await saveAccounts(accounts);
  }

  Future<void> updateAccount(Account account) async {
    final accounts = getAccounts();
    final index = accounts.indexWhere((a) => a.id == account.id);
    if (index != -1) {
      accounts[index] = account;
      await saveAccounts(accounts);
    }
  }

  // ==================== Vouchers ====================

  List<Voucher> getVouchers({int? year, int? month}) {
    final data = _box.read<List>(_vouchersKey);
    if (data == null) return [];
    var vouchers =
        data.map((e) => Voucher.fromJson(Map<String, dynamic>.from(e))).toList();

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
    final vouchers = getVouchers();
    try {
      return vouchers.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveVoucher(Voucher voucher) async {
    final vouchers = getVouchers();
    final index = vouchers.indexWhere((v) => v.id == voucher.id);
    if (index != -1) {
      vouchers[index] = voucher;
    } else {
      vouchers.add(voucher);
    }
    await _box.write(
        _vouchersKey,
        vouchers.map((v) => v.toJson()).toList());
  }

  Future<void> deleteVoucher(String id) async {
    final vouchers = getVouchers();
    vouchers.removeWhere((v) => v.id == id);
    await _box.write(
        _vouchersKey,
        vouchers.map((v) => v.toJson()).toList());
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

  // ==================== Knowledge Cards ====================

  List<KnowledgeCard> getKnowledgeCards() {
    final data = _box.read<List>(_knowledgeKey);
    if (data == null) return [];
    return data
        .map((e) => KnowledgeCard.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // ==================== Settings ====================

  String getLocale() => _box.read('locale') ?? 'zh_CN';

  Future<void> setLocale(String locale) async {
    await _box.write('locale', locale);
    await _refreshKnowledge();
  }

  String getDefaultPeriod() =>
      _box.read('defaultPeriod') ?? '${DateTime.now().year}-01';

  Future<void> setDefaultPeriod(String period) async {
    await _box.write('defaultPeriod', period);
  }

  String getColorScheme() => _box.read('colorScheme') ?? 'blue';
  Future<void> setColorScheme(String scheme) async {
    await _box.write('colorScheme', scheme);
  }

  String getThemeMode() => _box.read('themeMode') ?? 'system';
  Future<void> setThemeMode(String mode) async {
    await _box.write('themeMode', mode);
  }

  Future<void> resetAll() async {
    await _box.write(
        _accountsKey,
        presetAccounts.map((a) => a.toJson()).toList());
    await _box.write(_vouchersKey, <Map<String, dynamic>>[]);
    await _refreshKnowledge();
  }
}
