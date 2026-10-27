import 'dart:ui';
import 'package:material_ui/material_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/state/user_store.dart';
import 'package:ios_club_app/ui/components/empty_widget.dart';
import 'package:latlong2/latlong.dart';
import 'package:ios_club_app/state/map_notifier.dart';
import 'package:ios_club_app/state/map_state.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/state/school_store.dart';
import '../../../core/services/external_navigation_service.dart';
import '../../../core/utils/platform_utils.dart';
import 'map_compass_button.dart';
import 'navigation_app_picker.dart';

class CampusMapPage extends ConsumerStatefulWidget {
  const CampusMapPage({super.key});

  @override
  ConsumerState<CampusMapPage> createState() => _CampusMapPageState();
}

class _CampusMapPageState extends ConsumerState<CampusMapPage>
    with SingleTickerProviderStateMixin {
  static const double _minMapZoom = 4.0;
  static const double _maxMapZoom = 19.0;
  static const int _maxNativeTileZoom = 18;

  /// 与 MainApp 保持一致：窗口宽度超过该值时按平板布局处理，
  /// 此时没有底部导航栏兜底，地图需要自己提供返回键。
  static const double _tabletMinWindowWidth = 600.0;

  static const Duration _northResetMinDuration = Duration(milliseconds: 220);
  static const Duration _northResetMaxDuration = Duration(milliseconds: 480);

  late final MapController _mapController;
  late final TextEditingController _searchController;
  late final AnimationController _northResetAnimation;
  final ValueNotifier<double> _mapRotation = ValueNotifier<double>(0);
  double _northResetFrom = 0;
  double _northResetDelta = 0;
  CampusPOI? _selectedPOI;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  bool _isSidebarOpen = true;
  bool _isOpeningNavigation = false;
  final ExternalNavigationService _navigation = ExternalNavigationService();

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _searchController = TextEditingController();
    _northResetAnimation = AnimationController(
      vsync: this,
      duration: _northResetMinDuration,
    )..addListener(_onNorthResetAnimationTick);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mapNotifierProvider.notifier).checkLocationPermission();
      ref.read(mapNotifierProvider.notifier).fetchCampusPOIs();
    });
  }

  @override
  void dispose() {
    _northResetAnimation.dispose();
    _mapRotation.dispose();
    _mapController.dispose();
    _searchController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  void _moveToLocation(LatLng loc, {double zoom = 17.5}) {
    _mapController.move(loc, zoom.clamp(_minMapZoom, _maxMapZoom));
    HapticFeedback.lightImpact();
  }

  void _zoomBy(double delta) {
    final nextZoom = (_mapController.camera.zoom + delta).clamp(
      _minMapZoom,
      _maxMapZoom,
    );
    _mapController.move(_mapController.camera.center, nextZoom);
    HapticFeedback.lightImpact();
  }

  /// Keeps the on-screen compass in sync with the camera rotation.
  ///
  /// User gestures cancel an in-flight "reset to north" animation so that the
  /// map never fights the user's fingers.
  void _onMapEvent(MapEvent event) {
    final rotation = normalizeMapRotation(event.camera.rotation);
    final changed = (rotation - _mapRotation.value).abs() > 0.001;
    if (_northResetAnimation.isAnimating &&
        changed &&
        event.source != MapEventSource.mapController) {
      _northResetAnimation.stop();
    }
    if (!changed) return;
    _mapRotation.value = rotation;
  }

  void _onNorthResetAnimationTick() {
    final eased = Curves.easeOutCubic.transform(_northResetAnimation.value);
    _mapController.rotate(_northResetFrom + _northResetDelta * eased);
  }

  /// Rotates the map back so that north is up, along the shortest path.
  void _resetNorth() {
    HapticFeedback.lightImpact();
    final from = _mapRotation.value;
    final delta = shortestRotationToNorth(from);
    if (delta.abs() < 0.5) return;
    _northResetFrom = from;
    _northResetDelta = delta;
    final milliseconds = (220 + delta.abs() * 1.6).round().clamp(
      _northResetMinDuration.inMilliseconds,
      _northResetMaxDuration.inMilliseconds,
    );
    _northResetAnimation.duration = Duration(milliseconds: milliseconds);
    _northResetAnimation.forward(from: 0);
  }

  void _onPOITap(CampusPOI poi) {
    setState(() {
      _selectedPOI = poi;
    });
    _moveToLocation(poi.position);
    if (_sheetController.isAttached) {
      _sheetController.animateTo(
        0.35,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
    HapticFeedback.mediumImpact();
  }

  /// 返回地图入口页。
  ///
  /// 地图通常由个人中心以 push 方式打开，直接 pop 即可；若是深链直达、
  /// 没有可回退的页面，则退回地图入口所在的分支，避免用户被困在页面里。
  void _handleBack() {
    HapticFeedback.lightImpact();
    if (AppRouter.router.canPop()) {
      AppRouter.pop();
      return;
    }
    AppRouter.go(AppRoutes.profile);
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapNotifierProvider);
    final colors = context.mc.colors;
    final padding = MediaQuery.of(context).padding;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isLogin = ref.watch(userStoreProvider).isLogin;
    final school = ref.watch(schoolStoreProvider).school;
    final canMap = school?.supports(Feature.map) ?? true;

    if (school != null && !canMap) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.schoolBus)),
        body: Center(child: Text(context.l10n.schoolNotSupported)),
      );
    }

    if (!isLogin) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.schoolBus)),
        body: EmptyWidget(
          title: context.l10n.guestMode,
          subtitle: context.l10n.guestModeSubtitle,
          icon: Icons.lock_outline,
        ),
      );
    }

    // Listen for location changes to auto-center once
    ref.listen(mapNotifierProvider.select((s) => s.currentLocation), (
      previous,
      next,
    ) {
      if (previous == null && next != null) {
        _moveToLocation(next);
      }
    });

    final filteredPOIs = mapState.searchQuery.isEmpty
        ? mapState.campusPOIs
        : mapState.campusPOIs
              .where(
                (poi) =>
                    poi.name.toLowerCase().contains(
                      mapState.searchQuery.toLowerCase(),
                    ) ||
                    poi.description.toLowerCase().contains(
                      mapState.searchQuery.toLowerCase(),
                    ),
              )
              .toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          final effectiveSidebarOpen = isWide && _isSidebarOpen;
          // 平板窗口没有底部导航栏兜底，无论侧边栏展开还是收起都要有返回键。
          final showBackButton =
              isWide ||
              MediaQuery.sizeOf(context).width > _tabletMinWindowWidth;

          return Stack(
            children: [
              // 1. Map Layer (Now always full screen)
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: mapState.campusPOIs.isNotEmpty
                      ? mapState.campusPOIs.first.position
                      : const LatLng(34.2312, 108.9632),
                  initialZoom: 16.0,
                  maxZoom: _maxMapZoom,
                  onMapEvent: _onMapEvent,
                  onTap: (_, _) {
                    setState(() => _selectedPOI = null);
                    if (_sheetController.isAttached) {
                      _sheetController.animateTo(
                        0.0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeIn,
                      );
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://webrd0{s}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}',
                    subdomains: const ['1', '2', '3', '4'],
                    maxZoom: _maxMapZoom,
                    maxNativeZoom: _maxNativeTileZoom,
                    tileBuilder: isDarkMode
                        ? (context, tileWidget, tile) {
                            return ColorFiltered(
                              colorFilter: const ColorFilter.matrix(<double>[
                                -1, 0, 0, 0, 255, // R
                                0, -1, 0, 0, 255, // G
                                0, 0, -1, 0, 255, // B
                                0, 0, 0, 1, 0, // A
                              ]),
                              child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  colors.primary.withValues(alpha: 0.05),
                                  BlendMode.colorBurn,
                                ),
                                child: tileWidget,
                              ),
                            );
                          }
                        : null,
                  ),
                  MarkerLayer(
                    markers: [
                      ...filteredPOIs.map(
                        (poi) => Marker(
                          point: poi.position,
                          width: 120,
                          height: 60,
                          child: GestureDetector(
                            onTap: () => _onPOITap(poi),
                            child: _buildPOIMarker(
                              poi,
                              colors,
                              _selectedPOI == poi,
                            ),
                          ),
                        ),
                      ),
                      if (mapState.currentLocation != null)
                        Marker(
                          point: mapState.currentLocation!,
                          width: 60,
                          height: 60,
                          child: _buildMyLocationMarker(colors),
                        ),
                    ],
                  ),
                ],
              ),

              // 2. Search & Categories Panel (Top - Mobile Only)
              if (!isWide)
                Positioned(
                  top: padding.top + 12,
                  left: 16,
                  right: 16,
                  child: _buildFloatingTopPanel(
                    mapState,
                    colors,
                    filteredPOIs,
                    showBackButton: showBackButton,
                  ),
                ),

              // 3. Wide Screen Sidebar (Animated Floating)
              if (isWide)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                  top: padding.top + 20,
                  left: effectiveSidebarOpen ? 20 : -320,
                  bottom: 20,
                  width: 320,
                  child: _buildSidebar(mapState, colors, filteredPOIs),
                ),

              // 4. Top-left Floating Controls (Wide Screen Only)
              //    返回键跟随侧边栏折叠按钮一起移动，保证始终可见。
              if (isWide)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                  top: padding.top + 20,
                  left: effectiveSidebarOpen ? 350 : 20,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildBackButton(colors),
                      const SizedBox(width: 8),
                      _buildSidebarToggle(colors),
                    ],
                  ),
                ),

              // 5. Map Controls (Right)
              Positioned(
                bottom: isWide ? 40 : 120,
                right: 16,
                child: _buildMapControls(mapState, colors),
              ),

              // 6. Bottom Sheet (Mobile)
              if (!isWide) _buildPOIBottomSheet(colors),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackButton(McColors colors) {
    return _buildFloatingIconButton(
      colors: colors,
      icon: Icons.arrow_back_rounded,
      tooltip: context.l10n.back,
      onPressed: _handleBack,
    );
  }

  Widget _buildSidebarToggle(McColors colors) {
    return _buildFloatingIconButton(
      colors: colors,
      icon: _isSidebarOpen
          ? Icons.chevron_left_rounded
          : Icons.menu_open_rounded,
      tooltip: _isSidebarOpen
          ? context.l10n.collapseSidebar
          : context.l10n.expandSidebar,
      onPressed: _toggleSidebar,
    );
  }

  /// 地图上统一风格的悬浮圆形按钮（半透明毛玻璃）。
  Widget _buildFloatingIconButton({
    required McColors colors,
    required IconData icon,
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    final radius = BorderRadius.circular(20);
    return Container(
      decoration: ShapeDecoration(
        color: colors.cardOverlay,
        shape: McSmoothCorners.shape(
          radius,
          side: BorderSide(
            color: colors.separator.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
      ),
      child: McSmoothCorners.clip(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: IconButton(
            icon: Icon(icon, color: colors.label),
            tooltip: tooltip,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }

  Widget _buildPOIMarker(CampusPOI poi, McColors colors, bool isSelected) {
    final radius = BorderRadius.circular(20);
    return AnimatedScale(
      scale: isSelected ? 1.2 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: ShapeDecoration(
              color: isSelected ? colors.primary : colors.cardBackground,
              shape: McSmoothCorners.shape(
                radius,
                side: BorderSide(
                  color: isSelected
                      ? colors.onAccent
                      : colors.separator.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              shadows: [
                BoxShadow(
                  color: colors.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              poi.name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? colors.onAccent : colors.label,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Icon(
            Icons.location_on_rounded,
            color: isSelected
                ? colors.primary
                : colors.primary.withValues(alpha: 0.7),
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildMyLocationMarker(McColors colors) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: colors.onAccent,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingTopPanel(
    MapState mapState,
    McColors colors,
    List<CampusPOI> filteredPOIs, {
    required bool showBackButton,
  }) {
    final l10n = context.l10n;
    return Column(
      children: [
        McSmoothCorners.clip(
          borderRadius: McRadii.cardBorder,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: ShapeDecoration(
                color: colors.cardOverlay,
                shape: McSmoothCorners.shape(
                  McRadii.cardBorder,
                  side: BorderSide(
                    color: colors.separator.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (showBackButton) ...[
                    IconButton(
                      tooltip: l10n.back,
                      onPressed: _handleBack,
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: colors.label,
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 36,
                        height: 36,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    Container(
                      width: 1,
                      height: 20,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: colors.separator.withValues(alpha: 0.2),
                    ),
                  ],
                  Icon(Icons.search_rounded, color: colors.secondaryLabel),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        ref
                            .read(mapNotifierProvider.notifier)
                            .updateSearchQuery(value);
                      },
                      style: TextStyle(color: colors.label, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: l10n.searchLocation,
                        hintStyle: TextStyle(
                          color: colors.tertiaryLabel,
                          fontSize: 16,
                        ),
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        suffixIcon: mapState.searchQuery.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  ref
                                      .read(mapNotifierProvider.notifier)
                                      .updateSearchQuery('');
                                },
                                child: Icon(
                                  Icons.clear_rounded,
                                  color: colors.secondaryLabel,
                                  size: 18,
                                ),
                              )
                            : null,
                        suffixIconConstraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.map_rounded,
                      color: colors.primary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: filteredPOIs.map((poi) {
              final isSelected = _selectedPOI == poi;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(poi.name),
                  selected: isSelected,
                  onSelected: (_) => _onPOITap(poi),
                  backgroundColor: colors.cardOverlay,
                  selectedColor: colors.primarySoft,
                  labelStyle: TextStyle(
                    color: isSelected ? colors.primary : colors.label,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                  shape: McSmoothCorners.shape(
                    BorderRadius.circular(100),
                    side: BorderSide(
                      color: isSelected
                          ? colors.primary
                          : colors.separator.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  showCheckmark: false,
                  elevation: 0,
                  pressElevation: 0,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMapControls(MapState mapState, McColors colors) {
    final controlRadius = BorderRadius.circular(12);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Compass / reset-north control
        ValueListenableBuilder<double>(
          valueListenable: _mapRotation,
          builder: (context, rotation, _) => MapCompassButton(
            rotation: rotation,
            tooltip: context.l10n.resetNorth,
            onResetNorth: _resetNorth,
          ),
        ),
        const SizedBox(height: 12),
        // Zoom Controls
        McSmoothCorners.clip(
          borderRadius: controlRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 44,
              decoration: ShapeDecoration(
                color: colors.cardOverlay,
                shape: McSmoothCorners.shape(
                  controlRadius,
                  side: BorderSide(
                    color: colors.separator.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildControlItem(
                    icon: Icons.add_rounded,
                    onTap: () => _zoomBy(1),
                    colors: colors,
                  ),
                  Divider(
                    height: 1,
                    color: colors.separator.withValues(alpha: 0.1),
                  ),
                  _buildControlItem(
                    icon: Icons.remove_rounded,
                    onTap: () => _zoomBy(-1),
                    colors: colors,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Location Control
        McSmoothCorners.clip(
          borderRadius: controlRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 44,
              height: 44,
              decoration: ShapeDecoration(
                color: colors.cardOverlay,
                shape: McSmoothCorners.shape(
                  controlRadius,
                  side: BorderSide(
                    color: colors.separator.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                ),
              ),
              child: _buildControlItem(
                icon: mapState.isLoadingLocation
                    ? Icons.hourglass_empty_rounded
                    : Icons.my_location_rounded,
                onTap: () {
                  if (mapState.currentLocation != null) {
                    _moveToLocation(mapState.currentLocation!);
                  } else {
                    ref
                        .read(mapNotifierProvider.notifier)
                        .checkLocationPermission(openSettingsOnFailure: true);
                  }
                },
                colors: colors,
                iconColor: mapState.currentLocation != null
                    ? colors.primary
                    : colors.label,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlItem({
    required IconData icon,
    required VoidCallback onTap,
    required McColors colors,
    Color? iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: iconColor ?? colors.secondaryLabel,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(
    MapState mapState,
    McColors colors,
    List<CampusPOI> filteredPOIs,
  ) {
    final l10n = context.l10n;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return McSmoothCorners.clip(
      borderRadius: McRadii.cardBorder,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: ShapeDecoration(
            color: isDarkMode
                ? colors.cardBackground.withValues(alpha: 0.8)
                : colors.cardOverlay.withValues(alpha: 0.7),
            shape: McSmoothCorners.shape(
              McRadii.cardBorder,
              side: BorderSide(
                color: colors.separator.withValues(alpha: 0.15),
                width: 0.8,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: ShapeDecoration(
                        color: colors.surfaceRaised,
                        shape: McSmoothCorners.shape(BorderRadius.circular(12)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: colors.secondaryLabel,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                ref
                                    .read(mapNotifierProvider.notifier)
                                    .updateSearchQuery(value);
                              },
                              style: TextStyle(
                                color: colors.label,
                                fontSize: 15,
                              ),
                              decoration: InputDecoration(
                                hintText: l10n.search,
                                hintStyle: TextStyle(
                                  color: colors.secondaryLabel,
                                  fontSize: 15,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                suffixIcon: mapState.searchQuery.isNotEmpty
                                    ? GestureDetector(
                                        onTap: () {
                                          _searchController.clear();
                                          ref
                                              .read(
                                                mapNotifierProvider.notifier,
                                              )
                                              .updateSearchQuery('');
                                        },
                                        child: Icon(
                                          Icons.clear_rounded,
                                          color: colors.secondaryLabel,
                                          size: 18,
                                        ),
                                      )
                                    : null,
                                suffixIconConstraints: const BoxConstraints(
                                  minWidth: 24,
                                  minHeight: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(
                  height: 1,
                  color: colors.separator.withValues(alpha: 0.2),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: filteredPOIs.length,
                  separatorBuilder: (_, _) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Divider(
                      height: 1,
                      color: colors.separator.withValues(alpha: 0.1),
                    ),
                  ),
                  itemBuilder: (context, index) {
                    final poi = filteredPOIs[index];
                    final isSelected = _selectedPOI == poi;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 4,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.primary
                              : colors.primarySoft.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          color: isSelected ? colors.onAccent : colors.primary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        poi.name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: isSelected ? colors.primary : colors.label,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          poi.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.secondaryLabel,
                          ),
                        ),
                      ),
                      trailing: isSelected
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: l10n.startWalkingNavigation,
                                  onPressed: _isOpeningNavigation
                                      ? null
                                      : () => _openNavigation(destination: poi),
                                  icon: const Icon(Icons.directions_walk),
                                ),
                                IconButton(
                                  tooltip: l10n.otherNavigationMaps,
                                  onPressed: _isOpeningNavigation
                                      ? null
                                      : () => _openNavigation(
                                          destination: poi,
                                          chooseApp: true,
                                        ),
                                  icon: const Icon(Icons.more_horiz),
                                ),
                              ],
                            )
                          : null,
                      onTap: () => _onPOITap(poi),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openNavigation({
    bool chooseApp = false,
    CampusPOI? destination,
  }) async {
    final CampusPOI? poi = destination ?? _selectedPOI;
    if (poi == null || _isOpeningNavigation) return;
    setState(() => _isOpeningNavigation = true);
    try {
      final List<ExternalMap> maps = await _navigation.availableMaps();
      ExternalMap? selected = await _navigation.preferredMap();
      if (!maps.contains(selected)) selected = null;
      if (!mounted) return;
      if (maps.isEmpty) {
        selected = PlatformUtils.isIOS ? ExternalMap.apple : ExternalMap.baidu;
      } else if (chooseApp ||
          (selected == null &&
              maps.length > 1 &&
              !(PlatformUtils.isIOS && maps.contains(ExternalMap.apple)))) {
        selected = await showModalBottomSheet<ExternalMap>(
          context: context,
          builder: (sheetContext) => NavigationAppPicker(maps: maps),
        );
        if (selected == null) return;
      } else {
        selected ??= maps.first;
      }
      if (!mounted) return;
      final bool opened = await _navigation.open(
        map: selected,
        latitude: poi.position.latitude,
        longitude: poi.position.longitude,
        name: poi.name,
        webOnly: maps.isEmpty,
      );
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.navigationLaunchFailed)),
        );
      }
    } catch (error) {
      debugPrint('CampusMapPage: navigation failed for ${poi.name}: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.navigationLaunchFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _isOpeningNavigation = false);
    }
  }

  Widget _buildPOIBottomSheet(McColors colors) {
    final l10n = context.l10n;
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0,
      minChildSize: 0,
      maxChildSize: 0.6,
      snap: true,
      builder: (context, scrollController) {
        // DraggableScrollableSheet requires the provided controller to stay
        // attached. Without it, its controller may report isAttached while
        // animateTo still fails because there is no ScrollPosition.
        if (_selectedPOI == null) {
          return ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
          );
        }

        return Container(
          decoration: ShapeDecoration(
            color: colors.cardBackground,
            shape: McSmoothCorners.shape(
              const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            shadows: [
              BoxShadow(
                color: colors.shadowColor.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 5,
                  decoration: ShapeDecoration(
                    color: colors.separator.withValues(alpha: 0.3),
                    shape: McSmoothCorners.shape(BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      _selectedPOI!.name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colors.label,
                      ),
                    ),
                  ),
                  IconButton.filled(
                    onPressed: _isOpeningNavigation
                        ? null
                        : () => _openNavigation(),
                    tooltip: l10n.startWalkingNavigation,
                    icon: const Icon(Icons.directions_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onAccent,
                    ),
                  ),
                ],
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: _isOpeningNavigation
                      ? null
                      : () => _openNavigation(chooseApp: true),
                  child: Text(l10n.otherNavigationMaps),
                ),
              ),
              const SizedBox(height: 24),
              _buildInfoSection(
                title: l10n.buildingIntro,
                content: _selectedPOI!.description,
                icon: Icons.info_outline_rounded,
                colors: colors,
              ),
              const SizedBox(height: 16),
              _buildInfoSection(
                title: l10n.specificLocation,
                content:
                    '${_selectedPOI!.position.latitude.toStringAsFixed(6)}, ${_selectedPOI!.position.longitude.toStringAsFixed(6)}',
                icon: Icons.map_outlined,
                colors: colors,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoSection({
    required String title,
    required String content,
    required IconData icon,
    required McColors colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: colors.surfaceRaised,
        shape: McSmoothCorners.shape(BorderRadius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: colors.secondaryLabel),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colors.secondaryLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(fontSize: 15, height: 1.5, color: colors.label),
          ),
        ],
      ),
    );
  }
}
