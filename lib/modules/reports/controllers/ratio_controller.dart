import 'package:get/get.dart';
import '../../../data/services/financial_ratios.dart';
import '../../../data/repositories/account_repository.dart';
import 'reports_controller.dart';

/// Builds [FinancialRatios] from the account + income statement repositories.
class RatioController extends GetxController {
  final AccountRepository accountRepo = Get.find<AccountRepository>();
  final BalanceSheetController bs = Get.find<BalanceSheetController>();
  final IncomeStatementController isCtrl = Get.find<IncomeStatementController>();

  String get locale =>
      Get.locale?.toLanguageTag().replaceAll('-', '_') ?? 'zh_CN';

  int year = DateTime.now().year;
  int month = DateTime.now().month;

  FinancialRatios get ratios => FinancialRatios(
        year: year,
        month: month,
        currentAssets: bs.currentAssets,
        inventory: bs.inventory,
        totalAssets: bs.totalAssets,
        currentLiabilities: bs.currentLiabilities,
        totalLiabilities: bs.totalLiabilities,
        totalEquity: bs.totalEquity,
        revenue: isCtrl.totalRevenue,
        cogs: _cogs(),
        netProfit: isCtrl.netProfit,
      );

  double _cogs() {
    try {
      final a = accountRepo.getById('5401');
      if (a == null) return 0;
      return accountRepo.getPeriodSummary(a.id, year, month).debit;
    } catch (_) {
      return 0;
    }
  }

  void setPeriod(int y, int m) {
    year = y;
    month = m;
    bs.year = y;
    bs.month = m;
    isCtrl.year = y;
    isCtrl.month = m;
    update();
  }
}
