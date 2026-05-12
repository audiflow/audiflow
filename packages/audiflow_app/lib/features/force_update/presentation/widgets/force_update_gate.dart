import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../force_update_controller.dart';
import 'force_update_banner.dart';
import 'force_update_screen.dart';

/// Factory used to produce the lifecycle observer.
///
/// Exposed so widget tests can inject a no-op fake instead of touching
/// the real [WidgetsBinding] observer registry.
typedef ForceUpdateLifecycleObserverFactory =
    ForceUpdateLifecycleObserver Function(Future<void> Function() onResumed);

/// Top-level wrapper inserted between the root provider scope and
/// `MaterialApp.router`.
///
/// Render policy:
/// - [HardUpdate] / [Maintenance] -> render [ForceUpdateScreen] (router
///   never mounts; blocks deep links and back navigation).
/// - [SoftUpdate] -> render [child] with a [ForceUpdateBanner] above it.
/// - [NoUpdate] or loading -> render [child] unchanged.
///
/// The gate also wires a [ForceUpdateLifecycleObserver] so foregrounding
/// the app triggers a stale-cache refresh.
class ForceUpdateGate extends ConsumerStatefulWidget {
  const ForceUpdateGate({
    required this.child,
    this.lifecycleObserverFactory,
    super.key,
  });

  final Widget child;

  /// Optional factory used to build the lifecycle observer. Tests
  /// supply a fake to skip [WidgetsBinding.addObserver] side effects.
  final ForceUpdateLifecycleObserverFactory? lifecycleObserverFactory;

  @override
  ConsumerState<ForceUpdateGate> createState() => _ForceUpdateGateState();
}

class _ForceUpdateGateState extends ConsumerState<ForceUpdateGate> {
  ForceUpdateLifecycleObserver? _observer;

  @override
  void initState() {
    super.initState();
    final factory = widget.lifecycleObserverFactory ?? _defaultObserverFactory;
    _observer = factory(() async {
      await ref.read(forceUpdateControllerProvider.notifier).refreshIfStale();
    });
    WidgetsBinding.instance.addObserver(_observer!);
  }

  @override
  void dispose() {
    final observer = _observer;
    if (observer != null) {
      WidgetsBinding.instance.removeObserver(observer);
    }
    super.dispose();
  }

  ForceUpdateLifecycleObserver _defaultObserverFactory(
    Future<void> Function() onResumed,
  ) {
    return ForceUpdateLifecycleObserver(onResumed);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(forceUpdateControllerProvider);
    final decision = async.value;

    if (decision is HardUpdate || decision is Maintenance) {
      return ForceUpdateScreen(decision: decision! as ActionableUpdateDecision);
    }
    if (decision is SoftUpdate) {
      return _SoftOverlay(decision: decision, child: widget.child);
    }
    return widget.child;
  }
}

class _SoftOverlay extends StatelessWidget {
  const _SoftOverlay({required this.decision, required this.child});

  final SoftUpdate decision;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ForceUpdateBanner(decision: decision),
        ),
      ],
    );
  }
}
