import '../protocol/sync_messages.dart';

/// One connection to the relay. `WebSocketTransport` (M6d) and the
/// in-memory relay in tests implement it.
abstract class SyncTransport {
  /// Messages from the relay, in the order it sent them. Closes when the
  /// connection does.
  Stream<RelayMessage> get messages;

  void send(ClientMessage message);

  Future<void> close();
}
