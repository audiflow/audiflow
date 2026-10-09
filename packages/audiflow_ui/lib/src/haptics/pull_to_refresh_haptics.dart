import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'haptic_token.dart';
import 'haptics_scope.dart';

/// Plays `thresholdCross` / `thresholdRelease` as a pull-to-refresh passes /
/// falls back below the point where letting go refreshes.
///
/// Wrap a `RefreshIndicator` with it. The indicator exposes its state only
/// to its spinner-less variant, so this mirrors the indicator's own rule
/// from the same scroll notifications, which the indicator lets bubble up:
///
/// - Android (clamping scroll): letting go refreshes once the pull reaches a
///   quarter of the viewport; pulling back below it cancels.
/// - iOS (bouncing scroll): the indicator refreshes as soon as it arms, at
///   that distance divided by its 1.5 drag limit, and never disarms, so
///   there is no release token.
class PullToRefreshHaptics extends StatefulWidget {
  const PullToRefreshHaptics({required this.child, super.key});

  final Widget child;

  @override
  State<PullToRefreshHaptics> createState() => _PullToRefreshHapticsState();
}

class _PullToRefreshHapticsState extends State<PullToRefreshHaptics> {
  // Mirrors RefreshIndicator's _kDragContainerExtentPercentage and
  // _kDragSizeFactorLimit.
  static const _extentFraction = 0.25;
  static const _dragLimit = 1.5;

  double? _pull;
  bool _crossed = false;

  bool get _bounces => defaultTargetPlatform == TargetPlatform.iOS;

  bool _onNotification(ScrollNotification notification) {
    // Same scope as RefreshIndicator's default predicate and edge trigger.
    if (notification.depth != 0) return false;
    if (notification.metrics.axisDirection != AxisDirection.down) return false;
    switch (notification) {
      case ScrollStartNotification(dragDetails: _?)
          when notification.metrics.extentBefore == 0:
        _pull = 0;
        _crossed = false;
      case ScrollUpdateNotification(:final scrollDelta?):
        _track(-scrollDelta, notification.metrics.viewportDimension);
      case OverscrollNotification(:final overscroll):
        _track(-overscroll, notification.metrics.viewportDimension);
      case ScrollEndNotification():
        _pull = null;
      default:
        break;
    }
    return false;
  }

  void _track(double delta, double viewport) {
    final pull = _pull;
    if (pull == null) return;
    _pull = pull + delta;
    final threshold =
        viewport * _extentFraction / (_bounces ? _dragLimit : 1.0);
    final crossed = threshold <= _pull!;
    if (crossed == _crossed) return;
    if (!crossed && _bounces) return;
    _crossed = crossed;
    HapticsScope.of(
      context,
    ).play(crossed ? HapticToken.thresholdCross : HapticToken.thresholdRelease);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onNotification,
      child: widget.child,
    );
  }
}

/// A [RefreshIndicator] that plays the pull-to-refresh threshold haptics.
///
/// Use it in place of [RefreshIndicator] so every refreshable list feels the
/// same; see [PullToRefreshHaptics] for when each token plays.
class HapticRefreshIndicator extends StatelessWidget {
  const HapticRefreshIndicator({
    required this.onRefresh,
    required this.child,
    this.edgeOffset = 0.0,
    super.key,
  });

  final RefreshCallback onRefresh;
  final Widget child;
  final double edgeOffset;

  @override
  Widget build(BuildContext context) {
    return PullToRefreshHaptics(
      child: RefreshIndicator(
        onRefresh: onRefresh,
        edgeOffset: edgeOffset,
        child: child,
      ),
    );
  }
}
