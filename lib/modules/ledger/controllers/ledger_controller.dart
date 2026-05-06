import 'package:get/get.dart';
import '../../../data/models/account.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../data/repositories/voucher_repository.dart';

class LedgerController extends GetxController {
  final AccountRepository accountRepo = Get.find<AccountRepository>();
  final VoucherRepository voucherRepo = Get.find<VoucherRepository>();

  final accounts = <Account>[].obs;
  final periodYear = 0.obs;
  final periodMonth = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    periodYear.value = now.year;
    periodMonth.value = now.month;
    loadAccounts();
  }

  void loadAccounts() {
    accounts.value = accountRepo.getAll();
  }

  void setPeriod(int year, int month) {
    periodYear.value = year;
    periodMonth.value = month;
    update();
  }

  ({double opening, double debit, double credit, double ending}) getSummary(
      String accountId) {
    final summary =
        accountRepo.getPeriodSummary(accountId, periodYear.value, periodMonth.value);
    return summary;
  }
}

class LedgerDetailController extends GetxController {
  final AccountRepository accountRepo = Get.find<AccountRepository>();
  final VoucherRepository voucherRepo = Get.find<VoucherRepository>();

  late Account account;
  final entries = <LedgerEntry>[].obs;
  double runningBalance = 0;
  double openingBalance = 0;

  @override
  void onInit() {
    super.onInit();
    final id = Get.parameters['id']!;
    final acct = accountRepo.getById(id);
    if (acct != null) {
      account = acct;
      openingBalance = acct.openingBalance;
      loadEntries();
    }
  }

  void loadEntries() {
    final rawEntries =
        voucherRepo.getEntriesForAccount(account.id);
    final result = <LedgerEntry>[];
    runningBalance = openingBalance;

    for (final e in rawEntries) {
      if (account.normallyDebit) {
        runningBalance = runningBalance + e.debit - e.credit;
      } else {
        runningBalance = runningBalance + e.credit - e.debit;
      }
      result.add(LedgerEntry(
        date: e.voucher.date,
        voucherId: e.voucher.id,
        summary: e.voucher.summary,
        debit: e.debit,
        credit: e.credit,
        balance: runningBalance,
      ));
    }
    entries.value = result;
  }
}

class LedgerEntry {
  final DateTime date;
  final String voucherId;
  final String summary;
  final double debit;
  final double credit;
  final double balance;

  LedgerEntry({
    required this.date,
    required this.voucherId,
    required this.summary,
    required this.debit,
    required this.credit,
    required this.balance,
  });
}
