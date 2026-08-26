import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:easy_book/l10n/arabic_runtime_translations.dart';
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
    const allowedLiteralData = <String>{
      'EN',
      'AR',
      'RU',
      'Easy Book v2.5',
    };

    for (final file in uiFiles()) {
      final source = file.readAsStringSync();
      for (final match in textLiteral.allMatches(source)) {
        final literal = match.group(2) ?? '';

        // Already-localized fragments inside a formatted value are valid, e.g.
        // '$count ${context.tr('reviews')}'. The simple regex deliberately does
        // not try to parse nested Dart expressions.
        if (literal.contains('context.tr(')) continue;
        if (allowedLiteralData.contains(literal)) continue;

        final withoutInterpolation = literal
            .replaceAll(RegExp(r'\$\{[^}]+\}'), '')
            .replaceAll(RegExp(r'\$[A-Za-z_][A-Za-z0-9_\.]*'), '')
            .replaceAll(RegExp(r'\bAED\b'), '')
            .trim();

        // Dynamic values that begin with a map/property interpolation can be
        // truncated by the regex at an inner quote. Those contain no literal
        // user-facing copy for this test to localize.
        if (literal.startsWith(r'${') && withoutInterpolation.startsWith(r'${')) {
          continue;
        }
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
    final arabicKeys = <String>{
      ...arabicTranslations.keys,
      ...arabicRuntimeTranslations.keys,
    };
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
        final key = match.group(2)!.replaceAll(r'\n', '\n');
        if (!arabicKeys.contains(key)) missingArabic.add(key);
        if (!russianKeys.contains(key)) missingRussian.add(key);
      }
    }

    final failures = <String>[];
    if (missingArabic.isNotEmpty) {
      final values = missingArabic.toList()..sort();
      failures.add('Missing Arabic translations:\n$values');
    }
    if (missingRussian.isNotEmpty) {
      final values = missingRussian.toList()..sort();
      failures.add('Missing Russian translations:\n$values');
    }

    expect(
      failures,
      isEmpty,
      reason: failures.join('\n\n'),
    );
  });
}
