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
import '../../user_state/services/sync_meta_access.dart';
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
    this._onDevices,
    int Function()? nowMillis,
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

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
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
    _onDevices?.call(welcome.devices);
    _welcomed = true;
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
    final merged = await _mergerAt(now).mergeSections(
      file.body.sections,
      historyId: file.header.historyId,
      tombstoneHorizon: file.header.tombstoneHorizon,
      recordOps: false,
    );
    await dropBeatenOps(
      _isar,
      receivedFields(file.body.sections),
      nowMillis: now,
    );
    await _project(file.body.sections, merged, wholeLibrary: true);
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
    if (_caughtUp || more) return;
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
    try {
      frame = SyncFrame.decode(await _open(relayed.blob, SealPurpose.frame));
      merged = await _mergerAt(now).mergeSections(
        frame.sections,
        historyId: frame.historyId,
        recordOps: false,
      );
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
    final fields = receivedFields(frame.sections).toList();
    await dropBeatenOps(_isar, fields, nowMillis: now);
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

  SnapshotMerger _mergerAt(int now) =>
      SnapshotMerger(_isar, nowMillis: () => now);

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
    if (!inFlight.fullState) return _flush();
    final fullState = _fullState!;
    if (fullState.pushes.isNotEmpty) return _sendFullStatePush();
    _fullState = null;
    await _deleteSent(fullState.ops);
    await _recordFullStateSent(fullState.request);
    await _uploadSnapshot();
  }

  Future<void> _flush() async {
    if (!_caughtUp || _inFlight != null || _snapshotPending) return;
    // The cap may have dropped ops while connected; only the whole state
    // carries what they changed.
    final meta = (await _meta())!;
    if (meta.fullStateSent < meta.fullStateRequested) return _pushFullState();
    var rows = _takeWholeRows(
      await _isar.outboxOps.where().sortByOpId().findAll(),
    );
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
      return;
    }
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
