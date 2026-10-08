/// Spacing constants.
///
/// The `xxs`..`xxl` scale is the general-purpose grid. The named
/// layout values below come from redesign section 2.4 and should be
/// preferred where they apply so screens stay consistent.
class Spacing {
  Spacing._();

  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  /// Horizontal padding between screen edges and content.
  static const double screenHorizontal = 20.0;

  /// Vertical padding inside a list row.
  static const double rowVertical = 12.0;

  /// Horizontal padding inside a list row.
  static const double rowHorizontal = 16.0;

  /// Vertical gap between sections on a screen.
  static const double sectionGap = 24.0;

  /// Minimum width and height of any tappable target.
  static const double minTouchTarget = 44.0;
}
