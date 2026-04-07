import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';

/// A timeline entry is either a chapter header or a transcript segment.
sealed class _TimelineEntry {
  const _TimelineEntry();
}

class _ChapterEntry extends _TimelineEntry {
  const _ChapterEntry(this.chapter);
  final EpisodeChapter chapter;
}

class _SegmentEntry extends _TimelineEntry {
  const _SegmentEntry(this.segment);
  final TranscriptSegment segment;
}

/// Displays chapters and transcript segments in a merged timeline.
///
/// Highlights the currently active segment and auto-scrolls to it.
/// Tapping a segment seeks playback to that position.
class TranscriptTimelineView extends ConsumerStatefulWidget {
  const TranscriptTimelineView({
    required this.transcriptId,
    required this.episodeId,
    super.key,
  });

  final int transcriptId;
  final int episodeId;

  @override
  ConsumerState<TranscriptTimelineView> createState() =>
      _TranscriptTimelineViewState();
}

class _TranscriptTimelineViewState
    extends ConsumerState<TranscriptTimelineView> {
  final _scrollController = ScrollController();
  int _activeIndex = -1;
  bool _userScrolling = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final segmentsAsync = ref.watch(
      transcriptSegmentsProvider(widget.transcriptId),
    );
    final chaptersAsync = ref.watch(episodeChaptersProvider(widget.episodeId));

    return segmentsAsync.when(
      loading: _buildLoading,
      error: (error, _) => _buildError(error),
      data: (segments) => chaptersAsync.when(
        loading: _buildLoading,
        error: (error, _) => _buildError(error),
        data: (chapters) => _buildTimeline(segments, chapters),
      ),
    );
  }

  Widget _buildLoading() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(l10n.playerTranscriptLoading),
        ],
      ),
    );
  }

  Widget _buildError(Object error) {
    return Center(child: Text('$error'));
  }

  Widget _buildTimeline(
    List<TranscriptSegment> segments,
    List<EpisodeChapter> chapters,
  ) {
    if (segments.isEmpty) {
      final l10n = AppLocalizations.of(context);
      return Center(child: Text(l10n.playerTranscriptEmpty));
    }

    final entries = _buildEntries(segments, chapters);

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Stack(
        children: [
          _TimelineList(
            entries: entries,
            scrollController: _scrollController,
            activeIndex: _activeIndex,
            onSegmentTap: _handleSegmentTap,
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: _JumpToCurrentButton(
              onPressed: () => _scrollToActive(entries),
            ),
          ),
        ],
      ),
    );
  }

  /// Merges chapters and segments into a single sorted timeline.
  List<_TimelineEntry> _buildEntries(
    List<TranscriptSegment> segments,
    List<EpisodeChapter> chapters,
  ) {
    final progress = ref.watch(playbackProgressProvider);
    final positionMs = progress?.position.inMilliseconds ?? 0;

    final entries = <_TimelineEntry>[];

    // Sort chapters by startMs
    final sorted = [...chapters]
      ..sort((a, b) => a.startMs.compareTo(b.startMs));

    var chapterIdx = 0;
    var newActiveIndex = -1;

    for (var i = 0; i < segments.length; i++) {
      final segment = segments[i];

      // Insert chapter headers that start before this segment
      while (chapterIdx < sorted.length &&
          sorted[chapterIdx].startMs <= segment.startMs) {
        entries.add(_ChapterEntry(sorted[chapterIdx]));
        chapterIdx++;
      }

      entries.add(_SegmentEntry(segment));

      // Determine if this segment is active
      if (segment.startMs <= positionMs && positionMs < segment.endMs) {
        newActiveIndex = entries.length - 1;
      }
    }

    // Append remaining chapters
    while (chapterIdx < sorted.length) {
      entries.add(_ChapterEntry(sorted[chapterIdx]));
      chapterIdx++;
    }

    // Auto-scroll when active segment changes
    if (newActiveIndex != _activeIndex) {
      _activeIndex = newActiveIndex;
      if (!_userScrolling && -1 < _activeIndex) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToIndex(_activeIndex);
        });
      }
    }

    return entries;
  }

  bool _handleScrollNotification(ScrollNotification n) {
    if (n is ScrollStartNotification) {
      _userScrolling = true;
    } else if (n is ScrollEndNotification) {
      _userScrolling = false;
    }
    return false;
  }

  void _handleSegmentTap(TranscriptSegment segment) {
    ref
        .read(audioPlayerControllerProvider.notifier)
        .seek(Duration(milliseconds: segment.startMs));
  }

  void _scrollToActive(List<_TimelineEntry> entries) {
    if (-1 < _activeIndex) {
      _scrollToIndex(_activeIndex);
    }
  }

  void _scrollToIndex(int index) {
    if (!_scrollController.hasClients) return;

    // Estimate position: 56px per item
    const estimatedItemHeight = 56.0;
    final itemOffset = index * estimatedItemHeight;

    // Place the active segment roughly one-third from the top of the
    // viewport so it stays visible below the header.
    final viewportHeight = _scrollController.position.viewportDimension;
    final centeredOffset = itemOffset - viewportHeight / 3;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final targetOffset = centeredOffset.clamp(0.0, maxScroll);

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}

class _TimelineList extends StatelessWidget {
  const _TimelineList({
    required this.entries,
    required this.scrollController,
    required this.activeIndex,
    required this.onSegmentTap,
  });

  final List<_TimelineEntry> entries;
  final ScrollController scrollController;
  final int activeIndex;
  final ValueChanged<TranscriptSegment> onSegmentTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: entries.length,
      padding: const EdgeInsets.only(bottom: 72),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return switch (entry) {
          _ChapterEntry(:final chapter) => _ChapterHeader(chapter: chapter),
          _SegmentEntry(:final segment) => _SegmentTile(
            segment: segment,
            isActive: index == activeIndex,
            onTap: () => onSegmentTap(segment),
          ),
        };
      },
    );
  }
}

class _ChapterHeader extends StatelessWidget {
  const _ChapterHeader({required this.chapter});

  final EpisodeChapter chapter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 4),
      child: SelectableText(
        chapter.title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
      ),
    );
  }
}

class _SegmentTile extends StatelessWidget {
  const _SegmentTile({
    required this.segment,
    required this.isActive,
    required this.onTap,
  });

  final TranscriptSegment segment;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: isActive
            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
            : null,
        child: SelectionArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (segment.speaker != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    segment.speaker!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Text(
                segment.body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isActive
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JumpToCurrentButton extends StatelessWidget {
  const _JumpToCurrentButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return FloatingActionButton.small(
      onPressed: onPressed,
      backgroundColor: colorScheme.secondaryContainer,
      foregroundColor: colorScheme.onSecondaryContainer,
      tooltip: l10n.playerTranscriptJumpToCurrent,
      child: const Icon(Icons.my_location, size: 20),
    );
  }
}
