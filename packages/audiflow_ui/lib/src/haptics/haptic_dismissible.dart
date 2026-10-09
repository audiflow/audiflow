import 'package:flutter/widgets.dart';

import 'haptic_token.dart';
import 'haptics_scope.dart';

/// A [Dismissible] that plays `thresholdCross` / `thresholdRelease` as the
/// swipe passes / falls back below the point where releasing acts.
///
/// [Dismissible.onUpdate] also fires while the row animates back after
/// [confirmDismiss] declines (an action that springs back, such as a
/// download swipe). That return trip is not the finger cancelling, so the
/// release token is held back until the row has settled.
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
  bool _settling = false;

  void _onUpdate(DismissUpdateDetails details) {
    final crossed = details.reached != details.previousReached;
    if (crossed && !_settling) {
      HapticsScope.of(context).play(
        details.reached
            ? HapticToken.thresholdCross
            : HapticToken.thresholdRelease,
      );
    }
    // Checked after the crossing: the spring-back's last frame can land on
    // 0 in the same update that drops below the threshold.
    if (details.progress == 0) _settling = false;
  }

  Future<bool?> _confirm(DismissDirection direction) {
    // Released past the threshold: from here the row either leaves or
    // springs back on its own, neither of which is the finger's doing.
    _settling = true;
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
