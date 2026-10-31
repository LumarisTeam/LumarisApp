import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:ios_club_app/state/tile_edit_notifier.dart';
import 'package:ios_club_app/ui/components/tiles/tile_edit_controls.dart';
import 'package:ios_club_app/ui/components/tiles/editable_tile_wrapper.dart';

import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/state/school_store.dart';
import 'package:ios_club_app/ui/components/tiles/bus_tile.dart';
import 'package:ios_club_app/ui/components/tiles/electricity_tile.dart';
import 'package:ios_club_app/ui/components/tiles/payment_tile.dart';

class TilesWidget extends ConsumerStatefulWidget {
  const TilesWidget({super.key});

  @override
  ConsumerState<TilesWidget> createState() => _TilesWidgetState();
}

class _TilesWidgetState extends ConsumerState<TilesWidget>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  late final TileEditNotifier _tileEditController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tileEditController = ref.read(tileEditControllerProvider.notifier);
    // Listen to app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _tileEditController.forceExitEditMode();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Handle app going to background
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (ref.read(tileEditControllerProvider).isEditMode) {
        // Save changes when app goes to background
        _tileEditController.forceExitEditMode();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final tileEditState = ref.watch(tileEditControllerProvider);
    final controller = ref.read(tileEditControllerProvider.notifier);
    final school = ref.watch(schoolStoreProvider).school;
    final visibleTiles = tileEditState.config
        .getVisibleTiles()
        .where((t) => _isTileSupported(t.id, school))
        .toList();
    final isEditMode = tileEditState.isEditMode;

    return Column(
      children: [
        // Edit controls (replaces old title)
        const TileEditControls(),

        // Show available tiles list in edit mode
        if (isEditMode) const AvailableTilesList(),

        // Tiles grid or empty state
        if (visibleTiles.isEmpty)
          const EmptyTilesMessage()
        else if (isEditMode)
          _buildReorderableGrid(visibleTiles, controller, isTablet)
        else
          _buildNormalGrid(visibleTiles, isTablet),
      ],
    );
  }

  /// Build reorderable grid for full Flutter platforms
  Widget _buildReorderableGrid(
    List visibleTiles,
    TileEditNotifier controller,
    bool isTablet,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = isTablet ? 3 : 2;
          return SizedBox(
            height: _gridHeight(
              itemCount: visibleTiles.length,
              crossAxisCount: crossAxisCount,
              width: constraints.maxWidth,
            ),
            child: ReorderableGridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                childAspectRatio: 1.0,
              ),
              itemCount: visibleTiles.length,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: (oldIndex, newIndex) async {
                final l10n = context.l10n;
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await controller.reorderTile(
                    visibleTiles[oldIndex].id,
                    oldIndex,
                    newIndex,
                  );
                } catch (e) {
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('${l10n.reorderFailed}: $e'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              itemBuilder: (context, index) {
                final tile = visibleTiles[index];
                return EditableTileWrapper(
                  key: ValueKey(tile.id),
                  tileId: tile.id,
                  index: index,
                  child: buildTile(tile.id, context),
                );
              },
            ),
          );
        },
      ),
    );
  }

  double _gridHeight({
    required int itemCount,
    required int crossAxisCount,
    required double width,
  }) {
    const spacing = 16.0;
    final rows = (itemCount / crossAxisCount).ceil();
    if (rows == 0) {
      return 0;
    }
    final itemWidth = (width - spacing * (crossAxisCount - 1)) / crossAxisCount;
    return rows * itemWidth + spacing * (rows - 1);
  }

  /// Build normal grid (non-edit mode)
  Widget _buildNormalGrid(List visibleTiles, bool isTablet) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = isTablet ? 3 : 2;
          return SizedBox(
            height: _gridHeight(
              itemCount: visibleTiles.length,
              crossAxisCount: crossAxisCount,
              width: constraints.maxWidth,
            ),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                childAspectRatio: 1.0,
              ),
              itemCount: visibleTiles.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final tile = visibleTiles[index];
                return McAnimatedCard(
                  key: ValueKey(tile.id),
                  delay: Duration(milliseconds: 100 * index),
                  child: buildTile(tile.id, context),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

Widget buildTile(String tile, BuildContext context) {
  Widget? content;

  if (tile == '电费') {
    content = const ElectricityTile();
  }

  if (tile == '校车') {
    content = const BusTile();
  }

  if (tile == '饭卡') {
    content = const PaymentTile();
  }

  content ??= Container();

  return content;
}

Feature? _tileFeature(String tileId) {
  switch (tileId) {
    case '电费':
      return Feature.electricity;
    case '校车':
      return Feature.busSchedule;
    case '饭卡':
      return Feature.payment;
    default:
      return null;
  }
}

bool _isTileSupported(String tileId, School? school) {
  if (school == null) return true;
  final feature = _tileFeature(tileId);
  if (feature == null) return true;
  return school.supports(feature);
}
