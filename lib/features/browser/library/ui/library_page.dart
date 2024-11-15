import 'package:audiflow/common/ui/error_notifier.dart';
import 'package:audiflow/features/browser/common/ui/basic_app_bar.dart';
import 'package:audiflow/localization/generated/l10n.dart';
import 'package:audiflow/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';

class LibraryPage extends HookConsumerWidget {
  const LibraryPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useScrollController();
    final l10n = L10n.of(context);
    return ScrollsToTop(
      onScrollsToTop: (event) async {
        await controller.animateTo(
          event.to,
          duration: event.duration,
          curve: event.curve,
        );
      },
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              controller: controller,
              slivers: <Widget>[
                BasicAppBar(title: l10n.library),
                SliverFixedExtentList(
                  itemExtent: 60,
                  delegate: SliverChildListDelegate(
                    [
                      ListTile(
                        leading: const Icon(Symbols.fiber_new),
                        title: Text(l10n.latestEpisodes),
                        trailing: const Icon(Symbols.chevron_right),
                        onTap: () {},
                        // ref.read(appRouterProvider).pushLatestEpisodes,
                      ),
                      ListTile(
                        leading: const Icon(Symbols.podcasts),
                        title: Text(l10n.subscriptions),
                        trailing: const Icon(Symbols.chevron_right),
                        onTap: () => ref
                            .read(appRouterProvider.notifier)
                            .pushSubscribedPodcasts(),
                      ),
                      ListTile(
                        leading: const Icon(Symbols.history),
                        title: Text(l10n.recentlyPlayed),
                        trailing: const Icon(Symbols.chevron_right),
                        onTap: () {},
                        // onTap: ref.read(appRouterProvider).pushRecentlyPlayed,
                      ),
                      ListTile(
                        leading: const Icon(Symbols.download_for_offline),
                        title: Text(l10n.downloadedEpisodes),
                        trailing: const Icon(Symbols.chevron_right),
                        onTap: () {},
                        // ref.read(appRouterProvider).pushLatestEpisodes,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const ErrorNotifier(),
          ],
        ),
      ),
    );
  }
}
