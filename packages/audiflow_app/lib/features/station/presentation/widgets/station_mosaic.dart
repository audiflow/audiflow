import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

/// 2x2 artwork mosaic of a station's first four podcasts.
///
/// Fills the square it is given; empty cells show a podcast glyph.
class StationMosaic extends StatelessWidget {
  const StationMosaic({required this.artworkUrls, super.key});

  final List<String?> artworkUrls;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = constraints.maxWidth / 2;
        return Wrap(
          children: List.generate(4, (index) {
            final url = index < artworkUrls.length ? artworkUrls[index] : null;
            return SizedBox.square(
              dimension: cellSize,
              child: url == null
                  ? _placeholder(colors, cellSize)
                  : ArtworkImage(
                      url: url,
                      width: cellSize,
                      height: cellSize,
                      loading: const SizedBox.shrink(),
                      placeholder: _placeholder(colors, cellSize),
                    ),
            );
          }),
        );
      },
    );
  }

  Widget _placeholder(AppColors colors, double size) {
    return ColoredBox(
      color: colors.surfaceSunken,
      child: Icon(
        Icons.podcasts,
        size: size * 0.4,
        color: colors.inkQuaternary,
      ),
    );
  }
}
