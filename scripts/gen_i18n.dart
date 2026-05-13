// Code generator: JSON i18n files → Dart locale files.
//
// Reads JSON translation files from `i18n/` (hyphenated Crowdin format, e.g.
// `zh-CN.json`) and generates the corresponding Dart `const Map<String, String>`
// files under `lib/app/i18n/locales/` (underscored Dart format, e.g. `zh_cn.dart`).
//
// Usage:
//   dart run scripts/gen_i18n.dart

import 'dart:convert';
import 'dart:io';

const jsonDir = 'i18n';
const outputDir = 'lib/app/i18n/locales';

// Maps Crowdin locale (JSON filename, hyphen) → Dart output filename (underscore)
const localeFileMap = {
  'zh-CN': 'zh_cn.dart',
  'en-US': 'en_us.dart',
  'ko-KR': 'ko_kr.dart',
  'ja-JP': 'ja_jp.dart',
  'vi-VN': 'vi_vn.dart',
  'th-TH': 'th_th.dart',
};

// Maps Crowdin locale (JSON filename, hyphen) → Dart variable name
const localeVarMap = {
  'zh-CN': 'zhCN',
  'en-US': 'enUS',
  'ko-KR': 'koKR',
  'ja-JP': 'jaJP',
  'vi-VN': 'viVN',
  'th-TH': 'thTH',
};

// Maps Crowdin locale (JSON filename) → GetX locale key (underscore)
const dartLocaleKey = {
  'zh-CN': 'zh_CN',
  'en-US': 'en_US',
  'ko-KR': 'ko_KR',
  'ja-JP': 'ja_JP',
  'vi-VN': 'vi_VN',
  'th-TH': 'th_TH',
};

String escapeDartString(String s) {
  return s
      .replaceAll('\\', '\\\\')
      .replaceAll("'", "\\'")
      .replaceAll('\n', '\\n')
      .replaceAll(r'$', r'\$');
}

void main() {
  final jsonDirObj = Directory(jsonDir);
  if (!jsonDirObj.existsSync()) {
    stderr.writeln('Error: $jsonDir directory not found.');
    exit(1);
  }

  final outputDirObj = Directory(outputDir);
  if (!outputDirObj.existsSync()) {
    outputDirObj.createSync(recursive: true);
  }

  final jsonFiles = jsonDirObj
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.json'))
      .toList();

  if (jsonFiles.isEmpty) {
    stderr.writeln('Error: No JSON files found in $jsonDir.');
    exit(1);
  }

  final generatedLocales = <String>[];

  for (final jsonFile in jsonFiles) {
    final crowdinLocale =
        jsonFile.uri.pathSegments.last.replaceAll('.json', '');
    final dartFileName = localeFileMap[crowdinLocale];
    final varName = localeVarMap[crowdinLocale];

    if (dartFileName == null || varName == null) {
      stdout.writeln('Skipping unknown locale: $crowdinLocale');
      continue;
    }

    final content = jsonFile.readAsStringSync();
    Map<String, dynamic> map;
    try {
      map = json.decode(content) as Map<String, dynamic>;
    } catch (e) {
      stderr.writeln('Error parsing $jsonFile: $e');
      exit(1);
    }

    final buffer = StringBuffer();
    buffer.writeln('\tconst Map<String, String> $varName = {');

    final keys = map.keys.toList()..sort();
    for (final key in keys) {
      final value = map[key]?.toString() ?? '';
      buffer.writeln("\t  '$key': '${escapeDartString(value)}',");
    }

    buffer.writeln('\t};');
    buffer.writeln('');

    final outputFile = File('$outputDir/$dartFileName');
    outputFile.writeAsStringSync(buffer.toString());
    generatedLocales.add(crowdinLocale);

    stdout.writeln(
        'Generated: $outputDir/$dartFileName (${map.length} keys)');
  }

  _updateTranslationsDart(generatedLocales);

  stdout.writeln('Done. ${generatedLocales.length} locale files generated.');
}

void _updateTranslationsDart(List<String> crowdinLocales) {
  final imports = StringBuffer();
  final mapEntries = StringBuffer();

  for (final crowdinLocale in crowdinLocales) {
    final varName = localeVarMap[crowdinLocale]!;
    final dartKey = dartLocaleKey[crowdinLocale]!;
    final dartFile = localeFileMap[crowdinLocale]!;

    imports.writeln("import 'locales/$dartFile';");
    mapEntries.writeln("        '$dartKey': $varName,");
  }

  final content = '''
import 'package:get/get.dart';
${imports.toString()}
class LedgerLearnTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
${mapEntries.toString()}      };
}
''';

  File('lib/app/i18n/translations.dart').writeAsStringSync(content);
  stdout.writeln('Updated: lib/app/i18n/translations.dart');
}
