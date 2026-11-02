import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_queue_channel.g.dart';

/// Bridge to the native side of the media session (Android `MainActivity`),
/// for what audio_service does not offer.
class SessionQueueChannel {
  const SessionQueueChannel([this._channel = const MethodChannel(channelName)]);

  static const channelName = 'audiflow/session_queue';

  final MethodChannel _channel;

  /// Sets the title of the session's queue. A failure leaves the host's own
  /// label on the button, so it is not reported as an error.
  Future<bool> setTitle(String title) async {
    try {
      return await _channel.invokeMethod<bool>('setTitle', title) ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}

@Riverpod(keepAlive: true)
SessionQueueChannel sessionQueueChannel(Ref ref) => const SessionQueueChannel();
