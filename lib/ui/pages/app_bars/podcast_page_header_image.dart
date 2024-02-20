// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:seasoning/ui/widgets/delayed_progress_indicator.dart';
import 'package:seasoning/ui/widgets/placeholder_builder.dart';
import 'package:seasoning/ui/widgets/podcast_image.dart';

class PodcastHeaderImage extends StatelessWidget {
  const PodcastHeaderImage({
    super.key,
    required this.imageUrl,
    required this.placeholderBuilder,
  });

  final String imageUrl;
  final PlaceholderBuilder? placeholderBuilder;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return const SizedBox(
        height: 560,
        width: 560,
      );
    }

    return PodcastBannerImage(
      key: Key('details:$imageUrl'),
      url: imageUrl,
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
