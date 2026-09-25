import 'package:get_storage/get_storage.dart';
import '../models/practice.dart';

/// Built-in practice scenarios (keys resolved via i18n).
List<PracticeScenario> presetScenarios = [
  PracticeScenario(
    id: 'p_cash_withdraw',
    titleKey: 'practice_s1_title',
    descriptionKey: 'practice_s1_desc',
    explanationKey: 'practice_s1_exp',
    amountYuan: 5000,
    expected: const [
      ExpectedLine(accountId: '1001', isDebit: true),
      ExpectedLine(accountId: '1002', isDebit: false),
    ],
  ),
  PracticeScenario(
    id: 'p_purchase',
    titleKey: 'practice_s2_title',
    descriptionKey: 'practice_s2_desc',
    explanationKey: 'practice_s2_exp',
    amountYuan: 20000,
    expected: const [
      ExpectedLine(accountId: '1403', isDebit: true),
      ExpectedLine(accountId: '2202', isDebit: false),
    ],
  ),
  PracticeScenario(
    id: 'p_sales',
    titleKey: 'practice_s3_title',
    descriptionKey: 'practice_s3_desc',
    explanationKey: 'practice_s3_exp',
    amountYuan: 35000,
    expected: const [
      ExpectedLine(accountId: '1002', isDebit: true),
      ExpectedLine(accountId: '5001', isDebit: false),
    ],
  ),
  PracticeScenario(
    id: 'p_reimburse',
    titleKey: 'practice_s4_title',
    descriptionKey: 'practice_s4_desc',
    explanationKey: 'practice_s4_exp',
    amountYuan: 1200,
    expected: const [
      ExpectedLine(accountId: '5502', isDebit: true),
      ExpectedLine(accountId: '1001', isDebit: false),
    ],
  ),
  PracticeScenario(
    id: 'p_depreciation',
    titleKey: 'practice_s5_title',
    descriptionKey: 'practice_s5_desc',
    explanationKey: 'practice_s5_exp',
    amountYuan: 3000,
    expected: const [
      ExpectedLine(accountId: '5502', isDebit: true),
      ExpectedLine(accountId: '1602', isDebit: false),
    ],
  ),
  PracticeScenario(
    id: 'p_wages',
    titleKey: 'practice_s6_title',
    descriptionKey: 'practice_s6_desc',
    explanationKey: 'practice_s6_exp',
    amountYuan: 50000,
    expected: const [
      ExpectedLine(accountId: '2211', isDebit: true),
      ExpectedLine(accountId: '1002', isDebit: false),
    ],
  ),
  PracticeScenario(
    id: 'p_cogs',
    titleKey: 'practice_s7_title',
    descriptionKey: 'practice_s7_desc',
    explanationKey: 'practice_s7_exp',
    amountYuan: 25000,
    expected: const [
      ExpectedLine(accountId: '5401', isDebit: true),
      ExpectedLine(accountId: '1405', isDebit: false),
    ],
  ),
  PracticeScenario(
    id: 'p_close_revenue',
    titleKey: 'practice_s8_title',
    descriptionKey: 'practice_s8_desc',
    explanationKey: 'practice_s8_exp',
    amountYuan: 35000,
    expected: const [
      ExpectedLine(accountId: '5001', isDebit: true),
      ExpectedLine(accountId: '3103', isDebit: false),
    ],
  ),
  PracticeScenario(
    id: 'p_ad_expense',
    titleKey: 'practice_s9_title',
    descriptionKey: 'practice_s9_desc',
    explanationKey: 'practice_s9_exp',
    amountYuan: 8000,
    expected: const [
      ExpectedLine(accountId: '5501', isDebit: true),
      ExpectedLine(accountId: '1002', isDebit: false),
    ],
  ),
  PracticeScenario(
    id: 'p_invest',
    titleKey: 'practice_s10_title',
    descriptionKey: 'practice_s10_desc',
    explanationKey: 'practice_s10_exp',
    amountYuan: 100000,
    expected: const [
      ExpectedLine(accountId: '1002', isDebit: true),
      ExpectedLine(accountId: '3001', isDebit: false),
    ],
  ),
];

/// Persists practice attempts and the wrong-answer book.
class PracticeService {
  static const _attemptsKey = 'practice_attempts';
  static const _passedKey = 'practice_passed';
  final GetStorage _box = GetStorage();

  List<PracticeScenario> get scenarios => presetScenarios;

  PracticeScenario? byId(String id) {
    try {
      return presetScenarios.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  List<PracticeAttempt> getAttempts() {
    final data = _box.read<List>(_attemptsKey);
    if (data == null) return [];
    return data
        .map((e) => PracticeAttempt.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  List<PracticeAttempt> getWrongAttempts() =>
      getAttempts().where((a) => !a.passed).toList().reversed.toList();

  List<String> getPassedIds() {
    final data = _box.read<List>(_passedKey);
    return data == null ? [] : data.cast<String>();
  }

  bool isPassed(String scenarioId) => getPassedIds().contains(scenarioId);

  int get passedCount => getPassedIds().length;

  /// Grade and persist an attempt. Returns the attempt.
  Future<PracticeAttempt> submit({
    required PracticeScenario scenario,
    required List<PracticeAttemptLine> lines,
  }) async {
    final problems = PracticeGrader.grade(
      expected: scenario.expected,
      actual: lines,
      checkAmount: scenario.amountYuan != null,
      expectedAmountCents: scenario.amountYuan == null
          ? null
          : (scenario.amountYuan! * 100).round(),
    );
    final attempt = PracticeAttempt(
      scenarioId: scenario.id,
      at: DateTime.now(),
      lines: lines,
      passed: problems.isEmpty,
      problems: problems,
    );

    final attempts = getAttempts();
    attempts.add(attempt);
    await _box.write(_attemptsKey, attempts.map((a) => a.toJson()).toList());

    if (attempt.passed) {
      final passed = getPassedIds();
      if (!passed.contains(scenario.id)) {
        passed.add(scenario.id);
        await _box.write(_passedKey, passed);
      }
    }
    return attempt;
  }

  Future<void> clearWrongBook() async {
    final attempts = getAttempts().where((a) => a.passed).toList();
    await _box.write(_attemptsKey, attempts.map((a) => a.toJson()).toList());
  }

  Future<void> resetAll() async {
    await _box.write(_attemptsKey, <Map<String, dynamic>>[]);
    await _box.write(_passedKey, <String>[]);
  }
}
