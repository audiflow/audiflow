import 'dart:async';
import 'dart:typed_data';

import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../../snapshot/backup_file.dart';
import '../../snapshot/restore_projector.dart';
import '../../snapshot/snapshot_body.dart';
import '../../snapshot/snapshot_exporter.dart';
import '../../snapshot/snapshot_file.dart';
import '../../snapshot/snapshot_merger.dart';
import '../../station/models/station.dart';
import '../../subscription/models/subscriptions.dart';
import '../../user_state/models/outbox_op.dart';
import '../../user_state/models/sync_meta.dart';
import '../../user_state/services/key_reconciler.dart';
import '../../user_state/services/sync_meta_access.dart';
import '../../user_state/sync/user_state_fields.dart';
import '../crypto/sync_cipher.dart';
import '../crypto/sync_credentials.dart';
import '../protocol/sync_messages.dart';
import 'sync_frame.dart';
import 'sync_presence.dart';
import 'sync_session.dart';
import 'sync_transport.dart';

/// Sends the outbox to the relay and merges what other devices sent
/// (docs/architecture/user-data-sync.md, "Write path and sync engine").
///
/// Everything runs one step at a time on a serial queue, so a merge never
/// races a send over the same outbox rows. A received frame merges with
/// the snapshot rules, then the rows the app reads are projected again.
///
/// One engine serves one connection. When the relay refuses a request or
/// the connection drops, [done] completes with the [SyncRelayFailure] and
/// the engine stops; the caller connects a new one, and the outbox and the
/// cursor carry over.
class SyncEngine {
  SyncEngine({
    required this._isar,
    required this._session,
    required this._transport,
    required this._syncFeeds,
    required this._appVersion,
    required this._platform,
    required this._logger,
    this._onStationChanged,
    this._onSessionChanged,
    this._onDevices,
    this._onPresence,
    this._onEpisodesMerged,
    int Function()? nowMillis,
    this.steadyInterval = const Duration(seconds: 30),
    this.maxOpsPerFrame = 500,
    this.maxRowsPerFrame = 500,
    this.maxFrameBytes = 700 * 1024,
    this.maxFramesPerPush = 100,
    this.maxPushBytes = 5 * 1024 * 1024,
  }) : assert(0 < maxOpsPerFrame && 0 < maxRowsPerFrame),
       assert(0 < maxFrameBytes && 0 < maxFramesPerPush && 0 < maxPushBytes),
       _nowMillis = nowMillis ?? _wallClock,
       _cipher = SyncCipher(_session.credentials.accountId) {
    // A failure nobody awaited yet must not surface as an unhandled error;
    // a later listener on [done] still sees it.
    unawaited(_done.future.then<void>((_) {}, onError: (_) {}));
    // Likewise for an engine closed before [connect] was called.
    unawaited(_ready.future.then<void>((_) {}, onError: (_) {}));
  }

  final Isar _isar;
  final SyncSession _session;
  final SyncTransport _transport;
  final Future<void> Function(List<String> feedUrls) _syncFeeds;
  final Future<void> Function(int stationId)? _onStationChanged;
  final String _appVersion;
  final String _platform;
  final Logger _logger;
  final void Function(SyncSession session)? _onSessionChanged;

  /// The account's devices as the relay lists them on `welcome`.
  final void Function(List<SyncDevice> devices)? _onDevices;

  /// Another device's presence, opened and decoded.
  final void Function(String deviceId, SyncPresence presence)? _onPresence;

  /// The episodeKeys of rows another device's changes reached, after they
  /// are stored, so a paused player can take the newer position.
  final void Function(Set<String> episodeKeys)? _onEpisodesMerged;

  /// How often changes made only by playing (position, listened time) go
  /// out. Anything else goes at once, as does everything after
  /// [sendSoon] (design doc, Realtime playback position).
  final Duration steadyInterval;
  final int Function() _nowMillis;
  final SyncCipher _cipher;

  /// Ops per frame: bounds a frame's size after a long offline stretch.
  /// A row's ops are never split, so a frame can go over by one row.
  final int maxOpsPerFrame;

  /// Rows per frame when the whole state goes out.
  final int maxRowsPerFrame;

  /// Sealed bytes per frame and per push, and frames per push: below the
  /// relay's limits (1 MB and 8 MB of base64url, 100 frames), since
  /// base64url adds a third.
  final int maxFrameBytes;
  final int maxFramesPerPush;
  final int maxPushBytes;

  static int _wallClock() => DateTime.now().millisecondsSinceEpoch;

  /// Send order of entities: a row's parent goes first, since a receiver
  /// rejects a counter whose episode it has never seen, and frames merge
  /// in order.
  static final _entityRank = {
    for (final (i, e) in [
      UserStateEntities.podcast,
      UserStateEntities.podcastInfo,
      UserStateEntities.playOrder,
      UserStateEntities.episode,
      UserStateEntities.episodeCounter,
      UserStateEntities.queueEntry,
      UserStateEntities.station,
      UserStateEntities.stationMember,
      UserStateEntities.setting,
    ].indexed)
      e.name: i,
  };

  static int _rankOf(String entity) =>
      _entityRank[entity] ?? _entityRank.length;
  static const _uuid = Uuid();

  /// Episode fields that station filters read (favorites only, hide
  /// completed), so a received change of them rebuilds station lists.
  static final _stationFilterFields = {
    for (final f in UserStateEntities.episode.fields)
      if (f.name == 'favoritedAt' || f.name == 'completedAt') f.id,
  };

