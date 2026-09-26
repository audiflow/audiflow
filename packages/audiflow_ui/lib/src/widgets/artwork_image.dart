import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Network artwork decoded at the size it is displayed, not its intrinsic
/// size.
///
/// Channel artwork is 1400-3000 px per Apple's spec: a 3000 px image decodes
/// to 36 MB, so three of them fill Flutter's 100 MB image cache and evict
/// everything else. Bounding the decode width to the displayed physical
/// pixels keeps a 64 dp list tile at ~0.15 MB. The downloaded bytes are
/// kept once per URL on disk and shared by every size.
///
/// Artwork is square per the podcast spec, so only the width is bounded and
/// the height follows the aspect ratio.
class ArtworkImage extends StatelessWidget {
  const ArtworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.loading,
  });

  final String url;

  /// Displayed width. When null, the incoming layout constraints decide the
  /// decode size, so pass it explicitly wherever the size animates (Hero).
  final double? width;
  final double? height;
  final BoxFit fit;

  /// Shown when loading fails, and while loading unless [loading] is given.
  final Widget? placeholder;

  /// Shown while loading; falls back to [placeholder].
  final Widget? loading;

  /// Physical pixel width to decode [logicalWidth] at, or null when the
  /// width is unbounded and no sensible bound exists.
  static int? decodeWidth(double logicalWidth, double devicePixelRatio) {
    if (!logicalWidth.isFinite || logicalWidth <= 0) return null;
    return (logicalWidth * devicePixelRatio).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final explicitWidth = width;
    if (explicitWidth != null) return _buildImage(context, explicitWidth);

    return LayoutBuilder(
      builder: (context, constraints) =>
          _buildImage(context, constraints.maxWidth),
    );
  }

  Widget _buildImage(BuildContext context, double logicalWidth) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);

    return ExtendedImage.network(
      url,
      width: width,
      height: height,
      fit: fit,
      cache: true,
      cacheWidth: decodeWidth(logicalWidth, devicePixelRatio),
      loadStateChanged: (state) => switch (state.extendedImageLoadState) {
        LoadState.loading => loading ?? placeholder ?? const SizedBox.shrink(),
        LoadState.failed => placeholder ?? const SizedBox.shrink(),
        LoadState.completed => null,
      },
    );
  }
}

/// Platform spinner matching the loading state `ExtendedImage.network`
/// shows by default, for sites that relied on it before [ArtworkImage].
class ArtworkLoadingIndicator extends StatelessWidget {
  const ArtworkLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      alignment: Alignment.center,
      child: theme.platform == TargetPlatform.iOS
          ? const CupertinoActivityIndicator(radius: 16)
          : CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
            ),
    );
  }
}
