import '../models/knowledge_card.dart';
import '../services/database_service.dart';

class KnowledgeRepository {
  final DatabaseService _db;

  KnowledgeRepository(this._db);

  List<KnowledgeCard> getAll() => _db.getKnowledgeCards();

  List<KnowledgeCard> getByCategory(String category) =>
      getAll().where((k) => k.category == category).toList();

  List<KnowledgeCard> getByAccount(String accountId) =>
      getAll().where((k) => k.relatedAccountId == accountId).toList();

  List<KnowledgeCard> search(String query) {
    final lower = query.toLowerCase();
    return getAll().where((k) {
      return k.title.toLowerCase().contains(lower) ||
          k.content.toLowerCase().contains(lower) ||
          (k.relatedAccountId?.contains(lower) ?? false);
    }).toList();
  }

  KnowledgeCard? getById(String id) {
    try {
      return getAll().firstWhere((k) => k.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get a random knowledge card, optionally filtered by category
  KnowledgeCard? getRandom({String? category}) {
    final cards = category != null ? getByCategory(category) : getAll();
    if (cards.isEmpty) return null;
    cards.shuffle();
    return cards.first;
  }
}
