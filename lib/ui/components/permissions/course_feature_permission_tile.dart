import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:permission_handler/permission_handler.dart'
    show openAppSettings;
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/core/services/permission_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/features/system/permissions/course_feature_permissions.dart';

/// 设置页中的“课表提醒 / 课程小组件权限”入口。
///
/// 展示功能所需权限的授予状态；点击后先说明用途，再逐个申请缺失的权限。
class CourseFeaturePermissionTile extends StatefulWidget {
  const CourseFeaturePermissionTile({super.key, required this.feature});

  final CourseFeaturePermission feature;

  @override
  State<CourseFeaturePermissionTile> createState() =>
      _CourseFeaturePermissionTileState();
}

class _CourseFeaturePermissionTileState
    extends State<CourseFeaturePermissionTile>
    with WidgetsBindingObserver {
  Map<Permission, PermissionStatus> _statuses = const {};
  bool _loading = true;
  bool _requesting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshStatuses();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 从系统设置页返回时同步最新的授权结果。
    if (state == AppLifecycleState.resumed) {
      _refreshStatuses();
    }
  }

  @override
  void didUpdateWidget(covariant CourseFeaturePermissionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.feature != widget.feature) {
      _loading = true;
      _refreshStatuses();
    }
  }

  Future<void> _refreshStatuses() async {
    final statuses = await CourseFeaturePermissions.load(widget.feature);

    if (!mounted) {
      return;
    }

    setState(() {
      _statuses = statuses;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.mc.colors;
    final isGranted = CourseFeaturePermissions.allGranted(_statuses.values);

    return McListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      leading: Icon(
        widget.feature == CourseFeaturePermission.reminder
            ? CupertinoIcons.alarm_fill
            : CupertinoIcons.square_grid_2x2_fill,
        size: 20,
        color: widget.feature == CourseFeaturePermission.reminder
            ? colors.warning
            : colors.primary,
      ),
      title: Text(_title(context)),
      subtitle: Text(_description(context)),
      trailing: _loading || _requesting
          ? const CupertinoActivityIndicator(radius: 9)
          : _buildStatusBadge(context, isGranted),
      onTap: _loading || _requesting ? null : _onTap,
    );
  }

  Widget _buildStatusBadge(BuildContext context, bool isGranted) {
    if (isGranted) {
      return McBadge.success(child: Text(context.l10n.permissionStatusGranted));
    }

    final grantedCount = CourseFeaturePermissions.grantedCount(
      _statuses.values,
    );
    if (grantedCount > 0) {
      return McBadge.warning(child: Text(context.l10n.permissionStatusLimited));
    }

    return McBadge.warning(child: Text(context.l10n.permissionStatusDenied));
  }

  Future<void> _onTap() async {
    final l10n = context.l10n;
    final title = _title(context);
    final description = _description(context);

    if (CourseFeaturePermissions.allGranted(_statuses.values)) {
      final openSettings = await showMcConfirmDialog(
        context: context,
        title: title,
        message: l10n.permissionGrantedContent,
        confirmText: l10n.permissionActionSettings,
        cancelText: l10n.cancel,
      );

      if (openSettings == true) {
        await openAppSettings();
      }
      return;
    }

    final proceed = await showMcConfirmDialog(
      context: context,
      title: title,
      message: '$description\n\n${l10n.permissionRequiredContent}',
      confirmText: l10n.permissionActionRequest,
      cancelText: l10n.cancel,
    );

    if (proceed != true || !mounted) {
      return;
    }

    setState(() => _requesting = true);

    try {
      final granted = await CourseFeaturePermissions.requestMissing(
        context,
        widget.feature,
      );

      if (!mounted) {
        return;
      }

      await _refreshStatuses();

      if (!mounted) {
        return;
      }

      McFeedback.showMessage(
        context,
        message: granted
            ? l10n.permissionGrantedContent
            : l10n.permissionDeniedContent,
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to request permissions for ${widget.feature}',
        error: error,
        stackTrace: stackTrace,
      );

      if (mounted) {
        McFeedback.showMessage(context, message: l10n.permissionRequestFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _requesting = false);
      }
    }
  }

  String _title(BuildContext context) {
    final l10n = context.l10n;

    return switch (widget.feature) {
      CourseFeaturePermission.reminder => l10n.permissionReminderFeatureTitle,
      CourseFeaturePermission.widget => l10n.permissionWidgetFeatureTitle,
    };
  }

  String _description(BuildContext context) {
    final l10n = context.l10n;

    return switch (widget.feature) {
      CourseFeaturePermission.reminder => l10n.permissionReminderFeatureDesc,
      CourseFeaturePermission.widget => l10n.permissionWidgetFeatureDesc,
    };
  }
}
