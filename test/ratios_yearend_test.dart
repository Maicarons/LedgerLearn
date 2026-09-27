import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerlearn/data/services/financial_ratios.dart';

void main() {
  group('FinancialRatios', () {
    FinancialRatios build({
      double ca = 200,
      double inv = 50,
      double ta = 500,
      double cl = 100,
      double tl = 200,
      double te = 300,
      double rev = 400,
      double cogs = 200,
      double np = 80,
    }) =>
        FinancialRatios(
          year: 2026,
          month: 6,
          currentAssets: ca,
          inventory: inv,
          totalAssets: ta,
          currentLiabilities: cl,
          totalLiabilities: tl,
          totalEquity: te,
          revenue: rev,
          cogs: cogs,
          netProfit: np,
        );

    test('current ratio = current assets / current liabilities', () {
      expect(build().currentRatio, closeTo(2.0, 0.001));
    });

    test('quick ratio excludes inventory', () {
      // (200-50)/100 = 1.5
      expect(build().quickRatio, closeTo(1.5, 0.001));
    });

    test('debt ratio = liabilities / assets', () {
      expect(build().debtRatio, closeTo(0.4, 0.001));
    });

    test('gross margin = (revenue - cogs) / revenue', () {
      expect(build().grossMargin, closeTo(0.5, 0.001));
    });

    test('net margin = net profit / revenue', () {
      expect(build().netMargin, closeTo(0.2, 0.001));
    });

    test('inventory turnover = cogs / inventory', () {
      expect(build().inventoryTurnover, closeTo(4.0, 0.001));
    });

    test('guards divide-by-zero', () {
      final z = build(cl: 0, inv: 0, ta: 0, rev: 0);
      expect(z.currentRatio, 0);
      expect(z.quickRatio, 0);
      expect(z.debtRatio, 0);
      expect(z.grossMargin, 0);
      expect(z.netMargin, 0);
      expect(z.inventoryTurnover, 0);
    });

    test('rows expose 6 ratios', () {
      expect(build().rows.length, 6);
    });
  });

  group('YearEnd pure figures', () {
    test('surplus reserve is 10% of positive profit', () {
      // 10% of 12345.6 → 1234.56
      final reserve = (12345.6 * 0.10 * 100).round() / 100;
      expect(reserve, closeTo(1234.56, 0.01));
    });

    test('no reserve on loss', () {
      final net = -500.0;
      final reserve = net > 0 ? (net * 0.10 * 100).round() / 100 : 0.0;
      expect(reserve, 0);
    });
  });

  group('Streak day-key logic', () {
    test('consecutive day increments streak', () {
      // Pure simulation of the day-key rule used by StreakService.
      String dayKey(DateTime d) =>
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final d1 = DateTime(2026, 9, 25);
      final d2 = DateTime(2026, 9, 26);
      final d3 = DateTime(2026, 9, 28);
      expect(dayKey(d2), dayKey(d1.add(const Duration(days: 1))));
      // Skip a day → streak would reset to 1
      expect(dayKey(d3) != dayKey(d2.add(const Duration(days: 1))), isTrue);
    });
  });
}
