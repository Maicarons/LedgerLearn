/// Lightweight knowledge quick-check questions.
/// One question per key knowledge card id; answers are index into options.
class KnowledgeQuizQuestion {
  final String knowledgeId;
  final String questionKey;
  final List<String> optionKeys;
  final int answerIndex;
  final String explainKey;

  const KnowledgeQuizQuestion({
    required this.knowledgeId,
    required this.questionKey,
    required this.optionKeys,
    required this.answerIndex,
    required this.explainKey,
  });
}

const List<KnowledgeQuizQuestion> knowledgeQuizBank = [
  // ===== 0.6.0 core set =====
  KnowledgeQuizQuestion(
    knowledgeId: 'k1',
    questionKey: 'kq_k1_q',
    optionKeys: ['kq_k1_a0', 'kq_k1_a1', 'kq_k1_a2'],
    answerIndex: 0,
    explainKey: 'kq_k1_e',
  ),
  KnowledgeQuizQuestion(
    knowledgeId: 'k2',
    questionKey: 'kq_k2_q',
    optionKeys: ['kq_k2_a0', 'kq_k2_a1', 'kq_k2_a2'],
    answerIndex: 1,
    explainKey: 'kq_k2_e',
  ),
  KnowledgeQuizQuestion(
    knowledgeId: 'k4',
    questionKey: 'kq_k4_q',
    optionKeys: ['kq_k4_a0', 'kq_k4_a1', 'kq_k4_a2'],
    answerIndex: 2,
    explainKey: 'kq_k4_e',
  ),
  KnowledgeQuizQuestion(
    knowledgeId: 'k6',
    questionKey: 'kq_k6_q',
    optionKeys: ['kq_k6_a0', 'kq_k6_a1', 'kq_k6_a2'],
    answerIndex: 0,
    explainKey: 'kq_k6_e',
  ),
  KnowledgeQuizQuestion(
    knowledgeId: 'k8',
    questionKey: 'kq_k8_q',
    optionKeys: ['kq_k8_a0', 'kq_k8_a1', 'kq_k8_a2'],
    answerIndex: 1,
    explainKey: 'kq_k8_e',
  ),
  KnowledgeQuizQuestion(
    knowledgeId: 'k21',
    questionKey: 'kq_k21_q',
    optionKeys: ['kq_k21_a0', 'kq_k21_a1', 'kq_k21_a2'],
    answerIndex: 0,
    explainKey: 'kq_k21_e',
  ),
  // ===== 0.7.0 expansion =====
  KnowledgeQuizQuestion(
    knowledgeId: 'k3',
    questionKey: 'kq_k3_q',
    optionKeys: ['kq_k3_a0', 'kq_k3_a1', 'kq_k3_a2'],
    answerIndex: 1,
    explainKey: 'kq_k3_e',
  ),
  KnowledgeQuizQuestion(
    knowledgeId: 'k7',
    questionKey: 'kq_k7_q',
    optionKeys: ['kq_k7_a0', 'kq_k7_a1', 'kq_k7_a2'],
    answerIndex: 2,
    explainKey: 'kq_k7_e',
  ),
  KnowledgeQuizQuestion(
    knowledgeId: 'k10',
    questionKey: 'kq_k10_q',
    optionKeys: ['kq_k10_a0', 'kq_k10_a1', 'kq_k10_a2'],
    answerIndex: 0,
    explainKey: 'kq_k10_e',
  ),
  KnowledgeQuizQuestion(
    knowledgeId: 'k13',
    questionKey: 'kq_k13_q',
    optionKeys: ['kq_k13_a0', 'kq_k13_a1', 'kq_k13_a2'],
    answerIndex: 1,
    explainKey: 'kq_k13_e',
  ),
  KnowledgeQuizQuestion(
    knowledgeId: 'k15',
    questionKey: 'kq_k15_q',
    optionKeys: ['kq_k15_a0', 'kq_k15_a1', 'kq_k15_a2'],
    answerIndex: 0,
    explainKey: 'kq_k15_e',
  ),
  KnowledgeQuizQuestion(
    knowledgeId: 'k23',
    questionKey: 'kq_k23_q',
    optionKeys: ['kq_k23_a0', 'kq_k23_a1', 'kq_k23_a2'],
    answerIndex: 2,
    explainKey: 'kq_k23_e',
  ),
  KnowledgeQuizQuestion(
    knowledgeId: 'k25',
    questionKey: 'kq_k25_q',
    optionKeys: ['kq_k25_a0', 'kq_k25_a1', 'kq_k25_a2'],
    answerIndex: 1,
    explainKey: 'kq_k25_e',
  ),
  KnowledgeQuizQuestion(
    knowledgeId: 'k54',
    questionKey: 'kq_k54_q',
    optionKeys: ['kq_k54_a0', 'kq_k54_a1', 'kq_k54_a2'],
    answerIndex: 0,
    explainKey: 'kq_k54_e',
  ),
  KnowledgeQuizQuestion(
    knowledgeId: 't1',
    questionKey: 'kq_t1_q',
    optionKeys: ['kq_t1_a0', 'kq_t1_a1', 'kq_t1_a2'],
    answerIndex: 1,
    explainKey: 'kq_t1_e',
  ),
  KnowledgeQuizQuestion(
    knowledgeId: 't2',
    questionKey: 'kq_t2_q',
    optionKeys: ['kq_t2_a0', 'kq_t2_a1', 'kq_t2_a2'],
    answerIndex: 2,
    explainKey: 'kq_t2_e',
  ),
];

KnowledgeQuizQuestion? quizForKnowledge(String id) {
  try {
    return knowledgeQuizBank.firstWhere((q) => q.knowledgeId == id);
  } catch (_) {
    return null;
  }
}

/// All question ids that have a quiz (used by the SRS review queue).
List<String> quizKnowledgeIds() =>
    knowledgeQuizBank.map((q) => q.knowledgeId).toList();

/// Pick a random quiz question (optionally preferring [preferId]).
KnowledgeQuizQuestion? pickKnowledgeQuiz({String? preferId}) {
  if (preferId != null) {
    final q = quizForKnowledge(preferId);
    if (q != null) return q;
  }
  if (knowledgeQuizBank.isEmpty) return null;
  return (knowledgeQuizBank.toList()..shuffle()).first;
}

/// Pick up to [count] quiz questions for a review session,
/// preferring cards listed in [preferIds].
List<KnowledgeQuizQuestion> pickReviewQuiz({
  int count = 5,
  List<String> preferIds = const [],
}) {
  final preferred = <KnowledgeQuizQuestion>[];
  final rest = <KnowledgeQuizQuestion>[];
  for (final q in knowledgeQuizBank) {
    if (preferIds.contains(q.knowledgeId)) {
      preferred.add(q);
    } else {
      rest.add(q);
    }
  }
  preferred.shuffle();
  rest.shuffle();
  return [...preferred, ...rest].take(count).toList();
}