  /// Episode and counter fields that playing rewrites every few seconds,
  /// with the fields that have no clock: every write of a row carries
  /// them (a row's identity, such as an episode's podcastKey).
  static final _steadyFields = {
    for (final f in UserStateEntities.episode.fields)
      if (f.hlc == null ||
          const {
            'hasPlayback',
            'positionMs',
            'durationMs',
            'lastPlayedAt',
          }.contains(f.name))
        (UserStateEntities.episode.name, f.id),
    for (final f in UserStateEntities.episodeCounter.fields)
      if (f.hlc == null || const {'listenedMs', 'realtimeMs'}.contains(f.name))
        (UserStateEntities.episodeCounter.name, f.id),
  };

  /// When the last push went out, by [_nowMillis].
  int? _lastPushAt;

  /// Until when steady changes go at once, by [_nowMillis]: set by
  /// [sendSoon], long enough for the save that follows a pause to land.
  int _urgentUntil = 0;
  Timer? _steadyTimer;

  /// Completes when the relay acknowledges a push or stores a snapshot,
  /// for [drain].
  Completer<void>? _progress;

  void _completeProgress() {
    _progress?.complete();
    _progress = null;
  }

  Future<void> _queue = Future.value();
  StreamSubscription<RelayMessage>? _messages;
  StreamSubscription<void>? _outboxWatch;
  final _ready = Completer<void>();
  final _done = Completer<void>();
  SyncOpening _opening = SyncOpening.resume;
  bool _welcomed = false;
  bool _caughtUp = false;
  bool _closed = false;

  /// The push waiting for `pushed`: its frames' client ids, each op's id
  /// and clock when sent, and whether it carries the whole state. One push
  /// at a time keeps the frames in outbox order.
  ({Set<String> clientIds, Map<int, int> ops, bool fullState})? _inFlight;

  /// A whole-state send in progress: the pushes not yet sent, the ops
  /// pending at the export, and the request it answers.
  ({List<List<PushFrame>> pushes, Map<int, int> ops, int request})? _fullState;

  /// A snapshot upload is waiting for `stored`; sends wait with it, so the
  /// relay compacts before anything newer lands.
  bool _snapshotPending = false;

  /// The account's devices as the last `welcome` listed them, less any
  /// this device revoked since: who a revocation seals the new keys to.
  List<SyncDevice> _devices = const [];

  /// A revocation asked for and not yet answered; sends wait while it is.
  _Revocation? _revocation;

  /// Refusals for being behind the head before a revocation gives up: each
  /// one means frames arrived first, so the next try usually lands.
  static const _maxRevokeRetries = 3;

  /// Completes when the session ends: normally after [close], with a
  /// [SyncRelayFailure] when the relay refused something or the connection
  /// dropped.
  Future<void> get done => _done.future;

  /// Opens the connection and returns once this device has caught up:
  /// the account's snapshot and every frame after the cursor are merged,
  /// and the outbox is on its way. Throws [SyncRelayFailure] when the
  /// relay refuses.
  Future<void> connect(SyncOpening opening) {
    _opening = opening;
    _messages = _transport.messages.listen(
      (message) => _enqueue(() => _handle(message)),
      onError: (Object e, StackTrace stack) {
        _logger.w('Sync transport failed', error: e, stackTrace: stack);
        _enqueue(() async {
          throw const SyncRelayFailure(SyncRelayFailure.closed);
        });
      },
      onDone: () => _enqueue(() async {
        throw const SyncRelayFailure(SyncRelayFailure.closed);
      }),
    );
    _outboxWatch = _isar.outboxOps.watchLazy().listen((_) => _enqueue(_flush));
    _enqueue(() async {
      // Every later step reads it; a first launch writes it before sync
      // can be turned on, but a reset may have cleared it.
      await _isar.writeTxn(() => loadOrCreateSyncMeta(_isar));
      _transport.send(await _openingMessage(opening));
    });
    return _ready.future;
  }

  /// Runs once every step queued so far has finished; for tests and for a
  /// clean shutdown.
  Future<void> settle() => _queue;

  /// Sends pending changes at once, steady ones included, and keeps doing
  /// so for a moment: called on pause, seek, stop, and completion, around
  /// the save they cause.
  void sendSoon() {
    if (_closed) return;
    _urgentUntil = _nowMillis() + _urgentWindowMs;
    _enqueue(_flush);
  }

  static const _urgentWindowMs = 2000;

  /// Live-session [SyncPresence] for the other online devices. Dropped
  /// before the session is ready; a presence is only worth its moment.
  void sendPresence(SyncPresence presence) {
    if (_closed) return;
    _enqueue(() async {
      // Sealed under the key a revocation in flight retires, the relay
      // would refuse it and end the session.
      if (!_caughtUp || _revocation?.sent != null) return;
      final blob = await _seal(
        Uint8List.fromList(presence.encode()),
        SealPurpose.presence,
      );
      _transport.send(SendPresence(blob));
    });
  }

