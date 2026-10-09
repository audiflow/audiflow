import 'dart:async';

import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/services.dart';

/// Plays catalog haptics through the native `audiflow/haptics` channel.
///
/// The native side maps each token name to its platform pattern
/// (`HapticsChannel.swift` on iOS, `HapticsChannel.kt` on Android), as
/// specified in `docs/design/haptics.md` section 4.
class MethodChannelHapticPlayer implements HapticPlayer {
  const MethodChannelHapticPlayer([
    this._channel = const MethodChannel(channelName),
  ]);

  static const channelName = 'audiflow/haptics';

  final MethodChannel _channel;

  @override
  void play(HapticToken token) => _send('play', token);

  @override
  void prepare(HapticToken token) => _send('prepare', token);

  // Fire-and-forget: a haptic must not delay the gesture that caused it,
  // and a missing haptic is never worth surfacing to the user, so every
  // failure is dropped rather than left as an uncaught async error.
  void _send(String method, HapticToken token) {
    unawaited(
      _channel.invokeMethod<void>(method, token.name).catchError(_ignore),
    );
  }

  static void _ignore(Object _) {}
}
