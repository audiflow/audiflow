import 'dart:async';

import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../models/carplay_list_item.dart';
import 'carplay_catalog.dart';
import 'carplay_playback.dart';

/// Dart end of `audiflow/carplay`, the channel to the CarPlay scene
/// (`ios/Runner/CarPlayChannel.swift`).
///
/// The native side owns the templates and asks for their rows; Dart owns
/// the data. Dart sends `ready` (with the localized labels) whenever it
/// starts or the language changes, and `invalidate` when a list's data
/// changes while a head unit is connected. Native sends `connected` and
/// `disconnected`, `listItems`, `playItem`, and `cycleSpeed`.
class CarPlayBridge {
  CarPlayBridge({
    required this._catalog,
    required this._playback,
    required this._labels,
    required this._logger,
    this._onConnectionChanged,
    this._channel = const MethodChannel(channelName),
    this._invalidationDelay = const Duration(milliseconds: 500),
  });

  static const channelName = 'audiflow/carplay';

  final CarPlayCatalog _catalog;
  final CarPlayPlayback _playback;
  final Map<String, String> Function() _labels;
  final Logger _logger;
  final void Function({required bool connected})? _onConnectionChanged;
  final MethodChannel _channel;

  /// Coalesces bursts of changes (a playing episode saves its progress
  /// repeatedly) into one reload per list.
  final Duration _invalidationDelay;

  final Set<CarPlaySection> _pendingInvalidations = {};
  Timer? _invalidationTimer;
  bool _connected = false;

  /// Whether a head unit is showing the CarPlay scene.
  bool get isConnected => _connected;

  /// Starts answering the native side and tells it Dart is ready.
  void start() {
    _channel.setMethodCallHandler(_handle);
    unawaited(announce());
  }

  /// Sends `ready` with the current labels; native rebuilds its templates.
  Future<void> announce() => _send('ready', {'labels': _labels()});

  /// Asks the native side to reload [sections], if a head unit is connected.
  void invalidate(Set<CarPlaySection> sections) {
    if (!_connected) return;
    _pendingInvalidations.addAll(sections);
    _invalidationTimer ??= Timer(_invalidationDelay, _flushInvalidations);
  }

  void dispose() {
    _invalidationTimer?.cancel();
    _channel.setMethodCallHandler(null);
  }

  void _flushInvalidations() {
    _invalidationTimer = null;
    if (!_connected || _pendingInvalidations.isEmpty) return;
    final sections = [for (final s in _pendingInvalidations) s.name];
    _pendingInvalidations.clear();
    unawaited(_send('invalidate', {'sections': sections}));
  }

  Future<Object?> _handle(MethodCall call) async {
    switch (call.method) {
      case 'connected':
        _setConnected(connected: true);
        return null;
      case 'disconnected':
        _setConnected(connected: false);
        return null;
      case 'listItems':
        return _listItems(_arguments(call));
      case 'playItem':
        await _playItem(_arguments(call));
        return null;
      case 'cycleSpeed':
        return _playback.cycleSpeed();
    }
    // An older Dart build must answer a newer native call without failing.
    throw MissingPluginException('Unknown CarPlay method ${call.method}');
  }

  void _setConnected({required bool connected}) {
    if (_connected == connected) return;
    _connected = connected;
    if (!connected) {
      _invalidationTimer?.cancel();
      _invalidationTimer = null;
      _pendingInvalidations.clear();
    }
    _onConnectionChanged?.call(connected: connected);
  }

  Future<List<Map<String, Object?>>> _listItems(
    Map<Object?, Object?> arguments,
  ) async {
    final section = _section(arguments);
    final podcastId = arguments['podcastId'];
    try {
      final items = await _catalog.items(
        section,
        podcastId: podcastId is int ? podcastId : null,
      );
      return [for (final item in items) item.toMap()];
    } on Object catch (e, stack) {
      _logger.e(
        'Failed to list CarPlay ${section.name}',
        error: e,
        stackTrace: stack,
      );
      throw PlatformException(code: 'LIST_FAILED', message: '$e');
    }
  }

  Future<void> _playItem(Map<Object?, Object?> arguments) async {
    final section = _section(arguments);
    final id = arguments['id'];
    if (id is! int) throw _invalidArgument('id');
    // A podcast row opens its episode list on the native side; it is
    // never sent here.
    if (section == CarPlaySection.library) throw _invalidArgument('section');
    try {
      if (section == CarPlaySection.upNext) {
        await _playback.playQueueItem(id);
      } else {
        await _playback.playEpisode(id);
      }
    } on Object catch (e, stack) {
      _logger.e('Failed to play CarPlay item $id', error: e, stackTrace: stack);
      throw PlatformException(code: 'PLAY_FAILED', message: '$e');
    }
  }

  static Map<Object?, Object?> _arguments(MethodCall call) {
    final arguments = call.arguments;
    if (arguments is Map<Object?, Object?>) return arguments;
    throw _invalidArgument('arguments');
  }

  static CarPlaySection _section(Map<Object?, Object?> arguments) {
    return CarPlaySection.byName(arguments['section']) ??
        (throw _invalidArgument('section'));
  }

  static PlatformException _invalidArgument(String name) =>
      PlatformException(code: 'INVALID_ARGUMENT', message: 'Bad $name');

  Future<void> _send(String method, Map<String, Object?> arguments) async {
    try {
      await _channel.invokeMethod<void>(method, arguments);
    } on MissingPluginException {
      // No native handler: not an iOS build, or a test without one.
    } on PlatformException catch (e) {
      _logger.w('CarPlay $method failed', error: e);
    }
  }
}
