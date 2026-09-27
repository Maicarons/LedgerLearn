import 'dart:convert';

import '../models/account.dart';
import '../models/entry.dart';
import '../models/voucher.dart';
import '../repositories/account_repository.dart';
import '../repositories/voucher_repository.dart';
import '../../app/i18n/translations.dart';

/// Result of a CSV voucher import run.
class CsvImportResult {
  final List<Voucher> created;
  final List<String> errors;
  final int skipped;
  CsvImportResult({
    required this.created,
    required this.errors,
    required this.skipped,
  });

  bool get ok => errors.isEmpty && created.isNotEmpty;
}

/// Parse and import vouchers from CSV text.
///
/// Supported columns (header required, case-insensitive):
///
/// **Simple two-line form**
/// `date,summary,debit_account,credit_account,amount`
///
/// **Detailed multi-line form**
/// `voucher_id,date,summary,account_id,direction,amount`
/// where `direction` is `D`/`debit`/`借` or `C`/`credit`/`贷`.
/// Rows sharing the same `voucher_id` form one voucher.
class CsvImportService {
  final AccountRepository accountRepo;
  final VoucherRepository voucherRepo;

  CsvImportService({
    required this.accountRepo,
    required this.voucherRepo,
  });

  /// Parse CSV without writing. Useful for preview.
  ({List<Voucher> vouchers, List<String> errors, int skipped}) parse(
    String csvText, {
    String locale = 'zh_CN',
  }) {
    final errors = <String>[];
    final created = <Voucher>[];
    var skipped = 0;

    final lines = const LineSplitter()
        .convert(csvText)
        .where((l) => l.trim().isNotEmpty && !l.trim().startsWith('#'))
        .toList();
    if (lines.isEmpty) {
      return (vouchers: created, errors: ['csv_empty'], skipped: 0);
    }

    final header = _splitCsvLine(lines.first).map((h) => h.trim().toLowerCase()).toList();
    final col = <String, int>{};
    for (var i = 0; i < header.length; i++) {
      col[header[i]] = i;
    }

    final hasSimple = col.containsKey('debit_account') &&
        col.containsKey('credit_account') &&
        col.containsKey('amount');
    final hasDetailed = col.containsKey('account_id') &&
        col.containsKey('direction') &&
        col.containsKey('amount');

    if (!hasSimple && !hasDetailed) {
      return (
        vouchers: created,
        errors: ['csv_bad_header'],
        skipped: 0,
      );
    }

    // Group detailed rows by voucher_id.
    final detailedGroups = <String, List<List<String>>>{};
    final simpleRows = <List<String>>[];

    for (var i = 1; i < lines.length; i++) {
      final cells = _splitCsvLine(lines[i]);
      if (hasDetailed) {
        final vid = _cell(cells, col['voucher_id']) ?? 'row_$i';
        detailedGroups.putIfAbsent(vid, () => []).add(cells);
      } else {
        simpleRows.add(cells);
      }
    }

    if (hasSimple) {
      for (var i = 0; i < simpleRows.length; i++) {
        final cells = simpleRows[i];
        final lineNo = i + 2;
        try {
          final v = _buildSimple(cells, col, lineNo, locale);
          if (v != null) created.add(v);
        } on FormatException catch (e) {
          errors.add('L$lineNo: ${e.message}');
        }
      }
    } else {
      for (final entry in detailedGroups.entries) {
        try {
          final v = _buildDetailed(entry.key, entry.value, col, locale);
          if (v != null) {
            created.add(v);
          } else {
            skipped++;
          }
        } on FormatException catch (e) {
          errors.add('${entry.key}: ${e.message}');
        }
      }
    }

    return (vouchers: created, errors: errors, skipped: skipped);
  }

  /// Parse and persist. Auto-generates voucher ids on collision.
  Future<CsvImportResult> import(String csvText, {String locale = 'zh_CN'}) async {
    final parsed = parse(csvText, locale: locale);
    final saved = <Voucher>[];
    for (final v in parsed.vouchers) {
      // Re-key if id already exists.
      var id = v.id;
      if (voucherRepo.getById(id) != null) {
        id = voucherRepo.generateId(v.year, v.month);
      }
      final fresh = Voucher(
        id: id,
        date: v.date,
        summary: v.summary,
        entries: v.entries,
      );
      if (!fresh.isBalanced) {
        continue;
      }
      await voucherRepo.save(fresh);
      saved.add(fresh);
    }
    return CsvImportResult(
      created: saved,
      errors: parsed.errors,
      skipped: parsed.skipped,
    );
  }

