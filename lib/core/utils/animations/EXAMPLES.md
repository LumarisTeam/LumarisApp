# 动效使用示例

```dart
import 'package:ios_club_app/core/utils/animations/animations.dart';
```

一组内容只选一个入场层：

```dart
AnimatedCard(child: YourSummaryContent())

ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => AnimatedListItem(
    key: ValueKey(items[index].id),
    index: index,
    child: YourListTile(item: items[index]),
  ),
)
```

自定义交互卡片：

```dart
AnimatedInteractiveCard(
  onTap: openDetails,
  child: YourCardContent(),
)
```

自定义操作区域（子内容应为展示组件，已有按钮无需再包装）：

```dart
AnimatedButton(
  onTap: save,
  child: const Padding(
    padding: EdgeInsets.all(12),
    child: Text('保存'),
  ),
)
```

状态加载：

```dart
ShimmerLoading(
  isLoading: isLoading,
  skeleton: const ListItemSkeleton(),
  child: YourLoadedContent(),
)
```

这些组件自动读取系统减少动态效果。自定义状态动画也应响应同一设置：

```dart
AnimatedContainer(
  duration: AppAnimations.reduceMotionOf(context)
      ? Duration.zero
      : AppAnimations.standard,
  curve: AppAnimations.defaultCurve,
  // 其余属性由当前状态决定。
)
```
