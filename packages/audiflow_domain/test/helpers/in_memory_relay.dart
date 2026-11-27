import 'dart:async';
import 'dart:typed_data';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:crypto/crypto.dart';

/// The relay's semantics in memory (plan P1, P6), for engine tests.
///
/// Messages go through their JSON encoding both ways, so the codec is
/// exercised, and every message the relay receives is kept in [received]
/// for checks that it never sees plaintext.
class InMemoryRelay {
  final _accounts = <String, _Account>{};

  /// Every client message as the relay received it.
  final received = <String>[];

  int _tokens = 0;

  /// Mirrors the relay's push limit; a larger push is refused.
  int maxFramesPerPush = 100;

  /// Frames per catch-up message; a longer catch-up sets `more`.
  int get catchUpPage => _catchUpPage;
  set catchUpPage(int value) {
    if (value <= 0) throw RangeError.value(value, 'catchUpPage');
    _catchUpPage = value;
  }

  int _catchUpPage = 1 << 30;

  /// When set, pushes are stored and fanned out but never acknowledged, as
  /// when the connection drops before the ack arrives.
  bool holdAcks = false;

  final _open = <InMemoryTransport>{};

  InMemoryTransport connect() {
    final t = InMemoryTransport._(this);
    _open.add(t);
    return t;
  }

  /// Drops every connection from the relay's side, as a relay restart or
  /// network loss does.
  Future<void> disconnectAll() async {
    for (final t in _open.toList()) {
      await t.close();
    }
  }

  /// Stores [blob] as the next frame of [accountId] from [deviceId] and
  /// fans it out, as a misbehaving device's push would.
  void inject(String accountId, String deviceId, Uint8List blob) {
    final account = _accounts[accountId]!;
    final frame = RelayFrame(
      seq: ++account.head,
      deviceId: deviceId,
      blob: blob,
    );
    account.frames.add(frame);
    for (final c in account.connections) {
      c._deliver(Frames([frame]));
    }
  }

  /// Sends [blob] as a presence from [deviceId] to every connection of
  /// [accountId].
  void injectPresence(String accountId, String deviceId, Uint8List blob) {
    for (final c in _accounts[accountId]!.connections) {
      c._deliver(PresenceUpdate(deviceId: deviceId, blob: blob));
    }
  }

  /// Delivers [text] as is to every connection of [accountId], as a newer
  /// relay's message would arrive.
  void injectRaw(String accountId, String text) {
    for (final c in _accounts[accountId]!.connections) {
      c._deliverRaw(text);
    }
  }

  /// Frames the relay stores for [accountId], for checks.
  List<RelayFrame> framesOf(String accountId) =>
      List.of(_accounts[accountId]!.frames);

  RelaySnapshot? snapshotOf(String accountId) => _accounts[accountId]!.snapshot;

