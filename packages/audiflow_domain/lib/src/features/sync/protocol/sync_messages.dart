import 'dart:convert';
import 'dart:typed_data';

/// Relay protocol version 1 (docs/plans/2026-11-20-sync-plan.md, P6).
///
/// JSON text messages; binary values are unpadded base64url. The relay
/// reads only routing fields and never the sealed blobs.
const syncProtocolVersion = 1;

String encodeBytes(List<int> bytes) =>
    base64Url.encode(bytes).replaceAll('=', '');

Uint8List decodeBytes(Object? text) {
  if (text is! String) throw const FormatException('expected base64url');
  return base64Url.decode(base64Url.normalize(text));
}

/// A device as the relay lists it.
class SyncDevice {
  const SyncDevice({
    required this.deviceId,
    required this.name,
    required this.platform,
    required this.publicKey,
    this.tag,
  });

  factory SyncDevice.fromJson(Map<String, Object?> json) => SyncDevice(
    deviceId: _string(json, 'deviceId'),
    name: _string(json, 'name'),
    platform: _string(json, 'platform'),
    publicKey: decodeBytes(json['publicKey']),
    tag: json['tag'] == null ? null : decodeBytes(json['tag']),
  );

  final String deviceId;
  final String name;
  final String platform;
  final Uint8List publicKey;

  /// `SyncKeyDerivation.deviceTag` of [deviceId] and [publicKey] under the
  /// current sync key: proof the device was registered by a holder of the
  /// key, which the relay cannot forge. Null on this device's own record
  /// until the engine registers it.
  final Uint8List? tag;

  SyncDevice withTag(Uint8List tag) => SyncDevice(
    deviceId: deviceId,
    name: name,
    platform: platform,
    publicKey: publicKey,
    tag: tag,
  );

  Map<String, Object?> toJson() => {
    'deviceId': deviceId,
    'name': name,
    'platform': platform,
    'publicKey': encodeBytes(publicKey),
    if (tag case final t?) 'tag': encodeBytes(t),
  };
}

/// A sealed frame the relay ordered.
class RelayFrame {
  const RelayFrame({
    required this.seq,
    required this.deviceId,
    required this.blob,
  });

  factory RelayFrame.fromJson(Map<String, Object?> json) => RelayFrame(
    seq: _int(json, 'seq'),
    deviceId: _string(json, 'deviceId'),
    blob: decodeBytes(json['blob']),
  );

  final int seq;
  final String deviceId;
  final Uint8List blob;

  Map<String, Object?> toJson() => {
    'seq': seq,
    'deviceId': deviceId,
    'blob': encodeBytes(blob),
  };
}

/// The compacted snapshot the relay holds, and the last `seq` it covers.
class RelaySnapshot {
  const RelaySnapshot({required this.coversSeq, required this.blob});

  factory RelaySnapshot.fromJson(Map<String, Object?> json) => RelaySnapshot(
    coversSeq: _int(json, 'coversSeq'),
    blob: decodeBytes(json['blob']),
  );

  final int coversSeq;
  final Uint8List blob;

  Map<String, Object?> toJson() => {
    'coversSeq': coversSeq,
    'blob': encodeBytes(blob),
  };
}

// ---------------------------------------------------------------------------
// Client to relay

sealed class ClientMessage {
  const ClientMessage();

  String get type;

  Map<String, Object?> get fields;

  Map<String, Object?> toJson() => {'type': type, ...fields};

  String encode() => jsonEncode(toJson());

