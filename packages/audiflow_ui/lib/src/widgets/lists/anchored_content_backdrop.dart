import 'package:flutter/material.dart';

import 'content_backdrop.dart';

/// Puts a [ContentBackdrop] behind a scrolling [child], starting at the
/// top edge of the widget carrying [anchorKey] (e.g. the list's section
/// header) and following it as the content scrolls.
///
/// The child sits on a transparent [Material] so row ink draws above the
/// backdrop instead of on the Scaffold's Material underneath it.
class AnchoredContentBackdrop extends StatefulWidget {
  const AnchoredContentBackdrop({
    super.key,
    required this.anchorKey,
    required this.child,
  });

  final GlobalKey anchorKey;
  final Widget child;

  @override
  State<AnchoredContentBackdrop> createState() =>
      _AnchoredContentBackdropState();
}

class _AnchoredContentBackdropState extends State<AnchoredContentBackdrop> {
  /// Fires on every scroll or content change; the backdrop re-reads the
  /// anchor at paint time, after layout has moved it.
  final _Signal _moved = _Signal();
  final GlobalKey _backdropKey = GlobalKey();

  @override
  void dispose() {
    _moved.dispose();
    super.dispose();
  }

  /// The anchor's top edge in backdrop coordinates; infinite (no list
  /// surface) while there is no anchor, e.g. for an empty list.
  double _anchorTop() {
    final backdrop = _backdropKey.currentContext?.findRenderObject();
    final anchor = widget.anchorKey.currentContext?.findRenderObject();
    if (backdrop is! RenderBox || anchor is! RenderBox) return double.infinity;
    if (!anchor.attached || !anchor.hasSize) return double.infinity;
    // The anchor is in a sibling subtree, so compare global positions.
    return anchor.localToGlobal(Offset.zero).dy -
        backdrop.localToGlobal(Offset.zero).dy;
  }

  bool _onChange(Notification _) {
    _moved.fire();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // A rebuild may add or drop the anchor without any scroll.
    _moved.fire();
    return Stack(
      children: [
        Positioned.fill(
          child: ContentBackdrop.tracking(
            key: _backdropKey,
            topGetter: _anchorTop,
            reclip: _moved,
          ),
        ),
        NotificationListener<ScrollNotification>(
          onNotification: _onChange,
          child: NotificationListener<ScrollMetricsNotification>(
            onNotification: _onChange,
            child: Material(
              type: MaterialType.transparency,
              child: widget.child,
            ),
          ),
        ),
      ],
    );
  }
}

class _Signal extends ChangeNotifier {
  void fire() => notifyListeners();
}