  /// Sends what is pending and waits, up to [timeout], for the relay to
  /// acknowledge it: before closing as the app goes to the background.
  ///
  /// One deadline covers the whole call: queued steps, each push and its
  /// acknowledgement, and the pushes an acknowledgement lets go. It returns
  /// early once nothing is waiting for the relay.
  Future<void> drain({Duration timeout = const Duration(seconds: 3)}) async {
    if (_closed) return;
    final deadline = _nowMillis() + timeout.inMilliseconds;
    // Steady changes must not wait for their interval meanwhile.
    _urgentUntil = deadline;
    _enqueue(_flush);
    final stopwatch = Stopwatch()..start();
    Duration left() => timeout - stopwatch.elapsed;
    while (!_closed && Duration.zero < left()) {
      final queued = await _queue
          .then((_) => true)
          .timeout(left(), onTimeout: () => false);
      if (!queued || _closed) return;
      // Nothing sent and nothing on its way: whatever is left cannot go
      // now (not caught up yet), so waiting would only spin.
      if (_inFlight == null && !_snapshotPending) return;
      final progress = _progress ??= Completer<void>();
      final moved = await progress.future
          .then((_) => true)
          .timeout(left(), onTimeout: () => false);
      if (!moved) return;
    }
  }

  /// Removes [deviceId] from the account and rotates the sync key and the
  /// data key, so the removed device can neither read what follows nor
  /// enroll again; the recovery code changes with the sync key. It waits
  /// until nothing is on its way to the relay, as the state it sends along
  /// must cover the head, and holds back sends meanwhile.
  ///
  /// Throws [SyncRevokeFailure] when the relay refused, and
  /// [SyncRelayFailure] when the session ended first. In that case the
  /// revocation may still have applied; the next connection shows it, in
  /// the device list and in this device's own wrap.
  Future<void> revoke(String deviceId) {
    if (_closed) {
      return Future.error(const SyncRelayFailure(SyncRelayFailure.closed));
    }
    if (_revocation != null) {
      return Future.error(StateError('a revocation is in progress'));
    }
    final revocation = _revocation = _Revocation(deviceId);
    _enqueue(_tryRevoke);
    return revocation.done.future;
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    _endRevocation(const SyncRelayFailure(SyncRelayFailure.closed));
    _steadyTimer?.cancel();
    _completeProgress();
    await _outboxWatch?.cancel();
    await _messages?.cancel();
    await _queue;
    if (!_ready.isCompleted) {
      _ready.completeError(const SyncRelayFailure(SyncRelayFailure.closed));
    }
    if (!_done.isCompleted) _done.complete();
    await _closeTransport();
  }

  Future<void> _closeTransport() async {
    try {
      await _transport.close();
    } on Object catch (e, stack) {
      _logger.w('Sync transport close failed', error: e, stackTrace: stack);
    }
  }

  void _enqueue(Future<void> Function() step) {
    _queue = _queue.then((_) async {
      if (_closed) return;
      try {
        await step();
      } on SyncRelayFailure catch (e) {
        await _fail(e);
      } on Object catch (e, stack) {
        // IsarError extends Error. A failed step can leave a push waiting
        // or a merge half projected, so the session ends; the outbox and
        // cursor only move once a step succeeds, so reconnecting retries.
        _logger.e('Sync step failed', error: e, stackTrace: stack);
        await _fail(const SyncRelayFailure(SyncRelayFailure.internal));
      }
    });
  }

  /// Ends the session: a push left waiting would block every later send,
  /// and the relay keeps the frames it acknowledged, so a new connection
  /// resumes from the cursor and sends the outbox again.
  Future<void> _fail(SyncRelayFailure failure) async {
    _logger.w('Sync session ended: ${failure.code}');
    _closed = true;
    _endRevocation(failure);
    _steadyTimer?.cancel();
    _completeProgress();
    _inFlight = null;
    _fullState = null;
    _snapshotPending = false;
    // Completed first: nothing below may keep a caller waiting.
    if (!_ready.isCompleted) _ready.completeError(failure);
    if (!_done.isCompleted) _done.completeError(failure);
    try {
      await _outboxWatch?.cancel();
      await _messages?.cancel();
    } on Object catch (e, stack) {
      _logger.w('Sync cleanup failed', error: e, stackTrace: stack);
    }
    await _closeTransport();
  }

  Future<ClientMessage> _openingMessage(SyncOpening opening) async {
    final keys = await SyncKeyDerivation.derive(_session.syncKey);
    switch (opening) {
      case SyncOpening.create:
        final dataKey = _session.dataKey ??= DataKey(
          SyncCipher.generateKey(),
          version: 1,
        );
        return CreateAccount(
          accountId: _session.accountId,
          authVerifier: SyncKeyDerivation.authVerifier(keys.authSecret),
          syncWrap: await KeyWraps.sealSyncWrap(
            _cipher,
            wrapKey: keys.wrapKey,
            keys: dataKey,
          ),
          device: _session.device,
        );
      case SyncOpening.join:
        return EnrollDevice(
          accountId: _session.accountId,
          authSecret: keys.authSecret,
          device: _session.device,
        );
      case SyncOpening.resume:
        final token = _session.token;
        if (token == null) {
          throw const SyncRelayFailure(SyncRelayFailure.notEnrolled);
        }
        return Hello(
          accountId: _session.accountId,
          deviceId: _session.device.deviceId,
          token: token,
          cursor: (await _meta())?.serverCursor ?? 0,
        );
    }
  }

  Future<void> _handle(RelayMessage message) async {
    switch (message) {
      case Welcome():
        await _onWelcome(message);
      case Frames(:final frames, :final more):
        await _onFrames(frames, more: more);
      case Pushed(:final seqs):
        await _onPushed(seqs);
      case SnapshotStored():
        _snapshotPending = false;
        _completeProgress();
        await _flush();
      case UnknownRelayMessage(:final type):
        // A newer relay's message this version cannot use.
        _logger.d('Ignoring relay message $type');
      case PresenceUpdate(:final deviceId, :final blob):
        await _onPresenceUpdate(deviceId, blob);
      case RevokeResult():
        await _onRevokeResult(message);
      case RelayError(:final code):
        throw SyncRelayFailure(code);
    }
  }

