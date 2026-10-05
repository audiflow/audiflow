import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_route_channel.g.dart';

/// Bridge to the native audio output picker (Android `MainActivity`).
///
/// iOS does not use this channel: the picker there is an embedded
/// `AVRoutePickerView` platform view, see [audioRoutePickerViewType].
class AudioRouteChannel {
  const AudioRouteChannel([this._channel = const MethodChannel(channelName)]);

  static const channelName = 'audiflow/audio_route';

  final MethodChannel _channel;

  /// Whether the system output switcher exists (Android 11 / API 30+).
  Future<bool> isPickerAvailable() => _invokeBool('isPickerAvailable');

  /// Opens the system output switcher, or Bluetooth settings when the
  /// switcher cannot be shown. Returns false when neither opened.
  Future<bool> showPicker() => _invokeBool('showPicker');

  Future<bool> _invokeBool(String method) async {
    try {
      return await _channel.invokeMethod<bool>(method) ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      // Tests and unsupported platforms have no native handler; treat
      // the picker as unavailable rather than crash the player.
      return false;
    }
  }
}

/// iOS platform view type that hosts a transparent `AVRoutePickerView`.
const audioRoutePickerViewType = 'audiflow/audio_route_picker';

@Riverpod(keepAlive: true)
AudioRouteChannel audioRouteChannel(Ref ref) => const AudioRouteChannel();

/// Whether the player shows the audio output picker button.
///
/// Android 8-10 has no system output switcher, so the button stays hidden
/// there instead of sending the user to a Bluetooth-only settings screen.
@Riverpod(keepAlive: true)
Future<bool> audioOutputPickerAvailable(Ref ref) async {
  return switch (defaultTargetPlatform) {
    TargetPlatform.iOS => true,
    TargetPlatform.android =>
      ref.watch(audioRouteChannelProvider).isPickerAvailable(),
    _ => false,
  };
}
