import 'package:get/get.dart';
import '../../../data/models/account.dart';
import '../../../data/models/entry.dart';
import '../../../data/models/practice.dart';
import '../../../data/services/practice_service.dart';
import '../../../data/repositories/account_repository.dart';

class PracticeController extends GetxController {
  final PracticeService service = Get.find<PracticeService>();
  final AccountRepository accountRepo = Get.find<AccountRepository>();

  final scenarios = <PracticeScenario>[].obs;
  final passedIds = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    Future.microtask(reload);
  }

  void reload() {
    scenarios.value = service.scenarios;
    passedIds.value = service.getPassedIds();
  }

  double get progress =>
      scenarios.isEmpty ? 0 : passedIds.length / scenarios.length;
}

class PracticeDetailController extends GetxController {
  final PracticeService service = Get.find<PracticeService>();
  final AccountRepository accountRepo = Get.find<AccountRepository>();

  late PracticeScenario scenario;
  final entries = <Entry>[].obs;
  final result = Rxn<PracticeAttempt>();
  final showExplanation = false.obs;

  String locale = 'zh_CN';

  @override
  void onInit() {
    super.onInit();
    final id = Get.parameters['id'] ?? '';
    scenario = service.byId(id) ?? service.scenarios.first;
    locale = Get.locale?.toLanguageTag().replaceAll('-', '_') ?? 'zh_CN';
    // Start with two blank lines (like voucher form)
    entries.value = [
      Entry(accountId: '', accountName: '', isDebit: true, amountCents: 0),
      Entry(accountId: '', accountName: '', isDebit: false, amountCents: 0),
    ];
  }

  void addEntry() {
    entries.add(
        Entry(accountId: '', accountName: '', isDebit: true, amountCents: 0));
  }

  void removeEntry(int index) {
    if (entries.length > 2) {
      entries.removeAt(index);
    }
  }

  void setAccount(int index, Account account) {
    final old = entries[index];
    entries[index] = Entry(
      accountId: account.id,
      accountName: account.getName(locale),
      isDebit: old.isDebit,
      amountCents: old.amountCents,
    );
  }

  void setDirection(int index, bool isDebit) {
    final old = entries[index];
    entries[index] = Entry(
      accountId: old.accountId,
      accountName: old.accountName,
      isDebit: isDebit,
      amountCents: old.amountCents,
    );
  }

  void setAmountYuan(int index, double yuan) {
    final old = entries[index];
    entries[index] = Entry(
      accountId: old.accountId,
      accountName: old.accountName,
      isDebit: old.isDebit,
      amountCents: (yuan * 100).round(),
    );
  }

  /// Fill suggested amount (from scenario) into all filled lines.
  void applySuggestedAmount() {
    final yuan = scenario.amountYuan ?? 0;
    for (var i = 0; i < entries.length; i++) {
      if (entries[i].accountId.isNotEmpty) {
        setAmountYuan(i, yuan);
      }
    }
  }

  Future<PracticeAttempt> submit() async {
    final lines = entries
        .where((e) => e.accountId.isNotEmpty)
        .map((e) => PracticeAttemptLine(
              accountId: e.accountId,
              isDebit: e.isDebit,
              amountCents: e.amountCents,
            ))
        .toList();
    final attempt =
        await service.submit(scenario: scenario, lines: lines);
    result.value = attempt;
    showExplanation.value = true;
    return attempt;
  }
}

class WrongBookController extends GetxController {
  final PracticeService service = Get.find<PracticeService>();
  final items = <PracticeAttempt>[].obs;

  @override
  void onInit() {
    super.onInit();
    Future.microtask(reload);
  }

  void reload() {
    items.value = service.getWrongAttempts();
  }

  Future<void> clear() async {
    await service.clearWrongBook();
    reload();
  }
}