  Future<void> _onWelcome(Welcome welcome) async {
    if (syncProtocolVersion < welcome.minProtocolVersion) {
      throw const SyncRelayFailure(RelayError.tooOld);
    }
    var changed = false;
    // Before the sync key wrap: after a revocation this device's sync key
    // no longer opens it.
    if (welcome.deviceWrap case final wrap?) {
      changed = await _adoptDeviceWrap(wrap);
    }
    if (_session.dataKey == null) {
      final keys = await SyncKeyDerivation.derive(_session.syncKey);
      _session.dataKey = await KeyWraps.openSyncWrap(
        _cipher,
        wrapKey: keys.wrapKey,
        blob: welcome.syncWrap,
      );
      changed = true;
    }
    final snapshot = welcome.snapshot;
    // Without the snapshot a joining device cannot learn the account's
    // history, and its own would spread with its upload.
    if (_opening == SyncOpening.join && snapshot == null) {
      throw const SyncRelayFailure(SyncRelayFailure.accountNotReady);
    }
    // Recorded before anything is sent, so a stop before the relay holds
    // the whole state sends it again on the next connection (plan P9).
    if (_opening != SyncOpening.resume) await _requestFullState();
    // Joining merges it even at the same cursor: a snapshot of a new account
    // covers seq 0.
    if (snapshot != null &&
        (_opening == SyncOpening.join ||
            (await _meta())!.serverCursor < snapshot.coversSeq)) {
      await _mergeSnapshot(snapshot);
    }
    // Handed out last: the caller stores the session, and a device with a
    // stored token resumes. A stop before this point joins again, which
    // repeats the history adoption and the snapshot merge; the relay
    // re-enrolls the same device.
    if (welcome.token case final token?) {
      _session.token = token;
      changed = true;
    }
    if (changed) _onSessionChanged?.call(_session);
    _devices = List.unmodifiable(welcome.devices);
    _onDevices?.call(_devices);
    _welcomed = true;
  }

  /// Takes the keys a revocation sealed to this device, unless it holds
  /// them already. A sync key that differs at the same version is taken
  /// too: storing the rotated credentials failed after the revocation.
  ///
  /// A wrap that does not open changes nothing: frames under the new key
  /// then fail to open and the session ends as [SyncRelayFailure.unreadableFrame].
  Future<bool> _adoptDeviceWrap(Uint8List wrap) async {
    final keyPair = _session.keyPair;
    if (keyPair == null) return false;
    final DeviceSecrets secrets;
    try {
      secrets = await KeyWraps.openDeviceWrap(
        _cipher,
        keyPair: keyPair,
        blob: wrap,
      );
    } on SyncCryptoFailure catch (e) {
      _logger.w('Unreadable device wrap', error: e);
      return false;
    }
    final held = _session.dataKey;
    if (held != null) {
      if (secrets.dataKey.version < held.version) return false;
      if (secrets.dataKey.version == held.version &&
          _sameBytes(secrets.syncKey, _session.syncKey)) {
        return false;
      }
    }
    _session
      ..credentials = SyncCredentials(
        accountId: _session.credentials.accountId,
        syncKey: secrets.syncKey,
      )
      ..dataKey = secrets.dataKey;
    return true;
  }

