import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';

/// Modal 内部布局组件库
///
/// 提供统一的 Modal 内部布局设计风格，采用简约的苹果风格设计
///
/// 使用示例：
/// ```dart
/// showMcBottomSheet(
///   context: context,
///   contentPadding: const EdgeInsets.all(20),
///   builder: (context) => Column(
///     mainAxisSize: MainAxisSize.min,
///     crossAxisAlignment: CrossAxisAlignment.start,
///     children: [
///       ModalHeader(
///         title: '详细信息',
///         subtitle: '可选的副标题',
///         actions: ModalActionMenu(
///           onEdit: () => AppLogger.debug('编辑'),
///           onDelete: () => AppLogger.debug('删除'),
///         ),
///       ),
///       ModalInfoRow(
///         icon: CupertinoIcons.location_solid,
///         label: '地点',
///         content: '教学楼A101',
///         color: const Color(0xFF007AFF),
///       ),
///       const ModalSpacing(),
///       ModalInfoRow(
///         icon: CupertinoIcons.person_fill,
///         label: '负责人',
///         content: '张三',
///         color: const Color(0xFFFF3B30),
///       ),
///     ],
///   ),
/// );
/// ```

/// Modal 标题栏组件
///
/// 简约的苹果风格标题栏，支持可选的操作菜单
class ModalHeader extends StatelessWidget {
  const ModalHeader({
    super.key,
    required this.title,
    this.actions,
    this.subtitle,
  });

  final String title;
  final Widget? actions;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.mc.colors;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isTablet ? 24 : 22,
                      fontWeight: FontWeight.w700,
                      color: colors.label,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 13,
                        color: colors.secondaryLabel,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ?actions,
          ],
        ),
        SizedBox(height: isTablet ? 24 : 20),
      ],
    );
  }
}

/// Modal 信息行组件
///
/// 带图标、标签和内容的信息展示行，采用苹果风格设计
class ModalInfoRow extends StatelessWidget {
  const ModalInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.content,
    required this.color,
    this.maxLines,
  });

  final IconData icon;
  final String label;
  final String content;
  final Color color;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final colors = context.mc.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 图标容器
        Container(
          width: 36,
          height: 36,
          decoration: ShapeDecoration(
            color: color.withValues(alpha: 0.12),
            shape: McSmoothCorners.shape(McRadii.controlBorder),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 14),
        // 文本内容
        Expanded(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.secondaryLabel,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.label,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: maxLines,
                  overflow: maxLines != null ? TextOverflow.ellipsis : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Modal 操作菜单组件
///
/// 提供编辑、删除等操作的弹出菜单
class ModalActionMenu extends StatelessWidget {
  const ModalActionMenu({
    super.key,
    this.onEdit,
    this.onDelete,
    this.customActions,
  });

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final List<McPopoverMenuItem<String>>? customActions;

  @override
  Widget build(BuildContext context) {
    final List<McPopoverMenuItem<String>> items = <McPopoverMenuItem<String>>[
      if (onEdit != null)
        McPopoverMenuItem<String>(
          value: 'edit',
          label: context.l10n.edit,
          icon: CupertinoIcons.pencil,
        ),
      if (onDelete != null)
        McPopoverMenuItem<String>(
          value: 'delete',
          label: context.l10n.delete,
          icon: CupertinoIcons.delete,
          isDestructive: true,
        ),
      ...?customActions,
    ];

    return McPopoverMenu<String>(
      items: items,
      showCheckmark: false,
      onSelected: (String value) {
        Navigator.of(context).pop();
        if (value == 'edit' && onEdit != null) {
          onEdit!();
        } else if (value == 'delete' && onDelete != null) {
          onDelete!();
        }
      },
      child: SizedBox(
        width: 40,
        height: 40,
        child: Icon(
          CupertinoIcons.ellipsis_circle,
          size: 19,
          color: context.mc.secondaryLabel,
        ),
      ),
    );
  }
}

/// Modal 间距组件
///
/// 提供统一的响应式间距，根据屏幕尺寸自动调整
class ModalSpacing extends StatelessWidget {
  const ModalSpacing({super.key, this.small = false});

  final bool small;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    if (small) {
      return SizedBox(height: isTablet ? 12 : 10);
    }
    return SizedBox(height: isTablet ? 16 : 14);
  }
}
