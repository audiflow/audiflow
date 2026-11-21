import 'dart:async';

import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';

import '../../user_state/models/sync_meta.dart';
import '../crypto/sync_cipher.dart';
import '../crypto/sync_credentials.dart';
import '../engine/sync_engine.dart';
import '../engine/sync_session.dart';
import '../engine/sync_transport.dart';
import '../protocol/sync_messages.dart';
import '../storage/sync_key_store.dart';
import 'sync_status.dart';

/// Turns sync on and off on this device and keeps one engine connected
/// while the app wants it (plan P10).
///
/// It owns this device's enrollment: it creates it on [turnOn] or [join],
/// stores what the relay hands out, and drops it on [turnOff]. A device
/// whose enrollment belongs to another install (see
/// [StoredSyncDevice.deviceId]), or that has none while credentials
/// arrived from another device (iCloud Keychain), joins on its own unless
/// sync was turned off here.
class SyncController {
  SyncController({
    required this._isar,
    required this._store,
    required this._relayUrl,
    required this._deviceId,
    required this._deviceName,
    required this._platform,
    required this._appVersion,
    required this._syncFeeds,
    required this._logger,
    required this._openTransport,
    this._onStationChanged,
    Duration Function(int attempt)? retryDelay,
  }) : _retryDelay = retryDelay ?? defaultRetryDelay;

  final Isar _isar;
  final SyncKeyStore _store;
  final Uri? _relayUrl;
  final Future<String> Function() _deviceId;
  final String _deviceName;
  final String _platform;
  final String Function() _appVersion;
  final Future<void> Function(List<String> feedUrls) _syncFeeds;
  final Future<void> Function(int stationId)? _onStationChanged;
  final Logger _logger;
  final Future<SyncTransport> Function(Uri relayUrl, String accountId)
  _openTransport;
  final Duration Function(int attempt) _retryDelay;

  /// Failures a later attempt may get past on its own.
  static const _transient = {
    SyncRelayFailure.closed,
    SyncRelayFailure.internal,
    SyncRelayFailure.accountNotReady,
    RelayError.rateLimited,
  };

  /// 2 s, doubling to at most 5 minutes.
  static Duration defaultRetryDelay(int attempt) {
    const maxSeconds = 300;
    final seconds = attempt < 8 ? 2 << attempt : maxSeconds;
    return Duration(seconds: seconds < maxSeconds ? seconds : maxSeconds);
  }

  final _statusController = StreamController<SyncStatus>.broadcast();
  final _devicesController = StreamController<List<SyncDevice>>.broadcast();
  List<SyncDevice> _devices = const [];
  late SyncStatus _status = SyncStatus(
    _relayUrl == null ? SyncPhase.unavailable : SyncPhase.off,
  );

  SyncCredentials? _credentials;
  StoredSyncDevice? _device;
  SyncOpening _opening = SyncOpening.resume;
  bool _active = false;
  bool _loaded = false;
  bool _disposed = false;
  Future<void>? _running;
  SyncEngine? _engine;
  Timer? _retry;
  int _attempt = 0;
  Future<void> _saving = Future.value();
  Future<void>? _loading;

  SyncStatus get status => _status;

  /// The account's devices as the relay listed them on the last
  /// connection; empty while sync is off or before the first one.
  List<SyncDevice> get devices => _devices;

  /// [devices] as they change.
  Stream<List<SyncDevice>> get deviceChanges => _devicesController.stream;

  /// This device's id within the account, to mark it in [devices].
  String? get deviceId => isOn ? _device!.deviceId : null;

  /// [status] as it changes.
  Stream<SyncStatus> get statusChanges => _statusController.stream;

  /// The account's credentials while sync is on, to show as a QR code or
  /// recovery code on this device.
  SyncCredentials? get credentials => isOn ? _credentials : null;

  bool get isOn => _credentials != null && _device != null;

  /// Reads this device's enrollment. Call once at startup; nothing
  /// connects before it has finished.
  Future<void> load() => _loading ??= _load();

  Future<void> _load() async {
    if (_relayUrl == null) return;
    try {
      await _restore();
    } on Object catch (e, stack) {
      // Unreadable keys cannot be repaired; sync stays off until the user
      // turns it on or joins again.
      _logger.e('Sync keys unreadable', error: e, stackTrace: stack);
      _credentials = null;
      _device = null;
    }
    // Set last: a kick before this point would see half-restored state.
    _loaded = true;
    if (isOn) _setStatus(const SyncStatus(SyncPhase.idle));
    _kick();
  }

