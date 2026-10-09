import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/widgets.dart';

/// A [Dismissible] that plays `thresholdCross` / `thresholdRelease` as the
/// swipe passes / falls back below the point where releasing acts.
class HapticDismissible extends StatefulWidget {
  const HapticDismissible({
    required Key super.key,
    required this.child,
    this.background,
    this.secondaryBackground,
    this.confirmDismiss,
    this.onDismissed,
    this.direction = DismissDirection.horizontal,
  });

  final Widget child;
  final Widget? background;
  final Widget? secondaryBackground;
  final ConfirmDismissCallback? confirmDismiss;
  final DismissDirectionCallback? onDismissed;
  final DismissDirection direction;

  @override
  State<HapticDismissible> createState() => _HapticDismissibleState();
}

class _HapticDismissibleState extends State<HapticDismissible> {
  final _tracker = SwipeThresholdTracker();

  void _onUpdate(DismissUpdateDetails details) {
    final token = _tracker.update(details);
    if (token != null) HapticsScope.of(context).play(token);
  }

  Future<bool?> _confirm(DismissDirection direction) {
    _tracker.released();
    final confirm = widget.confirmDismiss;
    return confirm == null ? Future.value(true) : confirm(direction);
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: widget.key!,
      direction: widget.direction,
      background: widget.background,
      secondaryBackground: widget.secondaryBackground,
      confirmDismiss: _confirm,
      onDismissed: widget.onDismissed,
      onUpdate: _onUpdate,
      child: widget.child,
    );
  }
}

/// Decides which threshold token, if any, a [Dismissible] update plays.
///
/// [Dismissible.onUpdate] also fires while the row animates back after its
/// confirm callback declines (an action that springs back, such as a
/// download swipe). That return trip is not the finger cancelling, so the
/// release token is held back from [released] until the row settles, or
/// until a new drag takes over mid-return.
@visibleForTesting
class SwipeThresholdTracker {
  bool _settling = false;
  double _lastProgress = 0;

  /// Called when the finger lets go past the threshold.
  void released() => _settling = true;

  HapticToken? update(DismissUpdateDetails details) {
    // The return trip only shrinks progress; growth means a new drag took
    // over mid-return, and that drag's crossings are the finger's again.
    if (_settling && _lastProgress < details.progress) _settling = false;
    _lastProgress = details.progress;
    final crossed = details.reached != details.previousReached;
    final token = crossed && !_settling
        ? (details.reached
              ? HapticToken.thresholdCross
              : HapticToken.thresholdRelease)
        : null;
    // Checked after the crossing: the spring-back's last frame can land on
    // 0 in the same update that drops below the threshold.
    if (details.progress == 0) _settling = false;
    return token;
  }
}
