import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:material_ui/material_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/state/bus_tile_store.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';

class BusTile extends ConsumerWidget {
  const BusTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final busStore = ref.watch(busTileStoreProvider);
    final colors = context.mc.colors;

    return McCard.elevated(
      radius: McRadii.tile,
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => AppRouter.push(AppRoutes.schoolBus),
          borderRadius: McRadii.tileBorder,
          customBorder: McSmoothCorners.shape(McRadii.tileBorder),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Builder(
              builder: (context) {
                if (busStore.isLoading) {
                  return Center(
                    child: LoadingStateView(
                      title: l10n.busLoading,
                      subtitle: '',
                      compact: true,
                      padding: EdgeInsets.zero,
                    ),
                  );
                }

                final busData = busStore.busCount;
                final primaryColor = colors.success;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.bus,
                            color: primaryColor,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      l10n.schoolBus,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colors.secondaryLabel,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      busData > 0 ? '$busData' : l10n.noBusToday,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: busData > 0
                            ? colors.label
                            : colors.secondaryLabel,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
