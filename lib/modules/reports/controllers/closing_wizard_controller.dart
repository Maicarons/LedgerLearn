import 'package:get/get.dart';
import '../../../data/models/entry.dart';
import '../../../data/models/voucher.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../data/repositories/voucher_repository.dart';

/// Generates period-end closing vouchers step by step (教学向导).
class ClosingWizardController extends GetxController {
  final AccountRepository accountRepo = Get.find<AccountRepository>();
  final VoucherRepository voucherRepo = Get.find<VoucherRepository>();

  final step = 0.obs; // 0 intro, 1 revenue, 2 expense, 3 profit, 4 done
  final year = DateTime.now().year.obs;
  final month = DateTime.now().month.obs;
  final generated = <int, Voucher>{}.obs;
  final savedIds = <String>[].obs;

  String locale = 'zh_CN';

  @override
  void onInit() {
    super.onInit();
    locale = Get.locale?.toLanguageTag().replaceAll('-', '_') ?? 'zh_CN';
  }

  void nextStep() {
    if (step.value < 4) step.value++;
  }

  void prevStep() {
    if (step.value > 0) step.value--;
  }

  /// Revenue accounts with credit balance this period.
  List<({String id, String name, double amount})> get revenueItems {
    final result = <({String id, String name, double amount})>[];
    for (final a in accountRepo.getByType(5)) {
      final s = accountRepo.getPeriodSummary(a.id, year.value, month.value);
      if (s.credit > 0.005) {
        result.add((id: a.id, name: a.getName(locale), amount: s.credit));
      }
    }
    return result;
  }

  List<({String id, String name, double amount})> get expenseItems {
    final result = <({String id, String name, double amount})>[];
    for (final a in accountRepo.getByType(6)) {
      final s = accountRepo.getPeriodSummary(a.id, year.value, month.value);
      if (s.debit > 0.005) {
        result.add((id: a.id, name: a.getName(locale), amount: s.debit));
      }
    }
    return result;
  }

  double get totalRevenue =>
      revenueItems.fold(0.0, (s, i) => s + i.amount);
  double get totalExpense =>
      expenseItems.fold(0.0, (s, i) => s + i.amount);
  double get netProfit => totalRevenue - totalExpense;

  String nameOf(String id) =>
      accountRepo.getById(id)?.getName(locale) ?? id;

  /// Step 1: close revenues → 本年利润 (3103)
  Voucher buildRevenueClosing() {
    final entries = <Entry>[];
    for (final r in revenueItems) {
      entries.add(Entry.fromYuan(
          accountId: r.id, accountName: r.name, isDebit: true, amount: r.amount));
    }
    entries.add(Entry.fromYuan(
        accountId: '3103',
        accountName: nameOf('3103'),
        isDebit: false,
        amount: totalRevenue));
    return Voucher(
      id: voucherRepo.generateId(year.value, month.value),
      date: DateTime(year.value, month.value, 28),
      summary: 'closing_summary_revenue'.tr,
      entries: entries,
    );
  }

  /// Step 2: close expenses → 本年利润 (3103)
  Voucher buildExpenseClosing() {
    final entries = <Entry>[
      Entry.fromYuan(
          accountId: '3103',
          accountName: nameOf('3103'),
          isDebit: true,
          amount: totalExpense),
    ];
    for (final r in expenseItems) {
      entries.add(Entry.fromYuan(
          accountId: r.id,
          accountName: r.name,
          isDebit: false,
          amount: r.amount));
    }
    return Voucher(
      id: voucherRepo.generateId(year.value, month.value),
      date: DateTime(year.value, month.value, 28),
      summary: 'closing_summary_expense'.tr,
      entries: entries,
    );
  }

  /// Step 3: 本年利润 → 利润分配-未分配利润 (3104)
  Voucher buildProfitClosing() {
    final profit = netProfit;
    final isProfit = profit >= 0;
    return Voucher(
      id: voucherRepo.generateId(year.value, month.value),
      date: DateTime(year.value, month.value, 31),
      summary: 'closing_summary_profit'.tr,
      entries: [
        if (isProfit)
          Entry.fromYuan(
              accountId: '3103',
              accountName: nameOf('3103'),
              isDebit: true,
              amount: profit.abs())
        else
          Entry.fromYuan(
              accountId: '3104',
              accountName: nameOf('3104'),
              isDebit: true,
              amount: profit.abs()),
        if (isProfit)
          Entry.fromYuan(
              accountId: '3104',
              accountName: nameOf('3104'),
              isDebit: false,
              amount: profit.abs())
        else
          Entry.fromYuan(
              accountId: '3103',
              accountName: nameOf('3103'),
              isDebit: false,
              amount: profit.abs()),
      ],
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
        generated[3] = buildProfitClosing();
        break;
    }
    return generated[step];
  }

  Future<String?> saveStep(int step) async {
    final v = preview(step);
    if (v == null || v.entries.isEmpty) return null;
    // Regenerate id at save time in case prior steps were saved
    final fresh = Voucher(
      id: voucherRepo.generateId(year.value, month.value),
      date: v.date,
      summary: v.summary,
      entries: v.entries,
    );
    if (!fresh.isBalanced) return null;
    await voucherRepo.save(fresh);
    savedIds.add(fresh.id);
    generated[step] = fresh;
    return fresh.id;
  }
}
