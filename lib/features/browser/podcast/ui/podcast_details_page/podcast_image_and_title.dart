import 'package:audiflow/common/ui/placeholder_builder.dart';
import 'package:audiflow/constants/app_sizes.dart';
import 'package:audiflow/features/browser/podcast/ui/podcast_page_header_image.dart';
import 'package:flutter/material.dart';

class PodcastImageAndTitle extends StatelessWidget {
  const PodcastImageAndTitle({
    required this.title,
    required this.author,
    required this.thumbnailUrl,
    this.imageUrl,
    super.key,
  });

  final String title;
  final String? author;
  final String? thumbnailUrl;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final placeholderBuilder = PlaceholderBuilder.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              PodcastHeaderImage.small(
                imageUrl: thumbnailUrl ?? '',
                placeholderBuilder: placeholderBuilder,
              ),
              AnimatedOpacity(
                opacity: imageUrl?.isNotEmpty == true ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: PodcastHeaderImage.small(
                  imageUrl: imageUrl ?? '',
                  placeholderBuilder: placeholderBuilder,
                ),
              ),
            ],
          ),
          gapW8,
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium,
                  textAlign: TextAlign.left,
                ),
                gapH12,
                if (author != null)
                  Text(
                    author!,
                    style: textTheme.bodySmall,
                    textAlign: TextAlign.left,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
