import '../../shared/utils/helpers.dart';
import '../models/voucher.dart';

/// Simplified direct-method cash flow statement (teaching model).
///
/// Cash & cash equivalents = 1001 Cash on Hand + 1002 Bank Deposit +
/// 1012 Other Monetary Funds (and custom accounts under those prefixes).
/// Each voucher's cash movement is classified by the counterpart account.
class CashFlowService {
  /// Account ids treated as cash & cash equivalents.
  static const Set<String> cashAccountIds = {'1001', '1002', '1012'};

  static bool isCashAccount(String accountId) =>
      cashAccountIds.contains(accountId) ||
      accountId.startsWith('1001') ||
      accountId.startsWith('1002') ||
      accountId.startsWith('1012');

  /// Classify a counterpart account into a cash-flow category + line item.
  static CashFlowLine classify(String accountId) {
    // Contra / non-cash noise — treat residual as operating other.
    if (accountId == '1602' || accountId == '1702') {
      return const CashFlowLine(CashFlowCategory.operating, 'other');
    }

    // Investing activities
    if (_inRange(accountId, const [
      '1601', '1604', '1606', '1701', '1801',
      '1101', '1501', '1511',
      '1131', '1132', // dividends / interest receivable collected
    ])) {
      if (accountId == '1131' || accountId == '1132') {
        return const CashFlowLine(CashFlowCategory.investing, 'investIncome');
      }
      return const CashFlowLine(CashFlowCategory.investing, 'investAsset');
    }

    // Financing activities
    if (_inRange(accountId, const [
      '2001', '2501', '2502', '2701', // borrowings
      '3001', '3002', // paid-in capital / capital reserve
      '2232', // dividends payable
      '2231', // interest payable (paid)
    ])) {
      if (accountId == '2231') {
        return const CashFlowLine(CashFlowCategory.financing, 'interestPaid');
      }
      if (accountId == '2232') {
        return const CashFlowLine(CashFlowCategory.financing, 'dividendPaid');
      }
      if (accountId == '3001' || accountId == '3002') {
        return const CashFlowLine(CashFlowCategory.financing, 'capital');
      }
      return const CashFlowLine(CashFlowCategory.financing, 'borrowing');
    }

    // Operating — revenue side
    if (accountId == '5001' || accountId == '1122' || accountId == '1121') {
      return const CashFlowLine(CashFlowCategory.operating, 'salesReceipts');
    }
    if (accountId == '2203') {
      return const CashFlowLine(CashFlowCategory.operating, 'salesReceipts');
    }
    if (accountId == '5051' || accountId == '5301') {
      return const CashFlowLine(CashFlowCategory.operating, 'otherOpIn');
    }

    // Operating — purchase / payroll / tax / expense side
    if (accountId == '1401' ||
        accountId == '1403' ||
        accountId == '1405' ||
        accountId == '1411' ||
        accountId == '2202' ||
        accountId == '2201' ||
        accountId == '1123') {
      return const CashFlowLine(CashFlowCategory.operating, 'purchasePaid');
    }
    if (accountId == '2211') {
      return const CashFlowLine(CashFlowCategory.operating, 'wagesPaid');
    }
    if (accountId == '2221' || accountId == '5403') {
      return const CashFlowLine(CashFlowCategory.operating, 'taxPaid');
    }
    if (_inRange(accountId, const [
      '5501', '5502', '5503', '5401', '5402', '5601', '5701', '5801',
      '1221', '2241', '2231', '1231', '1471', '1901',
    ])) {
      return const CashFlowLine(CashFlowCategory.operating, 'otherOpOut');
    }

    // Cost accounts settle through inventory — treat as operating.
    if (accountId.startsWith('40') || accountId.startsWith('41')) {
      return const CashFlowLine(CashFlowCategory.operating, 'otherOpOut');
    }

    // Equity / profit distribution residual
    if (accountId.startsWith('31')) {
      return const CashFlowLine(CashFlowCategory.financing, 'dividendPaid');
    }

    return const CashFlowLine(CashFlowCategory.operating, 'otherOpOut');
  }

  static bool _inRange(String id, List<String> prefixes) =>
      prefixes.any((p) => id == p || id.startsWith(p));

