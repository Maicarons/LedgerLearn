import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'database_service.dart';

/// An unlockable achievement badge shown on the Settings page.
class Achievement {
  final String id;
  final String titleKey;
  final String descKey;
  final IconData icon;
  final Color color;
  final bool Function(int voucherCount, int knowledgeCount) unlocked;

  const Achievement({
    required this.id,
    required this.titleKey,
    required this.descKey,
    required this.icon,
    required this.color,
    required this.unlocked,
  });
}

/// Tracks learning progress (vouchers created, knowledge cards read) and
/// exposes unlocked achievements. Persists viewed knowledge ids in storage.
class ProgressService extends GetxController {
  final DatabaseService db = Get.find<DatabaseService>();

  final voucherCount = 0.obs;
  final knowledgeReadCount = 0.obs;
  final viewedKnowledgeIds = <String>[].obs;

  static final List<Achievement> achievements = [
    Achievement(
      id: 'first_voucher',
      titleKey: 'achievement_first_voucher',
      descKey: 'achievement_first_voucher_desc',
      icon: Icons.receipt_long,
      color: Color(0xFF1565C0),
      unlocked: (v, k) => v >= 1,
    ),
    Achievement(
      id: 'voucher_5',
      titleKey: 'achievement_voucher_5',
      descKey: 'achievement_voucher_5_desc',
      icon: Icons.assignment_turned_in,
      color: Color(0xFF00695C),
      unlocked: (v, k) => v >= 5,
    ),
    Achievement(
      id: 'voucher_20',
      titleKey: 'achievement_voucher_20',
      descKey: 'achievement_voucher_20_desc',
      icon: Icons.workspace_premium,
      color: Color(0xFFE65100),
      unlocked: (v, k) => v >= 20,
    ),
    Achievement(
      id: 'knowledge_5',
      titleKey: 'achievement_knowledge_5',
      descKey: 'achievement_knowledge_5_desc',
      icon: Icons.menu_book,
      color: Color(0xFF6A1B9A),
      unlocked: (v, k) => k >= 5,
    ),
    Achievement(
      id: 'knowledge_20',
      titleKey: 'achievement_knowledge_20',
      descKey: 'achievement_knowledge_20_desc',
      icon: Icons.emoji_events,
      color: Color(0xFF2E7D32),
      unlocked: (v, k) => k >= 20,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    viewedKnowledgeIds.value = db.getViewedKnowledgeIds();
    reload();
  }

  /// Recompute counters from persisted data.
  void reload() {
    voucherCount.value = db.getVouchers().length;
    knowledgeReadCount.value = viewedKnowledgeIds.length;
    update();
  }

  /// Record that a knowledge card was opened (idempotent per card).
  void recordKnowledgeViewed(String id) {
    if (viewedKnowledgeIds.contains(id)) return;
    viewedKnowledgeIds.add(id);
    db.addViewedKnowledge(id);
    reload();
  }

  List<Achievement> get unlockedAchievements =>
      achievements.where((a) => a.unlocked(voucherCount.value, knowledgeReadCount.value)).toList();
}
