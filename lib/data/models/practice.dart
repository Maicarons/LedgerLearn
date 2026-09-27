/// A guided business scenario the learner solves by building a voucher.
class PracticeScenario {
  final String id;
  final String titleKey;
  final String descriptionKey;
  final String explanationKey;
  final List<ExpectedLine> expected;

  /// Optional fixed amount in yuan that every line should use.
  final double? amountYuan;

  /// Chapter id used by the learning path (see [PracticeChapter]).
  final String chapterId;

  const PracticeScenario({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.explanationKey,
    required this.expected,
    this.amountYuan,
    this.chapterId = 'ch1',
  });
}

/// A themed chapter of the learning path. Scenarios unlock progressively.
class PracticeChapter {
  final String id;
  final String titleKey;
  final String subtitleKey;

  /// Optional knowledge card ids to read before / while drilling.
  final List<String> knowledgeIds;

  /// Scenarios are declared on [PracticeScenario.chapterId].
  const PracticeChapter({
    required this.id,
    required this.titleKey,
    required this.subtitleKey,
    this.knowledgeIds = const [],
  });
}

/// Derived mastery for one scenario (computed from persisted attempts).
class ScenarioMastery {
  final String scenarioId;
  final int attempts;
  final int passes;
  final bool firstTry;

  /// 0 = not passed, 1 = passed, 2 = passed within 2 tries, 3 = first try.
  final int stars;

  ScenarioMastery({
    required this.scenarioId,
    required this.attempts,
    required this.passes,
    required this.firstTry,
    required this.stars,
  });

  bool get passed => passes > 0;
}

class ExpectedLine {
  final String accountId;
  final bool isDebit;
  const ExpectedLine({required this.accountId, required this.isDebit});
}

/// One submitted attempt, used for grading and the wrong-answer book.
class PracticeAttempt {
  final String scenarioId;
  final DateTime at;
  final List<PracticeAttemptLine> lines;
  final bool passed;
  final List<String> problems;

  /// Account ids the learner omitted from the expected entry.
  final List<String> missingAccountIds;

  /// Account ids the learner added that are not in the expected entry.
  final List<String> unexpectedAccountIds;

  PracticeAttempt({
    required this.scenarioId,
    required this.at,
    required this.lines,
    required this.passed,
    required this.problems,
    this.missingAccountIds = const [],
    this.unexpectedAccountIds = const [],
  });

  Map<String, dynamic> toJson() => {
        'scenarioId': scenarioId,
        'at': at.toIso8601String(),
        'passed': passed,
        'problems': problems,
        'missingAccountIds': missingAccountIds,
        'unexpectedAccountIds': unexpectedAccountIds,
        'lines': lines
            .map((l) => {
                  'accountId': l.accountId,
                  'isDebit': l.isDebit,
                  'amountCents': l.amountCents,
                })
            .toList(),
      };

  factory PracticeAttempt.fromJson(Map<String, dynamic> json) =>
      PracticeAttempt(
        scenarioId: json['scenarioId'],
        at: DateTime.parse(json['at']),
        passed: json['passed'] ?? false,
        problems: (json['problems'] as List? ?? []).cast<String>(),
        missingAccountIds:
            (json['missingAccountIds'] as List? ?? []).cast<String>(),
        unexpectedAccountIds:
            (json['unexpectedAccountIds'] as List? ?? []).cast<String>(),
        lines: (json['lines'] as List? ?? [])
            .map((e) => PracticeAttemptLine(
                  accountId: e['accountId'],
                  isDebit: e['isDebit'],
                  amountCents: e['amountCents'] ?? 0,
                ))
            .toList(),
      );
}

class PracticeAttemptLine {
  final String accountId;
  final bool isDebit;
  final int amountCents;
  PracticeAttemptLine({
    required this.accountId,
    required this.isDebit,
    required this.amountCents,
  });
}

/// Pure grader — compares learner lines against expected account+direction sets.
class PracticeGraderResult {
  final List<String> problems;
  final List<String> missingAccountIds;
  final List<String> unexpectedAccountIds;
  PracticeGraderResult({
    required this.problems,
    required this.missingAccountIds,
    required this.unexpectedAccountIds,
  });
  bool get passed => problems.isEmpty;
}

class PracticeGrader {
  /// Returns human-readable problem keys (i18n) + account attribution.
  static PracticeGraderResult grade({
    required List<ExpectedLine> expected,
    required List<PracticeAttemptLine> actual,
    bool checkAmount = false,
    int? expectedAmountCents,
  }) {
    final problems = <String>[];

    final expKeys = expected
        .map((e) => '${e.accountId}|${e.isDebit ? 'D' : 'C'}')
        .toSet();
    final actKeys = actual
        .map((e) => '${e.accountId}|${e.isDebit ? 'D' : 'C'}')
        .toSet();

    if (actual.length < 2) {
      problems.add('practice_err_min_lines');
    }

    final missingKeys = expKeys.difference(actKeys);
    final unexpectedKeys = actKeys.difference(expKeys);
    if (missingKeys.isNotEmpty) problems.add('practice_err_missing');
    if (unexpectedKeys.isNotEmpty) problems.add('practice_err_wrong_line');

    final missingAccountIds = missingKeys
        .map((k) => k.split('|')[0])
        .toSet()
        .toList()
      ..sort();
    final unexpectedAccountIds = unexpectedKeys
        .map((k) => k.split('|')[0])
        .toSet()
        .toList()
      ..sort();

    // Balance check in cents
    final d = actual
        .where((e) => e.isDebit)
        .fold(0, (s, e) => s + e.amountCents);
    final c = actual
        .where((e) => !e.isDebit)
        .fold(0, (s, e) => s + e.amountCents);
    if (d != c) problems.add('practice_err_unbalanced');
    if (d == 0) problems.add('practice_err_zero');

    if (checkAmount && expectedAmountCents != null) {
      final ok = actual.every((e) =>
          e.amountCents == expectedAmountCents || e.amountCents == 0);
      if (!ok && problems.isEmpty) problems.add('practice_err_amount');
    }

    return PracticeGraderResult(
      problems: problems,
      missingAccountIds: missingAccountIds,
      unexpectedAccountIds: unexpectedAccountIds,
    );
  }

  /// Backwards-compatible wrapper returning only the problem keys.
  static List<String> gradeProblems({
    required List<ExpectedLine> expected,
    required List<PracticeAttemptLine> actual,
    bool checkAmount = false,
    int? expectedAmountCents,
  }) =>
      grade(
        expected: expected,
        actual: actual,
        checkAmount: checkAmount,
        expectedAmountCents: expectedAmountCents,
      ).problems;
}
