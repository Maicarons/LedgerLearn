import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/account.dart';
import '../models/practice.dart';
import '../models/voucher.dart';
import 'database_service.dart';
import 'practice_service.dart';

/// Full ledger book backup / restore as a single JSON document.
///
/// Covers accounts, vouchers, learning progress, practice attempts and
/// settings so a learner can move their work between devices.
class BackupService {
  static const int schemaVersion = 1;

  final DatabaseService _db;
  final PracticeService _practice;

  BackupService(this._db, this._practice);

  /// Build a portable JSON map of the current book.
  Map<String, dynamic> exportMap() {
    return {
      'app': 'LedgerLearn',
      'schemaVersion': schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'accounts': _db.getAccounts().map((a) => a.toJson()).toList(),
      'vouchers': _db.getVouchers().map((v) => v.toJson()).toList(),
      'viewedKnowledge': _db.getViewedKnowledgeIds(),
      'practiceAttempts':
          _practice.getAttempts().map((a) => a.toJson()).toList(),
      'practicePassed': _practice.getPassedIds(),
      'settings': {
        'locale': _db.getLocale(),
        'themeMode': _db.getThemeMode(),
        'colorScheme': _db.getColorScheme(),
        'defaultPeriod': _db.getDefaultPeriod(),
      },
    };
  }

  /// Serialise the current book to pretty JSON text.
  String exportJson() =>
      const JsonEncoder.withIndent('  ').convert(exportMap());

  /// Write the backup to the app documents directory. Returns the file path.
  Future<String?> exportToFile() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final now = DateTime.now();
      final stamp = '${now.year}${now.month.toString().padLeft(2, '0')}'
          '${now.day.toString().padLeft(2, '0')}_'
          '${now.hour.toString().padLeft(2, '0')}'
          '${now.minute.toString().padLeft(2, '0')}'
          '${now.second.toString().padLeft(2, '0')}';
      final file = File('${dir.path}/LedgerLearn-backup-$stamp.json');
      await file.writeAsString(exportJson(), flush: true);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  /// Parse and validate a backup document without applying it.
  /// Throws [FormatException] when the payload is not a valid backup.
  static BackupPayload parse(String jsonText) {
    final dynamic decoded;
    try {
      decoded = json.decode(jsonText);
    } catch (_) {
      throw const FormatException('backup_invalid');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('backup_invalid');
    }
    if (decoded['app'] != 'LedgerLearn') {
      throw const FormatException('backup_invalid');
    }
    final version = decoded['schemaVersion'];
    if (version is! int || version < 1 || version > schemaVersion) {
      throw const FormatException('backup_version_unsupported');
    }

    final accountsRaw = decoded['accounts'];
    final vouchersRaw = decoded['vouchers'];
    if (accountsRaw is! List || vouchersRaw is! List) {
      throw const FormatException('backup_invalid');
    }

    try {
      final accounts = accountsRaw
          .map((e) => Account.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      final vouchers = vouchersRaw
          .map((e) => Voucher.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      final settings = Map<String, dynamic>.from(
          (decoded['settings'] as Map?)?.map((k, v) => MapEntry(k.toString(), v)) ??
              {});
      return BackupPayload(
        accounts: accounts,
        vouchers: vouchers,
        viewedKnowledge:
            (decoded['viewedKnowledge'] as List? ?? []).cast<String>(),
        practiceAttempts: (decoded['practiceAttempts'] as List? ?? [])
            .map((e) => PracticeAttempt.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        practicePassed:
            (decoded['practicePassed'] as List? ?? []).cast<String>(),
        settings: settings,
      );
    } catch (_) {
      throw const FormatException('backup_invalid');
    }
  }

  /// Restore a previously exported book. Replaces accounts and vouchers.
  Future<void> restore(BackupPayload payload) async {
    await _db.saveAccounts(payload.accounts);
    await _db.restoreVouchers(payload.vouchers);
    await _db.restoreViewedKnowledge(payload.viewedKnowledge);
    await _practice.restore(
      attempts: payload.practiceAttempts,
      passedIds: payload.practicePassed,
    );

    final locale = payload.settings['locale'];
    if (locale is String && locale.isNotEmpty) {
      await _db.setLocale(locale);
    }
    final themeMode = payload.settings['themeMode'];
    if (themeMode is String && themeMode.isNotEmpty) {
      await _db.setThemeMode(themeMode);
    }
    final colorScheme = payload.settings['colorScheme'];
    if (colorScheme is String && colorScheme.isNotEmpty) {
      await _db.setColorScheme(colorScheme);
    }
    final period = payload.settings['defaultPeriod'];
    if (period is String && period.isNotEmpty) {
      await _db.setDefaultPeriod(period);
    }
  }

  /// Convenience: parse + restore from a JSON string.
  Future<void> restoreFromJson(String jsonText) =>
      restore(BackupService.parse(jsonText));
}

/// Validated backup document ready to be written into storage.
class BackupPayload {
  final List<Account> accounts;
  final List<Voucher> vouchers;
  final List<String> viewedKnowledge;
  final List<PracticeAttempt> practiceAttempts;
  final List<String> practicePassed;
  final Map<String, dynamic> settings;

  BackupPayload({
    required this.accounts,
    required this.vouchers,
    required this.viewedKnowledge,
    required this.practiceAttempts,
    required this.practicePassed,
    required this.settings,
  });
}
