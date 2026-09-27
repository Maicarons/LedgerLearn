import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerlearn/data/models/practice.dart';
import 'package:ledgerlearn/data/services/practice_service.dart';

void main() {
  group('practice chapters', () {
    test('has 6 chapters covering all 22 scenarios', () {
      expect(practiceChapters.length, 6);
      for (final s in presetScenarios) {
        final ch = chapterIdOf(s.id);
        expect(
          practiceChapters.any((c) => c.id == ch),
          isTrue,
          reason: 'scenario ${s.id} → $ch',
        );
      }
    });

    test('every scenario is assigned to exactly one chapter', () {
      for (final s in presetScenarios) {
        final ch = chapterIdOf(s.id);
        expect(ch, isNotEmpty);
        expect(
          practiceChapters.where((c) => c.id == ch).length,
          1,
          reason: s.id,
        );
      }
    });

    test('chapter ids are unique', () {
      final ids = practiceChapters.map((c) => c.id).toSet();
      expect(ids.length, practiceChapters.length);
    });

    test('each chapter has at least 2 scenarios', () {
      for (final ch in practiceChapters) {
        final n = presetScenarios.where((s) => chapterIdOf(s.id) == ch.id).length;
        expect(n, greaterThanOrEqualTo(2), reason: ch.id);
      }
    });

    test('unlock rule: first chapter open, later ones need previous passed', () {
      // Pure rule: chapter index 0 is always unlocked.
      expect(isChapterUnlockedPure('ch1', const {}), isTrue);
      // ch2 needs all ch1 scenario ids passed.
      final ch1Ids = presetScenarios
          .where((s) => chapterIdOf(s.id) == 'ch1')
          .map((s) => s.id)
          .toSet();
      expect(isChapterUnlockedPure('ch2', const {}), isFalse);
      expect(isChapterUnlockedPure('ch2', ch1Ids), isTrue);
    });

    test('mastery stars scoring rule', () {
      expect(scoreStars(attempts: 1, passes: 1, firstTry: true), 3);
      expect(scoreStars(attempts: 2, passes: 1, firstTry: false), 2);
      expect(scoreStars(attempts: 5, passes: 1, firstTry: false), 1);
      expect(scoreStars(attempts: 3, passes: 0, firstTry: false), 0);
    });
  });

  group('ScenarioMastery', () {
    test('passes flag is true when passes > 0', () {
      final m = ScenarioMastery(
        scenarioId: 'x',
        attempts: 2,
        passes: 1,
        firstTry: false,
        stars: 2,
      );
      expect(m.passed, isTrue);
    });
  });
}
