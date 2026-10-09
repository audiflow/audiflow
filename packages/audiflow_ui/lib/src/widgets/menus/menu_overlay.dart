import 'dart:async';

import 'package:flutter/material.dart';

/// Builds a menu; [choose] closes it with the chosen value.
typedef MenuOverlayBuilder<T> =
    Widget Function(BuildContext context, ValueChanged<T> choose);

/// Hosts the menus shown with [showMenuOverlay] from inside [child].
///
/// The menu renders in the root overlay, above everything, but stays a
/// logical child of this host: it inherits the trigger's theme and route,
/// lets that route's back gesture close it, closes when another screen
/// covers the route, and goes away with the host.
///
/// A route would be simpler, but pushing one cancels every pointer that is
/// down (`Navigator._afterNavigation`), which would cut off the finger that
/// opened the menu by pressing and holding its trigger.
class MenuOverlayHost extends StatefulWidget {
  const MenuOverlayHost({super.key, required this.child});

  final Widget child;

  @override
  State<MenuOverlayHost> createState() => _MenuOverlayHostState();
}

class _MenuOverlayHostState extends State<MenuOverlayHost> {
  final OverlayPortalController _portal = OverlayPortalController();
  Widget? _layer;

  void _show(Widget layer) {
    setState(() => _layer = layer);
    _portal.show();
  }

  void _hide(Widget layer) {
    // A newer menu may have replaced this one while it faded out.
    if (!mounted || !identical(_layer, layer)) return;
    _portal.hide();
    setState(() => _layer = null);
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _portal,
      overlayLocation: OverlayChildLocation.rootOverlay,
      overlayChildBuilder: (context) => _layer ?? const SizedBox.shrink(),
      child: widget.child,
    );
  }
}

/// Shows a menu above everything, behind a transparent barrier that closes
/// it with null on a tap outside, the back gesture, or Escape.
///
/// [context] must be inside a [MenuOverlayHost] (an `ActionMenuTrigger`
/// provides one). Completes as soon as the menu starts closing, so a chosen
/// action can open a sheet while the menu fades out.
Future<T?> showMenuOverlay<T>({
  required BuildContext context,
  required Alignment scaleOrigin,
  required MenuOverlayBuilder<T> builder,
}) {
  final host = context.findAncestorStateOfType<_MenuOverlayHostState>();
  if (host == null) {
    throw FlutterError(
      'showMenuOverlay was called outside a MenuOverlayHost.\n'
      'Open menus from an ActionMenuTrigger, passing the context it gives.',
    );
  }
  final result = Completer<T?>();
  late final Widget layer;
  layer = _MenuLayer<T>(
    key: ObjectKey(result),
    scaleOrigin: scaleOrigin,
    builder: builder,
    onResult: (value) {
      if (!result.isCompleted) result.complete(value);
    },
    onDismissed: () => host._hide(layer),
  );
  host._show(layer);
  return result.future;
}

class _MenuLayer<T> extends StatefulWidget {
  const _MenuLayer({
    super.key,
    required this.scaleOrigin,
    required this.builder,
    required this.onResult,
    required this.onDismissed,
  });

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
  bool _closing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Another screen covered the trigger's (e.g. a deep link); the menu
    // belongs to the covered one. Already rebuilding, so no setState.
    if (ModalRoute.isCurrentOf(context) == false) _beginClose(null);
  }

  @override
  void dispose() {
    // Torn down without a choice (e.g. the trigger went away).
    widget.onResult(null);
    _controller.dispose();
    super.dispose();
  }

  void _close(T? value) {
    if (_closing) return;
    setState(() => _beginClose(value));
  }

  void _beginClose(T? value) {
    if (_closing) return;
    _closing = true;
    widget.onResult(value);
    unawaited(_controller.reverse().then((_) => widget.onDismissed()));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Stays false through the fade-out, so a second back gesture lands
      // here rather than on the screen.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close(null);
      },
      child: Actions(
        actions: {
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (_) => _close(null),
          ),
        },
        // Keeps keyboard focus inside the menu, as a modal route would.
        child: FocusScope(
          autofocus: true,
          child: BlockSemantics(
            child: IgnorePointer(ignoring: _closing, child: _layers(context)),
          ),
        ),
      ),
    );
  }

  Widget _layers(BuildContext context) {
    return Stack(
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
    );
  }
}
