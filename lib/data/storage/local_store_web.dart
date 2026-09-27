import 'dart:convert';

import 'package:get_storage/get_storage.dart';

import 'local_store.dart';

/// GetStorage-backed [LocalStore] for web (no `dart:io` / SQLite).
class WebLocalStore implements LocalStore {
  bool _open = false;

  @override
  bool get isOpen => _open;

  @override
  Future<void> init({
    Object? factory,
    String? path,
    bool inMemory = false,
  }) async {
    await GetStorage.init();
    _open = true;
  }

  @override
  Future<void> close() async {
    _open = false;
  }

  @override
  Future<String?> getString(String key) async {
    final v = GetStorage().read(key);
    return v?.toString();
  }

  @override
  Future<T?> readJson<T>(String key) async {
    final raw = await getString(key);
    if (raw == null) return null;
    try {
      return json.decode(raw) as T;
    } catch (_) {
      return GetStorage().read<T>(key);
    }
  }

  @override
  Future<void> setString(String key, String value) async {
    await GetStorage().write(key, value);
  }

  @override
  Future<void> writeJson(String key, Object? value) async {
    await GetStorage().write(key, value);
  }

  @override
  Future<void> removeKey(String key) async {
    await GetStorage().remove(key);
  }

  // Documents are stored under 'docs_<kind>' as a list of maps.
  String _docsKey(String kind) => 'docs_$kind';

  @override
  Future<List<Map<String, dynamic>>> listDocuments(String kind) async {
    final raw = GetStorage().read<List>(_docsKey(kind));
    if (raw == null) return [];
    return raw.map((e) {
      final row = Map<String, dynamic>.from(e as Map);
      final j = row['json'];
      if (j is Map) return Map<String, dynamic>.from(j);
      if (j is String) {
        try {
          return Map<String, dynamic>.from(json.decode(j) as Map);
        } catch (_) {
          return <String, dynamic>{};
        }
      }
      return <String, dynamic>{};
    }).toList();
  }

  @override
  Future<Map<String, dynamic>?> getDocument(String kind, String id) async {
    final raw = GetStorage().read<List>(_docsKey(kind));
    if (raw == null) return null;
    for (final e in raw) {
      final row = Map<String, dynamic>.from(e as Map);
      if (row['id']?.toString() != id) continue;
      final j = row['json'];
      if (j is Map) return Map<String, dynamic>.from(j);
      if (j is String) {
        try {
          return Map<String, dynamic>.from(json.decode(j) as Map);
        } catch (_) {
          return null;
        }
      }
    }
    return null;
  }

  @override
  Future<void> putDocument(
    String kind,
    String id,
    Map<String, dynamic> data, {
    String? sortKey,
  }) async {
    final rows = await _rawRows(kind);
    rows.removeWhere((r) => r['id'] == id);
    rows.add({
      'id': id,
      'json': data,
      'sort_key': sortKey,
    });
    await GetStorage().write(_docsKey(kind), rows);
  }

  @override
  Future<void> deleteDocument(String kind, String id) async {
    final rows = await _rawRows(kind);
    rows.removeWhere((r) => r['id'] == id);
    await GetStorage().write(_docsKey(kind), rows);
  }

  @override
  Future<void> clearDocuments(String kind) async {
    await GetStorage().write(_docsKey(kind), <Map<String, dynamic>>[]);
  }

  @override
  Future<void> replaceAllDocuments(
    String kind,
    List<({String id, Map<String, dynamic> json, String? sortKey})> rows,
  ) async {
    await GetStorage().write(
      _docsKey(kind),
      [
        for (final r in rows)
          {'id': r.id, 'json': r.json, 'sort_key': r.sortKey}
      ],
    );
  }

  Future<List<Map<String, dynamic>>> _rawRows(String kind) async {
    final raw = GetStorage().read<List>(_docsKey(kind));
    if (raw == null) return [];
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}

LocalStore createStoreImpl() => WebLocalStore();
