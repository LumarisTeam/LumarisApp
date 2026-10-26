import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/state/schedule_color_themes.dart';

void main() {
  group('ScheduleColorThemeCatalog', () {
    test('should expose 14 accents for Latte and Macchiato', () {
      expect(ScheduleColorThemeCatalog.accentsById, hasLength(2));
      expect(ScheduleColorThemeCatalog.accentsById.keys, <String>[
        'latte',
        'macchiato',
      ]);
      for (final id in ScheduleColorThemeCatalog.builtInIds) {
        expect(
          ScheduleColorThemeCatalog.accentsById[id],
          hasLength(14),
          reason: id,
        );
      }
    });

    test('should keep the canonical accent order', () {
      expect(
        ScheduleColorThemeCatalog.latteAccents.first,
        const Color(0xFFDC8A78),
      );
      expect(
        ScheduleColorThemeCatalog.latteAccents[3],
        const Color(0xFF8839EF),
      );
      expect(
        ScheduleColorThemeCatalog.latteAccents.last,
        const Color(0xFF7287FD),
      );

      expect(
        ScheduleColorThemeCatalog.macchiatoAccents.first,
        const Color(0xFFF4DBD6),
      );
      expect(
        ScheduleColorThemeCatalog.macchiatoAccents[3],
        const Color(0xFFC6A0F6),
      );
      expect(
        ScheduleColorThemeCatalog.macchiatoAccents.last,
        const Color(0xFFB7BDF8),
      );
    });

    test('should use Macchiato as the default for both pools', () {
      expect(
        scheduleDefaultLightColorPool,
        ScheduleColorThemeCatalog.macchiatoAccents,
      );
      expect(
        scheduleDefaultDarkColorPool,
        ScheduleColorThemeCatalog.macchiatoAccents,
      );
      expect(scheduleDefaultLightThemeId, 'macchiato');
      expect(scheduleDefaultDarkThemeId, 'macchiato');
      expect(ScheduleColorThemeCatalog.defaultThemeId, 'macchiato');
      expect(
        ScheduleColorThemeCatalog.defaultColorPool,
        ScheduleColorThemeCatalog.macchiatoAccents,
      );
    });

    test('should resolve built-in, custom and unknown theme ids', () {
      final custom = ScheduleColorTheme(
        name: 'Custom',
        colors: const <Color>[Color(0xFF112233)],
      );
      final customThemes = <String, ScheduleColorTheme>{'custom:1': custom};

      expect(
        ScheduleColorThemeCatalog.resolvePool(
          themeId: 'latte',
          customThemes: customThemes,
        ),
        ScheduleColorThemeCatalog.latteAccents,
      );
      expect(
        ScheduleColorThemeCatalog.resolvePool(
          themeId: 'custom:1',
          customThemes: customThemes,
        ),
        custom.colors,
      );
      expect(
        ScheduleColorThemeCatalog.resolvePool(
          themeId: 'custom:missing',
          customThemes: customThemes,
        ),
        ScheduleColorThemeCatalog.macchiatoAccents,
      );
      expect(
        ScheduleColorThemeCatalog.resolvePool(
          themeId: '',
          customThemes: customThemes,
        ),
        ScheduleColorThemeCatalog.macchiatoAccents,
      );
    });

    test('should resolve display names', () {
      final custom = ScheduleColorTheme(
        name: '我的主题',
        colors: const <Color>[Color(0xFF112233)],
      );
      final customThemes = <String, ScheduleColorTheme>{'custom:1': custom};

      expect(ScheduleColorThemeCatalog.nameFor('latte', customThemes), 'Latte');
      expect(
        ScheduleColorThemeCatalog.nameFor('macchiato', customThemes),
        'Macchiato',
      );
      expect(
        ScheduleColorThemeCatalog.nameFor('custom:1', customThemes),
        '我的主题',
      );
      expect(
        ScheduleColorThemeCatalog.nameFor('custom:missing', customThemes),
        'custom:missing',
      );
    });

    test('should reserve only the remaining built-in names', () {
      expect(ScheduleColorThemeCatalog.isReservedName('latte'), isTrue);
      expect(ScheduleColorThemeCatalog.isReservedName('LATTE'), isTrue);
      expect(ScheduleColorThemeCatalog.isReservedName('Macchiato'), isTrue);
      expect(ScheduleColorThemeCatalog.isReservedName('MACCHIATO'), isTrue);
      expect(ScheduleColorThemeCatalog.isReservedName('Frappé'), isFalse);
      expect(ScheduleColorThemeCatalog.isReservedName('mocha'), isFalse);
      expect(ScheduleColorThemeCatalog.isReservedName('我的主题'), isFalse);
      expect(ScheduleColorThemeCatalog.isReservedName(''), isFalse);
    });
  });

  group('ScheduleColorTheme', () {
    test('should compare by name and colors', () {
      final first = ScheduleColorTheme(
        name: 'A',
        colors: const <Color>[Color(0xFF112233), Color(0xFF445566)],
      );
      final second = ScheduleColorTheme(
        name: 'A',
        colors: const <Color>[Color(0xFF112233), Color(0xFF445566)],
      );
      final differentName = ScheduleColorTheme(
        name: 'B',
        colors: const <Color>[Color(0xFF112233), Color(0xFF445566)],
      );
      final differentColors = ScheduleColorTheme(
        name: 'A',
        colors: const <Color>[Color(0xFF112233)],
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first, isNot(differentName));
      expect(first, isNot(differentColors));
    });

    test('should expose an unmodifiable color list', () {
      final theme = ScheduleColorTheme(
        name: 'A',
        colors: const <Color>[Color(0xFF112233)],
      );

      expect(
        () => theme.colors.add(const Color(0xFF000000)),
        throwsUnsupportedError,
      );
    });
  });
}
