import '../models/account.dart';
import '../models/voucher.dart';
import '../repositories/account_repository.dart';
import '../repositories/voucher_repository.dart';

/// Structured query helpers over the local book (GetStorage-backed repos).
///
/// These isolate "how we read" from "how we store" so a future SQLite
/// backend can swap the implementation without touching UI/controllers.
class BookQueryService {
  final AccountRepository accountRepo;
  final VoucherRepository voucherRepo;

  BookQueryService({
    required this.accountRepo,
    required this.voucherRepo,
  });

  /// Vouchers whose summary or any entry matches [keyword].
  List<Voucher> findVouchers(String keyword, {int? year, int? month}) {
    final q = keyword.trim().toLowerCase();
    return voucherRepo.getAll(year: year, month: month).where((v) {
      if (q.isEmpty) return true;
      if (v.id.toLowerCase().contains(q)) return true;
      if (v.summary.toLowerCase().contains(q)) return true;
      return v.entries.any(
        (e) =>
            e.accountId.toLowerCase().contains(q) ||
            e.accountName.toLowerCase().contains(q),
      );
    }).toList();
  }

  /// Account balances snapshot for reporting / export.
  List<({Account account, int balanceCents})> accountBalances() {
    final rows = <({Account account, int balanceCents})>[];
    for (final a in accountRepo.getAll()) {
      rows.add((
        account: a,
        balanceCents: accountRepo.getCurrentBalanceCents(a.id),
      ));
    }
    rows.sort((x, y) => x.account.id.compareTo(y.account.id));
    return rows;
  }

  /// Vouchers involving [accountId], newest first.
  List<Voucher> vouchersForAccount(String accountId, {int? year, int? month}) {
    return voucherRepo
        .getAll(year: year, month: month)
        .where((v) => v.entries.any((e) => e.accountId == accountId))
        .toList();
  }

  /// Count of vouchers per month for a given year (for charts / stats).
  Map<int, int> voucherCountByMonth(int year) {
    final map = <int, int>{};
    for (var m = 1; m <= 12; m++) {
      map[m] = voucherRepo.getAll(year: year, month: m).length;
    }
    return map;
  }
}
