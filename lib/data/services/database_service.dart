import 'package:get_storage/get_storage.dart';
import '../models/account.dart';
import '../models/voucher.dart';
import '../models/knowledge_card.dart';
import '../../app/config/preset_data.dart';
import 'remote_knowledge_service.dart';

class DatabaseService {
  static const String _accountsKey = 'accounts';
  static const String _vouchersKey = 'vouchers';
  static const String _knowledgeKey = 'knowledge_cards';
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

    // Knowledge — try remote first, fallback to preset
    if (_box.read(_knowledgeKey) == null) {
      await _refreshKnowledge();
    }

    if (_box.read(_vouchersKey) == null) {
      await _box.write(_vouchersKey, <Map<String, dynamic>>[]);
    }
  }

  /// Try to fetch knowledge cards from remote server.
  /// On success, overwrite local storage with remote data.
  /// On failure, use embedded preset data if local is empty.
  Future<bool> _refreshKnowledge() async {
    final remoteService = RemoteKnowledgeService();
    final remoteCards = await remoteService.fetchKnowledgeCards();

    if (remoteCards != null && remoteCards.isNotEmpty) {
      // Remote fetch succeeded — overwrite local storage
      await _box.write(
          _knowledgeKey,
          remoteCards.map((k) => k.toJson()).toList());
      return true;
    }

    // Remote failed — use embedded preset if local is still empty
    if (_box.read(_knowledgeKey) == null) {
      await _box.write(
          _knowledgeKey,
          presetKnowledgeCards.map((k) => k.toJson()).toList());
    }
    return false;
  }

  /// Public method: force re-fetch knowledge from remote.
  /// Returns true if remote fetch succeeded.
  Future<bool> refreshKnowledge() async {
    return _refreshKnowledge();
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
    // For knowledge, try remote first
    final remoteService = RemoteKnowledgeService();
    final remoteCards = await remoteService.fetchKnowledgeCards();
    if (remoteCards != null && remoteCards.isNotEmpty) {
      await _box.write(
          _knowledgeKey,
          remoteCards.map((k) => k.toJson()).toList());
    } else {
      await _box.write(
          _knowledgeKey,
          presetKnowledgeCards.map((k) => k.toJson()).toList());
    }
  }
}
