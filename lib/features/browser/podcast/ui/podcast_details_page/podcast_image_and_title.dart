import 'package:audiflow/constants/app_sizes.dart';
import 'package:audiflow/features/browser/podcast/ui/podcast_page_header_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class PodcastImageAndTitle extends HookWidget {
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
    final expandedState = useState(false);
    final animation = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );
    final maxImageSize = MediaQuery.of(context).size.width - 16;
    const minImageSize = 100.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: imageUrl?.isEmpty == true
                    ? null
                    : () {
                        expandedState.value = !expandedState.value;
                        if (expandedState.value) {
                          animation.animateTo(1);
                        } else {
                          animation.animateTo(0);
                        }
                      },
                child: AnimatedBuilder(
                  animation: animation,
                  child: PodcastHeaderImage(
                    size: maxImageSize,
                    imageUrl: imageUrl ?? '',
                    placeholder: PodcastHeaderImage(
                      size: minImageSize,
                      imageUrl: thumbnailUrl ?? '',
                    ),
                  ),
                  builder: (context, child) {
                    final d = (maxImageSize - minImageSize) * animation.value;
                    return SizedBox.square(
                      dimension: minImageSize + d,
                      child: child,
                    );
                  },
                ),
              ),
              AnimatedBuilder(
                animation: animation,
                child: Expanded(
                  child: AnimatedOpacity(
                    opacity: 1,
                    duration: const Duration(milliseconds: 300),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _TitleAndAuthor(title: title, author: author),
                    ),
                  ),
                ),
                builder: (context, child) {
                  return animation.value < 0.3
                      ? child!
                      : const SizedBox.shrink();
                },
              ),
            ],
          ),
          AnimatedBuilder(
            animation: animation,
            child: Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 16),
              child: _TitleAndAuthor(title: title, author: author),
            ),
            builder: (context, child) {
              return 0.3 <= animation.value ? child! : const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

class _TitleAndAuthor extends StatelessWidget {
  const _TitleAndAuthor({
    required this.title,
    required this.author,
  });

  final String title;
  final String? author;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SelectionArea(
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
    );
  }
}
