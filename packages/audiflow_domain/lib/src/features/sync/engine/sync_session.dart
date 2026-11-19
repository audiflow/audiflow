import 'dart:typed_data';

import '../crypto/sync_cipher.dart';
import '../crypto/sync_credentials.dart';
import '../protocol/sync_messages.dart';

/// What a device holds to sync with its account. The app keeps it in
/// secure storage (plan P8); the engine updates [token] and [dataKey] as
/// the relay hands them out.
class SyncSession {
  SyncSession({
    required this.credentials,
    required this.device,
    this.token,
    this.dataKey,
  });

  final SyncCredentials credentials;

  /// This device as the relay lists it, with its public key.
  final SyncDevice device;

  /// The per-device token from `welcome`; null until enrolled.
  String? token;

  /// The account's data key; null on a joining device until it unwraps
  /// the sync key wrap from `welcome`.
  DataKey? dataKey;

  String get accountId => credentials.accountIdText;

  Uint8List get syncKey => credentials.syncKey;

  // Never prints secrets.
  @override
  String toString() => 'SyncSession($accountId, ${device.deviceId})';
}

/// How a connection opens: a new account, a device joining with the sync
/// key, or a device already enrolled.
enum SyncOpening { create, join, resume }

/// The relay refused the connection or a request.
class SyncRelayFailure implements Exception {
  const SyncRelayFailure(this.code);

  /// One of the `RelayError` codes, or one of the engine's own below.
  final String code;

  /// The connection closed or errored.
  static const closed = 'closed';

  /// Resuming without a token: the device has not enrolled.
  static const notEnrolled = 'notEnrolled';

  /// Joining found no snapshot yet: the creating device has not finished
  /// its first upload, so the account's history is unknown. Retry later.
  static const accountNotReady = 'accountNotReady';

  /// A received frame could not be opened or merged. The cursor stays
  /// before it, so nothing it carried is skipped; retrying may succeed
  /// once a key arrives (M6g), else it needs attention.
  static const unreadableFrame = 'unreadableFrame';

  /// A local step failed (a database error); the outbox and cursor are
  /// intact, so a new connection retries.
  static const internal = 'internal';

  @override
  String toString() => 'SyncRelayFailure: $code';
}