  /// Build the cash-flow statement for one accounting period.
  ///
  /// [openingCashCents] / [closingCashCents] come from the account repository
  /// so the statement reconciles with the balance sheet cash balances.
  CashFlowStatement build({
    required List<Voucher> vouchers,
    required int openingCashCents,
    required int closingCashCents,
    required int year,
    required int month,
  }) {
    // Accumulators in cents.
    final inFlow = <String, int>{}; // lineKey -> cents
    final outFlow = <String, int>{};

    for (final v in vouchers) {
      if (v.year != year || v.month != month) continue;

      int cashDebit = 0;
      int cashCredit = 0;
      final counterparts = <({String accountId, int amountCents, bool isDebit})>[];

      for (final e in v.entries) {
        if (isCashAccount(e.accountId)) {
          if (e.isDebit) {
            cashDebit += e.amountCents;
          } else {
            cashCredit += e.amountCents;
          }
        } else {
          counterparts.add((
            accountId: e.accountId,
            amountCents: e.amountCents,
            isDebit: e.isDebit,
          ));
        }
      }

      // Net cash effect of this voucher (positive = inflow).
      final netCash = cashDebit - cashCredit;
      if (netCash == 0) continue;

      // Total non-cash amount for proportional allocation.
      int counterpartTotal = 0;
      for (final c in counterparts) {
        counterpartTotal += c.amountCents;
      }
      if (counterpartTotal == 0) {
        // Cash-only internal transfer (cash <-> bank) — not a cash flow event
        // at the cash-and-equivalents level.
        continue;
      }

      int allocated = 0;
      for (var i = 0; i < counterparts.length; i++) {
        final c = counterparts[i];
        int share;
        if (i == counterparts.length - 1) {
          share = netCash.abs() - allocated;
        } else {
          share = (netCash.abs() * c.amountCents) ~/ counterpartTotal;
          allocated += share;
        }
        final line = classify(c.accountId);
        final key = '${line.category.name}.${line.lineKey}';
        if (netCash > 0) {
          inFlow[key] = (inFlow[key] ?? 0) + share;
        } else {
          outFlow[key] = (outFlow[key] ?? 0) + share;
        }
      }
    }

    return CashFlowStatement(
      year: year,
      month: month,
      inflows: inFlow,
      outflows: outFlow,
      openingCashCents: openingCashCents,
      closingCashCents: closingCashCents,
    );
  }
}

enum CashFlowCategory { operating, investing, financing }

class CashFlowLine {
  final CashFlowCategory category;
  final String lineKey;
  const CashFlowLine(this.category, this.lineKey);
}

/// Aggregated cash-flow statement for one period. All amounts in cents.
class CashFlowStatement {
  final int year;
  final int month;

  /// Map of `category.lineKey` → inflow cents.
  final Map<String, int> inflows;

  /// Map of `category.lineKey` → outflow cents.
  final Map<String, int> outflows;

  final int openingCashCents;
  final int closingCashCents;

  CashFlowStatement({
    required this.year,
    required this.month,
    required this.inflows,
    required this.outflows,
    required this.openingCashCents,
    required this.closingCashCents,
  });

  int _sum(Map<String, int> map, CashFlowCategory category) {
    var total = 0;
    map.forEach((key, value) {
      if (key.startsWith('${category.name}.')) total += value;
    });
    return total;
  }

  int get operatingInflowCents => _sum(inflows, CashFlowCategory.operating);
  int get operatingOutflowCents => _sum(outflows, CashFlowCategory.operating);
  int get investingInflowCents => _sum(inflows, CashFlowCategory.investing);
  int get investingOutflowCents => _sum(outflows, CashFlowCategory.investing);
  int get financingInflowCents => _sum(inflows, CashFlowCategory.financing);
  int get financingOutflowCents => _sum(outflows, CashFlowCategory.financing);

  int get operatingNetCents => operatingInflowCents - operatingOutflowCents;
  int get investingNetCents => investingInflowCents - investingOutflowCents;
  int get financingNetCents => financingInflowCents - financingOutflowCents;

  int get netIncreaseCents =>
      operatingNetCents + investingNetCents + financingNetCents;

  /// Discrepancy between stated closing cash and computed closing.
  /// Should be 0 when every cash movement is classified.
  int get reconcileDiffCents =>
      (openingCashCents + netIncreaseCents) - closingCashCents;

  /// Lookup a specific line (inflow or outflow) in cents.
  int lineCents(CashFlowCategory category, String lineKey, {required bool isInflow}) {
    final map = isInflow ? inflows : outflows;
    return map['${category.name}.$lineKey'] ?? 0;
  }

  String formatted(int cents, String locale) => formatCents(cents, locale);
}