  /// For the relay side (and the in-memory relay in tests).
  static ClientMessage decode(String text) {
    final json = _object(jsonDecode(text));
    return switch (json['type']) {
      'create' => CreateAccount(
        accountId: _string(json, 'accountId'),
        authVerifier: decodeBytes(json['authVerifier']),
        syncWrap: decodeBytes(json['syncWrap']),
        device: SyncDevice.fromJson(_object(json['device'])),
      ),
      'enroll' => EnrollDevice(
        accountId: _string(json, 'accountId'),
        authSecret: decodeBytes(json['authSecret']),
        device: SyncDevice.fromJson(_object(json['device'])),
      ),
      'hello' => Hello(
        protocolVersion: _int(json, 'protocolVersion'),
        accountId: _string(json, 'accountId'),
        deviceId: _string(json, 'deviceId'),
        token: _string(json, 'token'),
        cursor: _int(json, 'cursor'),
      ),
      'push' => PushFrames([
        for (final f in _list(json, 'frames'))
          PushFrame(
            clientId: _string(_object(f), 'clientId'),
            blob: decodeBytes(_object(f)['blob']),
          ),
      ]),
      'snapshot' => UploadSnapshot(RelaySnapshot.fromJson(json)),
      'presence' => SendPresence(decodeBytes(json['blob'])),
      'revoke' => RevokeDevice(
        deviceId: _string(json, 'deviceId'),
        newAuthVerifier: decodeBytes(json['newAuthVerifier']),
        newSyncWrap: decodeBytes(json['newSyncWrap']),
        deviceWraps: _bytesMap(json, 'deviceWraps'),
        deviceTags: _bytesMap(json, 'deviceTags'),
        snapshot: RelaySnapshot.fromJson(_object(json['snapshot'])),
      ),
      final other => throw FormatException('unknown message type', other),
    };
  }
}

class CreateAccount extends ClientMessage {
  const CreateAccount({
    required this.accountId,
    required this.authVerifier,
    required this.syncWrap,
    required this.device,
  });

  final String accountId;
  final Uint8List authVerifier;
  final Uint8List syncWrap;
  final SyncDevice device;

  @override
  String get type => 'create';

  @override
  Map<String, Object?> get fields => {
    'protocolVersion': syncProtocolVersion,
    'accountId': accountId,
    'authVerifier': encodeBytes(authVerifier),
    'syncWrap': encodeBytes(syncWrap),
    'device': device.toJson(),
  };
}

class EnrollDevice extends ClientMessage {
  const EnrollDevice({
    required this.accountId,
    required this.authSecret,
    required this.device,
  });

  final String accountId;
  final Uint8List authSecret;
  final SyncDevice device;

  @override
  String get type => 'enroll';

  @override
  Map<String, Object?> get fields => {
    'protocolVersion': syncProtocolVersion,
    'accountId': accountId,
    'authSecret': encodeBytes(authSecret),
    'device': device.toJson(),
  };
}

class Hello extends ClientMessage {
  const Hello({
    this.protocolVersion = syncProtocolVersion,
    required this.accountId,
    required this.deviceId,
    required this.token,
    required this.cursor,
  });

  final int protocolVersion;
  final String accountId;
  final String deviceId;
  final String token;
  final int cursor;

  @override
  String get type => 'hello';

  @override
  Map<String, Object?> get fields => {
    'protocolVersion': protocolVersion,
    'accountId': accountId,
    'deviceId': deviceId,
    'token': token,
    'cursor': cursor,
  };
}

class PushFrame {
  const PushFrame({required this.clientId, required this.blob});

  final String clientId;
  final Uint8List blob;
}

class PushFrames extends ClientMessage {
  const PushFrames(this.frames);

  final List<PushFrame> frames;

  @override
  String get type => 'push';

  @override
  Map<String, Object?> get fields => {
    'frames': [
      for (final f in frames)
        {'clientId': f.clientId, 'blob': encodeBytes(f.blob)},
    ],
  };
}

class SendPresence extends ClientMessage {
  const SendPresence(this.blob);

  final Uint8List blob;

  @override
  String get type => 'presence';

  @override
  Map<String, Object?> get fields => {'blob': encodeBytes(blob)};
}

class UploadSnapshot extends ClientMessage {
  const UploadSnapshot(this.snapshot);

  final RelaySnapshot snapshot;

  @override
  String get type => 'snapshot';

  @override
  Map<String, Object?> get fields => snapshot.toJson();
}

/// Removes [deviceId] from the account, from a remaining device (plan P2,
/// P3). It carries the rotated secrets: the verifier and sync key wrap of
/// the new sync key, the new keys sealed to each remaining device (the
/// sender's own included, so a sender that never hears back recovers them
/// on its next connection), each remaining device's tag under the new
/// sync key, and the whole state at the head sealed under the new data
/// key, so nothing the relay keeps needs a retired key.
class RevokeDevice extends ClientMessage {
  const RevokeDevice({
    required this.deviceId,
    required this.newAuthVerifier,
    required this.newSyncWrap,
    required this.deviceWraps,
    required this.deviceTags,
    required this.snapshot,
  });

