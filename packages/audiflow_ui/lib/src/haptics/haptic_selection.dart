import 'package:flutter/foundation.dart';

import 'haptic_player.dart';
import 'haptic_token.dart';

/// Plays the catalog's selection haptic for discrete choice controls.
extension HapticSelection on HapticPlayer {
  /// Wraps a choice control's change callback so every new selection plays
  /// `selection` in the same frame as the visual change.
  ///
  /// Use it only on callbacks that fire for an actual change (for example
  /// `SegmentedButton.onSelectionChanged`); a null [onChanged] stays null.
  ValueChanged<T>? selectionHaptic<T>(ValueChanged<T>? onChanged) {
    if (onChanged == null) return null;
    return (value) {
      play(HapticToken.selection);
      onChanged(value);
    };
  }
}
