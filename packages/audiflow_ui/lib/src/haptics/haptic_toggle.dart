import 'package:flutter/foundation.dart';

import 'haptic_player.dart';
import 'haptic_token.dart';

/// Plays the catalog's toggle haptic for switch changes.
extension HapticToggle on HapticPlayer {
  /// Wraps a switch's [onChanged] so every flip plays `toggleOn` or
  /// `toggleOff` in the same frame as the visual change.
  ///
  /// A null [onChanged] stays null so the switch keeps its disabled look.
  ValueChanged<bool>? toggleHaptic(ValueChanged<bool>? onChanged) {
    if (onChanged == null) return null;
    return (value) {
      play(value ? HapticToken.toggleOn : HapticToken.toggleOff);
      onChanged(value);
    };
  }
}
