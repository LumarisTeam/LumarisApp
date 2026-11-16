import 'package:flutter/widget_previews.dart';

import 'package:material_ui/material_ui.dart';

import '../../../features/education/models/lesson_search_item.dart';
import '../../../l10n/app_localizations.dart';
import '../../theme/app_theme_color.dart';
import 'lesson_search_view.dart';

@Preview(name: '全校开课查询', size: Size(390, 740))
Widget lessonSearchPreview() => MaterialApp(
  locale: const Locale('zh'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    ...GlobalMaterialLocalizations.delegates,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  theme: AppThemeColor.blue.materialTheme(Brightness.light),
  darkTheme: AppThemeColor.blue.materialTheme(Brightness.dark),
  home: const Scaffold(
    body: SafeArea(
      child: LessonSearchView(
        lessons: [
          LessonSearchItem(
            courseCode: 'MATH1001',
            courseName: '高等数学 A（一）',
            sectionCode: '01',
            sectionName: '高等数学 A（一）01 班',
            teacher: '王宁',
            timeText: '周一第 1–2 节、周三第 3–4 节',
            location: '草堂校区 · 教学楼 1-203',
            semesterName: '2026–2027 学年第一学期',
            capacity: 64,
            selectedCount: 56,
            remaining: 8,
          ),
          LessonSearchItem(
            courseCode: 'CS2001',
            courseName: '数据结构',
            sectionCode: '02',
            sectionName: '数据结构 02 班',
            teacher: '刘洋',
            timeText: '周二第 1–2 节、周四第 3–4 节',
            location: '草堂校区 · 教学楼 2-206',
            semesterName: '2026–2027 学年第一学期',
            capacity: 60,
            selectedCount: 60,
            remaining: 0,
          ),
        ],
      ),
    ),
  ),
);
