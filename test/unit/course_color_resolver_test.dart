import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:ios_club_app/core/services/course_color_manager.dart';
import 'package:ios_club_app/core/services/schedule_color_resolver.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/state/schedule_color_themes.dart';

void main() {
  group('ScheduleColorResolver', () {
    test('should restore the legacy Lumaris course color algorithm', () {
      final course = CourseModel(
        courseName: '高等数学',
        weekIndexes: const [1],
        teachers: const [],
        room: '',
        weekday: 1,
        startUnit: 1,
        endUnit: 2,
      );
      final actual = ScheduleColorResolver.colorForCourse(
        course,
        ScheduleColorThemeCatalog.lumarisPreviewColors,
        const <String, Color>{},
        themeId: ScheduleColorThemeCatalog.lumarisId,
      );
      expect(actual, CourseColorManager.generateSoftColor(course.courseName));
    });
    test('stableHash should be stable for the same input', () {
      expect(
        ScheduleColorResolver.stableHash('高等数学'),
        ScheduleColorResolver.stableHash('高等数学'),
      );
      expect(
        ScheduleColorResolver.stableHash('高等数学'),
        isNot(ScheduleColorResolver.stableHash('大学英语')),
      );
    });

    test('colorFor should map the same course to the same pool slot', () {
      const pool = <Color>[
        Color(0xFFFFCC99),
        Color(0xFFFFE699),
        Color(0xFFE6FF99),
      ];
      final first = ScheduleColorResolver.colorFor('高等数学', pool);
      final second = ScheduleColorResolver.colorFor('高等数学', pool);

      expect(first, second);
      expect(pool, contains(first));
      expect(
        first,
        pool[ScheduleColorResolver.stableHash('高等数学') % pool.length],
      );
    });

    test('colorFor should use the first slot for an empty course name', () {
      const pool = <Color>[Color(0xFFFFCC99), Color(0xFF663300)];

      expect(ScheduleColorResolver.colorFor('   ', pool), pool.first);
    });

    test(
      'colorFor should fall back to the legacy hash color for an empty pool',
      () {
        final resolved = ScheduleColorResolver.colorFor('高等数学', const []);
        final legacy = CourseColorManager.generateSoftColor('高等数学');

        expect(resolved, legacy);
      },
    );

    test('autoContrast should pick dark text on light backgrounds', () {
      expect(
        ScheduleColorResolver.autoContrast(const Color(0xFFFFCC99)),
        McColors.light.foreground,
      );
    });

    test('autoContrast should pick white text on dark backgrounds', () {
      expect(
        ScheduleColorResolver.autoContrast(const Color(0xFF663300)),
        McColors.dark.foreground,
      );
    });

    test(
      'should use white text when course backgrounds have medium lightness',
      () {
        const backgrounds = <Color>[
          Color(0xFF70BF70),
          Color(0xFFC0C070),
          Color(0xFFBA70AF),
          Color(0xFFA7C370),
        ];

        for (final Color background in backgrounds) {
          expect(
            ScheduleColorResolver.autoContrast(background),
            McColors.dark.foreground,
            reason: 'Medium-lightness course background: $background',
          );
        }
      },
    );

    test('should use black text when any Macchiato accent is selected', () {
      for (final Color background
          in ScheduleColorThemeCatalog.macchiatoAccents) {
        expect(
          ScheduleColorResolver.autoContrast(background),
          McColors.light.foreground,
          reason: 'Macchiato background: $background',
        );
      }
    });

    test('should use white text when any Latte accent is selected', () {
      for (final Color background in ScheduleColorThemeCatalog.latteAccents) {
        expect(
          ScheduleColorResolver.autoContrast(background),
          McColors.dark.foreground,
          reason: 'Latte background: $background',
        );
      }
    });

    test('should use white text when actual Lumaris colors are generated', () {
      for (final String courseName in ['高等数学', '大学英语', '计算机组成原理']) {
        final Color background = ScheduleColorResolver.colorForCourse(
          CourseModel(courseName: courseName),
          ScheduleColorThemeCatalog.lumarisPreviewColors,
          const <String, Color>{},
          themeId: ScheduleColorThemeCatalog.lumarisId,
        );
        expect(
          ScheduleColorResolver.autoContrast(background),
          McColors.dark.foreground,
        );
      }
    });

    test('courseKey should prefer a non-empty lessonId', () {
      expect(
        ScheduleColorResolver.courseKey(
          lessonId: '12345',
          courseName: '高等数学A1',
        ),
        'id:12345',
      );
      expect(
        ScheduleColorResolver.courseKey(
          lessonId: '  12345  ',
          courseName: '高等数学A1',
        ),
        'id:12345',
      );
    });

    test('courseKey should fall back to the normalized name', () {
      expect(
        ScheduleColorResolver.courseKey(
          lessonId: '   ',
          courseName: '  高等数学   A1 ',
        ),
        'name:高等数学 A1',
      );
    });

    test('courseKey should keep id and name keys from colliding', () {
      expect(
        ScheduleColorResolver.courseKey(lessonId: '高等数学', courseName: '其他'),
        isNot(
          ScheduleColorResolver.courseKey(lessonId: '', courseName: '高等数学'),
        ),
      );
    });

    test('colorForCourse should prefer a matching override', () {
      const overrideColor = Color(0xFF123456);
      final course = CourseModel(courseName: '高等数学A1', lessonId: 'L1');

      expect(
        ScheduleColorResolver.colorForCourse(
          course,
          const <Color>[Color(0xFFFFCC99)],
          const <String, Color>{'id:L1': overrideColor},
        ),
        overrideColor,
      );
    });

    test('colorForCourse should fall back to the hashed pool color', () {
      const pool = <Color>[Color(0xFFFFCC99), Color(0xFF663300)];
      final course = CourseModel(courseName: '高等数学A1', lessonId: 'L1');

      expect(
        ScheduleColorResolver.colorForCourse(
          course,
          pool,
          const <String, Color>{},
        ),
        ScheduleColorResolver.colorFor('高等数学A1', pool),
      );
    });

    test(
      'colorForCourse should share an override across the same lessonId',
      () {
        const overrideColor = Color(0xFF123456);
        final monday = CourseModel(
          courseName: '高等数学A1',
          lessonId: 'L1',
          weekday: 1,
          startUnit: 1,
        );
        final wednesday = CourseModel(
          courseName: '高等数学A1',
          lessonId: 'L1',
          weekday: 3,
          startUnit: 5,
        );
        const pool = <Color>[Color(0xFFFFCC99), Color(0xFF663300)];
        const overrides = <String, Color>{'id:L1': overrideColor};

        expect(
          ScheduleColorResolver.colorForCourse(monday, pool, overrides),
          overrideColor,
        );
        expect(
          ScheduleColorResolver.colorForCourse(wednesday, pool, overrides),
          overrideColor,
        );
      },
    );

    test('colorForCourse should share an override across empty-id courses '
        'with the same name', () {
      const overrideColor = Color(0xFF123456);
      final first = CourseModel(courseName: '大学英语');
      final second = CourseModel(courseName: ' 大学英语 ');
      const pool = <Color>[Color(0xFFFFCC99), Color(0xFF663300)];
      const overrides = <String, Color>{'name:大学英语': overrideColor};

      expect(
        ScheduleColorResolver.colorForCourse(first, pool, overrides),
        overrideColor,
      );
      expect(
        ScheduleColorResolver.colorForCourse(second, pool, overrides),
        overrideColor,
      );
    });
  });
}
