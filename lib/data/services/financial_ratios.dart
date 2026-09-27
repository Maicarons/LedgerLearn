import '../../shared/utils/helpers.dart';

/// Pure financial-ratio formulas for the teaching report.
/// All inputs are yuan; returns ratios as percentages or multiples.
class FinancialRatios {
  final int year;
  final int month;

  // Balance-sheet figures (yuan)
  final double currentAssets;
  final double inventory;
  final double totalAssets;
  final double currentLiabilities;
  final double totalLiabilities;
  final double totalEquity;

  // Income-statement figures (yuan)
  final double revenue;
  final double cogs;
  final double netProfit;

  FinancialRatios({
    required this.year,
    required this.month,
    required this.currentAssets,
    required this.inventory,
    required this.totalAssets,
    required this.currentLiabilities,
    required this.totalLiabilities,
    required this.totalEquity,
    required this.revenue,
    required this.cogs,
    required this.netProfit,
  });

  double get workingCapital => currentAssets - currentLiabilities;

  /// Current ratio = current assets / current liabilities.
  double get currentRatio =>
      currentLiabilities == 0 ? 0 : currentAssets / currentLiabilities;

  /// Quick ratio = (current assets − inventory) / current liabilities.
  double get quickRatio => currentLiabilities == 0
      ? 0
      : (currentAssets - inventory) / currentLiabilities;

  /// Debt ratio = total liabilities / total assets (0–1).
  double get debtRatio => totalAssets == 0 ? 0 : totalLiabilities / totalAssets;

  /// Equity ratio = total equity / total assets (0–1).
  double get equityRatio => totalAssets == 0 ? 0 : totalEquity / totalAssets;

  /// Gross margin = (revenue − COGS) / revenue (0–1).
  double get grossMargin => revenue == 0 ? 0 : (revenue - cogs) / revenue;

  /// Net margin = net profit / revenue (0–1).
  double get netMargin => revenue == 0 ? 0 : netProfit / revenue;

  /// Inventory turnover = COGS / inventory (times).
  double get inventoryTurnover => inventory == 0 ? 0 : cogs / inventory;

  /// Render a ratio as a teaching-friendly string.
  static String formatPercent(double v, String locale) =>
      '${(v * 100).toStringAsFixed(1)}%';

  static String formatTimes(double v, String locale) =>
      '${v.toStringAsFixed(2)}x';

  static String formatAmount(double yuan, String locale) =>
      formatCurrency(yuan, locale);

  /// Flat list for the ratios report UI.
  List<RatioRow> get rows => [
        RatioRow(
          key: 'ratio_current',
          labelKey: 'ratio_current',
          value: currentRatio,
          display: formatTimes(currentRatio, ''),
          hintKey: 'ratio_current_hint',
        ),
        RatioRow(
          key: 'ratio_quick',
          labelKey: 'ratio_quick',
          value: quickRatio,
          display: formatTimes(quickRatio, ''),
          hintKey: 'ratio_quick_hint',
        ),
        RatioRow(
          key: 'ratio_debt',
          labelKey: 'ratio_debt',
          value: debtRatio,
          display: formatPercent(debtRatio, ''),
          hintKey: 'ratio_debt_hint',
        ),
        RatioRow(
          key: 'ratio_gross',
          labelKey: 'ratio_gross',
          value: grossMargin,
          display: formatPercent(grossMargin, ''),
          hintKey: 'ratio_gross_hint',
        ),
        RatioRow(
          key: 'ratio_net',
          labelKey: 'ratio_net',
          value: netMargin,
          display: formatPercent(netMargin, ''),
          hintKey: 'ratio_net_hint',
        ),
        RatioRow(
          key: 'ratio_inventory',
          labelKey: 'ratio_inventory',
          value: inventoryTurnover,
          display: formatTimes(inventoryTurnover, ''),
          hintKey: 'ratio_inventory_hint',
        ),
      ];
}

class RatioRow {
  final String key;
  final String labelKey;
  final double value;
  final String display;
  final String hintKey;
  RatioRow({
    required this.key,
    required this.labelKey,
    required this.value,
    required this.display,
    required this.hintKey,
  });
}
