import 'package:get/get.dart';

import 'database_service.dart';

/// Simplified spaced-repetition (SM-2 lite) scheduling for knowledge cards.
class ReviewService extends GetxService {
  static const _srsKey = 'knowledge_srs';
  static const _sessionKey = 'review_session_count';

  final DatabaseService _db;

  ReviewService([DatabaseService? db]) : _db = db ?? Get.find<DatabaseService>();

  final dueCount = 0.obs;
  final totalScheduled = 0.obs;
  final sessionsDone = 0.obs;

  @override
  void onInit() {
    super.onInit();
    reload();
  }

  void reload() {
    final map = _readAll();
    final now = DateTime.now();
    var due = 0;
    for (final item in map.values) {
      final dueAt = DateTime.tryParse(item['dueAt'] ?? '');
      if (dueAt == null || !dueAt.isAfter(now)) due++;
    }
    dueCount.value = due;
    totalScheduled.value = map.length;
    sessionsDone.value = _db.readKv<int>(_sessionKey) ?? 0;
  }

  Map<String, dynamic> _readAll() {
    final raw = _db.readKv<Map>(_srsKey);
    if (raw == null) return {};
    return raw.map((k, v) =>
        MapEntry(k.toString(), Map<String, dynamic>.from(v as Map)));
  }

  Future<void> _writeAll(Map<String, dynamic> map) async {
    await _db.writeKv(_srsKey, map);
    reload();
  }

  /// Current scheduling state for one card (or a fresh default).
  SrsCard stateOf(String knowledgeId) {
    final map = _readAll();
    final item = map[knowledgeId];
    if (item == null) {
      return SrsCard(
        knowledgeId: knowledgeId,
        ease: 2.5,
        intervalDays: 0,
        dueAt: DateTime.now(),
        reps: 0,
        lapses: 0,
      );
    }
    return SrsCard(
      knowledgeId: knowledgeId,
      ease: (item['ease'] ?? 2.5).toDouble(),
      intervalDays: (item['intervalDays'] ?? 0).toDouble(),
      dueAt: DateTime.tryParse(item['dueAt'] ?? '') ?? DateTime.now(),
      reps: item['reps'] ?? 0,
      lapses: item['lapses'] ?? 0,
    );
  }

  /// Card ids due for review now (or never scheduled).
  List<String> dueIds({DateTime? now}) {
    final t = now ?? DateTime.now();
    final map = _readAll();
    final ids = <String>[];
    map.forEach((id, item) {
      final dueAt = DateTime.tryParse(item['dueAt'] ?? '');
      if (dueAt == null || !dueAt.isAfter(t)) ids.add(id);
    });
    return ids;
  }

  /// Apply a review grade and schedule the next due date.
  Future<void> grade(String knowledgeId, int grade) async {
    final map = _readAll();
    final cur = stateOf(knowledgeId);
    double ease = cur.ease;
    double interval = cur.intervalDays;
    int reps = cur.reps;
    int lapses = cur.lapses;

    if (grade <= 0) {
      lapses++;
      reps = 0;
      interval = 0;
      ease = (ease - 0.2).clamp(1.3, 2.5);
    } else {
      reps++;
      if (reps == 1) {
        interval = 1;
      } else if (reps == 2) {
        interval = 3;
      } else {
        final factor = grade == 3 ? 1.3 : grade == 2 ? 1.0 : 0.8;
        interval = (cur.intervalDays * ease * factor).clamp(1.0, 365.0);
      }
      ease = (ease + (grade == 3 ? 0.15 : grade == 2 ? 0.0 : -0.15))
          .clamp(1.3, 2.5);
    }

    final dueAt = DateTime.now().add(Duration(days: interval.round()));
    map[knowledgeId] = {
      'ease': ease,
      'intervalDays': interval,
      'dueAt': dueAt.toIso8601String(),
      'reps': reps,
      'lapses': lapses,
    };
    await _writeAll(map);

    final sessions = (_db.readKv<int>(_sessionKey) ?? 0) + 1;
    await _db.writeKv(_sessionKey, sessions);
    sessionsDone.value = sessions;
  }

  /// Enqueue cards that have a quiz but are not yet scheduled.
  Future<void> enqueue(List<String> knowledgeIds) async {
    final map = _readAll();
    var changed = false;
    for (final id in knowledgeIds) {
      if (!map.containsKey(id)) {
        map[id] = {
          'ease': 2.5,
          'intervalDays': 0.0,
          'dueAt': DateTime.now().toIso8601String(),
          'reps': 0,
          'lapses': 0,
        };
        changed = true;
      }
    }
    if (changed) await _writeAll(map);
  }

  Future<void> resetAll() async {
    await _db.writeKv(_srsKey, <String, dynamic>{});
    await _db.writeKv(_sessionKey, 0);
    reload();
  }
}

class SrsCard {
  final String knowledgeId;
  final double ease;
  final double intervalDays;
  final DateTime dueAt;
  final int reps;
  final int lapses;

  SrsCard({
    required this.knowledgeId,
    required this.ease,
    required this.intervalDays,
    required this.dueAt,
    required this.reps,
    required this.lapses,
  });

  bool get isDue => !dueAt.isAfter(DateTime.now());
}