  void _receive(InMemoryTransport from, String text) {
    received.add(text);
    final message = ClientMessage.decode(text);
    switch (message) {
      case CreateAccount():
        if (_accounts.containsKey(message.accountId)) {
          return from._deliver(const RelayError(RelayError.exists));
        }
        final account = _accounts[message.accountId] = _Account(
          verifier: message.authVerifier,
          syncWrap: message.syncWrap,
        );
        _admit(from, account, message.device, cursor: 0, issueToken: true);
      case EnrollDevice():
        final account = _accounts[message.accountId];
        if (account == null ||
            !_equal(
              sha256.convert(message.authSecret).bytes,
              account.verifier,
            )) {
          return from._deliver(const RelayError(RelayError.unauthorized));
        }
        if (account.devices[message.device.deviceId]?.revoked ?? false) {
          return from._deliver(const RelayError(RelayError.revoked));
        }
        _admit(from, account, message.device, cursor: 0, issueToken: true);
      case Hello():
        final account = _accounts[message.accountId];
        final device = account?.devices[message.deviceId];
        if (account == null ||
            device == null ||
            device.token != message.token) {
          return from._deliver(const RelayError(RelayError.unauthorized));
        }
        if (device.revoked) {
          return from._deliver(const RelayError(RelayError.revoked));
        }
        _admit(
          from,
          account,
          device.info,
          cursor: message.cursor,
          issueToken: false,
        );
      case PushFrames(:final frames):
        final account = from._account;
        if (account == null) {
          return from._deliver(const RelayError(RelayError.unauthorized));
        }
        if (maxFramesPerPush < frames.length) {
          return from._deliver(const RelayError(RelayError.invalid));
        }
        if (!frames.every((f) => account.isCurrent(f.blob))) {
          return from._deliver(const RelayError(RelayError.rekeyed));
        }
        final acks = <String, int>{};
        for (final f in frames) {
          final frame = RelayFrame(
            seq: ++account.head,
            deviceId: from._deviceId!,
            blob: f.blob,
          );
          account.frames.add(frame);
          acks[f.clientId] = frame.seq;
          for (final other in account.connections) {
            if (other != from) other._deliver(Frames([frame]));
          }
        }
        if (!holdAcks) from._deliver(Pushed(acks));
      case UploadSnapshot(:final snapshot):
        final account = from._account;
        if (account == null) {
          return from._deliver(const RelayError(RelayError.unauthorized));
        }
        if (!account.isCurrent(snapshot.blob)) {
          return from._deliver(const RelayError(RelayError.rekeyed));
        }
        final current = account.snapshot;
        if (snapshot.coversSeq <= account.head &&
            (current == null || current.coversSeq <= snapshot.coversSeq)) {
          account.snapshot = snapshot;
          account.frames.removeWhere((f) => f.seq <= snapshot.coversSeq);
        }
        from._deliver(SnapshotStored(snapshot.coversSeq));
      case SendPresence(:final blob):
        final account = from._account;
        if (account == null) {
          return from._deliver(const RelayError(RelayError.unauthorized));
        }
        if (!account.isCurrent(blob)) {
          return from._deliver(const RelayError(RelayError.rekeyed));
        }
        final update = PresenceUpdate(deviceId: from._deviceId!, blob: blob);
        for (final c in account.connections) {
          if (c != from) c._deliver(update);
        }
      case RevokeDevice():
        _revoke(from, message);
    }
  }

  /// Counts revocations the relay applied, for checks.
  int revocations = 0;

  /// When set, a revocation applies but its answer is lost, as when the
  /// connection drops right after.
  bool dropRevokeResults = false;

  void _revoke(InMemoryTransport from, RevokeDevice m) {
    final account = from._account;
    if (account == null) {
      return from._deliver(const RelayError(RelayError.unauthorized));
    }
    final next = SyncCipher.keyVersionOf(m.newSyncWrap);
    final sealedUnderNext =
        account.keyVersion < next &&
        SyncCipher.keyVersionOf(m.snapshot.blob) == next &&
        m.deviceWraps.values.every(
          (w) => SyncCipher.keyVersionOf(w.sublist(32)) == next,
        );
    if (!sealedUnderNext) {
      return from._deliver(const RelayError(RelayError.invalid));
    }
    RevokeResult refuse(String code) =>
        RevokeResult(deviceId: m.deviceId, refused: code);
    final target = account.devices[m.deviceId];
    if (m.deviceId == from._deviceId || target == null || target.revoked) {
      return from._deliver(refuse(RevokeResult.unknownDevice));
    }
    final remaining = {
      for (final d in account.devices.values)
        if (!d.revoked && d != target) d.info.deviceId,
    };
    if (remaining.length != m.deviceWraps.length ||
        !remaining.every(m.deviceWraps.containsKey)) {
      return from._deliver(refuse(RevokeResult.devicesChanged));
    }
    if (m.snapshot.coversSeq != account.head) {
      return from._deliver(refuse(RevokeResult.behind));
    }
    target.revoked = true;
    account
      ..verifier = m.newAuthVerifier
      ..syncWrap = m.newSyncWrap
      ..snapshot = m.snapshot
      ..deviceWraps = Map.of(m.deviceWraps);
    account.frames.removeWhere((f) => f.seq <= m.snapshot.coversSeq);
    revocations++;
    if (!dropRevokeResults) from._deliver(RevokeResult(deviceId: m.deviceId));
    for (final other in account.connections.toList()) {
      if (other == from) continue;
      other._deliver(
        RelayError(
          other._deviceId == m.deviceId
              ? RelayError.revoked
              : RelayError.rekeyed,
        ),
      );
      unawaited(other._closeAfterDelivery());
    }
  }

