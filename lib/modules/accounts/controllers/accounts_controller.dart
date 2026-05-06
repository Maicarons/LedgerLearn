import 'package:get/get.dart';
import '../../../data/models/account.dart';
import '../../../data/repositories/account_repository.dart';

class AccountsController extends GetxController {
  final AccountRepository accountRepo = Get.find<AccountRepository>();
  final accounts = <Account>[].obs;
  final selectedCategory = 'all'.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAccounts();
  }

  void loadAccounts() {
    accounts.value = accountRepo.getAll();
  }

  List<Account> get filteredAccounts {
    final locale =
        Get.locale?.toLanguageTag().replaceAll('-', '_') ?? 'zh_CN';
    var list = accounts.toList();

    if (selectedCategory.value != 'all') {
      list = list.where((a) => a.category == selectedCategory.value).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list.where((a) {
        return a.getName(locale).toLowerCase().contains(q) ||
            a.id.contains(q);
      }).toList();
    }

    return list;
  }

  Map<String, List<Account>> get groupedAccounts {
    final map = <String, List<Account>>{};
    for (final a in filteredAccounts) {
      map.putIfAbsent(a.categoryKey, () => []);
      map[a.categoryKey]!.add(a);
    }
    return map;
  }
}

class AccountDetailController extends GetxController {
  final AccountRepository accountRepo = Get.find<AccountRepository>();

  late Account account;
  final debitTotal = 0.0.obs;
  final creditTotal = 0.0.obs;
  final currentBalance = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    final id = Get.parameters['id']!;
    final acct = accountRepo.getById(id);
    if (acct != null) {
      account = acct;
      loadSummary();
    }
  }

  void loadSummary() {
    final summary = accountRepo.getPeriodSummary(account.id, null, null);
    debitTotal.value = summary.debit;
    creditTotal.value = summary.credit;
    currentBalance.value = accountRepo.getCurrentBalance(account.id);
  }
}
