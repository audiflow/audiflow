import 'package:audiflow/common/ui/delayed_progress_indicator.dart';
import 'package:audiflow/common/ui/placeholder_builder.dart';
import 'package:audiflow/features/browser/common/ui/podcast_image.dart';
import 'package:flutter/material.dart';

class PodcastHeaderImage extends StatelessWidget {
  const PodcastHeaderImage({
    super.key,
    required this.imageUrl,
    required this.placeholderBuilder,
    required this.size,
  });

  const PodcastHeaderImage.large({
    super.key,
    required this.imageUrl,
    required this.placeholderBuilder,
  }) : size = 560;

  const PodcastHeaderImage.middle({
    super.key,
    required this.imageUrl,
    required this.placeholderBuilder,
  }) : size = 240;

  final String imageUrl;
  final PlaceholderBuilder? placeholderBuilder;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return  SizedBox(
        height: size,
        width: size,
      );
    }

    return PodcastBannerImage(
      key: Key('details:$imageUrl'),
      url: imageUrl,
      fit: BoxFit.contain,
      width: size,
      height: size,
      placeholder: placeholderBuilder != null
          ? placeholderBuilder?.builder()(context)
          : DelayedCircularProgressIndicator(),
      errorPlaceholder: placeholderBuilder != null
          ? placeholderBuilder?.errorBuilder()(context)
          : Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
            ),
    );
  }
}