  final String deviceId;
  final Uint8List newAuthVerifier;
  final Uint8List newSyncWrap;
  final Map<String, Uint8List> deviceWraps;
  final Map<String, Uint8List> deviceTags;
  final RelaySnapshot snapshot;

  @override
  String get type => 'revoke';

  @override
  Map<String, Object?> get fields => {
    'deviceId': deviceId,
    'newAuthVerifier': encodeBytes(newAuthVerifier),
    'newSyncWrap': encodeBytes(newSyncWrap),
    'deviceWraps': {
      for (final MapEntry(:key, :value) in deviceWraps.entries)
        key: encodeBytes(value),
    },
    'deviceTags': {
      for (final MapEntry(:key, :value) in deviceTags.entries)
        key: encodeBytes(value),
    },
    'snapshot': snapshot.toJson(),
  };
}

// ---------------------------------------------------------------------------
// Relay to client

sealed class RelayMessage {
  const RelayMessage();

  String get type;

  Map<String, Object?> get fields;

  Map<String, Object?> toJson() => {'type': type, ...fields};

  String encode() => jsonEncode(toJson());

  /// Throws [FormatException] for anything but a version 1 message. A
  /// type this version does not know decodes as [UnknownRelayMessage]: a
  /// newer relay may add messages within the version, and a session must
  /// not end over one.
  static RelayMessage decode(String text) {
    final json = _object(jsonDecode(text));
    return switch (json['type']) {
      'welcome' => Welcome(
        minProtocolVersion: _int(json, 'minProtocolVersion'),
        token: json['token'] as String?,
        syncWrap: decodeBytes(json['syncWrap']),
        deviceWrap: json['deviceWrap'] == null
            ? null
            : decodeBytes(json['deviceWrap']),
        snapshot: json['snapshot'] == null
            ? null
            : RelaySnapshot.fromJson(_object(json['snapshot'])),
        devices: [
          for (final d in _list(json, 'devices'))
            SyncDevice.fromJson(_object(d)),
        ],
      ),
      'frames' => Frames([
        for (final f in _list(json, 'frames')) RelayFrame.fromJson(_object(f)),
      ], more: json['more'] == true),
      'pushed' => Pushed({
        for (final a in _list(json, 'acks'))
          _string(_object(a), 'clientId'): _int(_object(a), 'seq'),
      }),
      'stored' => SnapshotStored(_int(json, 'coversSeq')),
      'presence' => PresenceUpdate(
        deviceId: _string(json, 'deviceId'),
        blob: decodeBytes(json['blob']),
      ),
      'revoked' => RevokeResult(
        deviceId: _string(json, 'deviceId'),
        refused: json['refused'] as String?,
        devices: json['devices'] == null
            ? null
            : [
                for (final d in _list(json, 'devices'))
                  SyncDevice.fromJson(_object(d)),
              ],
      ),
      'error' => RelayError(_string(json, 'code')),
      final String other => UnknownRelayMessage(other),
      final other => throw FormatException('message type missing', other),
    };
  }
}

class UnknownRelayMessage extends RelayMessage {
  const UnknownRelayMessage(this.type);

  @override
  final String type;

  @override
  Map<String, Object?> get fields => const {};
}

class Welcome extends RelayMessage {
  const Welcome({
    this.minProtocolVersion = syncProtocolVersion,
    this.token,
    required this.syncWrap,
    this.deviceWrap,
    this.snapshot,
    this.devices = const [],
  });

  final int minProtocolVersion;

  /// Issued after `create` or `enroll`; every later `hello` presents it.
  final String? token;
  final Uint8List syncWrap;

  /// The keys a revocation sealed to this device's public key; present
  /// from the revocation on, and ignored once this device holds them.
  final Uint8List? deviceWrap;

  /// Sent after `enroll`, and after `hello` when its cursor is older than
  /// what the snapshot covers.
  final RelaySnapshot? snapshot;
  final List<SyncDevice> devices;

  @override
  String get type => 'welcome';

