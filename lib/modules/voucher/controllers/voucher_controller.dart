import 'package:get/get.dart';
import '../../../data/models/account.dart';
import '../../../data/models/entry.dart';
import '../../../data/models/voucher.dart';
import '../../../data/models/knowledge_card.dart';
import '../../../data/repositories/voucher_repository.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../data/repositories/knowledge_repository.dart';

class VoucherFormController extends GetxController {
  final VoucherRepository voucherRepo = Get.find<VoucherRepository>();
  final AccountRepository accountRepo = Get.find<AccountRepository>();
  final KnowledgeRepository knowledgeRepo = Get.find<KnowledgeRepository>();

  final summary = ''.obs;
  final date = DateTime.now().obs;
  final entries = <Entry>[].obs;
  final isEdit = false.obs;
  String? editingId;

  final totalDebit = 0.0.obs;
  final totalCredit = 0.0.obs;
  final isBalanced = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['voucher'] != null) {
      final v = args['voucher'] as Voucher;
      isEdit.value = true;
      editingId = v.id;
      summary.value = v.summary;
      date.value = v.date;
      entries.value = v.entries.map((e) => Entry(
        accountId: e.accountId,
        accountName: e.accountName,
        isDebit: e.isDebit,
        amount: e.amount,
      )).toList();
      _recalculate();
    }
  }

  void setDate(DateTime d) {
    date.value = d;
  }

  void addEntry() {
    entries.add(Entry(
      accountId: '',
      accountName: '',
      isDebit: true,
      amount: 0,
    ));
  }

  void removeEntry(int index) {
    if (entries.length > 2) {
      entries.removeAt(index);
      _recalculate();
    }
  }

  void setEntryAccount(int index, Account account) {
    final old = entries[index];
    entries[index] = Entry(
      accountId: account.id,
      accountName: account.getName(
          Get.locale?.toLanguageTag().replaceAll('-', '_') ?? 'zh_CN'),
      isDebit: old.isDebit,
      amount: old.amount,
    );
  }

  void setEntryDirection(int index, bool isDebit) {
    final old = entries[index];
    entries[index] = Entry(
      accountId: old.accountId,
      accountName: old.accountName,
      isDebit: isDebit,
      amount: old.amount,
    );
  }

  void setEntryAmount(int index, double amount) {
    final old = entries[index];
    entries[index] = Entry(
      accountId: old.accountId,
      accountName: old.accountName,
      isDebit: old.isDebit,
      amount: amount,
    );
    _recalculate();
  }

  void _recalculate() {
    totalDebit.value =
        entries.where((e) => e.isDebit).fold(0.0, (s, e) => s + e.amount);
    totalCredit.value =
        entries.where((e) => !e.isDebit).fold(0.0, (s, e) => s + e.amount);
    isBalanced.value = (totalDebit.value - totalCredit.value).abs() < 0.001;
  }

  bool canSave() {
    if (summary.value.trim().isEmpty) return false;
    if (entries.length < 2) return false;
    if (entries.any((e) => e.accountId.isEmpty)) return false;
    if (!isBalanced.value) return false;
    return true;
  }

  String? validate() {
    if (summary.value.trim().isEmpty) return 'voucher_summary_hint'.tr;
    if (entries.length < 2) return 'voucher_no_entries'.tr;
    if (entries.any((e) => e.accountId.isEmpty)) {
      return '请为所有分录选择科目';
    }
    if (!isBalanced.value) return 'voucher_balance_rule'.tr;
    return null;
  }

  Future<Voucher?> save() async {
    if (!canSave()) return null;

    final id = isEdit.value
        ? editingId!
        : voucherRepo.generateId(date.value.year, date.value.month);

    final voucher = Voucher(
      id: id,
      date: date.value,
      summary: summary.value.trim(),
      entries: entries.toList(),
    );

    await voucherRepo.save(voucher);
    return voucher;
  }

  void applyTemplate(int templateIndex) {
    final locale =
        Get.locale?.toLanguageTag().replaceAll('-', '_') ?? 'zh_CN';

    switch (templateIndex) {
      case 0: // Cash withdrawal
        final cash = accountRepo.getById('1001')!;
        final bank = accountRepo.getById('1002')!;
        summary.value = locale == 'zh_CN'
            ? '从银行提取现金'
            : locale == 'ko_KR'
                ? '은행에서 현금 인출'
                : 'Withdraw cash from bank';
        entries.value = [
          Entry(accountId: cash.id, accountName: cash.getName(locale), isDebit: true, amount: 5000),
          Entry(accountId: bank.id, accountName: bank.getName(locale), isDebit: false, amount: 5000),
        ];
        break;
      case 1: // Purchase materials
        final materials = accountRepo.getById('1403')!;
        final payables = accountRepo.getById('2202')!;
        summary.value = locale == 'zh_CN'
            ? '采购原材料，价款未付'
            : locale == 'ko_KR'
                ? '원자재 외상 구매'
                : 'Purchase raw materials on credit';
        entries.value = [
          Entry(accountId: materials.id, accountName: materials.getName(locale), isDebit: true, amount: 20000),
          Entry(accountId: payables.id, accountName: payables.getName(locale), isDebit: false, amount: 20000),
        ];
        break;
      case 2: // Sales
        final bank = accountRepo.getById('1002')!;
        final revenue = accountRepo.getById('5001')!;
        summary.value = locale == 'zh_CN'
            ? '销售商品，款项存入银行'
            : locale == 'ko_KR'
                ? '상품 판매 후 은행 입금'
                : 'Sell goods, deposit to bank';
        entries.value = [
          Entry(accountId: bank.id, accountName: bank.getName(locale), isDebit: true, amount: 35000),
          Entry(accountId: revenue.id, accountName: revenue.getName(locale), isDebit: false, amount: 35000),
        ];
        break;
      case 3: // Reimbursement
        final admin = accountRepo.getById('5502')!;
        final cash = accountRepo.getById('1001')!;
        summary.value = locale == 'zh_CN'
            ? '报销差旅费'
            : locale == 'ko_KR'
                ? '출장비 정산'
                : 'Reimburse travel expenses';
        entries.value = [
          Entry(accountId: admin.id, accountName: admin.getName(locale), isDebit: true, amount: 1200),
          Entry(accountId: cash.id, accountName: cash.getName(locale), isDebit: false, amount: 1200),
        ];
        break;
    }
    _recalculate();
  }

  KnowledgeCard? getRandomKnowledge() {
    return knowledgeRepo.getRandom();
  }
}

class VoucherListController extends GetxController {
  final VoucherRepository voucherRepo = Get.find<VoucherRepository>();
  final vouchers = <Voucher>[].obs;
  final filterYear = 0.obs;
  final filterMonth = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    filterYear.value = now.year;
    filterMonth.value = now.month;
    loadVouchers();
  }

  void loadVouchers() {
    vouchers.value = voucherRepo.getAll(
      year: filterYear.value,
      month: filterMonth.value,
    );
  }

  void setFilter(int year, int month) {
    filterYear.value = year;
    filterMonth.value = month;
    loadVouchers();
  }

  Future<void> deleteVoucher(String id) async {
    await voucherRepo.delete(id);
    loadVouchers();
  }
}
