import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:easy_book/l10n/arabic_translations.dart';
import 'package:easy_book/l10n/russian_runtime_translations.dart';
import 'package:easy_book/l10n/russian_secondary_translations.dart';
import 'package:easy_book/l10n/russian_translations.dart';

void main() {
  final uiRoots = <Directory>[
    Directory('lib/screens'),
    Directory('lib/widgets'),
  ];

  List<File> uiFiles() => uiRoots
      .expand((root) => root
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart')))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  test('active UI has no forced dark-only semantic colors', () {
    const forbidden = <String>[
      'backgroundColor: AppColors.bgDark',
      'backgroundColor: AppColors.cardDark',
      'color: AppColors.textPrimaryDark',
      'color: AppColors.textSecondaryDark',
      'color: AppColors.textMutedDark',
      'color: AppColors.cardDark',
      'color: AppColors.glassBorderDark',
      'surface: AppColors.cardDark',
    ];

    final failures = <String>[];
    for (final file in uiFiles()) {
      final source = file.readAsStringSync();
      final lines = source.split('\n');
      for (var i = 0; i < lines.length; i++) {
        for (final token in forbidden) {
          if (lines[i].contains(token)) {
            failures.add('${file.path}:${i + 1}: $token');
          }
        }
      }
    }

    expect(
      failures,
      isEmpty,
      reason: 'Forced dark-only UI tokens remain:\n${failures.join('\n')}',
    );
  });

  test('visible Text literals are routed through localization', () {
    final failures = <String>[];
    final textLiteral = RegExp(
      r'''(?:const\s+)?Text\(\s*([\"'])(.*?)\1''',
      multiLine: true,
      dotAll: true,
    );
    final alpha = RegExp(r'[A-Za-z]');

    for (final file in uiFiles()) {
      final source = file.readAsStringSync();
      for (final match in textLiteral.allMatches(source)) {
        final literal = match.group(2) ?? '';
        final withoutInterpolation = literal
            .replaceAll(RegExp(r'\$\{[^}]+\}'), '')
            .replaceAll(RegExp(r'\$[A-Za-z_][A-Za-z0-9_\.]*'), '');
        if (!alpha.hasMatch(withoutInterpolation)) continue;

        final line = '\n'.allMatches(source.substring(0, match.start)).length + 1;
        failures.add('${file.path}:$line: Text("$literal")');
      }
    }

    expect(
      failures,
      isEmpty,
      reason: 'Hard-coded visible English Text literals remain:\n${failures.join('\n')}',
    );
  });

  test('every simple context.tr key has Arabic and Russian coverage', () {
    final arabicKeys = arabicTranslations.keys.toSet();
    final russianKeys = <String>{
      ...russianTranslations.keys,
      ...russianSecondaryTranslations.keys,
      ...russianRuntimeTranslations.keys,
    };
    final keyPattern = RegExp(r'''context\.tr\(\s*([\"'])(.*?)\1''', dotAll: true);
    final missingArabic = <String>{};
    final missingRussian = <String>{};

    for (final file in uiFiles()) {
      final source = file.readAsStringSync();
      for (final match in keyPattern.allMatches(source)) {
        final key = match.group(2)!;
        if (!arabicKeys.contains(key)) missingArabic.add(key);
        if (!russianKeys.contains(key)) missingRussian.add(key);
      }
    }

    expect(
      missingArabic,
      isEmpty,
      reason: 'Missing Arabic translations:\n${missingArabic.toList()..sort()}',
    );
    expect(
      missingRussian,
      isEmpty,
      reason: 'Missing Russian translations:\n${missingRussian.toList()..sort()}',
    );
  });
}
