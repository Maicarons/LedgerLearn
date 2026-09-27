/// Local persistence interface.
///
/// Implementations: SQLite on IO platforms, GetStorage fallback on web.
abstract class LocalStore {
  Future<void> init({
    Object? factory,
    String? path,
    bool inMemory = false,
  });

  Future<void> close();

  bool get isOpen;

  Future<String?> getString(String key);
  Future<T?> readJson<T>(String key);
  Future<void> setString(String key, String value);
  Future<void> writeJson(String key, Object? value);
  Future<void> removeKey(String key);

  Future<List<Map<String, dynamic>>> listDocuments(String kind);
  Future<Map<String, dynamic>?> getDocument(String kind, String id);
  Future<void> putDocument(
    String kind,
    String id,
    Map<String, dynamic> data, {
    String? sortKey,
  });
  Future<void> deleteDocument(String kind, String id);
  Future<void> clearDocuments(String kind);
  Future<void> replaceAllDocuments(
    String kind,
    List<({String id, Map<String, dynamic> json, String? sortKey})> rows,
  );
}
