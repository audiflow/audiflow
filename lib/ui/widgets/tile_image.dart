import 'package:audiflow/ui/widgets/placeholder_builder.dart';
import 'package:audiflow/ui/widgets/podcast_image.dart';
import 'package:flutter/material.dart';

class TileImage extends StatelessWidget {
  const TileImage({
    super.key,
    required this.url,
    required this.size,
    this.highlight = false,
  });

  /// The URL of the image to display.
  final String url;

  /// The size of the image container; both height and width.
  final double size;

  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final placeholderBuilder = PlaceholderBuilder.of(context);

    return PodcastImage(
      key: Key('tile$url'),
      highlight: highlight,
      url: url,
      height: size,
      width: size,
      borderRadius: 6,
      fit: BoxFit.contain,
      placeholder: placeholderBuilder != null
          ? placeholderBuilder.builder()(context)
          : Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(6),
              ),
            ),
      errorPlaceholder: placeholderBuilder != null
          ? placeholderBuilder.errorBuilder()(context)
          : Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(6),
              ),
            ),
    );
  }
}
