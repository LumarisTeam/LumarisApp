import 'dart:io';

import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:material_ui/material_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ios_club_app/core/repositories/course_repository.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/state/course_store.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/ui/pages/schedule_list_page/schedule_setting_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 测试环境没有安全存储插件，不装 handler 的话密码那一次读取会一直挂着，
/// _initData 也就走不到加载课程那一步。
const _secureStorageChannel = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);

CourseModel _course(String lessonId, String courseName) => CourseModel(
  lessonId: lessonId,
  courseName: courseName,
  teachers: const ['张老师'],
  room: 'A101',
  weekIndexes: const [1, 2, 3],
  weekday: 1,
  startUnit: 1,
  endUnit: 2,
);

void main() {
  late Directory tempDir;
  late ProviderContainer container;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await PrefsService.init();
  });

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorageChannel, (call) async => null);
    await PrefsService.instance.remove(PrefsKeys.IGNORE_DATA);

    tempDir = await Directory.systemTemp.createTemp('schedule_setting_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CourseModelAdapter());
    }
    await CourseRepository().saveCourses([
      _course('L1', '高等数学'),
      _course('L2', '大学英语'),
    ]);

    container = ProviderContainer();
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorageChannel, null);
    container.dispose();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: McThemeData.materialTheme(McColors.light),
          home: const ScheduleSettingPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// 忽略课程在页面底部，800x600 的测试视口里要先滚进可视区才点得到。
  Future<void> tapCourse(WidgetTester tester, String courseName) async {
    final finder = find.text(courseName);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('should_ignore_course_when_toggled_on', (tester) async {
    await pumpPage(tester);

    expect(find.text('高等数学'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.checkmark_square_fill), findsNothing);

    await tapCourse(tester, '高等数学');

    expect(container.read(courseStoreProvider).ignoreCourses, ['高等数学']);
    expect(find.byIcon(CupertinoIcons.checkmark_square_fill), findsOneWidget);
  });

  testWidgets('should_persist_ignored_course', (tester) async {
    await pumpPage(tester);

    await tapCourse(tester, '高等数学');

    expect(
      PrefsService.instance.getString(PrefsKeys.IGNORE_DATA),
      '{"data":["高等数学"]}',
    );
  });

  testWidgets('should_restore_ignored_course_when_toggled_off', (tester) async {
    await pumpPage(tester);

    await tapCourse(tester, '高等数学');
    await tapCourse(tester, '高等数学');

    expect(container.read(courseStoreProvider).ignoreCourses, isEmpty);
    expect(find.byIcon(CupertinoIcons.checkmark_square_fill), findsNothing);
    expect(
      PrefsService.instance.getString(PrefsKeys.IGNORE_DATA),
      '{"data":[]}',
    );
  });

  testWidgets('should_toggle_each_course_independently', (tester) async {
    await pumpPage(tester);

    await tapCourse(tester, '高等数学');
    await tapCourse(tester, '大学英语');

    expect(container.read(courseStoreProvider).ignoreCourses, ['高等数学', '大学英语']);
    expect(find.byIcon(CupertinoIcons.checkmark_square_fill), findsNWidgets(2));
  });
}
