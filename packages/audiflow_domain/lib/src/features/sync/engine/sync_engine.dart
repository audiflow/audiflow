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
import '../../user_state/models/outbox_op.dart';
import '../../user_state/models/sync_meta.dart';
import '../../user_state/sync/user_state_fields.dart';
import '../crypto/sync_cipher.dart';
import '../protocol/sync_messages.dart';
import 'sync_frame.dart';
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
    int Function()? nowMillis,
    this.maxOpsPerFrame = 500,
    this.maxRowsPerFrame = 500,
  }) : _nowMillis = nowMillis ?? _wallClock,
       _cipher = SyncCipher(_session.credentials.accountId) {
    // A failure nobody awaited yet must not surface as an unhandled error;
    // a later listener on [done] still sees it.
    unawaited(_done.future.then<void>((_) {}, onError: (_) {}));
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
  final int Function() _nowMillis;
  final SyncCipher _cipher;

  /// Ops per frame: bounds a frame's size after a long offline stretch.
  /// A row's ops are never split, so a frame can go over by one row.
  final int maxOpsPerFrame;

  /// Rows per frame when the whole state goes out.
  final int maxRowsPerFrame;

  static int _wallClock() => DateTime.now().millisecondsSinceEpoch;
  static const _uuid = Uuid();

  /// Episode fields that station filters read (favorites only, hide
  /// completed), so a received change of them rebuilds station lists.
  static final _stationFilterFields = {
    for (final f in UserStateEntities.episode.fields)
      if (f.name == 'favoritedAt' || f.name == 'completedAt') f.id,
  };

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

  /// A snapshot upload is waiting for `stored`; sends wait with it, so the
  /// relay compacts before anything newer lands.
  bool _snapshotPending = false;

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
      onDone: () => _enqueue(() async {
        throw const SyncRelayFailure('closed');
      }),
    );
    _outboxWatch = _isar.outboxOps.watchLazy().listen((_) => _enqueue(_flush));
    _enqueue(() async => _transport.send(await _openingMessage(opening)));
    return _ready.future;
  }

  /// Runs once every step queued so far has finished; for tests and for a
  /// clean shutdown.
  Future<void> settle() => _queue;

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _outboxWatch?.cancel();
    await _messages?.cancel();
    await _queue;
    await _transport.close();
    if (!_ready.isCompleted) {
      _ready.completeError(const SyncRelayFailure('closed'));
    }
    if (!_done.isCompleted) _done.complete();
  }

  void _enqueue(Future<void> Function() step) {
    _queue = _queue.then((_) async {
      if (_closed) return;
      try {
        await step();
      } on SyncRelayFailure catch (e) {
        await _fail(e);
      } on Object catch (e, stack) {
        // IsarError extends Error; one bad step must not stop the queue.
        _logger.e('Sync step failed', error: e, stackTrace: stack);
      }
    });
  }

  /// Ends the session: a push left waiting would block every later send,
  /// and the relay keeps the frames it acknowledged, so a new connection
  /// resumes from the cursor and sends the outbox again.
  Future<void> _fail(SyncRelayFailure failure) async {
    _logger.w('Sync session ended: ${failure.code}');
    _closed = true;
    _inFlight = null;
    _snapshotPending = false;
    await _outboxWatch?.cancel();
    await _messages?.cancel();
    await _transport.close();
    if (!_ready.isCompleted) _ready.completeError(failure);
    if (!_done.isCompleted) _done.completeError(failure);
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
        if (token == null) throw const SyncRelayFailure('notEnrolled');
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
      case Frames(:final frames):
        await _onFrames(frames);
      case Pushed(:final seqs):
        await _onPushed(seqs);
      case SnapshotStored():
        _snapshotPending = false;
        await _flush();
      case RelayError(:final code):
        throw SyncRelayFailure(code);
    }
  }

  Future<void> _onWelcome(Welcome welcome) async {
    if (syncProtocolVersion < welcome.minProtocolVersion) {
      throw const SyncRelayFailure(RelayError.tooOld);
    }
    var changed = false;
    if (welcome.token case final token?) {
      _session.token = token;
      changed = true;
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
    if (changed) _onSessionChanged?.call(_session);
    final snapshot = welcome.snapshot;
    // Joining merges it even at the same cursor: a snapshot of a new account
    // covers seq 0.
    if (snapshot != null &&
        (_opening == SyncOpening.join ||
            (await _meta())!.serverCursor < snapshot.coversSeq)) {
      await _mergeSnapshot(snapshot);
    }
    _welcomed = true;
  }

  Future<void> _mergeSnapshot(RelaySnapshot snapshot) async {
    final file = readSnapshotFile(
      await _open(snapshot.blob, SealPurpose.snapshot),
    );
    // Joining adopts the account's history (plan P9), so its tombstones
    // and horizon apply here from now on.
    if (_opening == SyncOpening.join && file.header.historyId.isNotEmpty) {
      await _isar.writeTxn(() async {
        final meta = await _isar.syncMetas.get(SyncMeta.singletonId);
        if (meta == null) return;
        await _isar.syncMetas.put(meta..historyId = file.header.historyId);
      });
    }
    final merged = await _merger.mergeSections(
      file.body.sections,
      historyId: file.header.historyId,
      tombstoneHorizon: file.header.tombstoneHorizon,
      recordOps: false,
    );
    await dropBeatenOps(
      _isar,
      receivedFields(file.body.sections),
      nowMillis: _nowMillis(),
    );
    await _project(file.body.sections, merged, wholeLibrary: true);
    await _setCursor(snapshot.coversSeq);
  }

  Future<void> _onFrames(List<RelayFrame> frames) async {
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
    if (_caughtUp) return;
    _caughtUp = true;
    // After joining, or when the outbox cap dropped ops, only the whole
    // state carries everything.
    final overflowed = (await _meta())?.outboxOverflowed ?? false;
    if (_opening != SyncOpening.resume || overflowed) {
      await _pushFullState();
    } else {
      await _flush();
    }
    if (!_ready.isCompleted) _ready.complete();
  }

  Future<void> _mergeFrame(RelayFrame relayed) async {
    final SyncFrame frame;
    final SnapshotMergeResult merged;
    try {
      frame = SyncFrame.decode(await _open(relayed.blob, SealPurpose.frame));
      merged = await _merger.mergeSections(
        frame.sections,
        historyId: frame.historyId,
        recordOps: false,
      );
    } on SyncCryptoFailure catch (e) {
      // Skipped, not retried: the cursor moves on so one frame cannot stall
      // sync, and the next compacted snapshot carries its state.
      _logger.w('Sync frame ${relayed.seq} unreadable: $e');
      return;
    } on SnapshotReadFailure catch (e) {
      _logger.w('Sync frame ${relayed.seq} rejected: $e');
      return;
    } on FormatException catch (e) {
      _logger.w('Sync frame ${relayed.seq} malformed: ${e.message}');
      return;
    }
    final fields = receivedFields(frame.sections).toList();
    await dropBeatenOps(_isar, fields, nowMillis: _nowMillis());
    final stationsAffected = fields.any(
      (f) =>
          f.entity == UserStateEntities.episode.name &&
          _stationFilterFields.contains(f.fieldId),
    );
    await _project(
      frame.sections,
      merged,
      wholeLibrary: false,
      stationsAffected: stationsAffected,
    );
  }

  SnapshotMerger get _merger => SnapshotMerger(_isar, nowMillis: _nowMillis);

  /// Turns merged state into the rows the app reads. Position, progress,
  /// favorites, and settings are read from the state itself and need none;
  /// station lists filtered on favorites or completion are rebuilt.
  Future<void> _project(
    Map<String, List<SnapshotRow>> sections,
    SnapshotMergeResult merged, {
    required bool wholeLibrary,
    bool stationsAffected = false,
  }) async {
    final projector = RestoreProjector(_isar);
    final library =
        wholeLibrary ||
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
    if (library || sections.containsKey(UserStateEntities.queueEntry.name)) {
      await projector.projectQueue();
    }
    if (stationsAffected) {
      stationIds.addAll(await _isar.stations.where().idProperty().findAll());
    }
    await _reconcileStations(stationIds);
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
    }
  }

  Future<void> _onPushed(Map<String, int> seqs) async {
    final inFlight = _inFlight;
    if (inFlight == null) return;
    final acked = [for (final id in inFlight.clientIds) ?seqs[id]]..sort();
    if (acked.length != inFlight.clientIds.length) return;
    _inFlight = null;
    await _deleteSent(inFlight.ops);
    // Frames from others before these arrived ahead of the ack, in seq
    // order; a gap means some did not, and the next catch-up brings them.
    for (final seq in acked) {
      if (seq == (await _meta())!.serverCursor + 1) await _setCursor(seq);
    }
    if (inFlight.fullState) {
      await _uploadSnapshot();
    } else {
      await _flush();
    }
  }

  Future<void> _flush() async {
    if (!_caughtUp || _inFlight != null || _snapshotPending) return;
    final ops = _takeWholeRows(
      await _isar.outboxOps.where().sortByOpId().findAll(),
    );
    if (ops.isEmpty) return;
    final frame = SyncFrame.fromOps(
      ops,
      historyId: (await _meta())?.historyId ?? '',
      deviceId: _session.device.deviceId,
    );
    final clientId = _uuid.v7();
    _inFlight = (
      clientIds: {clientId},
      ops: {for (final o in ops) o.id: o.hlc},
      fullState: false,
    );
    _transport.send(
      PushFrames([
        PushFrame(
          clientId: clientId,
          blob: await _seal(frame.encode(), SealPurpose.frame),
        ),
      ]),
    );
  }

  /// The oldest rows' ops, each row complete: a receiver that has never
  /// seen a row needs its required fields (an episode's podcastKey) in the
  /// same frame, or it rejects the frame.
  List<OutboxOp> _takeWholeRows(List<OutboxOp> ops) {
    final byRow = <(String, String), List<OutboxOp>>{};
    for (final op in ops) {
      (byRow[(op.entity, op.key)] ??= []).add(op);
    }
    final taken = <OutboxOp>[];
    for (final row in byRow.values) {
      if (taken.isNotEmpty && maxOpsPerFrame <= taken.length + row.length) {
        break;
      }
      taken.addAll(row);
    }
    return taken;
  }

  /// Sends the whole state as frames: after creating or joining, so
  /// devices already online merge it like any change and nothing the
  /// outbox dropped while sync was off is lost (plan P9), and after the
  /// outbox cap dropped ops. The compacted snapshot follows once the relay
  /// has them all.
  Future<void> _pushFullState() async {
    // Cleared before the export: an overflow during it is set again and
    // handled by the next connection.
    await _isar.writeTxn(() async {
      final meta = await _isar.syncMetas.get(SyncMeta.singletonId);
      if (meta == null || !meta.outboxOverflowed) return;
      await _isar.syncMetas.put(meta..outboxOverflowed = false);
    });
    final pending = await _isar.outboxOps.where().findAll();
    final exported = await SnapshotExporter(_isar).export();
    final historyId = (await _meta())?.historyId ?? '';
    final rows = [
      for (final MapEntry(key: entity, value: list)
          in exported.body.sections.entries)
        for (final row in list) (entity, row),
    ];
    final frames = <PushFrame>[];
    for (var start = 0; start < rows.length; start += maxRowsPerFrame) {
      final sections = <String, List<SnapshotRow>>{};
      for (final (entity, row) in rows.skip(start).take(maxRowsPerFrame)) {
        (sections[entity] ??= []).add(row);
      }
      final frame = SyncFrame(
        historyId: historyId,
        deviceId: _session.device.deviceId,
        sections: sections,
      );
      frames.add(
        PushFrame(
          clientId: _uuid.v7(),
          blob: await _seal(frame.encode(), SealPurpose.frame),
        ),
      );
    }
    if (frames.isEmpty) return _uploadSnapshot();
    // The ops pending at the export are in these frames; ones changed
    // since keep a newer clock and stay for the next send.
    _inFlight = (
      clientIds: {for (final f in frames) f.clientId},
      ops: {for (final o in pending) o.id: o.hlc},
      fullState: true,
    );
    _transport.send(PushFrames(frames));
  }

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

  Future<Uint8List> _seal(Uint8List plaintext, SealPurpose purpose) {
    final dataKey = _session.dataKey!;
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
