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

  /// One of the `RelayError` codes.
  final String code;

  @override
  String toString() => 'SyncRelayFailure: $code';
}
