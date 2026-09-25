import '../models/account.dart';
import '../services/database_service.dart';
import '../../shared/utils/helpers.dart';

class AccountRepository {
  final DatabaseService _db;

  AccountRepository(this._db);

  List<Account> getAll() => _db.getAccounts();

  Account? getById(String id) => _db.getAccount(id);

  List<Account> getByCategory(String category) =>
      getAll().where((a) => a.category == category).toList();

  List<Account> getByType(int type) =>
      getAll().where((a) => a.type == type).toList();

  List<Account> search(String query, String locale) {
    final lower = query.toLowerCase();
    return getAll().where((a) {
      return a.getName(locale).toLowerCase().contains(lower) ||
          a.id.contains(lower);
    }).toList();
  }

  Future<void> addCustom(Account account) async {
    await _db.addAccount(account);
  }

  /// Calculate the current balance for an account from all vouchers (yuan).
  double getCurrentBalance(String accountId) =>
      centsToYuan(getCurrentBalanceCents(accountId));

  int getCurrentBalanceCents(String accountId) {
    Account? account;
    try {
      account = getAll().firstWhere((a) => a.id == accountId);
    } catch (_) {
      return 0;
    }

    int totalDebit = 0;
    int totalCredit = 0;

    for (final v in _db.getVouchers()) {
      for (final e in v.entries) {
        if (e.accountId == accountId) {
          if (e.isDebit) {
            totalDebit += e.amountCents;
          } else {
            totalCredit += e.amountCents;
          }
        }
      }
    }

    return calculateEndingBalanceCents(
      openingCents: account.openingBalanceCents,
      totalDebitCents: totalDebit,
      totalCreditCents: totalCredit,
      normallyDebit: account.normallyDebit,
    );
  }

  /// Get period activity summary for an account (yuan fields for display).
  ({double debit, double credit, double opening, double ending}) getPeriodSummary(
      String accountId, int? year, int? month) {
    final s = getPeriodSummaryCents(accountId, year, month);
    return (
      debit: s.debitCents / 100.0,
      credit: s.creditCents / 100.0,
      opening: s.openingCents / 100.0,
      ending: s.endingCents / 100.0,
    );
  }

  /// Exact period summary in cents.
  ({
    int debitCents,
    int creditCents,
    int openingCents,
    int endingCents
  }) getPeriodSummaryCents(String accountId, int? year, int? month) {
    final account = getById(accountId);
    if (account == null) {
      return (debitCents: 0, creditCents: 0, openingCents: 0, endingCents: 0);
    }

    final vouchers = _db.getVouchers(year: year, month: month);
    int totalDebit = 0;
    int totalCredit = 0;

    for (final v in vouchers) {
      for (final e in v.entries) {
        if (e.accountId == accountId) {
          if (e.isDebit) {
            totalDebit += e.amountCents;
          } else {
            totalCredit += e.amountCents;
          }
        }
      }
    }

    // Opening balance includes prior periods' activity
    int priorDebit = 0;
    int priorCredit = 0;
    for (final v in _db.getVouchers()) {
      if (year != null && month != null) {
        if (v.year > year || (v.year == year && v.month >= month)) continue;
      }
      for (final e in v.entries) {
        if (e.accountId == accountId) {
          if (e.isDebit) {
            priorDebit += e.amountCents;
          } else {
            priorCredit += e.amountCents;
          }
        }
      }
    }

    final opening = calculateEndingBalanceCents(
      openingCents: account.openingBalanceCents,
      totalDebitCents: priorDebit,
      totalCreditCents: priorCredit,
      normallyDebit: account.normallyDebit,
    );

    final ending = calculateEndingBalanceCents(
      openingCents: opening,
      totalDebitCents: totalDebit,
      totalCreditCents: totalCredit,
      normallyDebit: account.normallyDebit,
    );

    return (
      debitCents: totalDebit,
      creditCents: totalCredit,
      openingCents: opening,
      endingCents: ending,
    );
  }

  /// Period activity of P&L / balance-sheet groups for charts.
  /// Returns yuan values keyed by account name.
  Map<String, double> amountsByType(int type, {int? year, int? month}) {
    final result = <String, double>{};
    final locale = 'zh_CN';
    for (final a in getByType(type)) {
      final s = getPeriodSummary(a.id, year, month);
      final amount = type == 5
          ? s.credit
          : type == 6
              ? s.debit
              : s.ending.abs();
      if (amount > 0) {
        result[a.getName(locale)] = amount;
      }
    }
    return result;
  }
}
