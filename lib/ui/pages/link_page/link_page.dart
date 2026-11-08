import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/page_app_bar.dart';
import '../../../core/extensions/localization_extensions.dart';
import '../../../features/education/apis/link_api.dart';
import '../../../features/education/models/link_model.dart';
import '../../../state/user_store.dart';
import '../../components/loading_state_view.dart';

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
    _linksFuture = LinkApi.getLinks();
  }

  void _refreshLinks() {
    setState(() {
      _linksFuture = LinkApi.getLinks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLogin = ref.watch(userStoreProvider).isLogin;

    return Scaffold(
      appBar: PageAppBar(
        title: l10n.campusNavigation,
        actions: [
          if (isLogin)
            IconButton(
              onPressed: _refreshLinks,
              icon: const Icon(CupertinoIcons.arrow_clockwise),
              tooltip: l10n.refreshData,
            ),
        ],
      ),
      body: !isLogin
          ? _LinkMessage(
              title: l10n.guestMode,
              subtitle: l10n.guestModeSubtitle,
            )
          : FutureBuilder<List<CategoryModel>>(
              future: _linksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return LoadingStateView(
                    title: l10n.linkLoading,
                    subtitle: l10n.linkLoadingSubtitle,
                  );
                }
                if (snapshot.hasError) {
                  return _LinkMessage(
                    title: l10n.loadFailed,
                    subtitle: '${snapshot.error}',
                  );
                }
                final categories = snapshot.data ?? [];
                if (categories.isEmpty) {
                  return _LinkMessage(
                    title: l10n.linkNoData,
                    subtitle: l10n.linkNoDataSubtitle,
                  );
                }
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                      itemCount: categories.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 28),
                        child: ScoreBuilder(categoryList: categories[index]),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _LinkMessage extends StatelessWidget {
  const _LinkMessage({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.mc.colors.secondaryLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ScoreBuilder extends StatelessWidget {
  final CategoryModel categoryList;

  const ScoreBuilder({super.key, required this.categoryList});

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.mc.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Text(
            categoryList.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.secondaryLabel,
            ),
          ),
        ),
        if (categoryList.links.isNotEmpty)
          McCard.grouped(
            radius: 24,
            child: Column(
              children: [
                for (
                  var index = 0;
                  index < categoryList.links.length;
                  index++
                ) ...[
                  if (index > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(
                        height: 1,
                        thickness: 0.5,
                        color: colors.separator,
                      ),
                    ),
                  _LinkItem(
                    link: categoryList.links[index],
                    onTap: () => _launchURL(categoryList.links[index].url),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _LinkItem extends StatelessWidget {
  const _LinkItem({required this.link, required this.onTap});

  final LinkModel link;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return McListTile(
      onTap: onTap,
      borderRadius: BorderRadius.zero,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 19),
      titleTextStyle: TextStyle(fontSize: 17, color: context.mc.primary),
      title: Text(link.name),
      trailing: const Icon(CupertinoIcons.arrow_right, size: 20),
    );
  }
}
