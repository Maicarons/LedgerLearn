/// Code generator: JSON i18n files → Dart locale files.
///
/// Reads JSON translation files from `i18n/` and generates the corresponding
/// Dart `const Map<String, String>` files under `lib/app/i18n/locales/`.
///
/// This script is intended to be run after Crowdin pulls updated translations.
///
/// Usage:
///   dart run scripts/gen_i18n.dart

import 'dart:convert';
import 'dart:io';

const jsonDir = 'i18n';
const outputDir = 'lib/app/i18n/locales';

const localeFileMap = {
  'zh_CN': 'zh_CN.dart',
  'en_US': 'en_US.dart',
  'ko_KR': 'ko_KR.dart',
  'ja_JP': 'ja_JP.dart',
  'vi_VN': 'vi_VN.dart',
  'th_TH': 'th_TH.dart',
};

const localeVarMap = {
  'zh_CN': 'zhCN',
  'en_US': 'enUS',
  'ko_KR': 'koKR',
  'ja_JP': 'jaJP',
  'vi_VN': 'viVN',
  'th_TH': 'thTH',
};

String escapeDartString(String s) {
  return s
      .replaceAll('\\', '\\\\')
      .replaceAll("'", "\\'")
      .replaceAll('\n', '\\n')
      .replaceAll('\$', '\\$');
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
    final localeCode =
        jsonFile.uri.pathSegments.last.replaceAll('.json', '');
    final dartFileName = localeFileMap[localeCode];
    final varName = localeVarMap[localeCode];

    if (dartFileName == null || varName == null) {
      stdout.writeln('Skipping unknown locale: $localeCode');
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
    generatedLocales.add(localeCode);

    stdout.writeln('Generated: $outputDir/$dartFileName (${map.length} keys)');
  }

  // Update translations.dart to include all generated locales
  _updateTranslationsDart(generatedLocales);

  stdout.writeln('Done. ${generatedLocales.length} locale files generated.');
}

void _updateTranslationsDart(List<String> locales) {
  final imports = StringBuffer();
  final mapEntries = StringBuffer();

  for (final locale in locales) {
    final varName = localeVarMap[locale]!;
    imports.writeln("import 'locales/$locale.dart';");
    mapEntries.writeln("        '$locale': $varName,");
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
