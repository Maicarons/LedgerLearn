import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final locales = [
    'zh-CN',
    'en-US',
    'ko-KR',
    'ja-JP',
    'vi-VN',
    'th-TH',
  ];

  Map<String, dynamic> load(String code) {
    final file = File('i18n/$code.json');
    return json.decode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  group('i18n key parity', () {
    test('zh-CN is the source and has keys', () {
      final src = load('zh-CN');
      expect(src.length, greaterThan(150));
    });

    test('all app locales share the same key set as zh-CN', () {
      final srcKeys = load('zh-CN').keys.toSet();
      for (final code in locales.skip(1)) {
        final keys = load(code).keys.toSet();
        final missing = srcKeys.difference(keys);
        final extra = keys.difference(srcKeys);
        expect(missing, isEmpty,
            reason: '$code missing keys: ${missing.take(20).toList()}');
        expect(extra, isEmpty,
            reason: '$code extra keys: ${extra.take(20).toList()}');
      }
    });

    test('no empty translations in app locales', () {
      for (final code in locales) {
        final data = load(code);
        final empty = data.entries
            .where((e) => e.value == null || (e.value as String).trim().isEmpty)
            .map((e) => e.key)
            .toList();
        expect(empty, isEmpty, reason: '$code empty: $empty');
      }
    });
  });

  group('knowledge_card assets', () {
    test('zh-CN has 70+ cards in 3 categories', () {
      final file = File('knowledge_card/zh-CN.json');
      final list = json.decode(file.readAsStringSync()) as List;
      expect(list.length, greaterThanOrEqualTo(70));
      final cats = list.map((e) => e['category']).toSet();
      expect(cats.containsAll(['accounting_practice', 'economic_law', 'tax']),
          isTrue);
    });

    test('knowledge cards share ids across zh/en/ko', () {
      List<String> ids(String code) {
        final list =
            json.decode(File('knowledge_card/$code.json').readAsStringSync())
                as List;
        return list.map((e) => e['id'] as String).toList()..sort();
      }

      final zh = ids('zh-CN');
      expect(ids('en-US'), zh);
      expect(ids('ko-KR'), zh);
    });
  });
}
