/// A guided business scenario the learner solves by building a voucher.
class PracticeScenario {
  final String id;
  final String titleKey;
  final String descriptionKey;
  final String explanationKey;
  final List<ExpectedLine> expected;

  /// Optional fixed amount in yuan that every line should use.
  final double? amountYuan;

  const PracticeScenario({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.explanationKey,
    required this.expected,
    this.amountYuan,
  });
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

  PracticeAttempt({
    required this.scenarioId,
    required this.at,
    required this.lines,
    required this.passed,
    required this.problems,
  });

  Map<String, dynamic> toJson() => {
        'scenarioId': scenarioId,
        'at': at.toIso8601String(),
        'passed': passed,
        'problems': problems,
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
class PracticeGrader {
  /// Returns human-readable problem keys (i18n) — empty means pass.
  static List<String> grade({
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

    final missing = expKeys.difference(actKeys);
    final unexpected = actKeys.difference(expKeys);
    if (missing.isNotEmpty) problems.add('practice_err_missing');
    if (unexpected.isNotEmpty) problems.add('practice_err_wrong_line');

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

    return problems;
  }
}
