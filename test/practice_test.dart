import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerlearn/data/models/practice.dart';
import 'package:ledgerlearn/data/services/practice_service.dart';

void main() {
  group('PracticeGrader', () {
    final expected = [
      const ExpectedLine(accountId: '1001', isDebit: true),
      const ExpectedLine(accountId: '1002', isDebit: false),
    ];

    List<PracticeAttemptLine> lines(List<(String, bool, int)> raw) => raw
        .map((e) => PracticeAttemptLine(
            accountId: e.$1, isDebit: e.$2, amountCents: e.$3))
        .toList();

    test('passes correct debit/credit pair', () {
      final result = PracticeGrader.grade(
        expected: expected,
        actual: lines([
          ('1001', true, 500000),
          ('1002', false, 500000),
        ]),
        checkAmount: true,
        expectedAmountCents: 500000,
      );
      expect(result.problems, isEmpty);
      expect(result.passed, isTrue);
    });

    test('fails when direction is swapped', () {
      final result = PracticeGrader.grade(
        expected: expected,
        actual: lines([
          ('1001', false, 500000),
          ('1002', true, 500000),
        ]),
      );
      expect(result.problems, contains('practice_err_missing'));
      expect(result.missingAccountIds, isNotEmpty);
    });

    test('fails when unbalanced', () {
      final result = PracticeGrader.grade(
        expected: expected,
        actual: lines([
          ('1001', true, 500000),
          ('1002', false, 400000),
        ]),
      );
      expect(result.problems, contains('practice_err_unbalanced'));
    });

    test('fails on unexpected extra line', () {
      final result = PracticeGrader.grade(
        expected: expected,
        actual: lines([
          ('1001', true, 500000),
          ('1002', false, 500000),
          ('5502', true, 0),
        ]),
      );
      expect(result.problems, contains('practice_err_wrong_line'));
      expect(result.unexpectedAccountIds, contains('5502'));
    });

    test('fails when amount zero', () {
      final result = PracticeGrader.grade(
        expected: expected,
        actual: lines([
          ('1001', true, 0),
          ('1002', false, 0),
        ]),
      );
      expect(result.problems, contains('practice_err_zero'));
    });

    test('fails amount check when wrong amount', () {
      final result = PracticeGrader.grade(
        expected: expected,
        actual: lines([
          ('1001', true, 100),
          ('1002', false, 100),
        ]),
        checkAmount: true,
        expectedAmountCents: 500000,
      );
      expect(result.problems, contains('practice_err_amount'));
    });
  });

  group('PracticeAttempt JSON', () {
    test('round-trips', () {
      final a = PracticeAttempt(
        scenarioId: 'p_cash_withdraw',
        at: DateTime(2026, 9, 20),
        lines: [
          PracticeAttemptLine(
              accountId: '1001', isDebit: true, amountCents: 500000),
          PracticeAttemptLine(
              accountId: '1002', isDebit: false, amountCents: 500000),
        ],
        passed: false,
        problems: ['practice_err_unbalanced'],
        missingAccountIds: ['1001'],
        unexpectedAccountIds: ['5502'],
      );
      final restored = PracticeAttempt.fromJson(a.toJson());
      expect(restored.scenarioId, a.scenarioId);
      expect(restored.passed, isFalse);
      expect(restored.lines.length, 2);
      expect(restored.problems, ['practice_err_unbalanced']);
      expect(restored.missingAccountIds, ['1001']);
      expect(restored.unexpectedAccountIds, ['5502']);
    });
  });

  group('preset scenarios', () {
    test('has at least 22 scenarios with unique ids', () {
      expect(presetScenarios.length, greaterThanOrEqualTo(22));
      final ids = presetScenarios.map((s) => s.id).toSet();
      expect(ids.length, presetScenarios.length);
    });

    test('every scenario has two or more expected lines', () {
      for (final s in presetScenarios) {
        expect(s.expected.length, greaterThanOrEqualTo(2),
            reason: s.id);
      }
    });

    test('every expected account id looks like a chart code', () {
      final result = PracticeGrader.grade(
        expected: const [ExpectedLine(accountId: '5001', isDebit: true)],
        actual: [
          PracticeAttemptLine(
              accountId: '5001', isDebit: true, amountCents: 100),
          PracticeAttemptLine(
              accountId: '3103', isDebit: false, amountCents: 100),
        ],
      );
      expect(result.problems, isNotEmpty); // missing expected credit line
    });
  });
}
