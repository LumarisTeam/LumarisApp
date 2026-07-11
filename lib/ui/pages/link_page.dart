import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/features/education/application/education_providers.dart';
import 'package:ios_club_app/state/user_store.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:ios_club_app/ui/components/empty_widget.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import 'package:ios_club_app/ui/theme/club_smooth_corners.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ios_club_app/features/education/models/link_model.dart';
import 'package:ios_club_app/ui/components/club_app_bar.dart';
import 'package:ios_club_app/ui/components/icon_font.dart';

class LinkPage extends ConsumerStatefulWidget {
  const LinkPage({super.key});

  @override
  ConsumerState<LinkPage> createState() => _LinkPageState();
}

class _LinkPageState extends ConsumerState<LinkPage> {
  late Future<List<CategoryModel>> _linksFuture;

  @override
  void initState() {
    super.initState();
    _linksFuture = _loadLinks();
  }

  Future<List<CategoryModel>> _loadLinks() async {
    final result = await ref.read(linkRepositoryProvider).getLinks();
    if (!result.isSuccess) throw result.error;
    return result.data;
  }

  void _refreshLinks() {
    setState(() {
      _linksFuture = _loadLinks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.clubColors;
    final isLogin = ref.watch(userStoreProvider).isLogin;

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

    return Scaffold(
      appBar: ClubAppBar(
        title: l10n.campusNavigation,
        actions: [
          IconButton(
            onPressed: _refreshLinks,
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refreshData,
          ),
        ],
      ),
      body: FutureBuilder(
        future: _linksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.loadFailed,
                      style: TextStyle(
                        fontSize: 16,
                        color: colors.secondaryLabel,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${snapshot.error}",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return EmptyWidget(
                  title: l10n.linkNoData,
                  subtitle: l10n.linkNoDataSubtitle,
                  icon: Icons.link);
            } else {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final categoryList = snapshot.data![index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: ScoreBuilder(
                      categoryList: categoryList,
                    ),
                  );
                },
              );
            }
          } else {
            return Center(
              child: LoadingStateView(
                title: l10n.linkLoading,
                subtitle: l10n.linkLoadingSubtitle,
              ),
            );
          }
        },
      ),
    );
  }
}

class ScoreBuilder extends StatelessWidget {
  final CategoryModel categoryList;

  const ScoreBuilder({super.key, required this.categoryList});

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.clubColors;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return ClubCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 分类标题
            Container(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: ShapeDecoration(
                      color: colors.indigo,
                      shape: ClubSmoothCorners.shape(ClubRadii.indicatorBorder),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    categoryList.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // 链接网格
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 6 : 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categoryList.links.length,
              itemBuilder: (context, index) {
                final linkList = categoryList.links[index];
                return _LinkItem(
                  link: linkList,
                  onTap: () => _launchURL(linkList.url),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// 单独的链接项组件
class _LinkItem extends StatelessWidget {
  final LinkModel link;
  final VoidCallback onTap;

  const _LinkItem({
    required this.link,
    required this.onTap,
  });

  Widget _buildIconPlaceholder(BuildContext context) {
    final colors = context.clubColors;
    return Container(
      width: 44,
      height: 44,
      decoration: ShapeDecoration(
        color: colors.surfaceRaised,
        shape: ClubSmoothCorners.shape(ClubRadii.control),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.link_rounded,
        size: 20,
        color: colors.secondaryLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.clubColors;
    return Material(
      color: Colors.transparent,
      shape: ClubSmoothCorners.shape(ClubRadii.navigation),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: ClubRadii.navigation,
        customBorder: ClubSmoothCorners.shape(ClubRadii.navigation),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 图标
              FutureBuilder<Widget>(
                future: IconUtil.getIconFont(link),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return snapshot.data!;
                  }

                  return _buildIconPlaceholder(context);
                },
              ),
              const SizedBox(height: 8),
              // 名称
              Text(
                link.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.2,
                  color: colors.tertiaryLabel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