  void _admit(
    InMemoryTransport from,
    _Account account,
    SyncDevice device, {
    required int cursor,
    required bool issueToken,
  }) {
    final record = account.devices[device.deviceId] ??= _Device(device);
    if (issueToken) record.token = 'token-${++_tokens}';
    from
      .._account = account
      .._deviceId = device.deviceId;
    account.connections.add(from);
    final snapshot = account.snapshot;
    // An enrolling device has merged nothing yet, even when the snapshot
    // covers no frame at all.
    final sendSnapshot =
        snapshot != null && (issueToken || cursor < snapshot.coversSeq);
    from._deliver(
      Welcome(
        token: issueToken ? record.token : null,
        syncWrap: account.syncWrap,
        deviceWrap: account.deviceWraps[device.deviceId],
        snapshot: sendSnapshot ? snapshot : null,
        devices: [
          for (final d in account.devices.values)
            if (!d.revoked) d.info,
        ],
      ),
    );
    final after = sendSnapshot ? snapshot.coversSeq : cursor;
    final backlog = [...account.frames.where((f) => after < f.seq)];
    var start = 0;
    do {
      final end = backlog.length < start + catchUpPage
          ? backlog.length
          : start + catchUpPage;
      from._deliver(
        Frames(backlog.sublist(start, end), more: end < backlog.length),
      );
      start = end;
    } while (start < backlog.length);
  }

  static bool _equal(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class _Account {
  _Account({required this.verifier, required this.syncWrap});

  List<int> verifier;
  Uint8List syncWrap;
  Map<String, Uint8List> deviceWraps = const {};

  int get keyVersion => SyncCipher.keyVersionOf(syncWrap);

  /// Whether [blob] is sealed under the current data key; tests that
  /// inject hand-made blobs too short to name one pass.
  bool isCurrent(Uint8List blob) =>
      blob.length < 5 || SyncCipher.keyVersionOf(blob) == keyVersion;
  final devices = <String, _Device>{};
  final frames = <RelayFrame>[];
  RelaySnapshot? snapshot;
  int head = 0;
  final connections = <InMemoryTransport>{};
}

class _Device {
  _Device(this.info);

  final SyncDevice info;
  String? token;
  bool revoked = false;
}

class InMemoryTransport implements SyncTransport {
  InMemoryTransport._(this._relay);

  final InMemoryRelay _relay;
  final _controller = StreamController<RelayMessage>();
  _Account? _account;
  String? _deviceId;
  bool _closed = false;

  @override
  Stream<RelayMessage> get messages => _controller.stream;

  @override
  void send(ClientMessage message) {
    if (_closed) return;
    final text = message.encode();
    // Delivered later, as over a socket.
    scheduleMicrotask(() {
      if (!_closed) _relay._receive(this, text);
    });
  }

  /// Fails the message stream, as a socket error does.
  void fail(Object error) {
    if (!_closed) _controller.addError(error);
  }

  void _deliver(RelayMessage message) => _deliverRaw(message.encode());

  void _deliverRaw(String text) {
    if (_closed) return;
    scheduleMicrotask(() {
      if (!_closed) _controller.add(RelayMessage.decode(text));
    });
  }

  /// Closes once what was delivered before has arrived, as a socket the
  /// relay closes after a last message does.
  Future<void> _closeAfterDelivery() async {
    await Future<void>.delayed(Duration.zero);
    await close();
  }

  /// Drops the connection, as going offline does.
  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    _account?.connections.remove(this);
    _relay._open.remove(this);
    // Not awaited: a single-subscription stream's close completes only
    // once a listener takes the done event, and none may be listening.
    unawaited(_controller.close());
  }
}
