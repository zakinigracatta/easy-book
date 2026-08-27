import 'package:easy_book/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryLocaleStorage implements LocaleStorage {
  String? languageCode;
  final writes = <String>[];

  @override
  String? readLanguageCode() => languageCode;

  @override
  Future<bool> writeLanguageCode(String languageCode) async {
    this.languageCode = languageCode;
    writes.add(languageCode);
    return true;
  }
}

void main() {
  group('LocaleController persistence', () {
    for (final code in ['ar', 'ru', 'en']) {
      test('saving $code and recreating the controller restores $code',
          () async {
        final storage = MemoryLocaleStorage();
        final first = LocaleController(storage: storage);

        expect(await first.setLanguageCode(code), isTrue);
        final restarted = LocaleController(storage: storage);

        expect(restarted.state, Locale(code));
      });
    }

    test('changing language repeatedly persists only the latest selection',
        () async {
      final storage = MemoryLocaleStorage();
      final controller = LocaleController(storage: storage);

      await controller.setLanguageCode('ar');
      await controller.setLanguageCode('ru');
      await controller.setLanguageCode('en');

      expect(storage.languageCode, 'en');
      expect(LocaleController(storage: storage).state, const Locale('en'));
    });

    test(
        'restarting application state does not reset a saved locale to English',
        () async {
      final storage = MemoryLocaleStorage()..languageCode = 'ru';

      final firstStartup = LocaleController(storage: storage);
      final secondStartup = LocaleController(storage: storage);

      expect(firstStartup.state, const Locale('ru'));
      expect(secondStartup.state, const Locale('ru'));
      expect(storage.writes, isEmpty);
    });

    test('unsupported language codes are neither saved nor applied', () async {
      final storage = MemoryLocaleStorage()..languageCode = 'ar';
      final controller = LocaleController(storage: storage);

      expect(await controller.setLanguageCode('fr'), isFalse);
      expect(controller.state, const Locale('ar'));
      expect(storage.languageCode, 'ar');
      expect(storage.writes, isEmpty);
    });
  });
}
