import 'dart:async';

import '../models/car_list_item.dart';

/// Coalesces bursts of in-car list changes into one report per list.
///
/// A playing episode saves its progress repeatedly, and every save would
/// otherwise reload the head unit's lists.
class CarChangeBatcher {
  CarChangeBatcher({
    required this._onFlush,
    this._delay = const Duration(milliseconds: 500),
  });

  final void Function(Set<CarSection> sections) _onFlush;
  final Duration _delay;

  final Set<CarSection> _pending = {};
  Timer? _timer;

  /// Records [sections] as changed; they are reported once [_delay] after
  /// the first change of a burst.
  void add(Set<CarSection> sections) {
    _pending.addAll(sections);
    _timer ??= Timer(_delay, _flush);
  }

  /// Drops changes not yet reported.
  void clear() {
    _timer?.cancel();
    _timer = null;
    _pending.clear();
  }

  void dispose() => clear();

  void _flush() {
    _timer = null;
    if (_pending.isEmpty) return;
    final sections = {..._pending};
    _pending.clear();
    _onFlush(sections);
  }
}
