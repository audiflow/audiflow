import 'package:flutter/material.dart';

/// Elevation shadows (redesign section 2.4).
///
/// Shadows are always neutral black at low opacity; colored or glow
/// shadows are not part of the design language.
class AppShadows {
  AppShadows._();

  /// Grouped surfaces: a single soft 1px shadow (`0 1px 2px` at 5%).
  static const List<BoxShadow> groupedSurface = [
    BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2),
  ];

  /// Floating elements (navigation buttons, mini player, menus): a tight
  /// contact shadow plus a wide ambient one so they lift off any content.
  static const List<BoxShadow> floating = [
    BoxShadow(color: Color(0x14000000), offset: Offset(0, 1), blurRadius: 3),
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 6), blurRadius: 16),
  ];
}
