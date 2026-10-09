import 'package:flutter/widgets.dart';

import 'haptic_player.dart';

/// Provides the app's [HapticPlayer] to the widget tree.
///
/// audiflow_ui widgets do not read Riverpod, so the app injects the player
/// (already gated by the user's setting) here, above the router.
class HapticsScope extends InheritedWidget {
  const HapticsScope({required this.player, required super.child, super.key});

  final HapticPlayer player;

  /// The nearest scope's player, or a silent one when there is no scope.
  static HapticPlayer of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<HapticsScope>();
    return scope?.player ?? const NoopHapticPlayer();
  }

  @override
  bool updateShouldNotify(HapticsScope oldWidget) =>
      !identical(player, oldWidget.player);
}
