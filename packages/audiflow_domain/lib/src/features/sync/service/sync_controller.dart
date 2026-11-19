import 'dart:async';

import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';

import '../crypto/sync_cipher.dart';
import '../crypto/sync_credentials.dart';
import '../engine/sync_engine.dart';
import '../engine/sync_session.dart';
import '../engine/sync_transport.dart';
import '../protocol/sync_messages.dart';
import '../storage/sync_key_store.dart';

/// Where sync stands on this device.
enum SyncPhase {
  /// This build has no relay to sync with.
  unavailable,

  /// Sync is off on this device.
  off,

  /// Sync is on but no connection is wanted (the app is in the background
  /// and not playing, plan P10).
  idle,

  /// Opening the connection and catching up.
  connecting,

  /// Caught up; changes flow both ways.
  connected,

  /// The connection failed and is retried after a pause.
  retrying,

  /// The relay refused this device; retried only when the app next comes
  /// to the foreground. [SyncStatus.failure] says why.
  failed,
}

class SyncStatus {
  const SyncStatus(this.phase, {this.failure});

  final SyncPhase phase;

  /// The [SyncRelayFailure.code] behind [SyncPhase.retrying] or
  /// [SyncPhase.failed].
  final String? failure;

  @override
  bool operator ==(Object other) =>
      other is SyncStatus && other.phase == phase && other.failure == failure;

  @override
  int get hashCode => Object.hash(phase, failure);

  @override
  String toString() => 'SyncStatus($phase, $failure)';
}

/// Turns sync on and off on this device and keeps one engine connected
/// while the app wants it (plan P10).
///
/// It owns the secrets: it creates them on [turnOn], stores what the relay
/// hands out, and forgets them on [turnOff]. A device whose stored record
/// belongs to another install (see [StoredSyncDevice.deviceId]) but whose
/// credentials arrived (iCloud Keychain) joins again on its own.
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
  static final _transient = {
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
  late SyncStatus _status = SyncStatus(
    _relayUrl == null ? SyncPhase.unavailable : SyncPhase.off,
  );

  SyncCredentials? _credentials;
  StoredSyncDevice? _device;
  SyncOpening _opening = SyncOpening.resume;
  bool _active = false;
  bool _loaded = false;
  SyncEngine? _engine;
  Future<void>? _running;
  Timer? _retry;
  int _attempt = 0;
  Future<void> _saving = Future.value();

  SyncStatus get status => _status;

  /// [status] as it changes.
  Stream<SyncStatus> get statusChanges => _statusController.stream;

  /// The account's credentials while sync is on, to show as a QR code or
  /// recovery code on this device.
  SyncCredentials? get credentials => _credentials;

  bool get isOn => _credentials != null;

  /// Reads the stored secrets. Call once at startup before anything else.
  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    if (_relayUrl == null) return;
    try {
      _credentials = await _store.readCredentials();
      _device = await _store.readDevice();
    } on Object catch (e, stack) {
      // Unreadable secrets cannot be repaired; sync stays off until the
      // user turns it on or joins again.
      _logger.e('Sync secrets unreadable', error: e, stackTrace: stack);
      _credentials = null;
      _device = null;
    }
    if (_credentials == null) return;
    final currentId = await _deviceId();
    final device = _device;
    if (device == null ||
        device.deviceId != currentId ||
        device.token == null) {
      // Credentials without this install's enrollment: join with them.
      _device = null;
      _opening = SyncOpening.join;
    }
    _setStatus(const SyncStatus(SyncPhase.idle));
    _kick();
  }

  /// Starts a new account with this device's data and connects.
  Future<void> turnOn() =>
      _enable(SyncCredentials.generate(), SyncOpening.create);

  /// Joins the account [credentials] name (scanned or typed) and connects.
  Future<void> join(SyncCredentials credentials) =>
      _enable(credentials, SyncOpening.join);

  Future<void> _enable(SyncCredentials credentials, SyncOpening opening) async {
    if (_relayUrl == null) throw StateError('sync is unavailable');
    if (isOn) throw StateError('sync is already on');
    await _store.writeCredentials(credentials);
    _credentials = credentials;
    _device = null;
    _opening = opening;
    _attempt = 0;
    _setStatus(const SyncStatus(SyncPhase.idle));
    _kick();
  }

  /// Stops syncing and forgets this device's secrets. The relay still
  /// lists the device until another one revokes it (M6g).
  Future<void> turnOff() async {
    _credentials = null;
    _device = null;
    await _stop();
    await _store.clear();
    if (_relayUrl != null) _setStatus(const SyncStatus(SyncPhase.off));
  }

  /// Whether the app wants a connection now: in the foreground, or
  /// playing (plan P10).
  void setActive(bool active) {
    if (_active == active) return;
    _active = active;
    if (active) {
      // Coming back is a fresh start for a refused or waiting device.
      if (_status.phase == SyncPhase.failed) _attempt = 0;
      _kick();
    } else {
      unawaited(_stop());
    }
  }

  Future<void> dispose() async {
    _active = false;
    await _stop();
    await _statusController.close();
  }

  Future<void> _stop() async {
    _retry?.cancel();
    _retry = null;
    await _engine?.close();
    await _running;
    if (isOn) _setStatus(const SyncStatus(SyncPhase.idle));
  }

  void _kick() {
    if (!_loaded || !_active || !isOn || _running != null || _retry != null) {
      return;
    }
    _running = _run().whenComplete(() => _running = null);
  }

  Future<void> _run() async {
    final relayUrl = _relayUrl!;
    final credentials = _credentials!;
    _setStatus(const SyncStatus(SyncPhase.connecting));
    SyncEngine? engine;
    try {
      final device = _device ?? await _newDevice();
      final transport = await _openTransport(
        relayUrl,
        credentials.accountIdText,
      );
      engine = SyncEngine(
        isar: _isar,
        session: SyncSession(
          credentials: credentials,
          device: await device.toSyncDevice(),
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
      );
      // Turned off or backgrounded while opening.
      if (!_active || !identical(credentials, _credentials)) {
        await engine.close();
        return;
      }
      _engine = engine;
      await engine.connect(_opening);
      await _saving;
      _opening = SyncOpening.resume;
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
    }
  }

  void _onFailure(String code, SyncCredentials credentials) {
    // A stop or turn-off ends the engine on purpose; that is no failure.
    if (!_active || !identical(credentials, _credentials)) return;
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

  Future<StoredSyncDevice> _newDevice() async {
    final keyPair = await DeviceKeyPair.generate();
    final device = StoredSyncDevice(
      deviceId: await _deviceId(),
      name: _deviceName,
      platform: _platform,
      privateKey: keyPair.privateKey,
    );
    // Stored before the relay sees its public key, so the key pair it
    // registers is the one kept.
    await _store.writeDevice(device);
    return _device = device;
  }

  void _saveSession(SyncSession session) {
    final device = _device;
    if (device == null) return;
    final updated = device.copyWith(
      token: session.token,
      dataKey: session.dataKey,
    );
    _device = updated;
    _saving = _saving.then((_) => _store.writeDevice(updated)).catchError((
      Object e,
      StackTrace stack,
    ) {
      // The next launch joins again with the credentials, so this is
      // recoverable; keep going on the token held in memory.
      _logger.e('Sync session not stored', error: e, stackTrace: stack);
    });
  }

  void _setStatus(SyncStatus status) {
    if (_status == status) return;
    _status = status;
    if (!_statusController.isClosed) _statusController.add(status);
  }
}
