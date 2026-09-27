import 'package:get/get.dart';
import '../../../data/models/entry.dart';
import '../../../data/models/voucher.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../data/repositories/voucher_repository.dart';

/// Year-end closing workbench: close P&L → transfer profit → surplus reserve.
///
/// Steps:
///  1. Close revenues → 本年利润 (3103)
///  2. Close expenses → 本年利润 (3103)
///  3. 本年利润 → 利润分配-未分配利润 (3104)
///  4. Accrue 10% statutory surplus reserve (3101)
///  5. Done — preview year-end balances
class YearEndClosingController extends GetxController {
  final AccountRepository accountRepo = Get.find<AccountRepository>();
  final VoucherRepository voucherRepo = Get.find<VoucherRepository>();

  final step = 0.obs; // 0 intro … 5 done
  final year = DateTime.now().year.obs;
  final generated = <int, Voucher>{}.obs;
  final savedIds = <String>[].obs;
  final savedSteps = <int>{}.obs;

  String locale = 'zh_CN';

  /// Statutory surplus reserve rate (teaching default 10%).
  static const double reserveRate = 0.10;

  @override
  void onInit() {
    super.onInit();
    locale = Get.locale?.toLanguageTag().replaceAll('-', '_') ?? 'zh_CN';
  }

  void setYear(int y) {
    year.value = y;
    generated.clear();
    savedSteps.clear();
    update();
  }

  void nextStep() {
    if (step.value < 5) step.value++;
  }

  void prevStep() {
    if (step.value > 0) step.value--;
  }

  String nameOf(String id) =>
      accountRepo.getById(id)?.getName(locale) ?? id;

  /// All revenue/expense activity for the whole year.
  List<({String id, String name, double amount})> get revenueItems {
    final result = <({String id, String name, double amount})>[];
    for (final a in accountRepo.getByType(5)) {
      double credit = 0;
      for (var m = 1; m <= 12; m++) {
        credit += accountRepo.getPeriodSummary(a.id, year.value, m).credit;
      }
      if (credit > 0.005) {
        result.add((id: a.id, name: a.getName(locale), amount: credit));
      }
    }
    return result;
  }

  List<({String id, String name, double amount})> get expenseItems {
    final result = <({String id, String name, double amount})>[];
    for (final a in accountRepo.getByType(6)) {
      double debit = 0;
      for (var m = 1; m <= 12; m++) {
        debit += accountRepo.getPeriodSummary(a.id, year.value, m).debit;
      }
      if (debit > 0.005) {
        result.add((id: a.id, name: a.getName(locale), amount: debit));
      }
    }
    return result;
  }

  double get totalRevenue =>
      revenueItems.fold(0.0, (s, i) => s + i.amount);
  double get totalExpense =>
      expenseItems.fold(0.0, (s, i) => s + i.amount);
  double get netProfit => totalRevenue - totalExpense;

  /// Statutory surplus reserve (only on profit).
  double get surplusReserve =>
      netProfit > 0 ? (netProfit * reserveRate * 100).round() / 100 : 0;

  /// 12/31 of the selected year.
  DateTime get closingDate => DateTime(year.value, 12, 31);

  Voucher _voucher(List<Entry> entries, String summaryKey) => Voucher(
        id: voucherRepo.generateId(year.value, 12),
        date: closingDate,
        summary: summaryKey.tr,
        entries: entries,
      );

  /// Step 1: close annual revenues.
  Voucher buildRevenueClosing() {
    final entries = <Entry>[
      for (final r in revenueItems)
        Entry.fromYuan(
            accountId: r.id,
            accountName: r.name,
            isDebit: true,
            amount: r.amount),
      Entry.fromYuan(
          accountId: '3103',
          accountName: nameOf('3103'),
          isDebit: false,
          amount: totalRevenue),
    ];
    return _voucher(entries, 'yearend_summary_revenue');
  }

  /// Step 2: close annual expenses.
  Voucher buildExpenseClosing() {
    final entries = <Entry>[
      Entry.fromYuan(
          accountId: '3103',
          accountName: nameOf('3103'),
          isDebit: true,
          amount: totalExpense),
      for (final r in expenseItems)
        Entry.fromYuan(
            accountId: r.id,
            accountName: r.name,
            isDebit: false,
            amount: r.amount),
    ];
    return _voucher(entries, 'yearend_summary_expense');
  }

  /// Step 3: 本年利润 → 利润分配-未分配利润.
  Voucher buildProfitTransfer() {
    final profit = netProfit.abs();
    final isProfit = netProfit >= 0;
    return _voucher(
      [
        if (isProfit)
          Entry.fromYuan(
              accountId: '3103',
              accountName: nameOf('3103'),
              isDebit: true,
              amount: profit)
        else
          Entry.fromYuan(
              accountId: '3104',
              accountName: nameOf('3104'),
              isDebit: true,
              amount: profit),
        if (isProfit)
          Entry.fromYuan(
              accountId: '3104',
              accountName: nameOf('3104'),
              isDebit: false,
              amount: profit)
        else
          Entry.fromYuan(
              accountId: '3103',
              accountName: nameOf('3103'),
              isDebit: false,
              amount: profit),
      ],
      'yearend_summary_profit',
    );
  }

  /// Step 4: accrue statutory surplus reserve (10% of net profit).
  Voucher? buildSurplusReserve() {
    final reserve = surplusReserve;
    if (reserve <= 0) return null;
    return _voucher(
      [
        Entry.fromYuan(
            accountId: '3104',
            accountName: nameOf('3104'),
            isDebit: true,
            amount: reserve),
        Entry.fromYuan(
            accountId: '3101',
            accountName: nameOf('3101'),
            isDebit: false,
            amount: reserve),
      ],
      'yearend_summary_reserve',
    );
  }

  Voucher? preview(int step) {
    if (generated.containsKey(step)) return generated[step];
    switch (step) {
      case 1:
        generated[1] = buildRevenueClosing();
        break;
      case 2:
        generated[2] = buildExpenseClosing();
        break;
      case 3:
        generated[3] = buildProfitTransfer();
        break;
      case 4:
        final v = buildSurplusReserve();
        if (v != null) generated[4] = v;
        break;
    }
    return generated[step];
  }

  Future<String?> saveStep(int step) async {
    final v = preview(step);
    if (v == null || v.entries.isEmpty) return null;
    final fresh = Voucher(
      id: voucherRepo.generateId(year.value, 12),
      date: v.date,
      summary: v.summary,
      entries: v.entries,
    );
    if (!fresh.isBalanced) return null;
    await voucherRepo.save(fresh);
    savedIds.add(fresh.id);
    savedSteps.add(step);
    generated[step] = fresh;
    return fresh.id;
  }

  bool isStepSaved(int step) => savedSteps.contains(step);
}
