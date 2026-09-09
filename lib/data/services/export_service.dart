import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../shared/utils/helpers.dart';
import '../../app/i18n/translations.dart';

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
          pw.TableHelper.fromTextArray(
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
      fileName: _datedFileName(
          LedgerLearnTranslations.tr('reports_trial_balance', locale), 'csv'),
      headers: [
        LedgerLearnTranslations.tr('ledger_account', locale),
        LedgerLearnTranslations.tr('reports_debit_current', locale),
        LedgerLearnTranslations.tr('reports_credit_current', locale),
        LedgerLearnTranslations.tr('reports_debit_ending', locale),
        LedgerLearnTranslations.tr('reports_credit_ending', locale),
      ],
      rows: rows.map<List<String>>((r) => [
            r.accountId == 'total'
                ? LedgerLearnTranslations.tr('total', locale)
                : '${r.accountId} ${r.accountName}',
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
      fileName: _datedFileName(
          '${LedgerLearnTranslations.tr('ledger_detail_title', locale)}_$accountName',
          'csv'),
      headers: [
        LedgerLearnTranslations.tr('ledger_date', locale),
        LedgerLearnTranslations.tr('ledger_voucher_no', locale),
        LedgerLearnTranslations.tr('ledger_summary', locale),
        LedgerLearnTranslations.tr('ledger_debit', locale),
        LedgerLearnTranslations.tr('ledger_credit', locale),
        LedgerLearnTranslations.tr('ledger_balance', locale),
      ],
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
    final revenueLabel = LedgerLearnTranslations.tr('reports_revenue', locale);
    final expenseLabel = LedgerLearnTranslations.tr('reports_expense', locale);
    rows.add([revenueLabel, '', '']);
    for (final r in revenues) {
      rows.add([r.key, formatCurrency(r.value, locale), '']);
    }
    rows.add([
      LedgerLearnTranslations.tr('export_revenue_total', locale),
      formatCurrency(totalRevenue, locale),
      ''
    ]);
    rows.add(['', '', '']);
    rows.add([expenseLabel, '', '']);
    for (final e in expenses) {
      rows.add([e.key, '', formatCurrency(e.value, locale)]);
    }
    rows.add([
      LedgerLearnTranslations.tr('export_expense_total', locale),
      '',
      formatCurrency(totalExpense, locale)
    ]);
    rows.add(['', '', '']);
    rows.add([
      LedgerLearnTranslations.tr('reports_net_profit', locale),
      '',
      formatCurrency(netProfit, locale)
    ]);

    return exportCsv(
      fileName: _datedFileName(
          LedgerLearnTranslations.tr('reports_income_statement', locale),
          'csv'),
      headers: [
        LedgerLearnTranslations.tr('reports_item', locale),
        revenueLabel,
        expenseLabel,
      ],
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
      fileName: _datedFileName(
          LedgerLearnTranslations.tr('reports_balance_sheet', locale), 'csv'),
      headers: [
        LedgerLearnTranslations.tr('reports_item', locale),
        LedgerLearnTranslations.tr('reports_amount', locale),
      ],
      rows: [
        [
          LedgerLearnTranslations.tr('reports_total_assets', locale),
          formatCurrency(totalAssets, locale)
        ],
        [
          LedgerLearnTranslations.tr('export_liabilities_total', locale),
          formatCurrency(totalLiabilities, locale)
        ],
        [
          LedgerLearnTranslations.tr('export_equity_total', locale),
          formatCurrency(totalEquity, locale)
        ],
        [
          LedgerLearnTranslations.tr('reports_total_liabilities_equity',
              locale),
          formatCurrency(totalLiabilities + totalEquity, locale)
        ],
      ],
    );
  }

  /// Export voucher list to CSV
  static Future<String?> exportVoucherListCsv(
      List<dynamic> vouchers, String locale) {
    return exportCsv(
      fileName: _datedFileName(
          LedgerLearnTranslations.tr('voucher_list', locale), 'csv'),
      headers: [
        LedgerLearnTranslations.tr('voucher_number', locale),
        LedgerLearnTranslations.tr('ledger_date', locale),
        LedgerLearnTranslations.tr('ledger_summary', locale),
        LedgerLearnTranslations.tr('voucher_debit_total', locale),
        LedgerLearnTranslations.tr('voucher_credit_total', locale),
      ],
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
