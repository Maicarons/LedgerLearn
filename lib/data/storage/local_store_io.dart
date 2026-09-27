import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'local_store.dart';

/// SQLite-backed [LocalStore] for mobile and desktop.
class SqliteLocalStore implements LocalStore {
  static const _dbVersion = 1;
  static const _dbName = 'ledgerlearn.db';

  Database? _db;

  Database get db {
    final d = _db;
    if (d == null) {
      throw StateError('LocalStore not initialised — call init() first');
    }
    return d;
  }

  @override
  bool get isOpen => _db != null;

  @override
  Future<void> init({
    Object? factory,
    String? path,
    bool inMemory = false,
  }) async {
    if (_db != null) return;
    final f = factory is DatabaseFactory ? factory : databaseFactory;

    String resolved;
    if (inMemory) {
      resolved = inMemoryDatabasePath;
    } else if (path != null) {
      resolved = path;
    } else {
      final dir = await f.getDatabasesPath();
      resolved = '$dir/$_dbName';
    }

    _db = await f.openDatabase(
      resolved,
      options: OpenDatabaseOptions(
        version: _dbVersion,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE kv (
              key TEXT PRIMARY KEY,
              value TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE documents (
              kind TEXT NOT NULL,
              id TEXT NOT NULL,
              json TEXT NOT NULL,
              sort_key TEXT,
              PRIMARY KEY (kind, id)
            )
          ''');
          await db.execute(
            'CREATE INDEX idx_documents_kind_sort ON documents(kind, sort_key)',
          );
        },
      ),
    );
  }

  @override
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  @override
  Future<String?> getString(String key) async {
    final rows =
        await db.query('kv', where: 'key = ?', whereArgs: [key], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  @override
  Future<T?> readJson<T>(String key) async {
    final raw = await getString(key);
    if (raw == null) return null;
    try {
      return json.decode(raw) as T;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> setString(String key, String value) async {
    await db.insert(
      'kv',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> writeJson(String key, Object? value) async {
    await setString(key, json.encode(value));
  }

  @override
  Future<void> removeKey(String key) async {
    await db.delete('kv', where: 'key = ?', whereArgs: [key]);
  }

  @override
  Future<List<Map<String, dynamic>>> listDocuments(String kind) async {
    final rows = await db.query(
      'documents',
      where: 'kind = ?',
      whereArgs: [kind],
      orderBy: 'sort_key IS NULL, sort_key, id',
    );
    return rows
        .map((r) => Map<String, dynamic>.from(
            json.decode(r['json'] as String) as Map))
        .toList();
  }

  @override
  Future<Map<String, dynamic>?> getDocument(String kind, String id) async {
    final rows = await db.query(
      'documents',
      where: 'kind = ? AND id = ?',
      whereArgs: [kind, id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Map<String, dynamic>.from(
        json.decode(rows.first['json'] as String) as Map);
  }

  @override
  Future<void> putDocument(
    String kind,
    String id,
    Map<String, dynamic> data, {
    String? sortKey,
  }) async {
    await db.insert(
      'documents',
      {
        'kind': kind,
        'id': id,
        'json': jsonEncode(data),
        'sort_key': sortKey,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteDocument(String kind, String id) async {
    await db.delete(
      'documents',
      where: 'kind = ? AND id = ?',
      whereArgs: [kind, id],
    );
  }

  @override
  Future<void> clearDocuments(String kind) async {
    await db.delete('documents', where: 'kind = ?', whereArgs: [kind]);
  }

  @override
  Future<void> replaceAllDocuments(
    String kind,
    List<({String id, Map<String, dynamic> json, String? sortKey})> rows,
  ) async {
    await db.transaction((txn) async {
      await txn.delete('documents', where: 'kind = ?', whereArgs: [kind]);
      for (final r in rows) {
        await txn.insert(
          'documents',
          {
            'kind': kind,
            'id': r.id,
            'json': jsonEncode(r.json),
            'sort_key': r.sortKey,
          },
        );
      }
    });
  }
}

LocalStore createStoreImpl() => SqliteLocalStore();
