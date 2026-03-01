/// Layout constants for responsive design.
class LayoutConstants {
  LayoutConstants._();

  /// Shortest-side threshold separating phone from tablet.
  /// Devices with `tabletBreakpoint <= shortestSide` are tablets.
  static const double tabletBreakpoint = 600.0;

  /// Maximum content width for centered layouts (player, settings).
  static const double contentMaxWidth = 560.0;

  /// Target width per podcast grid item for column count calculation.
  static const double podcastGridItemWidth = 130.0;

  /// Width of the sidebar in tablet landscape mode.
  static const double sidebarWidth = 280.0;
}
