import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'menu_overlay.dart';

/// Where a press-and-hold that opened a menu is in its gesture.
enum ActionMenuDragPhase {
  /// The finger is still down.
  moving,

  /// The finger was lifted at [ActionMenuDrag.position].
  released,

  /// The gesture was taken away (e.g. by the system); nothing is chosen.
  cancelled,
}

/// The finger that opened a menu by pressing and holding its trigger.
///
/// The pointer stays routed to the trigger after the menu route is pushed,
/// so the trigger reports the finger here and the menu follows it to
/// highlight and choose the item under it.
class ActionMenuDrag extends ChangeNotifier {
  ActionMenuDrag(this._position);

  Offset _position;
  ActionMenuDragPhase _phase = ActionMenuDragPhase.moving;

  /// The finger's last global position.
  Offset get position => _position;

  ActionMenuDragPhase get phase => _phase;

  void moveTo(Offset globalPosition) {
    if (_phase != ActionMenuDragPhase.moving) return;
    _position = globalPosition;
    notifyListeners();
  }

  void release(Offset globalPosition) {
    if (_phase != ActionMenuDragPhase.moving) return;
    _position = globalPosition;
    _phase = ActionMenuDragPhase.released;
    notifyListeners();
  }

  void cancel() {
    if (_phase != ActionMenuDragPhase.moving) return;
    _phase = ActionMenuDragPhase.cancelled;
    notifyListeners();
  }
}

/// Opens a menu below or beside [anchor] (the trigger's context). [drag] is
/// null for a plain tap, and follows the finger after a press-and-hold.
typedef ActionMenuOpener =
    void Function(BuildContext anchor, ActionMenuDrag? drag);

/// Wraps a menu's trigger so the menu opens on a tap, or on a press-and-hold
/// that then slides to an item and releases to choose it.
///
/// [builder] receives the tap callback to hand to the trigger's button
/// (null when [onOpen] is null, which disables the trigger), and the
/// context [onOpen] gets as its anchor. Menus open in a [MenuOverlayHost]
/// the trigger provides, so they close with the trigger's screen.
class ActionMenuTrigger extends StatefulWidget {
  const ActionMenuTrigger({
    super.key,
    required this.onOpen,
    required this.builder,
  });

  /// Shorter than the tooltip's long press, so holding a button with a
  /// tooltip opens its menu rather than the tooltip.
  static const Duration holdDuration = Duration(milliseconds: 300);

  final ActionMenuOpener? onOpen;
  final Widget Function(BuildContext context, VoidCallback? open) builder;

  @override
  State<ActionMenuTrigger> createState() => _ActionMenuTriggerState();
}

class _ActionMenuTriggerState extends State<ActionMenuTrigger> {
  ActionMenuDrag? _drag;

  @override
  void dispose() {
    _drag?.cancel();
    super.dispose();
  }

  void _openByHold(BuildContext anchor, LongPressStartDetails details) {
    final onOpen = widget.onOpen;
    if (onOpen == null) return;
    final drag = ActionMenuDrag(details.globalPosition);
    _drag = drag;
    onOpen(anchor, drag);
  }

  void _moveHold(LongPressMoveUpdateDetails details) {
    _drag?.moveTo(details.globalPosition);
  }

  void _endHold(LongPressEndDetails details) {
    _drag?.release(details.globalPosition);
    _drag = null;
  }

  void _cancelHold() {
    _drag?.cancel();
    _drag = null;
  }

  @override
  Widget build(BuildContext context) {
    // The anchor sits under the host so menus opened from it find the host.
    return MenuOverlayHost(child: Builder(builder: _buildTrigger));
  }

  Widget _buildTrigger(BuildContext anchor) {
    final onOpen = widget.onOpen;
    // The detector stays mounted while disabled, so enabling the trigger
    // does not remount the button and lose its ink or focus.
    return RawGestureDetector(
      gestures: {
        if (onOpen != null)
          LongPressGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
                () => LongPressGestureRecognizer(
                  duration: ActionMenuTrigger.holdDuration,
                ),
                (recognizer) {
                  recognizer
                    ..onLongPressStart = (details) {
                      _openByHold(anchor, details);
                    }
                    ..onLongPressMoveUpdate = _moveHold
                    ..onLongPressEnd = _endHold
                    ..onLongPressCancel = _cancelHold;
                },
              ),
      },
      child: widget.builder(
        anchor,
        onOpen == null ? null : () => onOpen(anchor, null),
      ),
    );
  }
}
