import 'package:get/get.dart';
import '../../../data/services/knowledge_quiz.dart';
import '../../../data/services/review_service.dart';
import '../../../data/services/streak_service.dart';
import '../../../data/repositories/knowledge_repository.dart';

/// One spaced-repetition review session: quiz questions for due cards,
/// graded Again / Hard / Good / Easy.
class ReviewController extends GetxController {
  final ReviewService review = Get.find<ReviewService>();
  final KnowledgeRepository knowledgeRepo = Get.find<KnowledgeRepository>();

  final queue = <KnowledgeQuizQuestion>[].obs;
  final index = 0.obs;
  final selected = Rxn<int>();
  final graded = false.obs;
  final finished = false.obs;
  final reviewed = 0.obs;

  KnowledgeQuizQuestion? get current =>
      index.value < queue.length ? queue[index.value] : null;

  int get total => queue.length;

  bool get hasNext => index.value + 1 < queue.length;

  String get cardTitle {
    final id = current?.knowledgeId;
    if (id == null) return '';
    return knowledgeRepo.getById(id)?.title ?? id;
  }

  String get cardCategory {
    final id = current?.knowledgeId;
    if (id == null) return '';
    return knowledgeRepo.getById(id)?.category ?? '';
  }

  @override
  void onInit() {
    super.onInit();
    Future.microtask(_start);
  }

  void _start() {
    // Ensure all quiz cards are scheduled, then pick due ones first.
    review.enqueue(quizKnowledgeIds());
    final due = review.dueIds();
    queue.value = pickReviewQuiz(
      count: 5,
      preferIds: due,
    );
    index.value = 0;
    selected.value = null;
    graded.value = false;
    finished.value = queue.isEmpty;
    reviewed.value = 0;
    update();
  }

  void select(int i) {
    if (graded.value) return;
    selected.value = i;
    update();
  }

  bool get isCorrect {
    final q = current;
    if (q == null || selected.value == null) return false;
    return selected.value == q.answerIndex;
  }

  /// Reveal the answer without scheduling yet.
  void reveal() {
    graded.value = true;
    update();
  }

  /// Apply SRS grade and record progress.
  Future<void> applyGrade(int grade) async {
    final q = current;
    if (q == null) return;
    graded.value = true;
    await review.grade(q.knowledgeId, grade);
    reviewed.value++;
    if (Get.isRegistered<StreakService>()) {
      await Get.find<StreakService>().recordQuizResult(correct: grade >= 2);
    }
    update();
  }

  void next() {
    if (!hasNext) {
      finished.value = true;
      update();
      return;
    }
    index.value++;
    selected.value = null;
    graded.value = false;
    update();
  }

  void restart() {
    _start();
  }

  int get dueBefore => review.dueCount.value;
}
