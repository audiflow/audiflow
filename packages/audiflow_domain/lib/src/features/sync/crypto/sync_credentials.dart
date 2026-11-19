import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:meta/meta.dart';

/// What another device needs to join a sync account: the account's address
/// and the sync key (docs/plans/2026-11-20-sync-plan.md, P7).
///
/// The data key is not here: a joining device unwraps it from the relay's
/// sync key wrap, so rotating the data key never invalidates a QR code the
/// user has not shown yet.
@immutable
class SyncCredentials {
  SyncCredentials({required this.accountId, required this.syncKey}) {
    if (accountId.length != accountIdLength) {
      throw ArgumentError.value(accountId.length, 'accountId', 'length');
    }
    if (syncKey.length != syncKeyLength) {
      throw ArgumentError.value(syncKey.length, 'syncKey', 'length');
    }
  }

  /// A new account: random id, random 256-bit sync key.
  factory SyncCredentials.generate([Random? random]) {
    final rng = random ?? Random.secure();
    Uint8List bytes(int n) =>
        Uint8List.fromList(List.generate(n, (_) => rng.nextInt(256)));
    return SyncCredentials(
      accountId: bytes(accountIdLength),
      syncKey: bytes(syncKeyLength),
    );
  }

  static const accountIdLength = 16;
  static const syncKeyLength = 32;

  /// Routes to the account's Durable Object; fixed for the account's life.
  final Uint8List accountId;

  /// Shared by every device of the account; replaced by a revocation.
  final Uint8List syncKey;

  /// The account id as the relay addresses it.
  String get accountIdText => base64Url.encode(accountId).replaceAll('=', '');

  Uint8List get _bytes => Uint8List.fromList([...accountId, ...syncKey]);

  @override
  bool operator ==(Object other) =>
      other is SyncCredentials && _equal(_bytes, other._bytes);

  @override
  int get hashCode => Object.hashAll(_bytes);

  // Never prints the key: credentials end up in logs through toString.
  @override
  String toString() => 'SyncCredentials($accountIdText)';
}

/// The QR payload and the printable recovery code for [SyncCredentials].
abstract final class PairingCodec {
  static const _qrPrefix = 'audiflow-sync:1:';
  static const _payloadLength =
      SyncCredentials.accountIdLength + SyncCredentials.syncKeyLength;
  static const _checksumLength = 2;
  static const _groupLength = 4;

  /// Characters in a recovery code, separators not counted: 50 bytes of
  /// credentials and checksum, 5 bits per character.
  static const recoveryCodeLength = 80;

  /// Crockford base32: no I, L, O, or U, so a hand-copied code has fewer
  /// look-alikes.
  static const _alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

  static String encodeQr(SyncCredentials credentials) =>
      _qrPrefix + base64Url.encode(credentials._bytes).replaceAll('=', '');

  /// Throws a [FormatException] for anything but a version 1 payload.
  static SyncCredentials decodeQr(String text) {
    if (!text.startsWith(_qrPrefix)) {
      throw const FormatException('Not an audiflow sync code');
    }
    final Uint8List bytes;
    try {
      bytes = base64Url.decode(
        base64Url.normalize(text.substring(_qrPrefix.length)),
      );
    } on FormatException {
      throw const FormatException('Damaged sync code');
    }
    if (bytes.length != _payloadLength) {
      throw const FormatException('Damaged sync code');
    }
    return _fromBytes(bytes);
  }

  /// 80 characters in 20 groups of 4: the credentials and a 16-bit
  /// checksum, so most typing mistakes are caught before any network call.
  static String encodeRecoveryCode(SyncCredentials credentials) {
    final payload = credentials._bytes;
    final text = _toBase32([...payload, ..._checksum(payload)]);
    final groups = <String>[
      for (var i = 0; i < text.length; i += _groupLength)
        text.substring(i, i + _groupLength),
    ];
    return groups.join('-');
  }

  /// Accepts any case, spaces or hyphens between characters, and O, I, or L
  /// typed for 0 and 1. Throws a [FormatException] otherwise or when the
  /// checksum does not match.
  static SyncCredentials decodeRecoveryCode(String code) {
    final cleaned = code
        .toUpperCase()
        .replaceAll(RegExp(r'[\s-]'), '')
        .replaceAll('O', '0')
        .replaceAll(RegExp('[IL]'), '1');
    // Checked on the characters, not the decoded bytes: the last five bits
    // of an extra character would be dropped and still decode.
    if (cleaned.length != recoveryCodeLength) {
      throw const FormatException('Recovery code has the wrong length');
    }
    final bytes = _fromBase32(cleaned);
    final payload = Uint8List.sublistView(bytes, 0, _payloadLength);
    if (!_equal(
      Uint8List.sublistView(bytes, _payloadLength),
      _checksum(payload),
    )) {
      throw const FormatException('Recovery code does not check out');
    }
    return _fromBytes(payload);
  }

  static SyncCredentials _fromBytes(Uint8List bytes) => SyncCredentials(
    accountId: Uint8List.fromList(
      bytes.sublist(0, SyncCredentials.accountIdLength),
    ),
    syncKey: Uint8List.fromList(bytes.sublist(SyncCredentials.accountIdLength)),
  );

  static Uint8List _checksum(List<int> payload) => Uint8List.fromList(
    sha256.convert(payload).bytes.sublist(0, _checksumLength),
  );

  static String _toBase32(List<int> bytes) {
    final out = StringBuffer();
    var buffer = 0;
    var bits = 0;
    for (final byte in bytes) {
      buffer = (buffer << 8) | byte;
      bits += 8;
      while (5 <= bits) {
        bits -= 5;
        out.write(_alphabet[(buffer >> bits) & 31]);
      }
    }
    if (0 < bits) out.write(_alphabet[(buffer << (5 - bits)) & 31]);
    return out.toString();
  }

  static Uint8List _fromBase32(String text) {
    final out = <int>[];
    var buffer = 0;
    var bits = 0;
    for (final char in text.split('')) {
      final value = _alphabet.indexOf(char);
      if (value < 0) {
        throw FormatException('Not a recovery code character', char);
      }
      buffer = ((buffer << 5) | value) & 0xFFFF;
      bits += 5;
      if (8 <= bits) {
        bits -= 8;
        out.add((buffer >> bits) & 0xFF);
      }
    }
    return Uint8List.fromList(out);
  }
}

bool _equal(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a[i] ^ b[i];
  }
  return diff == 0;
}
