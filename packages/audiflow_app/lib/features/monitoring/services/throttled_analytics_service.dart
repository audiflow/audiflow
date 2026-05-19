import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/foundation.dart';

class ThrottledAnalyticsService implements AnalyticsService {
  ThrottledAnalyticsService(
    this._inner, {
    Duration window = const Duration(seconds: 5),
    DateTime Function()? now,
  }) : _window = window,
       _now = now ?? DateTime.now;

  final AnalyticsService _inner;
  final Duration _window;
  final DateTime Function() _now;
  final _lastEmittedAt = <String, DateTime>{};

  static const _throttled = {'episode_pause', 'episode_seek'};

  @override
  Future<void> log(AnalyticsEvent event) async {
    if (_throttled.contains(event.name)) {
      final key = _keyFor(event);
      final now = _now();
      final last = _lastEmittedAt[key];
      if (last != null && now.difference(last) < _window) {
        if (kDebugMode) {
          debugPrint(
            '[ANALYTICS] throttled ${event.name} key=$key '
            'sinceLast=${now.difference(last).inMilliseconds}ms',
          );
        }
        return;
      }
      _lastEmittedAt[key] = now;
    }
    await _inner.log(event);
  }

  String _keyFor(AnalyticsEvent event) {
    final episodeId = event.params['episode_id'] ?? '';
    return '${event.name}:$episodeId';
  }

  @override
  Future<void> setUserId(String? id) => _inner.setUserId(id);

  @override
  Future<void> setOptIn(bool optIn) => _inner.setOptIn(optIn);
}
