import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Declares the system status bar style for everything beneath it, derived
/// from the ambient [Theme] brightness.
///
/// Flutter only pushes a new [SystemUiOverlayStyle] when it finds an
/// [AnnotatedRegion] under the status bar. Without one at the app root,
/// a transient region (such as the light icons a Cupertino sheet sets over
/// its dark top gap) keeps applying after its route is gone. Placing this
/// in `MaterialApp.builder` guarantees a fallback region that also tracks
/// the in-app theme setting rather than the platform appearance. Deeper
/// regions still win while they are on screen.
class ThemedSystemUiOverlay extends StatelessWidget {
  const ThemedSystemUiOverlay({super.key, required this.child});

  final Widget child;

  /// Style whose icons stay readable over a background of [background]
  /// brightness.
  ///
  /// Sets both the iOS field (brightness of the content behind the bar) and
  /// the Android field (icon brightness), since each platform reads only
  /// one of them. Navigation bar fields stay null so the platform defaults
  /// are left untouched.
  static SystemUiOverlayStyle styleOn(Brightness background) {
    final icons = background == Brightness.light
        ? Brightness.dark
        : Brightness.light;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: background,
      statusBarIconBrightness: icons,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: styleOn(Theme.of(context).brightness),
      child: child,
    );
  }
}
