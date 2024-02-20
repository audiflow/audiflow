// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seasoning/entities/podcast.dart';
import 'package:seasoning/providers/podcast/podcast_details_provider.dart';
import 'package:seasoning/services/podcast/mobile_podcast_service.dart';
import 'package:seasoning/ui/widgets/delayed_progress_indicator.dart';
import 'package:seasoning/ui/widgets/placeholder_builder.dart';
import 'package:seasoning/ui/widgets/podcast_image.dart';

class PodcastDetailsAppBar extends ConsumerWidget {
  const PodcastDetailsAppBar({
    super.key,
    required this.summary,
    required this.heroPrefix,
  });

  final PodcastSummary summary;
  final String heroPrefix;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final placeholderBuilder = PlaceholderBuilder.of(context);
    final podcastState = ref.watch(podcastDetailsProvider(summary));
    final subscribed = podcastState.value?.stats?.subscribed;

    return SliverLayoutBuilder(
        builder: (BuildContext context, SliverConstraints constraints) {
      return SliverAppBar(
        expandedHeight: 350,
        pinned: true,
        title: AnimatedOpacity(
          opacity: 300 < constraints.scrollOffset ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Text(summary.title),
        ),
        actions: [
          Opacity(
            opacity: podcastState.hasValue ? 1.0 : 0.0,
            child: subscribed == true
                ? IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      ref
                          .read(podcastServiceProvider)
                          .unsubscribe(podcastState.value!.podcast);
                    },
                  )
                : IconButton(
                    icon: const Icon(Icons.bookmark_add),
                    onPressed: () {
                      ref
                          .read(podcastServiceProvider)
                          .subscribe(podcastState.value!.podcast);
                    },
                  ),
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ),
        ],
        flexibleSpace: FlexibleSpaceBar(
          background: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 46),
              Expanded(
                child: Hero(
                  key: Key(
                    'detailHero:${summary.imageUrl}:${summary.guid}',
                  ),
                  tag: '$heroPrefix:${summary.guid}',
                  child: ExcludeSemantics(
                    child: _PodcastHeaderImage(
                      basicInfo: summary,
                      placeholderBuilder: placeholderBuilder,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _PodcastHeaderImage extends StatelessWidget {
  const _PodcastHeaderImage({
    required this.basicInfo,
    required this.placeholderBuilder,
  });

  final PodcastSummary basicInfo;
  final PlaceholderBuilder? placeholderBuilder;

  @override
  Widget build(BuildContext context) {
    if (basicInfo.imageUrl.isEmpty) {
      return const SizedBox(
        height: 560,
        width: 560,
      );
    }

    return PodcastBannerImage(
      key: Key('details${basicInfo.imageUrl}'),
      url: basicInfo.imageUrl,
      fit: BoxFit.contain,
      placeholder: placeholderBuilder != null
          ? placeholderBuilder?.builder()(context)
          : DelayedCircularProgressIndicator(),
      errorPlaceholder: placeholderBuilder != null
          ? placeholderBuilder?.errorBuilder()(context)
          : const Image(
              image: AssetImage('assets/images/app-placeholder-logo.png'),
            ),
    );
  }
}
