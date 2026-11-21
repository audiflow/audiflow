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

  /// How long the WebSocket upgrade may take before the attempt fails and
  /// is retried; a server that accepts but never answers would otherwise
  /// hold the connection, and a turn-off waiting on it, forever.
  static const connectTimeout = Duration(seconds: 20);

  /// Opens a connection for [accountId] to the relay at [relayUrl] (an
  /// `https://` or `wss://` base URL). Completes once the socket is open;
  /// throws when it cannot be.
  static Future<WebSocketTransport> connect(
    Uri relayUrl,
    String accountId, {
    WebSocketChannel Function(Uri uri)? open,
    Duration timeout = connectTimeout,
  }) async {
    final uri = connectUri(relayUrl, accountId);
    final channel = (open ?? WebSocketChannel.connect)(uri);
    try {
      await channel.ready.timeout(timeout);
    } on Object {
      unawaited(channel.sink.close().catchError((Object _) {}));
      rethrow;
    }
    return WebSocketTransport._(channel);
  }

  /// Hosts a cleartext relay may run on: the developer's machine, as the
  /// device or the Android emulator reaches it. Anywhere else the device
  /// token and the enrollment secret would travel unencrypted.
  static const _localHosts = {'localhost', '127.0.0.1', '::1', '10.0.2.2'};

  /// The connect endpoint for [accountId] under [relayUrl]; `https` becomes
  /// `wss`, and `http` becomes `ws` for a local relay only.
  static Uri connectUri(Uri relayUrl, String accountId) {
    final scheme = switch (relayUrl.scheme) {
      'https' || 'wss' => 'wss',
      'http' || 'ws' when _localHosts.contains(relayUrl.host) => 'ws',
      final other => throw ArgumentError.value(
        relayUrl,
        'relayUrl',
        'needs https, or http to a local relay ($other)',
      ),
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
        // Any decode failure, a wrongly typed field (TypeError) included,
        // goes down the stream: thrown here it would escape as an
        // uncaught error and the session would not end.
        try {
          sink.add(RelayMessage.decode(data));
        } on Object catch (e, stack) {
          sink.addError(
            e is FormatException ? e : FormatException('$e'),
            stack,
          );
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
