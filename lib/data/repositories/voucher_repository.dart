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

  /// Get all entries for a specific account, ordered by date
  List<({Voucher voucher, double debit, double credit})> getEntriesForAccount(
      String accountId,
      {int? year, int? month}) {
    final vouchers = _db.getVouchers(year: year, month: month);
    final result = <({Voucher voucher, double debit, double credit})>[];

    for (final v in vouchers) {
      for (final e in v.entries) {
        if (e.accountId == accountId) {
          result.add((
            voucher: v,
            debit: e.isDebit ? e.amount : 0,
            credit: e.isDebit ? 0 : e.amount,
          ));
        }
      }
    }
    result.sort((a, b) => a.voucher.date.compareTo(b.voucher.date));
    return result;
  }

  /// Check if all vouchers in a period are balanced
  bool isPeriodBalanced(int year, int month) {
    final vouchers = getAll(year: year, month: month);
    for (final v in vouchers) {
      if (!v.isBalanced) return false;
    }
    return true;
  }

  /// Total debit across all vouchers in a period
  double totalPeriodDebit(int year, int month) {
    return getAll(year: year, month: month)
        .fold(0.0, (sum, v) => sum + v.totalDebit);
  }

  /// Total credit across all vouchers in a period
  double totalPeriodCredit(int year, int month) {
    return getAll(year: year, month: month)
        .fold(0.0, (sum, v) => sum + v.totalCredit);
  }
}
