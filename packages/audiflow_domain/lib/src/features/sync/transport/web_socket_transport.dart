import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../engine/sync_transport.dart';
import '../protocol/sync_messages.dart';

/// [SyncTransport] over a WebSocket to the relay's `/v1/connect`.
///
/// A message the app cannot decode is reported as a stream error, which
/// ends the engine's session: the relay speaks a newer protocol, or the
/// connection is not to a relay at all.
class WebSocketTransport implements SyncTransport {
  WebSocketTransport._(this._channel);

  /// Opens a connection for [accountId] to the relay at [relayUrl] (an
  /// `https://` or `wss://` base URL). Completes once the socket is open;
  /// throws when it cannot be.
  static Future<WebSocketTransport> connect(
    Uri relayUrl,
    String accountId, {
    WebSocketChannel Function(Uri uri)? open,
  }) async {
    final uri = connectUri(relayUrl, accountId);
    final channel = (open ?? WebSocketChannel.connect)(uri);
    await channel.ready;
    return WebSocketTransport._(channel);
  }

  /// The connect endpoint for [accountId] under [relayUrl]; `https` becomes
  /// `wss` and `http` (a local relay) becomes `ws`.
  static Uri connectUri(Uri relayUrl, String accountId) {
    final scheme = switch (relayUrl.scheme) {
      'https' || 'wss' => 'wss',
      'http' || 'ws' => 'ws',
      final other => throw ArgumentError.value(other, 'relayUrl', 'scheme'),
    };
    final base = relayUrl.path.endsWith('/')
        ? relayUrl.path.substring(0, relayUrl.path.length - 1)
        : relayUrl.path;
    return relayUrl.replace(
      scheme: scheme,
      path: '$base/v1/connect',
      queryParameters: {'account': accountId},
    );
  }

  final WebSocketChannel _channel;

  @override
  late final Stream<RelayMessage> messages = _channel.stream.transform(
    StreamTransformer.fromHandlers(
      handleData: (Object? data, EventSink<RelayMessage> sink) {
        if (data is! String) {
          sink.addError(const FormatException('binary relay message'));
          return;
        }
        try {
          sink.add(RelayMessage.decode(data));
        } on FormatException catch (e) {
          sink.addError(e);
        }
      },
    ),
  );

  @override
  void send(ClientMessage message) => _channel.sink.add(message.encode());

  @override
  Future<void> close() async {
    await _channel.sink.close();
  }
}
