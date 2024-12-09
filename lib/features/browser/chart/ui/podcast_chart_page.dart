import 'package:audiflow/common/ui/error_notifier.dart';
import 'package:audiflow/common/ui/fill_remaining_error.dart';
import 'package:audiflow/common/ui/fill_remaining_loading.dart';
import 'package:audiflow/constants/country.dart';
import 'package:audiflow/features/browser/chart/ui/podcast_chart_controller.dart';
import 'package:audiflow/features/browser/common/ui/basic_app_bar.dart';
import 'package:audiflow/features/browser/common/ui/chart_item_list.dart';
import 'package:audiflow/localization/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';

class PodcastChartPage extends HookConsumerWidget {
  const PodcastChartPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      podcastChartControllerProvider(size: 50, country: Country.japan),
    );
    final controller = useScrollController();

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
                BasicAppBar(title: L10n.of(context).browse),
                // Podcast in chart
                if (state.isLoading)
                  const FillRemainingLoading()
                else if (state.hasError)
                  FillRemainingError.podcastNoResults()
                else ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40, left: 20),
                      child: Text(
                        L10n.of(context).popularPodcasts,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 30),
                    sliver: ITunesItemList(items: state.value!.chartItems),
                  ),
                ],
              ],
            ),
            const ErrorNotifier(),
          ],
        ),
      ),
    );
  }
}