  Future<void> _restore() async {
    if (await _store.readOptedOut()) return;
    final stored = await _store.readDevice();
    final currentId = await _deviceId();
    if (stored != null && stored.deviceId == currentId) {
      final credentials = await _store.readCredentials(stored.accountId);
      if (credentials == null) return;
      _credentials = credentials;
      _device = stored;
      _opening = stored.token != null
          ? SyncOpening.resume
          : (stored.pendingOpening ?? SyncOpening.join);
      return;
    }
    // Another install's record, or none: join the account it names, else
    // the one set up last on the user's other devices.
    final named = stored == null
        ? null
        : await _store.readCredentials(stored.accountId);
    final credentials = named ?? await _store.readLatestCredentials();
    if (credentials == null) return;
    await _enroll(credentials, SyncOpening.join);
  }

  /// Starts a new account with this device's data and connects.
  Future<void> turnOn() =>
      _enable(SyncCredentials.generate(), SyncOpening.create);

  /// Joins the account [credentials] name (scanned or typed) and connects.
  Future<void> join(SyncCredentials credentials) =>
      _enable(credentials, SyncOpening.join);

  Future<void> _enable(SyncCredentials credentials, SyncOpening opening) async {
    if (_relayUrl == null) throw StateError('sync is unavailable');
    // Its restore would otherwise overwrite this enrollment.
    await load();
    if (isOn) throw StateError('sync is already on');
    await _store.writeCredentials(credentials);
    await _store.writeOptedOut(optedOut: false);
    await _enroll(credentials, opening);
    _attempt = 0;
    _setStatus(const SyncStatus(SyncPhase.idle));
    _kick();
  }

  /// Makes a new enrollment record before anything reaches the relay, so
  /// the key pair it registers is the one kept, and a new account is
  /// still created after a restart.
  Future<void> _enroll(SyncCredentials credentials, SyncOpening opening) async {
    final device = StoredSyncDevice(
      accountId: credentials.accountIdText,
      deviceId: await _deviceId(),
      name: _deviceName,
      platform: _platform,
      privateKey: (await DeviceKeyPair.generate()).privateKey,
      pendingOpening: opening,
    );
    // A token write still queued from an earlier session must not land
    // over this record.
    await _saving;
    await _store.writeDevice(device);
    // The cursor counts another account's frames, or none at all.
    await _resetCursor();
    _credentials = credentials;
    _device = device;
    _opening = opening;
  }

  /// Stops syncing on this device and drops its enrollment. The account's
  /// credentials stay for the user's other devices. The relay still lists
  /// this device until another one revokes it (M6g).
  Future<void> turnOff() async {
    // A startup restore still running would bring the enrollment back.
    await load();
    _credentials = null;
    _device = null;
    await _stop();
    if (_relayUrl == null) return;
    // A queued token write would bring the deleted record back.
    await _saving;
    await _store.deleteDevice();
    await _store.writeOptedOut(optedOut: true);
    await _resetCursor();
    _setDevices(const []);
    _setStatus(const SyncStatus(SyncPhase.off));
  }

  /// Whether the app wants a connection now: in the foreground, or
  /// playing (plan P10).
  void setActive(bool active) {
    if (_active == active) return;
    _active = active;
    if (active) {
      _kick();
    } else {
      unawaited(_stop());
    }
  }

  /// The app came to the foreground: a refused device tries once more.
  /// Separate from [setActive], which playback can hold true throughout.
  void onForeground() {
    if (_status.phase != SyncPhase.failed) return;
    _attempt = 0;
    _setStatus(const SyncStatus(SyncPhase.idle));
    _kick();
  }

  Future<void> dispose() async {
    _disposed = true;
    _active = false;
    await _stop();
    await _statusController.close();
    await _devicesController.close();
  }

  Future<void> _stop() async {
    _retry?.cancel();
    _retry = null;
    await _engine?.close();
    await _running;
    // A connection restarted meanwhile (active again) keeps its status.
    if (isOn && _running == null && _retry == null) {
      _setStatus(const SyncStatus(SyncPhase.idle));
    }
  }

