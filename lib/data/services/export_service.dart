import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../shared/utils/helpers.dart';

class ExportService {
  static Future<String?> exportCsv({
    required String fileName,
    required List<String> headers,
    required List<List<String>> rows,
  }) async {
    final buffer = StringBuffer();
    // BOM for Excel UTF-8 compatibility
    buffer.write('﻿');
    buffer.writeln(headers.join(','));
    for (final row in rows) {
      buffer.writeln(row
          .map((cell) => '"${cell.replaceAll('"', '""')}"')
          .join(','));
    }

    return _saveFile(fileName, buffer.toString());
  }

  static Future<String?> exportPdf({
    required String fileName,
    required String title,
    required List<String> headers,
    required List<List<String>> rows,
    String? subtitle,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(title,
                style: pw.TextStyle(
                    fontSize: 18, fontWeight: pw.FontWeight.bold)),
          ),
          if (subtitle != null)
            pw.Paragraph(
                text: subtitle,
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headers: headers,
            data: rows,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.grey300,
            ),
            cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 6, vertical: 4),
            border: pw.TableBorder.all(color: PdfColors.grey400),
          ),
        ],
      ),
    );

    final bytes = await pdf.save();
    return _saveFile(fileName, String.fromCharCodes(bytes));
  }

  static Future<String?> _saveFile(
      String fileName, String content) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(content, flush: true);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  // ==================== Pre-built exporters ====================

  /// Export a trial balance table to CSV
  static Future<String?> exportTrialBalanceCsv(
      List<dynamic> rows, String locale) {
    return exportCsv(
      fileName: _datedFileName('试算平衡表', 'csv'),
      headers: ['科目', '借方本期', '贷方本期', '借方期末', '贷方期末'],
      rows: rows.map<List<String>>((r) => [
            r.accountId == 'total' ? '合计' : '${r.accountId} ${r.accountName}',
            r.debitCurrent > 0
                ? formatCurrency(r.debitCurrent, locale)
                : '',
            r.creditCurrent > 0
                ? formatCurrency(r.creditCurrent, locale)
                : '',
            r.debitEnding > 0
                ? formatCurrency(r.debitEnding, locale)
                : '',
            r.creditEnding > 0
                ? formatCurrency(r.creditEnding, locale)
                : '',
          ]).toList(),
    );
  }

  /// Export a ledger detail to CSV
  static Future<String?> exportLedgerDetailCsv({
    required String accountName,
    required String accountId,
    required List<dynamic> entries,
    required String locale,
  }) {
    return exportCsv(
      fileName: _datedFileName('明细账_$accountName', 'csv'),
      headers: ['日期', '凭证号', '摘要', '借方', '贷方', '余额'],
      rows: entries.map<List<String>>((e) => [
            '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}',
            e.voucherId,
            e.summary,
            e.debit > 0 ? formatCurrency(e.debit, locale) : '',
            e.credit > 0 ? formatCurrency(e.credit, locale) : '',
            formatCurrency(e.balance, locale),
          ]).toList(),
    );
  }

  /// Export income statement to CSV
  static Future<String?> exportIncomeStatementCsv({
    required List<MapEntry<String, double>> revenues,
    required List<MapEntry<String, double>> expenses,
    required double totalRevenue,
    required double totalExpense,
    required double netProfit,
    required String locale,
  }) {
    final rows = <List<String>>[];
    rows.add(['收入', '', '']);
    for (final r in revenues) {
      rows.add([r.key, formatCurrency(r.value, locale), '']);
    }
    rows.add(['收入合计', formatCurrency(totalRevenue, locale), '']);
    rows.add(['', '', '']);
    rows.add(['费用', '', '']);
    for (final e in expenses) {
      rows.add([e.key, '', formatCurrency(e.value, locale)]);
    }
    rows.add(['费用合计', '', formatCurrency(totalExpense, locale)]);
    rows.add(['', '', '']);
    rows.add(['净利润', '', formatCurrency(netProfit, locale)]);

    return exportCsv(
      fileName: _datedFileName('利润表', 'csv'),
      headers: ['项目', '收入', '费用'],
      rows: rows,
    );
  }

  /// Export balance sheet to CSV
  static Future<String?> exportBalanceSheetCsv({
    required double totalAssets,
    required double totalLiabilities,
    required double totalEquity,
    required String locale,
  }) {
    return exportCsv(
      fileName: _datedFileName('资产负债表', 'csv'),
      headers: ['项目', '金额'],
      rows: [
        ['资产总计', formatCurrency(totalAssets, locale)],
        ['负债合计', formatCurrency(totalLiabilities, locale)],
        ['所有者权益合计', formatCurrency(totalEquity, locale)],
        ['负债与所有者权益总计',
          formatCurrency(totalLiabilities + totalEquity, locale)],
      ],
    );
  }

  /// Export voucher list to CSV
  static Future<String?> exportVoucherListCsv(
      List<dynamic> vouchers, String locale) {
    return exportCsv(
      fileName: _datedFileName('凭证列表', 'csv'),
      headers: ['凭证号', '日期', '摘要', '借方合计', '贷方合计'],
      rows: vouchers.map<List<String>>((v) => [
            v.id,
            '${v.date.year}-${v.date.month.toString().padLeft(2, '0')}-${v.date.day.toString().padLeft(2, '0')}',
            v.summary,
            formatCurrency(v.totalDebit, locale),
            formatCurrency(v.totalCredit, locale),
          ]).toList(),
    );
  }

  static String _datedFileName(String name, String ext) {
    final now = DateTime.now();
    final date =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    return '$name-$date.$ext';
  }
}
