import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Builds a menu; [choose] closes it with the chosen value.
typedef MenuOverlayBuilder<T> =
    Widget Function(BuildContext context, ValueChanged<T> choose);

/// Shows a menu above everything, behind a transparent barrier that closes
/// it with null on a tap outside or on the system back gesture.
///
/// The menu lives in the root overlay rather than in a route: pushing a
/// route cancels every pointer that is down (`Navigator._afterNavigation`),
/// which would cut off the finger that opened the menu by pressing and
/// holding its trigger.
///
/// Completes as soon as the menu starts closing, so a chosen action can
/// open a sheet while the menu fades out.
Future<T?> showMenuOverlay<T>({
  required BuildContext context,
  required Alignment scaleOrigin,
  required MenuOverlayBuilder<T> builder,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  final themes = InheritedTheme.capture(from: context, to: overlay.context);
  final route = ModalRoute.of(context);
  final result = Completer<T?>();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => themes.wrap(
      _MenuLayer<T>(
        route: route,
        scaleOrigin: scaleOrigin,
        builder: builder,
        onResult: (value) {
          if (!result.isCompleted) result.complete(value);
        },
        onDismissed: () => entry
          ..remove()
          ..dispose(),
      ),
    ),
  );
  overlay.insert(entry);
  return result.future;
}

class _MenuLayer<T> extends StatefulWidget {
  const _MenuLayer({
    required this.route,
    required this.scaleOrigin,
    required this.builder,
    required this.onResult,
    required this.onDismissed,
  });

  /// The trigger's route, which hands its back gesture to the menu.
  final ModalRoute<Object?>? route;
  final Alignment scaleOrigin;
  final MenuOverlayBuilder<T> builder;
  final ValueChanged<T?> onResult;
  final VoidCallback onDismissed;

  @override
  State<_MenuLayer<T>> createState() => _MenuLayerState<T>();
}

class _MenuLayerState<T> extends State<_MenuLayer<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 160),
  )..forward();
  late final Animation<double> _curved = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );
  late final _CloseOnPop _popEntry = _CloseOnPop(() => _close(null));
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    widget.route?.registerPopEntry(_popEntry);
  }

  @override
  void dispose() {
    // Torn down without a choice (e.g. the overlay itself went away).
    widget.onResult(null);
    widget.route?.unregisterPopEntry(_popEntry);
    _popEntry.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _close(T? value) {
    if (_closing) return;
    // The pop entry stays registered until dispose: the route may be
    // iterating its entries right now (this close came from a back
    // gesture), and a back gesture during the fade-out should still land
    // here rather than on the screen.
    setState(() => _closing = true);
    widget.onResult(value);
    unawaited(_controller.reverse().then((_) => widget.onDismissed()));
  }

  @override
  Widget build(BuildContext context) {
    return BlockSemantics(
      child: IgnorePointer(
        ignoring: _closing,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ModalBarrier(
              onDismiss: () => _close(null),
              semanticsLabel: MaterialLocalizations.of(
                context,
              ).modalBarrierDismissLabel,
            ),
            FadeTransition(
              opacity: _curved,
              child: ScaleTransition(
                scale: Tween(begin: 0.92, end: 1.0).animate(_curved),
                alignment: widget.scaleOrigin,
                child: widget.builder(context, _close),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Blocks the trigger route's pop and closes the menu instead, so the
/// back gesture dismisses the menu rather than the screen beneath it.
class _CloseOnPop extends PopEntry<Object?> {
  _CloseOnPop(this._onPop);

  final VoidCallback _onPop;
  final ValueNotifier<bool> _canPop = ValueNotifier(false);

  @override
  ValueListenable<bool> get canPopNotifier => _canPop;

  @override
  void onPopInvokedWithResult(bool didPop, Object? result) {
    if (!didPop) _onPop();
  }

  void dispose() => _canPop.dispose();
}