  void _kick() {
    if (_disposed || !_loaded || !_active || !isOn) return;
    if (_running != null || _retry != null) return;
    if (_status.phase == SyncPhase.failed) return;
    _running = _run().whenComplete(() {
      _running = null;
      // Wanted again while the last connection was closing.
      _kick();
    });
  }

  Future<void> _run() async {
    final relayUrl = _relayUrl!;
    final credentials = _credentials!;
    final device = _device!;
    _setStatus(const SyncStatus(SyncPhase.connecting));
    SyncTransport? transport;
    SyncEngine? engine;
    try {
      // Before the socket opens, so a damaged record opens nothing.
      final syncDevice = await device.toSyncDevice();
      transport = await _openTransport(relayUrl, credentials.accountIdText);
      engine = SyncEngine(
        isar: _isar,
        session: SyncSession(
          credentials: credentials,
          device: syncDevice,
          token: device.token,
          dataKey: device.dataKey,
        ),
        transport: transport,
        syncFeeds: _syncFeeds,
        onStationChanged: _onStationChanged,
        appVersion: _appVersion(),
        platform: _platform,
        logger: _logger,
        onSessionChanged: _saveSession,
        onDevices: _setDevices,
      );
      // Turned off or backgrounded while opening.
      if (!_wanted(credentials)) {
        await engine.close();
        return;
      }
      _engine = engine;
      await engine.connect(_opening);
      await _saving;
      _attempt = 0;
      _setStatus(const SyncStatus(SyncPhase.connected));
      await engine.done;
    } on SyncRelayFailure catch (e) {
      _onFailure(e.code, credentials);
    } on Object catch (e, stack) {
      // No socket, DNS failure, or a storage error: worth another try.
      _logger.w('Sync connection failed', error: e, stackTrace: stack);
      _onFailure(SyncRelayFailure.closed, credentials);
    } finally {
      if (identical(_engine, engine)) _engine = null;
      // The engine closes its transport; one opened without an engine
      // would stay open.
      if (engine == null) await _closeQuietly(transport);
    }
  }

  bool _wanted(SyncCredentials credentials) =>
      _active && !_disposed && identical(credentials, _credentials);

  Future<void> _closeQuietly(SyncTransport? transport) async {
    try {
      await transport?.close();
    } on Object catch (e, stack) {
      _logger.w('Sync transport close failed', error: e, stackTrace: stack);
    }
  }

  void _onFailure(String code, SyncCredentials credentials) {
    // A stop or turn-off ends the engine on purpose; that is no failure.
    if (!_wanted(credentials)) return;
    if (_transient.contains(code)) {
      final delay = _retryDelay(_attempt++);
      _setStatus(SyncStatus(SyncPhase.retrying, failure: code));
      _retry = Timer(delay, () {
        _retry = null;
        _kick();
      });
    } else {
      _logger.w('Sync refused: $code');
      _setStatus(SyncStatus(SyncPhase.failed, failure: code));
    }
  }

  void _saveSession(SyncSession session) {
    final device = _device;
    if (device == null || session.token == null) return;
    final updated = device.enrolled(
      token: session.token,
      dataKey: session.dataKey,
    );
    _device = updated;
    // Holding a token, the next attempt resumes even if this one drops
    // before catching up.
    _opening = SyncOpening.resume;
    _saving = _saving.then((_) => _store.writeDevice(updated)).catchError((
      Object e,
      StackTrace stack,
    ) {
      // The next launch joins again with the credentials, so this is
      // recoverable; keep going on the token held in memory.
      _logger.e('Sync enrollment not stored', error: e, stackTrace: stack);
    });
  }

  Future<void> _resetCursor() => _isar.writeTxn(() async {
    final meta = await _isar.syncMetas.get(SyncMeta.singletonId);
    if (meta == null) return;
    await _isar.syncMetas.put(meta..serverCursor = 0);
  });

  void _setDevices(List<SyncDevice> devices) {
    _devices = List.unmodifiable(devices);
    if (!_devicesController.isClosed) _devicesController.add(_devices);
  }

  void _setStatus(SyncStatus status) {
    if (_status == status) return;
    _status = status;
    if (!_statusController.isClosed) _statusController.add(status);
  }
}
