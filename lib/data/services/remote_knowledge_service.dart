import 'package:get/get.dart';

import '../models/knowledge_card.dart';

class RemoteKnowledgeService extends GetConnect {
  /// Remote JSON URL — change this to your own server
  static const String remoteUrl =
      'https://fastly.jsdelivr.net/gh/Maicarons/LedgerLearn@master/knowledge_cards.json';

  /// Fetch knowledge cards from remote server.
  /// Returns null if the fetch fails (no network, timeout, bad response).
  Future<List<KnowledgeCard>?> fetchKnowledgeCards() async {
    try {
      final response = await get(
        remoteUrl,
        decoder: (data) {
          if (data is List) {
            return data
                .map(
                  (e) => KnowledgeCard.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList();
          }
          return null;
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 && response.body is List) {
        return response.body as List<KnowledgeCard>;
      }
      return null;
    } catch (_) {
      // Network error, timeout, or malformed data
      return null;
    }
  }
}
