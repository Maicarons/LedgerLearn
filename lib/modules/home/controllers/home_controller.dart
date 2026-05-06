import 'package:get/get.dart';
import '../../../data/repositories/voucher_repository.dart';
import '../../../shared/utils/helpers.dart';

class HomeSummary {
  final int voucherCount;
  final double totalDebit;
  final double totalCredit;
  final bool isBalanced;

  HomeSummary({
    required this.voucherCount,
    required this.totalDebit,
    required this.totalCredit,
    required this.isBalanced,
  });
}

class HomeController extends GetxController {
  final VoucherRepository voucherRepo = Get.find<VoucherRepository>();

  final currentPeriod = ''.obs;
  final locale = ''.obs;
  final summary = HomeSummary(
          voucherCount: 0, totalDebit: 0, totalCredit: 0, isBalanced: true)
      .obs;

  List<String> get availablePeriods {
    final now = DateTime.now();
    final periods = <String>[];
    for (int y = now.year; y >= now.year - 1; y--) {
      for (int m = 12; m >= 1; m--) {
        periods.add('$y-${m.toString().padLeft(2, '0')}');
      }
    }
    return periods;
  }

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    currentPeriod.value = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    locale.value = Get.locale?.toLanguageTag().replaceAll('-', '_') ?? 'zh_CN';
    refreshSummary();
  }

  void setPeriod(String period) {
    currentPeriod.value = period;
    refreshSummary();
  }

  void refreshSummary() {
    final parts = currentPeriod.value.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    final count = voucherRepo.getAll(year: year, month: month).length;
    final debit = voucherRepo.totalPeriodDebit(year, month);
    final credit = voucherRepo.totalPeriodCredit(year, month);
    final balanced = (debit - credit).abs() < 0.01;

    summary.value = HomeSummary(
      voucherCount: count,
      totalDebit: debit,
      totalCredit: credit,
      isBalanced: balanced,
    );
  }

  String formatAmount(double amount) {
    return formatCurrency(amount, locale.value);
  }
}
