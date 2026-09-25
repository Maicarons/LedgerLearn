import 'package:get/get.dart';
import '../models/knowledge_card.dart';

class RemoteKnowledgeService extends GetConnect {
  /// Prefer a release tag so clients don't track moving `master`.
  /// Fallback chain: release tag → major.minor → master (last resort).
  static const String _baseTag = 'v0.3.0';
  static const String _fallbackTag = 'v0.2.0';

  static String _urlFor(String tag, String lang) =>
      'https://fastly.jsdelivr.net/gh/Maicarons/LedgerLearn@$tag/knowledge_card/$lang.json';

  /// Fetch knowledge cards for the given locale from remote server.
  /// Returns null if the fetch fails (no network, timeout, bad response).
  Future<List<KnowledgeCard>?> fetchKnowledgeCards(String locale) async {
    final lang = locale.replaceAll('_', '-');
    for (final tag in [_baseTag, _fallbackTag, 'master']) {
      final cards = await _fetch(_urlFor(tag, lang));
      if (cards != null && cards.isNotEmpty) return cards;
    }
    return null;
  }

  Future<List<KnowledgeCard>?> _fetch(String url) async {
    try {
      final response = await get(
        url,
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
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 && response.body is List) {
        return response.body as List<KnowledgeCard>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
