import 'package:flutter/foundation.dart';

import 'haptic_player.dart';
import 'haptic_token.dart';

/// Plays the catalog's long-press haptic.
extension HapticLongPress on HapticPlayer {
  /// Wraps a long-press handler so it plays `longPress` as it fires.
  ///
  /// The host `InkWell` must set `enableFeedback: false`, or Flutter's own
  /// long-press vibration plays alongside the token. A null [onLongPress]
  /// stays null.
  VoidCallback? longPressHaptic(VoidCallback? onLongPress) {
    if (onLongPress == null) return null;
    return () {
      play(HapticToken.longPress);
      onLongPress();
    };
  }
}
