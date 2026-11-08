import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:material_ui/material_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/state/school_store.dart';
import 'package:ios_club_app/state/tile_edit_notifier.dart';
import 'package:ios_club_app/ui/components/empty_widget.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';

/// Maps tile identifiers to their localized display names.
String _tileDisplayName(String tileId, AppLocalizations l10n) {
  switch (tileId) {
    case '电费':
      return l10n.electricity;
    case '校车':
      return l10n.schoolBus;
    case '饭卡':
      return l10n.payment;
    default:
      return tileId;
  }
}

/// Controls for entering and exiting tile edit mode
class TileEditControls extends ConsumerWidget {
  const TileEditControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isEditMode = ref.watch(
      tileEditControllerProvider.select((value) => value.isEditMode),
    );
    final controller = ref.read(tileEditControllerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          Text(
            l10n.shortcuts,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),

          // Edit/Done button
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isEditMode
                ? _buildDoneButton(context, controller)
                : _buildEditButton(context, controller),
          ),
        ],
      ),
    );
  }

  /// Build edit button
  Widget _buildEditButton(BuildContext context, TileEditNotifier controller) {
    final l10n = context.l10n;
    final colors = context.mc.colors;

    return TextButton.icon(
      key: const ValueKey('edit_button'),
      onPressed: () => controller.toggleEditMode(),
      icon: const Icon(CupertinoIcons.pencil, size: 18),
      label: Text(l10n.edit),
      style: TextButton.styleFrom(
        foregroundColor: colors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  /// Build done button
  Widget _buildDoneButton(BuildContext context, TileEditNotifier controller) {
    final l10n = context.l10n;
    final colors = context.mc.colors;

    return ElevatedButton.icon(
      key: const ValueKey('done_button'),
      onPressed: () => controller.toggleEditMode(),
      icon: const Icon(CupertinoIcons.checkmark, size: 18),
      label: Text(l10n.done),
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onAccent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        elevation: 2,
      ),
    );
  }
}

/// Visual indicator for edit mode (optional overlay)
class EditModeIndicator extends ConsumerWidget {
  final Widget child;

  const EditModeIndicator({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditMode = ref.watch(
      tileEditControllerProvider.select((value) => value.isEditMode),
    );
    final colors = context.mc.colors;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: ShapeDecoration(
        shape: McSmoothCorners.shape(
          McRadii.controlBorder,
          side: isEditMode
              ? BorderSide(
                  color: colors.primary.withValues(alpha: 0.3),
                  width: 2,
                )
              : BorderSide.none,
        ),
      ),
      child: child,
    );
  }
}

/// Empty state message when all tiles are hidden
class EmptyTilesMessage extends StatelessWidget {
  const EmptyTilesMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return McCard.elevated(
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.zero,
      child: EmptyWidget(
        title: l10n.noShortcuts,
        icon: CupertinoIcons.square_grid_2x2,
        subtitle: l10n.addInEditMode,
      ),
    );
  }
}

/// Available tiles list for edit mode (shows hidden tiles)
class AvailableTilesList extends ConsumerWidget {
  const AvailableTilesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tileEditState = ref.watch(tileEditControllerProvider);
    final controller = ref.read(tileEditControllerProvider.notifier);
    final school = ref.watch(schoolStoreProvider).school;
    final allTiles = tileEditState.config.configurations;
    final hiddenTiles = allTiles
        .where((t) => !t.isVisible && _isTileSupported(t.id, school))
        .toList();
    final colors = context.mc.colors;

    if (hiddenTiles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0, top: 16.0),
            child: Text(
              context.l10n.moreFunctions,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
          ),
          McCard.elevated(
            padding: EdgeInsets.zero,
            child: Column(
              children: hiddenTiles.map((tile) {
                final tileId = tile.id;
                return McListTile(
                  leading: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.success,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.add,
                      color: colors.onAccent,
                      size: 16,
                    ),
                  ),
                  title: Text(
                    _tileDisplayName(tileId, context.l10n),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () => controller.toggleVisibility(tileId),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

bool _isTileSupported(String tileId, School? school) {
  if (school == null) return true;
  final feature = switch (tileId) {
    '电费' => Feature.electricity,
    '校车' => Feature.busSchedule,
    '饭卡' => Feature.payment,
    _ => null,
  };
  if (feature == null) return true;
  return school.supports(feature);
}
