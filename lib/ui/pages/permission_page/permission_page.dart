import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';

import '../../components/page_app_bar.dart';

/// 权限管理页：集中展示应用用到的系统权限，并支持申请或跳转系统设置。
class PermissionPage extends StatefulWidget {
  const PermissionPage({super.key, this.isMobileOverride});

  /// 测试可注入的平台标记，为空时使用 [PlatformUtils.isMobile]。
  final bool? isMobileOverride;

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage>
    with WidgetsBindingObserver {
  final Map<Permission, PermissionStatus> _statuses = {};

  bool _loading = true;
  bool _refreshing = false;
  Permission? _requestingPermission;

  bool get _isMobile => widget.isMobileOverride ?? PlatformUtils.isMobile;

  bool get _isAndroid => _isMobile && PlatformUtils.isAndroid;

  bool get _isIOS => _isMobile && PlatformUtils.isIOS;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshStatuses(showLoading: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 从系统设置返回时重新读取，保证授权结果及时同步。
    if (state == AppLifecycleState.resumed) {
      _refreshStatuses();
    }
  }

  List<_PermissionKind> get _kinds => [
    if (_isMobile) _PermissionKind.notification,
    if (_isMobile) _PermissionKind.location,
    if (_isAndroid) _PermissionKind.exactAlarm,
    if (_isAndroid) _PermissionKind.backgroundBattery,
    if (_isIOS) _PermissionKind.backgroundRefresh,
  ];

  Future<void> _refreshStatuses({bool showLoading = false}) async {
    final kinds = _kinds;

    if (mounted) {
      setState(() {
        _refreshing = true;
        if (showLoading) {
          _loading = true;
        }
      });
    }

    final statuses = <Permission, PermissionStatus>{};
    var failed = false;

    for (final kind in kinds) {
      final permission = _permissionOf(kind);
      try {
        statuses[permission] = await permission.status;
      } catch (error, stackTrace) {
        failed = true;
        statuses[permission] = PermissionStatus.denied;
        AppLogger.error(
          'Failed to read permission status for $permission',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _statuses
        ..clear()
        ..addAll(statuses);
      _loading = false;
      _refreshing = false;
    });

    if (failed) {
      McFeedback.showMessage(
        context,
        message: context.l10n.permissionRequestFailed,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final specs = _kinds
        .map((kind) => _buildSpec(context, kind))
        .toList(growable: false);
    final grantedCount = specs
        .where((spec) => _isGranted(_statuses[spec.permission]))
        .length;

    return Scaffold(
      appBar: PageAppBar(
        title: l10n.permissionManagement,
        actions: [
          IconButton(
            onPressed: _refreshing ? null : _refreshStatuses,
            tooltip: l10n.permissionRefresh,
            icon: _refreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CupertinoActivityIndicator(radius: 9),
                  )
                : const Icon(CupertinoIcons.arrow_clockwise),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth > 600 ? 32.0 : 16.0;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (specs.isEmpty)
                      McEmpty.placeholder(
                        icon: CupertinoIcons.checkmark_shield,
                        title: l10n.permissionNotSupported,
                        description: l10n.permissionNotSupportedContent,
                      )
                    else ...[
                      _buildSummaryCard(
                        context,
                        grantedCount: grantedCount,
                        total: specs.length,
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle(context, l10n.permissionSectionTitle),
                      const SizedBox(height: 12),
                      _buildPermissionCard(context, specs),
                      const SizedBox(height: 16),
                      _buildFootnote(context),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  _PermissionSpec _buildSpec(BuildContext context, _PermissionKind kind) {
    final l10n = context.l10n;
    final colors = context.mc.colors;

    return switch (kind) {
      _PermissionKind.notification => _PermissionSpec(
        permission: Permission.notification,
        icon: CupertinoIcons.bell_fill,
        tint: colors.primary,
        title: l10n.permissionNotificationTitle,
        description: l10n.permissionNotificationDesc,
      ),
      _PermissionKind.location => _PermissionSpec(
        permission: Permission.locationWhenInUse,
        icon: CupertinoIcons.location_fill,
        tint: colors.cyan,
        title: l10n.permissionLocationTitle,
        description: l10n.permissionLocationDesc,
      ),
      _PermissionKind.exactAlarm => _PermissionSpec(
        permission: Permission.scheduleExactAlarm,
        icon: CupertinoIcons.alarm_fill,
        tint: colors.warning,
        title: l10n.permissionExactAlarmTitle,
        description: l10n.permissionExactAlarmDesc,
      ),
      _PermissionKind.backgroundBattery => _PermissionSpec(
        permission: Permission.ignoreBatteryOptimizations,
        icon: CupertinoIcons.bolt_fill,
        tint: colors.success,
        title: l10n.permissionBatteryTitle,
        description: l10n.permissionBatteryDesc,
      ),
      _PermissionKind.backgroundRefresh => _PermissionSpec(
        permission: Permission.backgroundRefresh,
        icon: CupertinoIcons.arrow_2_circlepath,
        tint: colors.indigo,
        title: l10n.permissionBackgroundRefreshTitle,
        description: l10n.permissionBackgroundRefreshDesc,
        openSettingsOnly: true,
      ),
    };
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required int grantedCount,
    required int total,
  }) {
    final l10n = context.l10n;
    final colors = context.mc.colors;
    final allGranted = grantedCount == total;

    return McCard.elevated(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: allGranted ? colors.successSoft : colors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              allGranted
                  ? CupertinoIcons.checkmark_shield_fill
                  : CupertinoIcons.checkmark_shield,
              size: 24,
              color: allGranted ? colors.success : colors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allGranted
                      ? l10n.permissionAllGranted
                      : l10n.permissionSummary(grantedCount, total),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: colors.label,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.permissionIntro,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: colors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCard(
    BuildContext context,
    List<_PermissionSpec> specs,
  ) {
    final colors = context.mc.colors;

    return McCard.elevated(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < specs.length; index++) ...[
            if (index > 0)
              Container(
                height: 0.5,
                margin: const EdgeInsets.only(left: 64),
                color: colors.separator,
              ),
            _buildPermissionTile(context, specs[index]),
          ],
        ],
      ),
    );
  }

  Widget _buildPermissionTile(BuildContext context, _PermissionSpec spec) {
    final status = _statuses[spec.permission];
    final requesting = _requestingPermission == spec.permission;

    return McListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: spec.tint.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(spec.icon, size: 18, color: spec.tint),
      ),
      title: Text(spec.title),
      subtitle: Text(spec.description),
      trailing: requesting
          ? const CupertinoActivityIndicator(radius: 9)
          : _buildStatusBadge(context, status),
      onTap: _loading || requesting
          ? null
          : () => _onPermissionTap(spec, status),
    );
  }

  Widget _buildStatusBadge(BuildContext context, PermissionStatus? status) {
    if (status == null) {
      return const CupertinoActivityIndicator(radius: 9);
    }

    final l10n = context.l10n;

    return switch (status) {
      PermissionStatus.granted || PermissionStatus.provisional =>
        McBadge.success(child: Text(l10n.permissionStatusGranted)),
      PermissionStatus.limited => McBadge.warning(
        child: Text(l10n.permissionStatusLimited),
      ),
      PermissionStatus.permanentlyDenied => McBadge.error(
        child: Text(l10n.permissionStatusPermanentlyDenied),
      ),
      PermissionStatus.restricted => McBadge.neutral(
        child: Text(l10n.permissionStatusRestricted),
      ),
      PermissionStatus.denied => McBadge.warning(
        child: Text(l10n.permissionStatusDenied),
      ),
    };
  }

  Future<void> _onPermissionTap(
    _PermissionSpec spec,
    PermissionStatus? status,
  ) async {
    if (status == null || _requestingPermission != null) {
      return;
    }

    final l10n = context.l10n;
    final needsSettings =
        spec.openSettingsOnly ||
        _isGranted(status) ||
        status.isPermanentlyDenied ||
        status.isRestricted;

    if (needsSettings) {
      await _openSettingsPrompt(
        title: spec.title,
        message: _isGranted(status)
            ? l10n.permissionGrantedContent
            : l10n.permissionDeniedContent,
      );
      return;
    }

    // 申请前先说明用途，避免系统弹窗出现时用户不清楚原因。
    final proceed = await showMcConfirmDialog(
      context: context,
      title: spec.title,
      message: '${spec.description}\n\n${l10n.permissionRequiredContent}',
      confirmText: l10n.permissionActionRequest,
      cancelText: l10n.cancel,
    );

    if (proceed != true || !mounted) {
      return;
    }

    setState(() => _requestingPermission = spec.permission);

    PermissionStatus result;
    try {
      result = await spec.permission.request();
    } catch (error, stackTrace) {
      if (!mounted) {
        return;
      }
      setState(() => _requestingPermission = null);
      AppLogger.error(
        'Failed to request permission ${spec.permission}',
        error: error,
        stackTrace: stackTrace,
      );
      McFeedback.showMessage(context, message: l10n.permissionRequestFailed);
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _requestingPermission = null;
      _statuses[spec.permission] = result;
    });

    if (result.isPermanentlyDenied || result.isRestricted) {
      await _openSettingsPrompt(
        title: spec.title,
        message: l10n.permissionDeniedContent,
      );
      return;
    }

    // 有些系统在用户拒绝后不会再弹窗（如 iOS），此时只能引导去设置。
    if (result.isDenied) {
      var canAskAgain = false;
      try {
        canAskAgain = await spec.permission.shouldShowRequestRationale;
      } catch (error, stackTrace) {
        AppLogger.error(
          'Failed to check permission rationale ${spec.permission}',
          error: error,
          stackTrace: stackTrace,
        );
      }

      if (!canAskAgain && mounted) {
        await _openSettingsPrompt(
          title: spec.title,
          message: l10n.permissionDeniedContent,
        );
      }
    }
  }

  Future<void> _openSettingsPrompt({
    required String title,
    required String message,
  }) async {
    final l10n = context.l10n;

    final confirmed = await showMcConfirmDialog(
      context: context,
      title: title,
      message: message,
      confirmText: l10n.permissionActionSettings,
      cancelText: l10n.cancel,
    );

    if (confirmed == true) {
      await openAppSettings();
    }
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colors = context.mc.colors;

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: colors.secondaryLabel,
          ),
        ),
      ),
    );
  }

  Widget _buildFootnote(BuildContext context) {
    final colors = context.mc.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        context.l10n.permissionFootnote,
        style: TextStyle(
          fontSize: 12,
          height: 1.4,
          color: colors.tertiaryLabel,
        ),
      ),
    );
  }
}

bool _isGranted(PermissionStatus? status) {
  return status == PermissionStatus.granted ||
      status == PermissionStatus.limited ||
      status == PermissionStatus.provisional;
}

enum _PermissionKind {
  notification,
  location,
  exactAlarm,
  backgroundBattery,
  backgroundRefresh,
}

Permission _permissionOf(_PermissionKind kind) {
  return switch (kind) {
    _PermissionKind.notification => Permission.notification,
    _PermissionKind.location => Permission.locationWhenInUse,
    _PermissionKind.exactAlarm => Permission.scheduleExactAlarm,
    _PermissionKind.backgroundBattery => Permission.ignoreBatteryOptimizations,
    _PermissionKind.backgroundRefresh => Permission.backgroundRefresh,
  };
}

class _PermissionSpec {
  const _PermissionSpec({
    required this.permission,
    required this.icon,
    required this.tint,
    required this.title,
    required this.description,
    this.openSettingsOnly = false,
  });

  final Permission permission;
  final IconData icon;
  final Color tint;
  final String title;
  final String description;

  /// iOS 后台刷新无法通过系统弹窗申请，只能前往设置手动开启。
  final bool openSettingsOnly;
}