  static bool _sameBytes(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Sends the revocation once nothing else is on its way: then the
  /// cursor is the head, unless frames from others are still arriving,
  /// which the relay answers with [RevokeResult.behind].
  Future<void> _tryRevoke() async {
    final revocation = _revocation;
    if (revocation == null || revocation.sent != null) return;
    if (!_caughtUp ||
        _inFlight != null ||
        _snapshotPending ||
        _fullState != null) {
      return;
    }
    final target = revocation.deviceId;
    if (target == _session.device.deviceId ||
        !_devices.any((d) => d.deviceId == target)) {
      _endRevocation(const SyncRevokeFailure(RevokeResult.unknownDevice));
      return;
    }
    final credentials = SyncCredentials(
      accountId: _session.credentials.accountId,
      syncKey: SyncCipher.generateKey(),
    );
    final dataKey = DataKey(
      SyncCipher.generateKey(),
      version: _session.dataKey!.version + 1,
    );
    final keys = await SyncKeyDerivation.derive(credentials.syncKey);
    final deviceWraps = <String, Uint8List>{
      for (final d in _devices)
        if (d.deviceId != target)
          d.deviceId: await KeyWraps.sealDeviceWrap(
            _cipher,
            recipientPublicKey: d.publicKey,
            syncKey: credentials.syncKey,
            keys: dataKey,
          ),
    };
    final backup = await buildBackupFile(
      _isar,
      now: DateTime.fromMillisecondsSinceEpoch(_nowMillis(), isUtc: true),
      appVersion: _appVersion,
      platform: _platform,
    );
    final message = RevokeDevice(
      deviceId: target,
      newAuthVerifier: SyncKeyDerivation.authVerifier(keys.authSecret),
      newSyncWrap: await KeyWraps.sealSyncWrap(
        _cipher,
        wrapKey: keys.wrapKey,
        keys: dataKey,
      ),
      deviceWraps: deviceWraps,
      snapshot: RelaySnapshot(
        coversSeq: (await _meta())?.serverCursor ?? 0,
        blob: await _seal(backup.bytes, SealPurpose.snapshot, key: dataKey),
      ),
    );
    // A step above may have been outrun by a close.
    if (_closed || !identical(_revocation, revocation)) return;
    revocation.sent = (credentials: credentials, dataKey: dataKey);
    _transport.send(message);
  }

  Future<void> _onRevokeResult(RevokeResult result) async {
    final revocation = _revocation;
    final sent = revocation?.sent;
    if (revocation == null ||
        sent == null ||
        revocation.deviceId != result.deviceId) {
      return;
    }
    switch (result.refused) {
      case null:
        _session
          ..credentials = sent.credentials
          ..dataKey = sent.dataKey;
        _onSessionChanged?.call(_session);
        _devices = List.unmodifiable([
          for (final d in _devices)
            if (d.deviceId != revocation.deviceId) d,
        ]);
        _onDevices?.call(_devices);
        _endRevocation(null);
      case RevokeResult.behind when revocation.behindCount < _maxRevokeRetries:
        // The frames that put the head ahead arrived before this answer.
        revocation
          ..behindCount += 1
          ..sent = null;
        return _tryRevoke();
      case final String code:
        _endRevocation(SyncRevokeFailure(code));
    }
    await _flush();
  }

  /// Answers the caller of [revoke]: with [error], or done when null.
  void _endRevocation(Object? error) {
    final revocation = _revocation;
    if (revocation == null) return;
    _revocation = null;
    if (error == null) {
      revocation.done.complete();
    } else {
      revocation.done.completeError(error);
    }
  }

  Future<void> _mergeSnapshot(RelaySnapshot snapshot) async {
    final file = readSnapshotFile(
      await _open(snapshot.blob, SealPurpose.snapshot),
    );
    // Joining adopts the account's history (plan P9), so its tombstones
    // and horizon apply here from now on. The old horizon belongs to
    // another history and would drop live rows of this one, so it resets;
    // the merge then raises it to the account's, after the snapshot's own
    // rows are in (they are live however old their clocks).
    if (_opening == SyncOpening.join && file.header.historyId.isNotEmpty) {
      await _isar.writeTxn(() async {
        final meta = await _isar.syncMetas.get(SyncMeta.singletonId);
        if (meta == null || meta.historyId == file.header.historyId) return;
        await _isar.syncMetas.put(
          meta
            ..historyId = file.header.historyId
            ..tombstoneHorizon = 0,
        );
      });
    }
    final now = _nowMillis();
    final reconciler = KeyReconciler(_isar);
    final sections = await reconciler.translate(file.body.sections);
    final merged = await _mergerAt(now).mergeSections(
      sections,
      historyId: file.header.historyId,
      tombstoneHorizon: file.header.tombstoneHorizon,
      recordOps: false,
    );
    await dropBeatenOps(_isar, receivedFields(sections), nowMillis: now);
    // The whole account arrived; any show or episode in it may be one this
    // device keys differently.
    final joined = await reconciler.reconcile();
    await _project(sections, merged, joined, wholeLibrary: true);
    await _setCursor(snapshot.coversSeq);
  }

  Future<void> _onFrames(List<RelayFrame> frames, {required bool more}) async {
    if (!_welcomed) throw const SyncRelayFailure(RelayError.invalid);
    for (final frame in frames) {
      if (frame.seq <= (await _meta())!.serverCursor) continue;
      // Its own frames come back in a catch-up after a lost ack; their
      // content is already here.
      if (frame.deviceId != _session.device.deviceId) {
        await _mergeFrame(frame);
      }
      await _setCursor(frame.seq);
    }
    // A revocation refused for being behind waits for these.
    if (_caughtUp) return _tryRevoke();
    if (more) return;
    _caughtUp = true;
    // After creating or joining, or when the outbox cap dropped ops, only
    // the whole state carries everything.
    final meta = (await _meta())!;
    if (meta.fullStateSent < meta.fullStateRequested) {
      await _pushFullState();
    } else {
      await _flush();
    }
    if (!_ready.isCompleted) _ready.complete();
  }

  Future<void> _mergeFrame(RelayFrame relayed) async {
    final SyncFrame frame;
    final SnapshotMergeResult merged;
    // The merge clamps clocks against this time; cleanup must use the same
    // cutoff, or a local write made meanwhile could look beaten.
    final now = _nowMillis();
    final reconciler = KeyReconciler(_isar);
    final Map<String, List<SnapshotRow>> sections;
    try {
      frame = SyncFrame.decode(await _open(relayed.blob, SealPurpose.frame));
      sections = await reconciler.translate(frame.sections);
      merged = await _mergerAt(
        now,
      ).mergeSections(sections, historyId: frame.historyId, recordOps: false);
    } on Object catch (e) {
      if (e is! SyncCryptoFailure &&
          e is! SnapshotReadFailure &&
          e is! FormatException) {
        rethrow;
      }
      // Not skipped: the cursor stays before the frame, so a snapshot this
      // device uploads never claims to cover what it did not merge.
      _logger.w('Sync frame ${relayed.seq} unreadable: $e');
      throw const SyncRelayFailure(SyncRelayFailure.unreadableFrame);
    }
    final fields = receivedFields(sections).toList();
    await dropBeatenOps(_isar, fields, nowMillis: now);
    final joined = await reconciler.reconcile(
      podcastKeys: _keysOf(sections, UserStateEntities.podcast),
      episodeKeys: _keysOf(sections, UserStateEntities.episode),
    );
    final stationsAffected = fields.any(
      (f) =>
          f.entity == UserStateEntities.episode.name &&
          _stationFilterFields.contains(f.fieldId),
    );
    await _project(
      sections,
      merged,
      joined,
      wholeLibrary: false,
      stationsAffected: stationsAffected,
    );
  }

  SnapshotMerger _mergerAt(int now) =>
      SnapshotMerger(_isar, nowMillis: () => now);

  static Set<String> _keysOf<T>(
    Map<String, List<SnapshotRow>> sections,
    EntitySpec<T> spec,
  ) => {for (final row in sections[spec.name] ?? const []) row.key};

  /// Turns merged state into the rows the app reads. Position, progress,
  /// favorites, and settings are read from the state itself and need none;
  /// station lists filtered on favorites or completion are rebuilt.
  Future<void> _project(
    Map<String, List<SnapshotRow>> sections,
    SnapshotMergeResult merged,
    KeyReconcileResult joined, {
    required bool wholeLibrary,
    bool stationsAffected = false,
  }) async {
    final projector = RestoreProjector(_isar);
    final library =
        wholeLibrary ||
        joined.podcastsJoined ||
        sections.containsKey(UserStateEntities.podcast.name) ||
        sections.containsKey(UserStateEntities.station.name) ||
        sections.containsKey(UserStateEntities.stationMember.name);
    final stationIds = <int>{};
    if (library) {
      final projection = await projector.projectLibrary(
        podcastInfo: merged.podcastInfo,
      );
      stationIds.addAll(projection.stationIds);
      if (projection.feedUrls.isNotEmpty) {
        unawaited(_fetchFeeds(projection.feedUrls));
      }
    }
    if (library ||
        joined.queueChanged ||
        sections.containsKey(UserStateEntities.queueEntry.name)) {
      await projector.projectQueue();
    }
    // A joined episode's favorite or completion now counts for its local
    // row, which station filters read.
    if (stationsAffected || joined.episodeKeys.isNotEmpty) {
      stationIds.addAll(await _isar.stations.where().idProperty().findAll());
    }
    await _reconcileStations(stationIds);
    final episodeKeys = {
      ..._keysOf(sections, UserStateEntities.episode),
      ...joined.episodeKeys,
    };
    if (episodeKeys.isNotEmpty) _onEpisodesMerged?.call(episodeKeys);
  }

  Future<void> _reconcileStations(Set<int> ids) async {
    final reconcile = _onStationChanged;
    if (reconcile == null) return;
    for (final id in ids) {
      try {
        await reconcile(id);
      } on Object catch (e, stack) {
        _logger.w(
          'Station reconcile after sync failed',
          error: e,
          stackTrace: stack,
        );
      }
    }
  }

  Future<void> _fetchFeeds(List<String> urls) async {
    try {
      await _syncFeeds(urls);
    } on Object catch (e, stack) {
      _logger.w('Feed fetch after sync failed', error: e, stackTrace: stack);
      return;
    }
    if (_closed) return;
    // The fetched episodes may be ones that state from another device
    // names by other keys.
    _enqueue(() => _joinAfterFetch(urls));
  }

  Future<void> _joinAfterFetch(List<String> urls) async {
    try {
      final keys = <String>{};
      for (final url in urls) {
        final subs = await _isar.subscriptions
            .filter()
            .feedUrlEqualTo(url)
            .findAll();
        keys.addAll([for (final s in subs) ?s.podcastKey]);
      }
      if (keys.isEmpty) return;
      final joined = await KeyReconciler(_isar).reconcile(podcastKeys: keys);
      if (joined.isEmpty) return;
      await _project(
        const {},
        const SnapshotMergeResult(
          changedRows: 0,
          sameHistory: true,
          podcastInfo: {},
        ),
        joined,
        wholeLibrary: false,
      );
    } on Object catch (e, stack) {
      // Not worth the session: the next merge or fetch tries again.
      _logger.w('Key join after fetch failed', error: e, stackTrace: stack);
    }
  }

  Future<void> _onPresenceUpdate(String deviceId, Uint8List blob) async {
    if (deviceId == _session.device.deviceId) return;
    final SyncPresence presence;
    try {
      presence = SyncPresence.decode(await _open(blob, SealPurpose.presence));
    } on Object catch (e) {
      if (e is! SyncCryptoFailure && e is! FormatException) rethrow;
      // Not worth the session: a newer app's presence, or a damaged one.
      _logger.w('Unreadable presence from $deviceId', error: e);
      return;
    }
    _onPresence?.call(deviceId, presence);
  }

  Future<void> _onPushed(Map<String, int> seqs) async {
    final inFlight = _inFlight;
    if (inFlight == null) return;
    final acked = [for (final id in inFlight.clientIds) ?seqs[id]]..sort();
    if (acked.length != inFlight.clientIds.length) return;
    _inFlight = null;
    _completeProgress();
    await _deleteSent(inFlight.ops);
    // Frames from others before these arrived ahead of the ack, in seq
    // order; a gap means some did not, and the next catch-up brings them.
    for (final seq in acked) {
      if (seq == (await _meta())!.serverCursor + 1) await _setCursor(seq);
    }
    if (!inFlight.fullState) return _flush();
    final fullState = _fullState!;
    if (fullState.pushes.isNotEmpty) return _sendFullStatePush();
    _fullState = null;
    await _deleteSent(fullState.ops);
    await _recordFullStateSent(fullState.request);
    await _uploadSnapshot();
  }

  Future<void> _flush() async {
    // Its snapshot must cover the head, so nothing goes out before it, and
    // what it rotates away would seal anything sent after.
    if (_revocation != null) return _tryRevoke();
    if (!_caughtUp || _inFlight != null || _snapshotPending) return;
    // The cap may have dropped ops while connected; only the whole state
    // carries what they changed.
    final meta = (await _meta())!;
    if (meta.fullStateSent < meta.fullStateRequested) return _pushFullState();
    final pending = await _isar.outboxOps.where().sortByOpId().findAll();
    if (pending.isEmpty) return;
    if (_waitForSteady(pending)) return;
    var rows = _takeWholeRows(pending);
    if (rows.isEmpty) return;
    while (true) {
      final ops = rows.expand((r) => r).toList();
      final frame = SyncFrame.fromOps(
        ops,
        historyId: meta.historyId,
        deviceId: _session.device.deviceId,
      );
      final blob = await _seal(frame.encode(), SealPurpose.frame);
      // Halved until it fits the relay's frame limit; a single row too
      // large goes as is, and the relay's refusal ends the session.
      if (maxFrameBytes < blob.length && 1 < rows.length) {
        rows = rows.sublist(0, rows.length ~/ 2);
        continue;
      }
      final clientId = _uuid.v7();
      _inFlight = (
        clientIds: {clientId},
        ops: {for (final o in ops) o.id: o.hlc},
        fullState: false,
      );
      _transport.send(PushFrames([PushFrame(clientId: clientId, blob: blob)]));
      _lastPushAt = _nowMillis();
      return;
    }
  }

  /// Whether [pending] holds only changes that playing makes every few
  /// seconds and the last push was too recent for them; if so, a flush is
  /// scheduled for when [steadyInterval] has passed.
  bool _waitForSteady(List<OutboxOp> pending) {
    final now = _nowMillis();
    final last = _lastPushAt;
    if (last == null || now < _urgentUntil) return false;
    final due = last + steadyInterval.inMilliseconds;
    if (due <= now) return false;
    if (!pending.every((o) => _steadyFields.contains((o.entity, o.fieldId)))) {
      return false;
    }
    _steadyTimer?.cancel();
    _steadyTimer = Timer(Duration(milliseconds: due - now), () {
      _enqueue(_flush);
    });
    return true;
  }

  /// The oldest rows' ops, each row complete and parents first: a
  /// receiver that has never seen a row needs its required fields (an
  /// episode's podcastKey) in the same frame, and an episode before its
  /// counters, or it rejects them.
  List<List<OutboxOp>> _takeWholeRows(List<OutboxOp> ops) {
    final byRow = <(String, String), List<OutboxOp>>{};
    for (final op in ops) {
      (byRow[(op.entity, op.key)] ??= []).add(op);
    }
    final taken = <List<OutboxOp>>[];
    var count = 0;
    for (final row in byRow.values) {
      if (taken.isNotEmpty && maxOpsPerFrame <= count + row.length) break;
      taken.add(row);
      count += row.length;
    }
    // Stable, so rows of one entity keep their outbox order.
    return taken..sort(
      (a, b) => _rankOf(a.first.entity).compareTo(_rankOf(b.first.entity)),
    );
  }

  /// Sends the whole state as frames: after creating or joining, so
  /// devices already online merge it like any change and nothing the
  /// outbox dropped while sync was off is lost (plan P9), and after the
  /// outbox cap dropped ops. The compacted snapshot follows once the relay
  /// has them all.
  Future<void> _pushFullState() async {
    final request = (await _meta())!.fullStateRequested;
    final pending = await _isar.outboxOps.where().findAll();
    final exported = await SnapshotExporter(_isar).export();
    final historyId = (await _meta())?.historyId ?? '';
    final units = _units(exported.body.sections);
    final frames = <PushFrame>[];
    var batch = <List<(String, SnapshotRow)>>[];
    var count = 0;
    for (final unit in units) {
      if (batch.isNotEmpty && maxRowsPerFrame < count + unit.length) {
        frames.addAll(await _sealRows(batch, historyId));
        batch = [];
        count = 0;
      }
      batch.add(unit);
      count += unit.length;
    }
    if (batch.isNotEmpty) frames.addAll(await _sealRows(batch, historyId));
    if (frames.isEmpty) {
      await _recordFullStateSent(request);
      return _uploadSnapshot();
    }
    // The ops pending at the export are in these frames; ones changed
    // since keep a newer clock and stay for the next send.
    _fullState = (
      pushes: _splitPushes(frames),
      ops: {for (final o in pending) o.id: o.hlc},
      request: request,
    );
    await _sendFullStatePush();
  }

  /// The exported rows in send order, in units a frame never splits: a
  /// podcast with its details, so a device seeing the podcast first titles
  /// it right; parents before children otherwise (see [_entityRank]).
  List<List<(String, SnapshotRow)>> _units(
    Map<String, List<SnapshotRow>> sections,
  ) {
    final info = {
      for (final row in sections[UserStateEntities.podcastInfo.name] ?? [])
        row.key: row,
    };
    final entities = sections.keys.toList()
      ..sort((a, b) => _rankOf(a).compareTo(_rankOf(b)));
    final units = <List<(String, SnapshotRow)>>[];
    for (final entity in entities) {
      if (entity == UserStateEntities.podcastInfo.name) continue;
      for (final row in sections[entity]!) {
        final details = entity == UserStateEntities.podcast.name
            ? info.remove(row.key)
            : null;
        units.add([
          (entity, row),
          if (details != null) (UserStateEntities.podcastInfo.name, details),
        ]);
      }
    }
    // Details without a podcast row, kept for completeness.
    for (final row in info.values) {
      units.add([(UserStateEntities.podcastInfo.name, row)]);
    }
    return units;
  }

  /// Seals [units] as one frame, halving it until it fits the relay's
  /// frame limit. A single unit too large goes as is and the relay refuses
  /// it, which ends the session with a logged failure.
  Future<List<PushFrame>> _sealRows(
    List<List<(String, SnapshotRow)>> units,
    String historyId,
  ) async {
    final sections = <String, List<SnapshotRow>>{};
    for (final (entity, row) in units.expand((u) => u)) {
      (sections[entity] ??= []).add(row);
    }
    final frame = SyncFrame(
      historyId: historyId,
      deviceId: _session.device.deviceId,
      sections: sections,
    );
    final blob = await _seal(frame.encode(), SealPurpose.frame);
    if (blob.length <= maxFrameBytes || units.length == 1) {
      return [PushFrame(clientId: _uuid.v7(), blob: blob)];
    }
    final half = units.length ~/ 2;
    return [
      ...await _sealRows(units.sublist(0, half), historyId),
      ...await _sealRows(units.sublist(half), historyId),
    ];
  }

  /// Groups frames into pushes within the relay's per-push limits.
  List<List<PushFrame>> _splitPushes(List<PushFrame> frames) {
    final pushes = <List<PushFrame>>[];
    var current = <PushFrame>[];
    var bytes = 0;
    for (final f in frames) {
      final full =
          maxFramesPerPush <= current.length ||
          maxPushBytes < bytes + f.blob.length;
      if (current.isNotEmpty && full) {
        pushes.add(current);
        current = [];
        bytes = 0;
      }
      current.add(f);
      bytes += f.blob.length;
    }
    if (current.isNotEmpty) pushes.add(current);
    return pushes;
  }

  /// Sends the next push of the whole state; one at a time, like any push.
  Future<void> _sendFullStatePush() async {
    final push = _fullState!.pushes.removeAt(0);
    _inFlight = (
      clientIds: {for (final f in push) f.clientId},
      ops: const {},
      fullState: true,
    );
    _transport.send(PushFrames(push));
  }

  Future<void> _requestFullState() => _isar.writeTxn(() async {
    final meta = await _isar.syncMetas.get(SyncMeta.singletonId);
    if (meta == null) return;
    await _isar.syncMetas.put(meta..fullStateRequested += 1);
  });

  /// Marks [request] done; a request raised since stays pending.
  Future<void> _recordFullStateSent(int request) => _isar.writeTxn(() async {
    final meta = await _isar.syncMetas.get(SyncMeta.singletonId);
    if (meta == null || request <= meta.fullStateSent) return;
    await _isar.syncMetas.put(meta..fullStateSent = request);
  });

  /// Uploads a compacted snapshot covering the cursor, which the relay
  /// keeps in place of the frames it covers, so a later device starts from
  /// one file. It deletes no ops: a change made after the full-state
  /// export is in the snapshot but has reached no device yet, so it still
  /// goes out as a frame.
  Future<void> _uploadSnapshot() async {
    final backup = await buildBackupFile(
      _isar,
      now: DateTime.fromMillisecondsSinceEpoch(_nowMillis(), isUtc: true),
      appVersion: _appVersion,
      platform: _platform,
    );
    _snapshotPending = true;
    _transport.send(
      UploadSnapshot(
        RelaySnapshot(
          coversSeq: (await _meta())?.serverCursor ?? 0,
          blob: await _seal(backup.bytes, SealPurpose.snapshot),
        ),
      ),
    );
  }

  /// Deletes the ops the relay now holds; one changed since it was sent
  /// has a newer clock and goes out with the next frame.
  Future<void> _deleteSent(Map<int, int> ops) => _isar.writeTxn(() async {
    final current = await _isar.outboxOps.getAll(ops.keys.toList());
    await _isar.outboxOps.deleteAll([
      for (final op in current)
        if (op != null && op.hlc == ops[op.id]) op.id,
    ]);
  });

  Future<Uint8List> _seal(
    Uint8List plaintext,
    SealPurpose purpose, {
    DataKey? key,
  }) {
    final dataKey = key ?? _session.dataKey!;
    return _cipher.seal(
      key: dataKey.key,
      keyVersion: dataKey.version,
      purpose: purpose,
      plaintext: plaintext,
    );
  }

  Future<Uint8List> _open(Uint8List blob, SealPurpose purpose) {
    final dataKey = _session.dataKey!;
    return _cipher.open(
      blob,
      purpose: purpose,
      keyFor: (v) => v == dataKey.version ? dataKey.key : null,
    );
  }

  Future<SyncMeta?> _meta() => _isar.syncMetas.get(SyncMeta.singletonId);

  Future<void> _setCursor(int seq) => _isar.writeTxn(() async {
    final meta = await _isar.syncMetas.get(SyncMeta.singletonId);
    if (meta == null || seq <= meta.serverCursor) return;
    await _isar.syncMetas.put(meta..serverCursor = seq);
  });
}

/// A revocation from [SyncEngine.revoke] until the relay answers.
class _Revocation {
  _Revocation(this.deviceId);

  final String deviceId;
  final done = Completer<void>();

  /// The secrets it rotates to, once sent.
  ({SyncCredentials credentials, DataKey dataKey})? sent;
  int behindCount = 0;
}
