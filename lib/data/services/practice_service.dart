import 'dart:math';

import '../models/practice.dart';
import 'database_service.dart';

/// Learning-path chapters (unlock progressively left → right).
const List<PracticeChapter> practiceChapters = [
  PracticeChapter(
    id: 'ch1',
    titleKey: 'chapter_1_title',
    subtitleKey: 'chapter_1_sub',
    knowledgeIds: ['k1', 'k3', 'k11'],
  ),
  PracticeChapter(
    id: 'ch2',
    titleKey: 'chapter_2_title',
    subtitleKey: 'chapter_2_sub',
    knowledgeIds: ['k13', 'k17', 'k21'],
  ),
  PracticeChapter(
    id: 'ch3',
    titleKey: 'chapter_3_title',
    subtitleKey: 'chapter_3_sub',
    knowledgeIds: ['k23', 'k62', 'k63'],
  ),
  PracticeChapter(
    id: 'ch4',
    titleKey: 'chapter_4_title',
    subtitleKey: 'chapter_4_sub',
    knowledgeIds: ['t1', 't2', 'k25'],
  ),
  PracticeChapter(
    id: 'ch5',
    titleKey: 'chapter_5_title',
    subtitleKey: 'chapter_5_sub',
    knowledgeIds: ['k44', 'k15', 'k40'],
  ),
  PracticeChapter(
    id: 'ch6',
    titleKey: 'chapter_6_title',
    subtitleKey: 'chapter_6_sub',
    knowledgeIds: ['k6', 'k54', 'k8'],
  ),
];

/// Scenario id → chapter id (fallback ch1).
const Map<String, String> scenarioChapterMap = {
  'p_cash_withdraw': 'ch1',
  'p_advance': 'ch1',
  'p_sell_material': 'ch1',
  'p_purchase': 'ch2',
  'p_prepay': 'ch2',
  'p_sales': 'ch2',
  'p_notes_receivable': 'ch2',
  'p_bad_debt': 'ch2',
  'p_writeoff': 'ch2',
  'p_reimburse': 'ch3',
  'p_wages': 'ch3',
  'p_ad_expense': 'ch3',
  'p_depreciation': 'ch3',
  'p_close_expense': 'ch3',
  'p_tax_pay': 'ch4',
  'p_short_loan': 'ch4',
  'p_interest': 'ch4',
  'p_fa_buy': 'ch5',
  'p_intangible': 'ch5',
  'p_invest': 'ch5',
  'p_cogs': 'ch6',
  'p_close_revenue': 'ch6',
};

/// Chapter assignment for a scenario id (pure helper, safe in tests).
String chapterIdOf(String scenarioId) =>
    scenarioChapterMap[scenarioId] ?? 'ch1';

/// Unlock rule (pure): first chapter open; later chapters need every
/// scenario of the previous chapter present in [passedIds].
bool isChapterUnlockedPure(String chapterId, Set<String> passedIds) {
  final idx = practiceChapters.indexWhere((c) => c.id == chapterId);
  if (idx <= 0) return true;
  final prev = practiceChapters[idx - 1];
  final prevIds = presetScenarios
      .where((s) => chapterIdOf(s.id) == prev.id)
      .map((s) => s.id)
      .toSet();
  if (prevIds.isEmpty) return true;
  return prevIds.every(passedIds.contains);
}

