import 'package:get/get.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../data/repositories/voucher_repository.dart';
import '../../../data/services/cash_flow_service.dart';

/// Drives the simplified direct-method cash flow statement.
class CashFlowController extends GetxController {
  final AccountRepository accountRepo = Get.find<AccountRepository>();
  final VoucherRepository voucherRepo = Get.find<VoucherRepository>();
  final CashFlowService service = CashFlowService();

  String get locale =>
      Get.locale?.toLanguageTag().replaceAll('-', '_') ?? 'zh_CN';

  int year = DateTime.now().year;
  int month = DateTime.now().month;

  /// Opening cash = sum of opening balances of cash accounts at period start.
  int get openingCashCents {
    var total = 0;
    for (final id in CashFlowService.cashAccountIds) {
      final s = accountRepo.getPeriodSummaryCents(id, year, month);
      total += s.openingCents;
    }
    // Custom cash sub-accounts
    for (final a in accountRepo.getAll()) {
      if (CashFlowService.isCashAccount(a.id) &&
          !CashFlowService.cashAccountIds.contains(a.id)) {
        final s = accountRepo.getPeriodSummaryCents(a.id, year, month);
        total += s.openingCents;
      }
    }
    return total;
  }

  int get closingCashCents {
    var total = 0;
    for (final a in accountRepo.getAll()) {
      if (CashFlowService.isCashAccount(a.id)) {
        total += accountRepo.getCurrentBalanceCents(a.id);
      }
    }
    return total;
  }

  CashFlowStatement get statement => service.build(
        vouchers: voucherRepo.getAll(),
        openingCashCents: openingCashCents,
        closingCashCents: closingCashCents,
        year: year,
        month: month,
      );

  void setPeriod(int y, int m) {
    year = y;
    month = m;
    update();
  }
}

/// A single display row on the cash-flow report.
class CashFlowRow {
  final String labelKey;
  final int amountCents;
  final bool isSubtotal;
  final bool isTotal;
  CashFlowRow({
    required this.labelKey,
    required this.amountCents,
    this.isSubtotal = false,
    this.isTotal = false,
  });
}
