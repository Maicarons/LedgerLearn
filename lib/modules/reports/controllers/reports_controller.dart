import 'package:get/get.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../data/repositories/voucher_repository.dart';

class ReportsController extends GetxController {
  final int currentYear = DateTime.now().year;
  final int currentMonth = DateTime.now().month;
}

class TrialBalanceController extends GetxController {
  final AccountRepository accountRepo = Get.find<AccountRepository>();
  final VoucherRepository voucherRepo = Get.find<VoucherRepository>();

  int year = DateTime.now().year;
  int month = DateTime.now().month;

  List<TrialBalanceRow> get rows {
    final result = <TrialBalanceRow>[];
    double totalDebitOpening = 0, totalCreditOpening = 0;
    double totalDebitCurrent = 0, totalCreditCurrent = 0;
    double totalDebitEnding = 0, totalCreditEnding = 0;

    for (final account in accountRepo.getAll()) {
      final summary = accountRepo.getPeriodSummary(account.id, year, month);
      final normallyDebit = account.normallyDebit;

      double debitOpening = 0, creditOpening = 0;
      double debitCurrent = summary.debit;
      double creditCurrent = summary.credit;
      double debitEnding = 0, creditEnding = 0;

      if (normallyDebit) {
        if (summary.opening > 0) debitOpening = summary.opening;
        if (summary.ending > 0) debitEnding = summary.ending;
      } else {
        if (summary.opening > 0) creditOpening = summary.opening;
        if (summary.ending > 0) creditEnding = summary.ending;
      }

      if (summary.opening < 0) {
        if (normallyDebit) {
          creditOpening = -summary.opening;
        } else {
          debitOpening = -summary.opening;
        }
      }
      if (summary.ending < 0) {
        if (normallyDebit) {
          creditEnding = -summary.ending;
        } else {
          debitEnding = -summary.ending;
        }
      }

      if (debitOpening == 0 && creditOpening == 0 &&
          debitCurrent == 0 && creditCurrent == 0) { continue; }

      totalDebitOpening += debitOpening;
      totalCreditOpening += creditOpening;
      totalDebitCurrent += debitCurrent;
      totalCreditCurrent += creditCurrent;
      totalDebitEnding += debitEnding;
      totalCreditEnding += creditEnding;

      result.add(TrialBalanceRow(
        accountId: account.id,
        accountName: account.nameZh,
        debitOpening: debitOpening,
        creditOpening: creditOpening,
        debitCurrent: debitCurrent,
        creditCurrent: creditCurrent,
        debitEnding: debitEnding,
        creditEnding: creditEnding,
      ));
    }

    result.add(TrialBalanceRow(
      accountId: 'total',
      accountName: 'total'.tr,
      debitOpening: totalDebitOpening,
      creditOpening: totalCreditOpening,
      debitCurrent: totalDebitCurrent,
      creditCurrent: totalCreditCurrent,
      debitEnding: totalDebitEnding,
      creditEnding: totalCreditEnding,
      isTotal: true,
    ));

    return result;
  }

  bool get isBalanced {
    final r = rows.last;
    return (r.debitCurrent - r.creditCurrent).abs() < 0.01 &&
        (r.debitEnding - r.creditEnding).abs() < 0.01;
  }
}

class TrialBalanceRow {
  final String accountId;
  final String accountName;
  final double debitOpening;
  final double creditOpening;
  final double debitCurrent;
  final double creditCurrent;
  final double debitEnding;
  final double creditEnding;
  final bool isTotal;

  TrialBalanceRow({
    required this.accountId,
    required this.accountName,
    required this.debitOpening,
    required this.creditOpening,
    required this.debitCurrent,
    required this.creditCurrent,
    required this.debitEnding,
    required this.creditEnding,
    this.isTotal = false,
  });
}

class IncomeStatementController extends GetxController {
  final AccountRepository accountRepo = Get.find<AccountRepository>();

  int year = DateTime.now().year;
  int month = DateTime.now().month;

  List<IncomeItem> get revenueItems {
    final income = accountRepo.getByType(5);
    return income.map((a) {
      final summary = accountRepo.getPeriodSummary(a.id, year, month);
      return IncomeItem(name: a.nameZh, amount: summary.credit);
    }).toList();
  }

  List<IncomeItem> get expenseItems {
    final expenses = accountRepo.getByType(6);
    return expenses.map((a) {
      final summary = accountRepo.getPeriodSummary(a.id, year, month);
      return IncomeItem(name: a.nameZh, amount: summary.debit);
    }).toList();
  }

  double get totalRevenue =>
      revenueItems.fold(0.0, (s, i) => s + i.amount);
  double get totalExpense =>
      expenseItems.fold(0.0, (s, i) => s + i.amount);
  double get netProfit => totalRevenue - totalExpense;
}

class IncomeItem {
  final String name;
  final double amount;
  IncomeItem({required this.name, required this.amount});
}

class BalanceSheetController extends GetxController {
  final AccountRepository accountRepo = Get.find<AccountRepository>();

  double get totalAssets {
    final assets = accountRepo.getByType(1);
    double total = 0;
    for (final a in assets) {
      total += accountRepo.getCurrentBalance(a.id);
    }
    return total;
  }

  double get totalLiabilities {
    final liabilities = accountRepo.getByType(2);
    double total = 0;
    for (final a in liabilities) {
      total += accountRepo.getCurrentBalance(a.id).abs();
    }
    return total;
  }

  double get totalEquity {
    final equity = accountRepo.getByType(3);
    double total = 0;
    for (final a in equity) {
      total += accountRepo.getCurrentBalance(a.id).abs();
    }
    return total;
  }

  double get totalLiabilitiesEquity => totalLiabilities + totalEquity;
}