/// Mastery stars (pure): 0 not passed, 1 later pass, 2 within 2 tries, 3 first try.
int scoreStars({
  required int attempts,
  required int passes,
  required bool firstTry,
}) {
  if (passes <= 0) return 0;
  if (firstTry && attempts == 1) return 3;
  if (attempts <= 2) return 2;
  return 1;
}

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
  // ===== 0.4.0 — expanded drill bank (tax, credit, financing, closing) =====
  PracticeScenario(
    id: 'p_bad_debt',
    titleKey: 'practice_s11_title',
    descriptionKey: 'practice_s11_desc',
    explanationKey: 'practice_s11_exp',
    amountYuan: 2000,
    expected: const [
      ExpectedLine(accountId: '5601', isDebit: true),
      ExpectedLine(accountId: '1231', isDebit: false),
    ],
  ),
  PracticeScenario(
    id: 'p_writeoff',
    titleKey: 'practice_s12_title',
    descriptionKey: 'practice_s12_desc',
    explanationKey: 'practice_s12_exp',
    amountYuan: 3000,
    expected: const [
      ExpectedLine(accountId: '1231', isDebit: true),
      ExpectedLine(accountId: '1122', isDebit: false),
    ],
  ),
  PracticeScenario(
    id: 'p_prepay',
    titleKey: 'practice_s13_title',
    descriptionKey: 'practice_s13_desc',
    explanationKey: 'practice_s13_exp',
    amountYuan: 15000,
    expected: const [
      ExpectedLine(accountId: '1123', isDebit: true),
      ExpectedLine(accountId: '1002', isDebit: false),
    ],
  ),
  PracticeScenario(
    id: 'p_advance',
    titleKey: 'practice_s14_title',
    descriptionKey: 'practice_s14_desc',
    explanationKey: 'practice_s14_exp',
    amountYuan: 12000,
    expected: const [
      ExpectedLine(accountId: '1002', isDebit: true),
      ExpectedLine(accountId: '2203', isDebit: false),
    ],
  ),
  PracticeScenario(
    id: 'p_short_loan',
    titleKey: 'practice_s15_title',
    descriptionKey: 'practice_s15_desc',
    explanationKey: 'practice_s15_exp',
    amountYuan: 80000,
    expected: const [
      ExpectedLine(accountId: '1002', isDebit: true),
      ExpectedLine(accountId: '2001', isDebit: false),
    ],
  ),
  PracticeScenario(
    id: 'p_interest',
    titleKey: 'practice_s16_title',
    descriptionKey: 'practice_s16_desc',
    explanationKey: 'practice_s16_exp',
    amountYuan: 1500,
    expected: const [
      ExpectedLine(accountId: '5503', isDebit: true),
      ExpectedLine(accountId: '2231', isDebit: false),
    ],
  ),
  PracticeScenario(
    id: 'p_tax_pay',
    titleKey: 'practice_s17_title',
    descriptionKey: 'practice_s17_desc',
    explanationKey: 'practice_s17_exp',
    amountYuan: 5600,
    expected: const [
      ExpectedLine(accountId: '2221', isDebit: true),
      ExpectedLine(accountId: '1002', isDebit: false),
    ],
  ),
  PracticeScenario(
    id: 'p_sell_material',
    titleKey: 'practice_s18_title',
    descriptionKey: 'practice_s18_desc',
    explanationKey: 'practice_s18_exp',
    amountYuan: 4000,
    expected: const [
      ExpectedLine(accountId: '1002', isDebit: true),
      ExpectedLine(accountId: '5051', isDebit: false),
    ],
  ),
  PracticeScenario(
    id: 'p_fa_buy',
    titleKey: 'practice_s19_title',
    descriptionKey: 'practice_s19_desc',
    explanationKey: 'practice_s19_exp',
    amountYuan: 50000,
    expected: const [
      ExpectedLine(accountId: '1601', isDebit: true),
      ExpectedLine(accountId: '1002', isDebit: false),
    ],
  ),
  PracticeScenario(
    id: 'p_close_expense',
    titleKey: 'practice_s20_title',
    descriptionKey: 'practice_s20_desc',
    explanationKey: 'practice_s20_exp',
    amountYuan: 9000,
    expected: const [
      ExpectedLine(accountId: '3103', isDebit: true),
      ExpectedLine(accountId: '5502', isDebit: false),
    ],
  ),
  PracticeScenario(
    id: 'p_intangible',
    titleKey: 'practice_s21_title',
    descriptionKey: 'practice_s21_desc',
    explanationKey: 'practice_s21_exp',
    amountYuan: 30000,
    expected: const [
      ExpectedLine(accountId: '1701', isDebit: true),
      ExpectedLine(accountId: '1002', isDebit: false),
    ],
  ),
  PracticeScenario(
    id: 'p_notes_receivable',
    titleKey: 'practice_s22_title',
    descriptionKey: 'practice_s22_desc',
    explanationKey: 'practice_s22_exp',
    amountYuan: 20000,
    expected: const [
      ExpectedLine(accountId: '1121', isDebit: true),
      ExpectedLine(accountId: '5001', isDebit: false),
    ],
  ),
];

/// Persists practice attempts and the wrong-answer book.
class PracticeService {
  static const _attemptsKey = 'practice_attempts';
  static const _passedKey = 'practice_passed';

  final DatabaseService _db;

  PracticeService([DatabaseService? db]) : _db = db ?? DatabaseService();

  List<PracticeScenario> get scenarios => presetScenarios;

  /// Chapter assignment for a scenario id.
  String chapterIdOfScenario(String scenarioId) => chapterIdOf(scenarioId);