  @override
  Map<String, Object?> get fields => {
    'minProtocolVersion': minProtocolVersion,
    'token': ?token,
    'syncWrap': encodeBytes(syncWrap),
    if (deviceWrap case final w?) 'deviceWrap': encodeBytes(w),
    if (snapshot case final s?) 'snapshot': s.toJson(),
    'devices': [for (final d in devices) d.toJson()],
  };
}

/// Frames in `seq` order. After a `welcome`, the catch-up comes first
/// (possibly empty): everything after the cursor, the device's own frames
/// included, since an acknowledgement may have been lost. A long one is
/// split over several messages; all but the last set [more].
class Frames extends RelayMessage {
  const Frames(this.frames, {this.more = false});

  final List<RelayFrame> frames;

  /// More catch-up follows in the next message.
  final bool more;

  @override
  String get type => 'frames';

  @override
  Map<String, Object?> get fields => {
    'frames': [for (final f in frames) f.toJson()],
    if (more) 'more': true,
  };
}

/// The `seq` assigned to each pushed frame, by its `clientId`.
class Pushed extends RelayMessage {
  const Pushed(this.seqs);

  final Map<String, int> seqs;

  @override
  String get type => 'pushed';

  @override
  Map<String, Object?> get fields => {
    'acks': [
      for (final MapEntry(:key, :value) in seqs.entries)
        {'clientId': key, 'seq': value},
    ],
  };
}

/// The relay now holds the uploaded snapshot covering [coversSeq]; only
/// then may the uploader drop the outbox ops the snapshot carries.
class SnapshotStored extends RelayMessage {
  const SnapshotStored(this.coversSeq);

  final int coversSeq;

  @override
  String get type => 'stored';

  @override
  Map<String, Object?> get fields => {'coversSeq': coversSeq};
}

class PresenceUpdate extends RelayMessage {
  const PresenceUpdate({required this.deviceId, required this.blob});

  final String deviceId;
  final Uint8List blob;

  @override
  String get type => 'presence';

  @override
  Map<String, Object?> get fields => {
    'deviceId': deviceId,
    'blob': encodeBytes(blob),
  };
}

/// The answer to [RevokeDevice]: applied when [refused] is null, else one
/// of the refusal codes below, and nothing changed.
class RevokeResult extends RelayMessage {
  const RevokeResult({required this.deviceId, this.refused, this.devices});

  /// The snapshot does not cover the head: frames are on their way.
  static const behind = 'behind';

  /// The wraps miss a remaining device: one enrolled meanwhile.
  static const devicesChanged = 'devicesChanged';

  /// No such device, the sender itself, or one already revoked.
  static const unknownDevice = 'unknownDevice';

  final String deviceId;
  final String? refused;

  /// The devices now listed, with [devicesChanged], so a retry seals the
  /// keys for them.
  final List<SyncDevice>? devices;

  @override
  String get type => 'revoked';

  @override
  Map<String, Object?> get fields => {
    'deviceId': deviceId,
    'refused': ?refused,
    if (devices case final d?) 'devices': [for (final x in d) x.toJson()],
  };
}

class RelayError extends RelayMessage {
  const RelayError(this.code);

  static const unauthorized = 'unauthorized';
  static const revoked = 'revoked';
  static const tooOld = 'tooOld';
  static const invalid = 'invalid';
  static const exists = 'exists';
  static const rateLimited = 'rateLimited';

  /// Sealed under a data key a revocation replaced; a new connection
  /// brings the new one in `welcome`.
  static const rekeyed = 'rekeyed';

  final String code;

  @override
  String get type => 'error';

  @override
  Map<String, Object?> get fields => {'code': code};
}

Map<String, Object?> _object(Object? value) {
  if (value is Map<String, Object?>) return value;
  throw const FormatException('expected an object');
}

List<Object?> _list(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is List<Object?>) return value;
  throw FormatException('expected a list', key);
}

String _string(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is String) return value;
  throw FormatException('expected a string', key);
}

int _int(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is int) return value;
  throw FormatException('expected an integer', key);
}

Map<String, Uint8List> _bytesMap(Map<String, Object?> json, String key) => {
  for (final MapEntry(:key, :value) in _object(json[key]).entries)
    key: decodeBytes(value),
};
