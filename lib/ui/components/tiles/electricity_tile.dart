import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import 'package:ios_club_app/ui/theme/club_smooth_corners.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import '../club_card.dart';
import '../../../state/electricity_store.dart';

class ElectricityTile extends ConsumerWidget {
  const ElectricityTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final electricity = ref.watch(electricityStoreProvider);
    final colors = context.clubColors;

    return ClubCard(
      borderRadius: ClubRadii.tile,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => AppRouter.push(AppRoutes.electricity),
          borderRadius: ClubRadii.tile,
          customBorder: ClubSmoothCorners.shape(ClubRadii.tile),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Builder(builder: (context) {
              // Loading state
              if (electricity.isLoading) {
                return Center(
                  child: LoadingStateView(
                    title: l10n.electricityLoading,
                    subtitle: '',
                    compact: true,
                    padding: EdgeInsets.zero,
                  ),
                );
              }

              // Has Data state
              if (electricity.hasData) {
                final amount = electricity.electricity;
                final isLow = amount <= 10;
                final primaryColor = isLow ? colors.danger : colors.primary;

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
                            CupertinoIcons.bolt_fill,
                            color: primaryColor,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      l10n.electricityBalance,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colors.secondaryLabel,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '¥${amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: isLow ? colors.danger : colors.label,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              }

              // Unsubscribed state
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.surfaceMuted,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.bolt_fill,
                      color: colors.secondaryLabel,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    l10n.electricity,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colors.secondaryLabel,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    electricity.hasConfiguredSource
                        ? l10n.electricityNoData
                        : l10n.tapToSubscribe,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: colors.secondaryLabel,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
