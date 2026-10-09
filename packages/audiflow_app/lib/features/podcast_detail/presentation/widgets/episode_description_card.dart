import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_localizations.dart';

/// "About this episode" card (redesign 4.9): show notes as rich text
/// with `accent` links, clamped to about six lines behind a
/// "show more / show less" toggle.
class EpisodeDescriptionCard extends StatefulWidget {
  const EpisodeDescriptionCard({super.key, required this.content});

  static const double _fontSize = 15;
  static const double _lineHeight = 1.6;

  /// About six lines of body text.
  static const double collapsedHeight = _fontSize * _lineHeight * 6;

  /// Raw show notes (HTML or plain text).
  final String content;

  @override
  State<EpisodeDescriptionCard> createState() => _EpisodeDescriptionCardState();
}

class _EpisodeDescriptionCardState extends State<EpisodeDescriptionCard> {
  bool _expanded = false;
  bool _overflows = false;

  late String _html = _toHtml(widget.content);

  // Section breaks drawn as runs of `=` or `-` become a hairline rule;
  // runs decorating a heading are dropped (redesign section 5).
  static String _toHtml(String content) => content
      .withoutInvisibleLinks
      .plainTextToHtml
      .linkifyUrls
      .separatorRunsAsRules;

  @override
  void didUpdateWidget(EpisodeDescriptionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) _html = _toHtml(widget.content);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.screenHorizontal),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppBorders.groupedSurface,
          boxShadow: AppShadows.groupedSurface,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.screenHorizontal,
            Spacing.md + Spacing.xs,
            Spacing.screenHorizontal,
            Spacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.episodeDetailAbout,
                style: AppTextStyles.overline.copyWith(
                  color: colors.inkSecondary,
                ),
              ),
              const SizedBox(height: Spacing.sm + Spacing.xs),
              _clamped(colors),
              _toggle(l10n, colors),
            ],
          ),
        ),
      ),
    );
  }

  /// Kept in one subtree whether expanded or not, so toggling does not
  /// rebuild the HTML or drop a text selection.
  Widget _clamped(AppColors colors) {
    final clamp = _overflows && !_expanded;
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [Colors.white, Colors.transparent],
        // Fade only the last line, and only while clamped.
        stops: clamp
            ? [(1 - 28 / bounds.height).clamp(0.0, 1.0), 1]
            : const [1, 1],
      ).createShader(bounds),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: _expanded
              ? double.infinity
              : EpisodeDescriptionCard.collapsedHeight,
        ),
        child: NotificationListener<ScrollMetricsNotification>(
          onNotification: _onMetrics,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: SelectionArea(child: _body(colors)),
          ),
        ),
      ),
    );
  }

  bool _onMetrics(ScrollMetricsNotification notification) {
    // Measured only while clamped: expanded, nothing overflows.
    if (_expanded) return true;
    final overflows = 0 < notification.metrics.maxScrollExtent;
    if (overflows != _overflows) setState(() => _overflows = overflows);
    return true;
  }

  Widget _body(AppColors colors) {
    return Html(
      data: _html,
      style: {
        'body': Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          fontSize: FontSize(EpisodeDescriptionCard._fontSize),
          lineHeight: const LineHeight(EpisodeDescriptionCard._lineHeight),
          color: colors.ink,
        ),
        // Browser default margins would open the card with a blank line.
        'p': Style(margin: Margins.only(top: 0, bottom: Spacing.sm)),
        'ul': Style(margin: Margins.only(top: 0, bottom: Spacing.sm)),
        'ol': Style(margin: Margins.only(top: 0, bottom: Spacing.sm)),
        'hr': Style(
          margin: Margins.symmetric(vertical: Spacing.md),
          border: Border(bottom: BorderSide(color: colors.outline)),
        ),
        'a': Style(
          color: colors.accent,
          textDecoration: TextDecoration.underline,
          textDecorationColor: colors.accent,
        ),
      },
      onLinkTap: (url, _, _) => _openLink(url),
    );
  }

  Widget _toggle(AppLocalizations l10n, AppColors colors) {
    if (!_overflows) return const SizedBox(height: Spacing.sm);
    return TextButton(
      onPressed: () => setState(() => _expanded = !_expanded),
      style: TextButton.styleFrom(
        foregroundColor: colors.accent,
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, Spacing.minTouchTarget),
        textStyle: AppTextStyles.label.copyWith(fontSize: 15),
      ),
      child: Text(
        _expanded ? l10n.episodeDetailShowLess : l10n.episodeDetailShowMore,
      ),
    );
  }
}

Future<void> _openLink(String? url) async {
  if (url == null || url.isEmpty) return;
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  // Prefer the in-app browser; fall back to external when unavailable
  // (e.g. the iOS simulator has no SFSafariViewController).
  final launched = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
  if (!launched) await launchUrl(uri, mode: LaunchMode.externalApplication);
}
