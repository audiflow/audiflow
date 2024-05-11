import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/events/podcast_chart_event.dart';
import 'package:audiflow/gen/l10n/l10n.dart';
import 'package:audiflow/ui/pages/app_bars/basic_app_bar.dart';
import 'package:audiflow/ui/podcast/chart_item_list.dart';
// import 'package:audiflow/ui/podcast/podcast_list_horz.dart';
import 'package:audiflow/ui/providers/podcast_chart_provider.dart';
import 'package:audiflow/ui/providers/podcast_subscriptions_provider.dart';
import 'package:audiflow/ui/widgets/error_notifier.dart';
import 'package:audiflow/ui/widgets/fill_remaining_error.dart';
import 'package:audiflow/ui/widgets/fill_remaining_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';

/// This widget renders the search bar and allows the user to search for
/// podcasts.
class PodcastHomePage extends HookConsumerWidget {
  const PodcastHomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(podcastChartProvider);

    useEffect(
      () {
        ref.read(podcastChartProvider.notifier).input(
            const NewPodcastChartEvent(size: 50, country: Country.japan));
        return null;
      },
      [],
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
                BasicAppBar(title: L10n.of(context).home),
                const _SubscribedPodcasts(),
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
                    sliver: ChartItemList(items: state.value!.chartItems),
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

class _SubscribedPodcasts extends ConsumerWidget {
  const _SubscribedPodcasts();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(podcastSubscriptionsProvider);
    return
        // state.valueOrNull?.isNotEmpty == true
        //   ? PodcastListHorz(metadataList: state.value!)
        //   :
        const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}
