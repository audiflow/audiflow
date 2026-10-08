import 'package:flutter/material.dart';

/// Border radius constants.
///
/// The `xs`..`xl` scale is the general-purpose set. The named radii
/// below come from redesign section 2.4.
class AppBorders {
  AppBorders._();

  static const BorderRadius xs = BorderRadius.all(Radius.circular(4));
  static const BorderRadius sm = BorderRadius.all(Radius.circular(8));
  static const BorderRadius md = BorderRadius.all(Radius.circular(12));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(16));
  static const BorderRadius xl = BorderRadius.all(Radius.circular(24));

  /// Grouped list surface holding several rows.
  static const BorderRadius groupedSurface = BorderRadius.all(
    Radius.circular(18),
  );

  /// Standalone card (continue-listening card, mini player).
  static const BorderRadius card = BorderRadius.all(Radius.circular(16));

  /// Artwork inside list rows and grids.
  static const BorderRadius artworkList = BorderRadius.all(Radius.circular(12));

  /// Artwork in a detail-screen hero.
  static const BorderRadius artworkHero = BorderRadius.all(Radius.circular(20));

  /// Top corners of bottom sheets.
  static const BorderRadius sheet = BorderRadius.vertical(
    top: Radius.circular(28),
  );

  /// Fully rounded ends for pills and circular buttons.
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}
