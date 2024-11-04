import 'package:audiflow/common/ui/error_notifier.dart';
import 'package:audiflow/common/ui/fill_remaining_error.dart';
import 'package:audiflow/common/ui/fill_remaining_loading.dart';
import 'package:audiflow/features/browser/chart/ui/podcast_list_horizontal.dart';
import 'package:audiflow/features/browser/common/data/podcast_subscriptions.dart';
import 'package:audiflow/features/browser/common/ui/basic_app_bar.dart';
import 'package:audiflow/features/browser/podcast/ui/podcast_list.dart';
import 'package:audiflow/localization/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';

class SubscribedPodcastsPage extends HookConsumerWidget {
  const SubscribedPodcastsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(podcastSubscriptionsProvider);
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
                BasicAppBar(title: L10n.of(context).subscriptions),
                if (state.isLoading)
                  const FillRemainingLoading()
                else if (state.hasError)
                  FillRemainingError.podcastNoResults()
                else
                  PodcastList(podcasts: state.value!),
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
    return state.valueOrNull?.isNotEmpty == true
        ? PodcastListHorizontal(podcasts: state.value!)
        : const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}
