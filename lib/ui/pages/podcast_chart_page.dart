// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seasoning/events/podcast_chart_event.dart';
import 'package:seasoning/providers/podcast/podcast_chart_provider.dart';
import 'package:seasoning/providers/podcast/podcast_subscriptions_provider.dart';
import 'package:seasoning/ui/podcast/podcast_list.dart';
import 'package:seasoning/ui/podcast/podcast_list_horz.dart';
import 'package:seasoning/ui/widgets/basic_app_bar.dart';
import 'package:seasoning/ui/widgets/fill_remaining_error.dart';
import 'package:seasoning/ui/widgets/fill_remaining_loading.dart';

/// This widget renders the search bar and allows the user to search for
/// podcasts.
class PodcastChartPage extends HookConsumerWidget {
  const PodcastChartPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(
      () {
        ref
            .read(podcastChartProvider.notifier)
            .input(const NewPodcastChartEvent(size: 10, countryCode: 'jp'));
        return null;
      },
      [],
    );

    final state = ref.watch(podcastChartProvider);
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          BasicAppBar.chart(),
          const _SubscribedPodcasts(),
          if (state.hasValue)
            PodcastList(results: state.value!.podcasts)
          else if (state.hasError)
            FillRemainingError.podcastNoResults()
          else
            const FillRemainingLoading(),
        ],
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
        ? PodcastListHorz(summaries: state.value!.map((e) => e.$1).toList())
        : const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}
