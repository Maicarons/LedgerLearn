// Bumps the version in version.json.
//
// Usage: dart run scripts/bump_version.dart (patch|minor|major)

import 'dart:convert';
import 'dart:io';

const versionFile = 'version.json';

void main(List<String> args) {
  if (args.length != 1 || !['patch', 'minor', 'major'].contains(args[0])) {
    stderr.writeln('Usage: dart run scripts/bump_version.dart <patch|minor|major>');
    exit(1);
  }

  final level = args[0];
  final file = File(versionFile);
  final data = json.decode(file.readAsStringSync()) as Map<String, dynamic>;

  final parts = (data['version'] as String).split('.');
  var major = int.parse(parts[0]);
  var minor = int.parse(parts[1]);
  var patch = int.parse(parts[2]);

  switch (level) {
    case 'major':
      major++;
      minor = 0;
      patch = 0;
    case 'minor':
      minor++;
      patch = 0;
    case 'patch':
      patch++;
  }

  data['version'] = '$major.$minor.$patch';
  data['version_code'] = (data['version_code'] as int) + 1;

  file.writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(data)}\n');
  stdout.writeln('Bumped version to ${data['version']}+${data['version_code']}');
}
