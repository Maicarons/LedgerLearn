import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerlearn/data/services/knowledge_quiz.dart';

void main() {
  group('knowledge quiz bank', () {
    test('has at least 16 questions', () {
      expect(knowledgeQuizBank.length, greaterThanOrEqualTo(16));
    });

    test('question ids are unique', () {
      final ids = knowledgeQuizBank.map((q) => q.knowledgeId).toSet();
      expect(ids.length, knowledgeQuizBank.length);
    });

    test('every question has 3 options and a valid answer index', () {
      for (final q in knowledgeQuizBank) {
        expect(q.optionKeys.length, 3, reason: q.knowledgeId);
        expect(q.answerIndex, inInclusiveRange(0, 2), reason: q.knowledgeId);
        expect(q.questionKey, isNotEmpty);
        expect(q.explainKey, isNotEmpty);
      }
    });

    test('quizForKnowledge finds existing and returns null otherwise', () {
      expect(quizForKnowledge('k1'), isNotNull);
      expect(quizForKnowledge('nope'), isNull);
    });

    test('pickReviewQuiz prefers listed ids', () {
      final list = pickReviewQuiz(count: 3, preferIds: ['k1', 'k2']);
      expect(list.length, 3);
      expect(list.first.knowledgeId, anyOf('k1', 'k2'));
    });

    test('pickReviewQuiz respects count', () {
      expect(pickReviewQuiz(count: 5).length, 5);
      expect(pickReviewQuiz(count: 100).length, knowledgeQuizBank.length);
    });
  });

  group('SRS interval math (pure)', () {
    double nextInterval({
      required int reps,
      required double prevInterval,
      required double ease,
      required int grade,
    }) {
      if (grade <= 0) return 0;
      if (reps == 1) return 1;
      if (reps == 2) return 3;
      final factor = grade == 3 ? 1.3 : grade == 2 ? 1.0 : 0.8;
      return (prevInterval * ease * factor).clamp(1.0, 365.0);
    }

    test('first good review → 1 day', () {
      expect(nextInterval(reps: 1, prevInterval: 0, ease: 2.5, grade: 2), 1);
    });

    test('second good review → 3 days', () {
      expect(nextInterval(reps: 2, prevInterval: 1, ease: 2.5, grade: 2), 3);
    });

    test('later good review multiplies by ease', () {
      // 3 * 2.5 * 1.0 = 7.5
      expect(
        nextInterval(reps: 3, prevInterval: 3, ease: 2.5, grade: 2),
        closeTo(7.5, 0.01),
      );
    });

    test('forgot resets interval to 0', () {
      expect(nextInterval(reps: 5, prevInterval: 10, ease: 2.0, grade: 0), 0);
    });

    test('easy is faster than good', () {
      final easy = nextInterval(reps: 3, prevInterval: 3, ease: 2.5, grade: 3);
      final good = nextInterval(reps: 3, prevInterval: 3, ease: 2.5, grade: 2);
      expect(easy, greaterThan(good));
    });
  });
}
