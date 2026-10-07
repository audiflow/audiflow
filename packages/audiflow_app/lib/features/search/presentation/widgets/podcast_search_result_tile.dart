import 'package:audiflow_search/audiflow_search.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

/// A podcast search result row (redesign 4.7): artwork, title, author,
/// and first category, with an optional [trailing] control (the subscribe
/// button). Rows run full width and end in a hairline that starts at the
/// text.
class PodcastSearchResultTile extends StatelessWidget {
  const PodcastSearchResultTile({
    required this.podcast,
    required this.onTap,
    this.trailing,
    super.key,
  });

  /// Podcast data to display.
  final Podcast podcast;

  /// Callback when tile is tapped.
  final VoidCallback onTap;

  /// Control after the text, e.g. the subscribe button.
  final Widget? trailing;

  static const double artworkSize = 60.0;

  /// Hairline inset so separators start at the text.
  static const double separatorIndent =
      Spacing.screenHorizontal + artworkSize + Spacing.sm + Spacing.xs;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
              start: Spacing.screenHorizontal,
              top: Spacing.rowVertical,
              bottom: Spacing.rowVertical,
              end: Spacing.xs,
            ),
            child: Row(
              children: [
                _buildArtwork(colors),
                const SizedBox(width: Spacing.sm + Spacing.xs),
                Expanded(child: _buildContent(colors)),
                ?trailing,
              ],
            ),
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: colors.hairline,
          indent: separatorIndent,
        ),
      ],
    );
  }

  Widget _buildArtwork(AppColors colors) {
    final url = podcast.artworkUrl;
    return ClipRRect(
      borderRadius: AppBorders.artworkList,
      child: SizedBox.square(
        dimension: artworkSize,
        child: url != null
            ? ArtworkImage(
                url: url,
                width: artworkSize,
                height: artworkSize,
                loading: const SizedBox.shrink(),
                placeholder: _buildPlaceholder(colors),
              )
            : _buildPlaceholder(colors),
      ),
    );
  }

  Widget _buildPlaceholder(AppColors colors) {
    return ColoredBox(
      color: colors.surfaceSunken,
      child: Icon(Icons.podcasts, size: 28, color: colors.inkTertiary),
    );
  }

  Widget _buildContent(AppColors colors) {
    final genre = podcast.genres.firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          podcast.name,
          style: AppTextStyles.rowTitle.copyWith(color: colors.ink),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: Spacing.xxs),
        Text(
          podcast.artistName,
          style: AppTextStyles.meta.copyWith(color: colors.inkSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (genre != null)
          Text(
            genre,
            style: AppTextStyles.caption.copyWith(color: colors.inkTertiary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}
