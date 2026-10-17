import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

/// Arranges a detail hero (podcast 4.2, episode 4.9): artwork above the
/// content on phones, artwork beside it on tablets.
///
/// On tablets the artwork sits in a square column whose side equals the
/// artwork's phone footprint (top inset + artwork + gap below it), so the
/// artwork keeps its size and the content takes all remaining width.
class DetailHeroLayout extends StatelessWidget {
  const DetailHeroLayout({
    super.key,
    required this.artwork,
    required this.artworkSize,
    required this.artworkGap,
    required this.phonePadding,
    required this.content,
    this.phoneAlignment = CrossAxisAlignment.center,
  });

  /// Key of the square artwork column, shown only side by side.
  @visibleForTesting
  static const Key artworkColumnKey = ValueKey('detail-hero-artwork-column');

  final Widget artwork;
  final double artworkSize;

  /// Space between the artwork and the content below it on phones.
  final double artworkGap;

  /// Outer padding of the stacked phone layout. Side by side only its top
  /// applies; the sides follow the screen gutter and the bottom is
  /// [artworkGap] under both columns.
  final EdgeInsets phonePadding;
  final Widget content;
  final CrossAxisAlignment phoneAlignment;

  /// Whether heroes lay out side by side for this screen size. Uses the
  /// app-wide tablet breakpoint, like the tablet navigation shells.
  static bool isSideBySide(BuildContext context) =>
      DeviceUtils.isTablet(MediaQuery.sizeOf(context).shortestSide);

  @override
  Widget build(BuildContext context) {
    return isSideBySide(context) ? _sideBySide() : _stacked();
  }

  Widget _stacked() {
    return Padding(
      padding: phonePadding,
      child: Column(
        crossAxisAlignment: phoneAlignment,
        children: [
          Center(child: artwork),
          SizedBox(height: artworkGap),
          content,
        ],
      ),
    );
  }

  Widget _sideBySide() {
    // The screen gutter, not the phone padding, so the artwork lines up
    // with the rows and bars below the hero.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.screenHorizontal),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _artworkColumn(),
          Expanded(
            // Ends artworkGap below the text, as the square does below
            // the artwork, so the hero's bottom gap does not depend on
            // which column is taller.
            child: Padding(
              padding: EdgeInsets.only(
                top: phonePadding.top,
                bottom: artworkGap,
              ),
              child: content,
            ),
          ),
        ],
      ),
    );
  }

  Widget _artworkColumn() {
    return SizedBox.square(
      key: artworkColumnKey,
      dimension: phonePadding.top + artworkSize + artworkGap,
      child: Padding(
        padding: EdgeInsets.only(top: phonePadding.top),
        child: Align(alignment: AlignmentDirectional.topStart, child: artwork),
      ),
    );
  }
}
