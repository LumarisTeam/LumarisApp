import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/ui/components/app_action_sheet.dart';
import 'package:material_ui/material_ui.dart';

Widget _host(void Function(String?) onResult) {
  return MaterialApp(
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: CupertinoButton(
            onPressed: () async {
              final result = await showAppActionSheet<String>(
                context: context,
                title: '选择操作',
                message: '请选择一个选项',
                cancelLabel: '取消',
                items: const [
                  AppActionSheetItem(value: 'refresh', label: '刷新数据'),
                  AppActionSheetItem(
                    value: 'change',
                    label: '更换房间',
                    isSelected: true,
                  ),
                ],
              );
              onResult(result);
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
}

Future<void> _openSheet(
  WidgetTester tester,
  void Function(String?) onResult,
) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(_host(onResult));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the title, options and cancel row', (tester) async {
    await _openSheet(tester, (_) {});

    expect(tester.takeException(), isNull);
    expect(find.text('选择操作'), findsOneWidget);
    expect(find.text('请选择一个选项'), findsOneWidget);
    expect(find.text('刷新数据'), findsOneWidget);
    expect(find.text('更换房间'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);
  });

  testWidgets('returns the value of the tapped option', (tester) async {
    String? result;
    await _openSheet(tester, (value) => result = value);

    await tester.tap(find.text('刷新数据'));
    await tester.pumpAndSettle();

    expect(result, 'refresh');
    expect(find.text('选择操作'), findsNothing);
  });

  testWidgets('returns null when cancelled', (tester) async {
    var called = false;
    String? result = 'unchanged';
    await _openSheet(tester, (value) {
      called = true;
      result = value;
    });

    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    expect(called, isTrue);
    expect(result, isNull);
  });
}
