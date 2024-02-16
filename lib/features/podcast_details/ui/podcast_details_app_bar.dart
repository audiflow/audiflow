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
    required this.basicInfo,
  });

  final PodcastBaseInfo basicInfo;

  @override
  Widget build(BuildContext context) {
    final placeholderBuilder = PlaceholderBuilder.of(context);
    return SliverLayoutBuilder(
        builder: (BuildContext context, SliverConstraints constraints) {
      return SliverAppBar(
        expandedHeight: 300,
        title: 100 < constraints.scrollOffset ? Text(basicInfo.title) : null,
        flexibleSpace: FlexibleSpaceBar(
          collapseMode: CollapseMode.pin,
          background: Hero(
            key: Key(
              'detailHero:${basicInfo.imageUrl}:${basicInfo.guid}',
            ),
            tag: '${basicInfo.imageUrl}:${basicInfo.guid}',
            child: ExcludeSemantics(
              child: _PodcastHeaderImage(
                basicInfo: basicInfo,
                placeholderBuilder: placeholderBuilder,
              ),
            ),
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

  final PodcastBaseInfo basicInfo;
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
