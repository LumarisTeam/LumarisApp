import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import 'package:smooth_corner/smooth_corner.dart';

Widget _wrap(Widget child, {ThemeMode themeMode = ThemeMode.light}) {
  return MaterialApp(
    themeMode: themeMode,
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('should_render_title_subtitle_and_full_layout', (tester) async {
    await tester.pumpWidget(
      _wrap(const LoadingStateView(title: '正在同步教务数据', subtitle: '网络较慢时可能需要几秒')),
    );

    expect(find.text('正在同步教务数据'), findsOneWidget);
    expect(find.text('网络较慢时可能需要几秒'), findsOneWidget);
    expect(find.byKey(const ValueKey('loading_full')), findsOneWidget);
  });

  testWidgets('should_build_in_light_and_dark_themes', (tester) async {
    await tester.pumpWidget(
      _wrap(const LoadingStateView(title: '正在加载课表', subtitle: '正在读取课程和偏好设置')),
    );
    expect(find.text('正在加载课表'), findsOneWidget);

    await tester.pumpWidget(
      _wrap(
        const LoadingStateView(title: '正在加载课表', subtitle: '正在读取课程和偏好设置'),
        themeMode: ThemeMode.dark,
      ),
    );
    expect(find.text('正在加载课表'), findsOneWidget);
  });

  testWidgets('should_keep_text_in_compact_card_layout', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 320,
          child: LoadingStateView(
            title: '正在刷新用电趋势',
            subtitle: '正在读取最新电费记录',
            compact: true,
            showCard: true,
          ),
        ),
      ),
    );

    expect(find.text('正在刷新用电趋势'), findsOneWidget);
    expect(find.text('正在读取最新电费记录'), findsOneWidget);
    expect(find.byKey(const ValueKey('loading_compact')), findsOneWidget);
    expect(find.byType(SmoothClipRRect), findsOneWidget);
  });
}
