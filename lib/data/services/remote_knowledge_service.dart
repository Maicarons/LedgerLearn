import 'package:get/get.dart';
import '../models/knowledge_card.dart';

class RemoteKnowledgeService extends GetConnect {
  static const String _baseUrl =
      'https://fastly.jsdelivr.net/gh/Maicarons/LedgerLearn@master/knowledge_card';

  /// Fetch knowledge cards for the given locale from remote server.
  /// Returns null if the fetch fails (no network, timeout, bad response).
  Future<List<KnowledgeCard>?> fetchKnowledgeCards(String locale) async {
    // Convert 'zh_CN' → 'zh-CN' for URL path
    final lang = locale.replaceAll('_', '-');
    try {
      final response = await get(
        '$_baseUrl/$lang.json',
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
      return null;
    }
  }
}