  PracticeChapter? chapterById(String id) {
    try {
      return practiceChapters.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  List<PracticeScenario> scenariosOfChapter(String chapterId) =>
      scenarios.where((s) => chapterIdOf(s.id) == chapterId).toList();

  /// True when the chapter is unlocked (first always open; later ones need
  /// every scenario of the previous chapter passed at least once).
  bool isChapterUnlocked(String chapterId) =>
      isChapterUnlockedPure(chapterId, getPassedIds().toSet());

  /// Derived mastery for one scenario.
  ScenarioMastery masteryOf(String scenarioId) {
    final all = getAttempts().where((a) => a.scenarioId == scenarioId);
    final attempts = all.length;
    final passes = all.where((a) => a.passed).length;
    final firstTry = all.isNotEmpty && all.first.passed;
    return ScenarioMastery(
      scenarioId: scenarioId,
      attempts: attempts,
      passes: passes,
      firstTry: firstTry,
      stars: scoreStars(attempts: attempts, passes: passes, firstTry: firstTry),
    );
  }

  /// Chapter completion ratio in \[0, 1\].
  double chapterProgress(String chapterId) {
    final list = scenariosOfChapter(chapterId);
    if (list.isEmpty) return 0;
    final passed = getPassedIds().toSet();
    final done = list.where((s) => passed.contains(s.id)).length;
    return done / list.length;
  }

  /// Best next drill: first unpassed scenario in the first unlocked chapter
  /// that still has unpassed items. Falls back to lowest-mastery retry.
  PracticeScenario? nextRecommended() {
    for (final ch in practiceChapters) {
      if (!isChapterUnlocked(ch.id)) continue;
      for (final s in scenariosOfChapter(ch.id)) {
        if (!isPassed(s.id)) return s;
      }
    }
    // All passed — pick lowest stars for review.
    PracticeScenario? best;
    var bestStars = 4;
    for (final s in scenarios) {
      final stars = masteryOf(s.id).stars;
      if (stars < bestStars) {
        bestStars = stars;
        best = s;
      }
    }
    return best ?? (scenarios.isEmpty ? null : scenarios.first);
  }

  /// Pick up to [count] weak scenarios for a quiz session:
  /// failed / unpassed first, then low-star, then random unseen.
  List<PracticeScenario> pickQuiz({int count = 5, Random? random}) {
    final rng = random ?? Random();
    final weak = <PracticeScenario>[];
    final mid = <PracticeScenario>[];
    final ok = <PracticeScenario>[];

    for (final s in scenarios) {
      if (!isChapterUnlocked(chapterIdOf(s.id))) continue;
      final m = masteryOf(s.id);
      if (!m.passed) {
        weak.add(s);
      } else if (m.stars <= 1) {
        mid.add(s);
      } else {
        ok.add(s);
      }
    }

    weak.shuffle(rng);
    mid.shuffle(rng);
    ok.shuffle(rng);
    final pool = [...weak, ...mid, ...ok];
    return pool.take(count).toList();
  }

  PracticeScenario? byId(String id) {
    try {
      return presetScenarios.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  List<PracticeAttempt> getAttempts() {
    final data = _db.readKv<List>(_attemptsKey);
    if (data == null) return [];
    return data
        .map((e) => PracticeAttempt.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  List<PracticeAttempt> getWrongAttempts() =>
      getAttempts().where((a) => !a.passed).toList().reversed.toList();

  List<String> getPassedIds() {
    final data = _db.readKv<List>(_passedKey);
    return data == null ? [] : data.cast<String>();
  }

  bool isPassed(String scenarioId) => getPassedIds().contains(scenarioId);

  int get passedCount => getPassedIds().length;

  /// Grade and persist an attempt. Returns the attempt.
  Future<PracticeAttempt> submit({
    required PracticeScenario scenario,
    required List<PracticeAttemptLine> lines,
  }) async {
    final result = PracticeGrader.grade(
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
      passed: result.passed,
      problems: result.problems,
      missingAccountIds: result.missingAccountIds,
      unexpectedAccountIds: result.unexpectedAccountIds,
    );

    final attempts = getAttempts();
    attempts.add(attempt);
    await _db.writeKv(
        _attemptsKey, attempts.map((a) => a.toJson()).toList());

    if (attempt.passed) {
      final passed = getPassedIds();
      if (!passed.contains(scenario.id)) {
        passed.add(scenario.id);
        await _db.writeKv(_passedKey, passed);
      }
    }
    return attempt;
  }

  /// Restore practice state from a backup payload.
  Future<void> restore({
    required List<PracticeAttempt> attempts,
    required List<String> passedIds,
  }) async {
    await _db.writeKv(_attemptsKey, attempts.map((a) => a.toJson()).toList());
    await _db.writeKv(_passedKey, passedIds);
  }

  Future<void> clearWrongBook() async {
    final attempts = getAttempts().where((a) => a.passed).toList();
    await _db.writeKv(
        _attemptsKey, attempts.map((a) => a.toJson()).toList());
  }

  Future<void> resetAll() async {
    await _db.writeKv(_attemptsKey, <Map<String, dynamic>>[]);
    await _db.writeKv(_passedKey, <String>[]);
  }
}
