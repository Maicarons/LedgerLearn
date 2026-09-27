import 'package:get/get.dart';
import '../../../data/models/account.dart';
import '../../../data/models/entry.dart';
import '../../../data/models/practice.dart';
import '../../../data/services/practice_service.dart';
import '../../../data/repositories/account_repository.dart';

/// A timed quiz session: N weak scenarios in sequence, then a summary.
class QuizController extends GetxController {
  final PracticeService service = Get.find<PracticeService>();
  final AccountRepository accountRepo = Get.find<AccountRepository>();

  final queue = <PracticeScenario>[].obs;
  final index = 0.obs;
  final results = <PracticeAttempt>[].obs;
  final entries = <Entry>[].obs;
  final finished = false.obs;
  final showExplanation = false.obs;
  final currentResult = Rxn<PracticeAttempt>();

  String locale = 'zh_CN';

  PracticeScenario? get current =>
      index.value < queue.length ? queue[index.value] : null;

  int get total => queue.length;

  bool get hasNext => index.value + 1 < queue.length;

  @override
  void onInit() {
    super.onInit();
    locale = Get.locale?.toLanguageTag().replaceAll('-', '_') ?? 'zh_CN';
    // Accept ids from route parameters (`/practice/quiz?ids=a,b`) or
    // from Get.to(arguments: <String>[...]).
    final rawParam = Get.parameters['ids'];
    final rawArgs = Get.arguments;
    List<String> ids = [];
    if (rawArgs is List) {
      ids = rawArgs.whereType<String>().toList();
    } else if (rawArgs is String && rawArgs.isNotEmpty) {
      ids = rawArgs.split(',');
    } else if (rawParam != null && rawParam.isNotEmpty) {
      ids = rawParam.split(',');
    }
    if (ids.isNotEmpty) {
      queue.value = ids
          .map((id) => service.byId(id))
          .whereType<PracticeScenario>()
          .toList();
    }
    if (queue.isEmpty) {
      queue.value = service.pickQuiz();
    }
    _resetEntries();
  }

  void _resetEntries() {
    entries.value = [
      Entry(accountId: '', accountName: '', isDebit: true, amountCents: 0),
      Entry(accountId: '', accountName: '', isDebit: false, amountCents: 0),
    ];
    currentResult.value = null;
    showExplanation.value = false;
  }

  void addEntry() {
    entries.add(
        Entry(accountId: '', accountName: '', isDebit: true, amountCents: 0));
  }

  void removeEntry(int index) {
    if (entries.length > 2) entries.removeAt(index);
  }

  void setAccount(int i, Account account) {
    final old = entries[i];
    entries[i] = Entry(
      accountId: account.id,
      accountName: account.getName(locale),
      isDebit: old.isDebit,
      amountCents: old.amountCents,
    );
  }

  void setDirection(int i, bool isDebit) {
    final old = entries[i];
    entries[i] = Entry(
      accountId: old.accountId,
      accountName: old.accountName,
      isDebit: isDebit,
      amountCents: old.amountCents,
    );
  }

  void setAmountYuan(int i, double yuan) {
    final old = entries[i];
    entries[i] = Entry(
      accountId: old.accountId,
      accountName: old.accountName,
      isDebit: old.isDebit,
      amountCents: (yuan * 100).round(),
    );
  }

  void applySuggestedAmount() {
    final yuan = current?.amountYuan ?? 0;
    for (var i = 0; i < entries.length; i++) {
      if (entries[i].accountId.isNotEmpty) setAmountYuan(i, yuan);
    }
  }

  Future<PracticeAttempt?> submitCurrent() async {
    final s = current;
    if (s == null) return null;
    final lines = entries
        .where((e) => e.accountId.isNotEmpty)
        .map((e) => PracticeAttemptLine(
              accountId: e.accountId,
              isDebit: e.isDebit,
              amountCents: e.amountCents,
            ))
        .toList();
    final attempt = await service.submit(scenario: s, lines: lines);
    results.add(attempt);
    currentResult.value = attempt;
    showExplanation.value = true;
    return attempt;
  }

  void next() {
    if (!hasNext) {
      finished.value = true;
      return;
    }
    index.value++;
    _resetEntries();
    update();
  }

  int get passCount => results.where((r) => r.passed).length;

  void restart() {
    queue.value = service.pickQuiz();
    index.value = 0;
    results.clear();
    finished.value = false;
    _resetEntries();
    update();
  }
}
