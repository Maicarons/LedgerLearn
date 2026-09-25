import '../models/voucher.dart';
import '../services/database_service.dart';

class VoucherRepository {
  final DatabaseService _db;

  VoucherRepository(this._db);

  List<Voucher> getAll({int? year, int? month}) =>
      _db.getVouchers(year: year, month: month);

  Voucher? getById(String id) => _db.getVoucher(id);

  Future<String> save(Voucher voucher) async {
    await _db.saveVoucher(voucher);
    return voucher.id;
  }

  Future<void> delete(String id) async {
    await _db.deleteVoucher(id);
  }

  String generateId(int year, int month) =>
      _db.generateVoucherId(year, month);

  /// Get all entries for a specific account, ordered by date.
  /// Amounts are in yuan (from cents-backed [Entry.amount]).
  List<({Voucher voucher, double debit, double credit, int debitCents, int creditCents})>
      getEntriesForAccount(String accountId, {int? year, int? month}) {
    final vouchers = _db.getVouchers(year: year, month: month);
    final result =
        <({Voucher voucher, double debit, double credit, int debitCents, int creditCents})>[];

    for (final v in vouchers) {
      for (final e in v.entries) {
        if (e.accountId == accountId) {
          final dC = e.isDebit ? e.amountCents : 0;
          final cC = e.isDebit ? 0 : e.amountCents;
          result.add((
            voucher: v,
            debit: dC / 100.0,
            credit: cC / 100.0,
            debitCents: dC,
            creditCents: cC,
          ));
        }
      }
    }
    result.sort((a, b) => a.voucher.date.compareTo(b.voucher.date));
    return result;
  }

  /// Check if all vouchers in a period are balanced (exact cents).
  bool isPeriodBalanced(int year, int month) {
    final vouchers = getAll(year: year, month: month);
    for (final v in vouchers) {
      if (!v.isBalanced) return false;
    }
    return true;
  }

  int totalPeriodDebitCents(int year, int month) {
    return getAll(year: year, month: month)
        .fold(0, (sum, v) => sum + v.totalDebitCents);
  }

  int totalPeriodCreditCents(int year, int month) {
    return getAll(year: year, month: month)
        .fold(0, (sum, v) => sum + v.totalCreditCents);
  }

  /// Total debit across all vouchers in a period (yuan)
  double totalPeriodDebit(int year, int month) =>
      totalPeriodDebitCents(year, month) / 100.0;

  /// Total credit across all vouchers in a period (yuan)
  double totalPeriodCredit(int year, int month) =>
      totalPeriodCreditCents(year, month) / 100.0;

  /// Monthly debit/credit series for the last [months] months ending at [end].
  List<({String label, double debit, double credit})> monthlyTrend({
    required int endYear,
    required int endMonth,
    int months = 6,
  }) {
    final result = <({String label, double debit, double credit})>[];
    var y = endYear;
    var m = endMonth;
    for (var i = 0; i < months; i++) {
      result.insert(
        0,
        (
          label: '$y-${m.toString().padLeft(2, '0')}',
          debit: totalPeriodDebit(y, m),
          credit: totalPeriodCredit(y, m),
        ),
      );
      m -= 1;
      if (m == 0) {
        m = 12;
        y -= 1;
      }
    }
    return result;
  }
}
