// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:seasoning/entities/podcast.dart';
import 'package:seasoning/ui/widgets/delayed_progress_indicator.dart';
import 'package:seasoning/ui/widgets/placeholder_builder.dart';
import 'package:seasoning/ui/widgets/podcast_image.dart';

class PodcastDetailsAppBar extends StatelessWidget {
  const PodcastDetailsAppBar({
    super.key,
    required this.summary,
  });

  final PodcastSummary summary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final placeholderBuilder = PlaceholderBuilder.of(context);
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
        flexibleSpace: FlexibleSpaceBar(
          collapseMode: CollapseMode.pin,
          background: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Hero(
                  key: Key(
                    'detailHero:${summary.imageUrl}:${summary.guid}',
                  ),
                  tag: '${summary.imageUrl}:${summary.guid}',
                  child: ExcludeSemantics(
                    child: _PodcastHeaderImage(
                      basicInfo: summary,
                      placeholderBuilder: placeholderBuilder,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(summary.title, style: textTheme.titleMedium),
              Text(summary.copyright, style: textTheme.bodySmall),
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
