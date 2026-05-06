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

  /// Calculate the current balance for an account from all vouchers
  double getCurrentBalance(String accountId) {
    final accounts = getAll();
    Account? account;
    try {
      account = accounts.firstWhere((a) => a.id == accountId);
    } catch (_) {
      return 0;
    }

    final vouchers = _db.getVouchers();
    double totalDebit = 0;
    double totalCredit = 0;

    for (final v in vouchers) {
      for (final e in v.entries) {
        if (e.accountId == accountId) {
          if (e.isDebit) {
            totalDebit += e.amount;
          } else {
            totalCredit += e.amount;
          }
        }
      }
    }

    return calculateEndingBalance(
      opening: account.openingBalance,
      totalDebit: totalDebit,
      totalCredit: totalCredit,
      normallyDebit: account.normallyDebit,
    );
  }

  /// Get period activity summary for an account
  ({double debit, double credit, double opening, double ending}) getPeriodSummary(
      String accountId, int? year, int? month) {
    final account = getById(accountId);
    if (account == null) {
      return (debit: 0, credit: 0, opening: 0, ending: 0);
    }

    final vouchers = _db.getVouchers(year: year, month: month);
    double totalDebit = 0;
    double totalCredit = 0;

    for (final v in vouchers) {
      for (final e in v.entries) {
        if (e.accountId == accountId) {
          if (e.isDebit) {
            totalDebit += e.amount;
          } else {
            totalCredit += e.amount;
          }
        }
      }
    }

    // Opening balance includes prior periods' activity
    double priorDebit = 0;
    double priorCredit = 0;
    final priorVouchers = _db.getVouchers();
    for (final v in priorVouchers) {
      if (year != null && month != null) {
        if (v.year > year || (v.year == year && v.month >= month)) continue;
      }
      for (final e in v.entries) {
        if (e.accountId == accountId) {
          if (e.isDebit) {
            priorDebit += e.amount;
          } else {
            priorCredit += e.amount;
          }
        }
      }
    }

    final opening = calculateEndingBalance(
      opening: account.openingBalance,
      totalDebit: priorDebit,
      totalCredit: priorCredit,
      normallyDebit: account.normallyDebit,
    );

    final ending = calculateEndingBalance(
      opening: opening,
      totalDebit: totalDebit,
      totalCredit: totalCredit,
      normallyDebit: account.normallyDebit,
    );

    return (debit: totalDebit, credit: totalCredit, opening: opening, ending: ending);
  }
}