  Voucher? _buildSimple(
    List<String> cells,
    Map<String, int> col,
    int lineNo,
    String locale,
  ) {
    final dateStr = _cell(cells, col['date']);
    final summary = _cell(cells, col['summary']) ?? '';
    final debitId = _cell(cells, col['debit_account']);
    final creditId = _cell(cells, col['credit_account']);
    final amountStr = _cell(cells, col['amount']);

    if (dateStr == null || debitId == null || creditId == null || amountStr == null) {
      throw FormatException('csv_missing_field');
    }
    final date = _parseDate(dateStr);
    final amount = _parseAmount(amountStr);
    final debit = accountRepo.getById(debitId) ?? _custom(debitId, locale);
    final credit = accountRepo.getById(creditId) ?? _custom(creditId, locale);

    return Voucher(
      id: 'csv_$lineNo',
      date: date,
      summary: summary.isEmpty
          ? LedgerLearnTranslations.tr('csv_import_summary', locale)
          : summary,
      entries: [
        Entry.fromYuan(
            accountId: debit.id,
            accountName: debit.getName(locale),
            isDebit: true,
            amount: amount),
        Entry.fromYuan(
            accountId: credit.id,
            accountName: credit.getName(locale),
            isDebit: false,
            amount: amount),
      ],
    );
  }

  Voucher? _buildDetailed(
    String voucherId,
    List<List<String>> rows,
    Map<String, int> col,
    String locale,
  ) {
    if (rows.isEmpty) return null;
    final dateStr = _cell(rows.first, col['date']);
    final summary = _cell(rows.first, col['summary']) ?? '';
    if (dateStr == null) throw const FormatException('csv_missing_field');
    final date = _parseDate(dateStr);

    final entries = <Entry>[];
    for (final cells in rows) {
      final accId = _cell(cells, col['account_id']);
      final dir = _cell(cells, col['direction']) ?? 'D';
      final amountStr = _cell(cells, col['amount']);
      if (accId == null || amountStr == null) {
        throw const FormatException('csv_missing_field');
      }
      final amount = _parseAmount(amountStr);
      final isDebit = _isDebit(dir);
      final acc = accountRepo.getById(accId) ?? _custom(accId, locale);
      entries.add(Entry.fromYuan(
        accountId: acc.id,
        accountName: acc.getName(locale),
        isDebit: isDebit,
        amount: amount,
      ));
    }

    return Voucher(
      id: voucherId,
      date: date,
      summary: summary,
      entries: entries,
    );
  }

  Account _custom(String id, String locale) => Account(
        id: id,
        nameZh: id,
        nameEn: id,
        nameKo: id,
        category: 'asset',
        type: 1,
        isSystem: false,
      );

  bool _isDebit(String dir) {
    final d = dir.trim().toLowerCase();
    return d == 'd' || d == 'debit' || d == '借' || d == 'dr';
  }

  DateTime _parseDate(String raw) {
    final s = raw.trim().replaceAll('/', '-');
    final parts = s.split('-');
    if (parts.length == 3) {
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final d = int.tryParse(parts[2]);
      if (y != null && m != null && d != null) {
        return DateTime(y, m, d);
      }
    }
    final dt = DateTime.tryParse(s);
    if (dt != null) return dt;
    throw const FormatException('csv_bad_date');
  }

  double _parseAmount(String raw) {
    final cleaned = raw.trim().replaceAll(',', '').replaceAll('¥', '');
    final v = double.tryParse(cleaned);
    if (v == null || v < 0) throw const FormatException('csv_bad_amount');
    return v;
  }

  String? _cell(List<String> cells, int? index) {
    if (index == null || index >= cells.length) return null;
    final v = cells[index].trim();
    return v.isEmpty ? null : v;
  }

  /// Minimal CSV splitter supporting quoted fields.
  static List<String> _splitCsvLine(String line) {
    final result = <String>[];
    final buf = StringBuffer();
    var inQuotes = false;
    for (var i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buf.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if ((ch == ',' || ch == '\t') && !inQuotes) {
        result.add(buf.toString());
        buf.clear();
      } else {
        buf.write(ch);
      }
    }
    result.add(buf.toString());
    return result;
  }
}
