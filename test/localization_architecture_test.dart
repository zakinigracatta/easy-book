import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final presentationRoots = <Directory>[
    Directory('lib/screens'),
    Directory('lib/features'),
    Directory('lib/widgets'),
  ];

  test('presentation code contains no hard-coded Arabic or Russian text', () {
    final forbiddenScripts = RegExp(r'[\u0600-\u06ff\u0400-\u04ff]');
    final violations = <String>[];

    for (final root in presentationRoots) {
      if (!root.existsSync()) continue;
      for (final entity in root.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final lines = entity.readAsLinesSync();
        for (var index = 0; index < lines.length; index++) {
          if (forbiddenScripts.hasMatch(lines[index])) {
            violations
                .add('${entity.path}:${index + 1}: ${lines[index].trim()}');
          }
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'UI copy must come from the ARB localization source.\n'
          '${violations.join('\n')}',
    );
  });

  test('all locales expose exactly the English source keys', () {
    Map<String, dynamic> readArb(String locale) =>
        jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())
            as Map<String, dynamic>;

    Set<String> messageKeys(Map<String, dynamic> arb) => arb.keys
        .where((key) => key != '@@locale' && !key.startsWith('@'))
        .toSet();

    final english = messageKeys(readArb('en'));
    for (final locale in ['ar', 'ru']) {
      final localized = messageKeys(readArb(locale));
      expect(localized.difference(english), isEmpty,
          reason: '$locale contains keys absent from the English source.');
      expect(english.difference(localized), isEmpty,
          reason: '$locale is missing English source keys.');
    }
  });
}
