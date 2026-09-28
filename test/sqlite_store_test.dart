@TestOn('vm')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerlearn/data/storage/local_store_io.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('LocalStore SQLite', () {
    late SqliteLocalStore store;

    setUp(() async {
      store = SqliteLocalStore();
      await store.init(factory: databaseFactoryFfi, inMemory: true);
    });

    tearDown(() async {
      await store.close();
    });

    test('kv write / read / remove', () async {
      await store.setString('locale', 'en_US');
      expect(await store.getString('locale'), 'en_US');
      await store.removeKey('locale');
      expect(await store.getString('locale'), isNull);
    });

    test('kv json round-trip', () async {
      await store.writeJson('score', {'correct': 3, 'total': 5});
      final v = await store.readJson<Map>('score');
      expect(v?['correct'], 3);
      expect(v?['total'], 5);
    });

    test('documents put / get / list / delete', () async {
      await store.putDocument('voucher', 'V1', {'id': 'V1', 'summary': 'a'},
          sortKey: '2026-01-01');
      await store.putDocument('voucher', 'V2', {'id': 'V2', 'summary': 'b'},
          sortKey: '2026-01-02');

      final list = await store.listDocuments('voucher');
      expect(list.length, 2);
      expect(list.first['id'], 'V1'); // ordered by sort_key

      final one = await store.getDocument('voucher', 'V2');
      expect(one?['summary'], 'b');

      await store.deleteDocument('voucher', 'V1');
      expect((await store.listDocuments('voucher')).length, 1);
    });

    test('replaceAllDocuments replaces the kind only', () async {
      await store.putDocument('account', '1001', {'id': '1001'});
      await store.putDocument('voucher', 'V9', {'id': 'V9'});

      await store.replaceAllDocuments('account', [
        (id: '2001', json: {'id': '2001'}, sortKey: null),
      ]);

      final accounts = await store.listDocuments('account');
      expect(accounts.length, 1);
      expect(accounts.first['id'], '2001');

      final vouchers = await store.listDocuments('voucher');
      expect(vouchers.length, 1);
    });

    test('document id is unique per kind', () async {
      await store.putDocument('account', '1001', {'v': 1});
      await store.putDocument('account', '1001', {'v': 2});
      final rows = await store.listDocuments('account');
      expect(rows.length, 1);
      expect(rows.first['v'], 2);
    });
  });
}
