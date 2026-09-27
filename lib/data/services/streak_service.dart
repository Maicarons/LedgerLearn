import 'package:get/get.dart';

import 'database_service.dart';

/// Daily learning streak + simple goal tracking.
class StreakService extends GetxService {
  static const _streakKey = 'learning_streak';
  static const _lastDayKey = 'learning_last_day';
  static const _todayDoneKey = 'learning_today_done';
  static const _quizScoreKey = 'knowledge_quiz_score';

  final DatabaseService _db;

  StreakService([DatabaseService? db]) : _db = db ?? Get.find<DatabaseService>();

  final streak = 0.obs;
  final todayDone = false.obs;
  final quizCorrect = 0.obs;
  final quizTotal = 0.obs;

  String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  void onInit() {
    super.onInit();
    reload();
  }

  void reload() {
    streak.value = _db.readKv<int>(_streakKey) ?? 0;
    todayDone.value = _db.readKv<bool>(_todayDoneKey) ?? false;
    final score = _db.readKv<Map>(_quizScoreKey);
    quizCorrect.value = score?['correct'] ?? 0;
    quizTotal.value = score?['total'] ?? 0;
  }

  /// Call whenever the learner completes a meaningful action.
  Future<void> markActivity() async {
    final today = _dayKey(DateTime.now());
    final last = _db.readKv<String>(_lastDayKey);
    if (last == today) {
      await _db.writeKv(_todayDoneKey, true);
      todayDone.value = true;
      return;
    }
    final yesterday = _dayKey(DateTime.now().subtract(const Duration(days: 1)));
    final next = last == yesterday ? (streak.value + 1) : 1;
    await _db.writeKv(_lastDayKey, today);
    await _db.writeKv(_streakKey, next);
    await _db.writeKv(_todayDoneKey, true);
    streak.value = next;
    todayDone.value = true;
  }

  /// Record one knowledge quick-check result.
  Future<void> recordQuizResult({required bool correct}) async {
    final map = Map<String, dynamic>.from(_db.readKv<Map>(_quizScoreKey) ?? {});
    map['correct'] = (map['correct'] ?? 0) + (correct ? 1 : 0);
    map['total'] = (map['total'] ?? 0) + 1;
    await _db.writeKv(_quizScoreKey, map);
    quizCorrect.value = map['correct'];
    quizTotal.value = map['total'];
    await markActivity();
  }

  Future<void> resetAll() async {
    await _db.writeKv(_streakKey, 0);
    await _db.writeKv(_todayDoneKey, false);
    await _db.writeKv(_quizScoreKey, <String, dynamic>{});
    reload();
  }
}
