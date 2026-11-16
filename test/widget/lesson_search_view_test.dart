import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoSearchTextField;
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/ui/pages/lesson_search_page/lesson_search_preview.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets(
    'should narrow and restore results when searching by code and teacher',
    (WidgetTester tester) async {
      await tester.pumpWidget(lessonSearchPreview());
      await tester.pumpAndSettle();

      expect(find.text('共 2 个教学班'), findsOneWidget);
      final Finder field = find.byType(CupertinoSearchTextField);
      await tester.enterText(field, 'math1001 王宁');
      await tester.pumpAndSettle();
      expect(find.text('共 1 个教学班'), findsOneWidget);
      expect(find.text('数据结构'), findsNothing);

      await tester.enterText(field, '不存在的课程');
      await tester.pumpAndSettle();
      expect(find.text('没有符合条件的教学班'), findsOneWidget);
      await tester.tap(find.text('清除条件'));
      await tester.pumpAndSettle();
      expect(find.text('共 2 个教学班'), findsOneWidget);
    },
  );

  testWidgets(
    'should apply availability only when confirmed and open section details',
    (WidgetTester tester) async {
      await tester.pumpWidget(lessonSearchPreview());
      await tester.pumpAndSettle();

      await tester.tap(find.text('筛选'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SwitchListTile));
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
      expect(find.text('共 2 个教学班'), findsOneWidget);

      await tester.tap(find.text('筛选'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SwitchListTile));
      await tester.tap(find.text('应用筛选'));
      await tester.pumpAndSettle();
      expect(find.text('共 1 个教学班'), findsOneWidget);
      expect(find.text('已满'), findsNothing);

      await tester.tap(find.text('高等数学 A（一）'));
      await tester.pumpAndSettle();
      expect(find.text('草堂校区 · 教学楼 1-203'), findsOneWidget);
      expect(find.text('64 人'), findsOneWidget);
      expect(find.text('56 人'), findsOneWidget);
    },
  );
}
