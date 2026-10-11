import 'dart:async';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Signature of [SystemChrome.setPreferredOrientations]; injectable for tests.
typedef SetPreferredOrientations =
    Future<void> Function(List<DeviceOrientation> orientations);

/// Orientations allowed on a screen of [logicalSize]: tablets rotate freely,
/// phones stay portrait.
List<DeviceOrientation> preferredOrientationsFor(Size logicalSize) {
  if (DeviceUtils.isTablet(logicalSize.shortestSide)) {
    return DeviceOrientation.values;
  }
  return const [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown];
}

/// Applies the orientation policy once the app first reaches the foreground.
///
/// On Android, audio_service can start the Flutter engine with no activity
/// (media button, Bluetooth AVRCP browsing, media resumption) and run
/// `main()` headless. Until an activity attaches, the embedder drops
/// `flutter/platform` calls without replying, so an awaited
/// [SystemChrome.setPreferredOrientations] never completes and a call made
/// then is lost. Boot used to await it before `runApp`, which left the app
/// on the splash screen when the user opened it later (#674). A resumed
/// state guarantees an attached activity and a measured view size.
class OrientationLock {
  OrientationLock({
    WidgetsBinding? binding,
    SetPreferredOrientations? setPreferredOrientations,
  }) : _binding = binding ?? WidgetsBinding.instance,
       _setPreferredOrientations =
           setPreferredOrientations ?? SystemChrome.setPreferredOrientations;

  final WidgetsBinding _binding;
  final SetPreferredOrientations _setPreferredOrientations;
  AppLifecycleListener? _listener;

  /// Applies the policy now when resumed, otherwise on the first resume.
  void applyWhenResumed() {
    if (_binding.lifecycleState == AppLifecycleState.resumed) {
      _apply();
      return;
    }
    _listener ??= AppLifecycleListener(
      binding: _binding,
      onResume: () {
        _disposeListener();
        _apply();
      },
    );
  }

  void dispose() => _disposeListener();

  void _disposeListener() {
    _listener?.dispose();
    _listener = null;
  }

  void _apply() {
    final view = _binding.platformDispatcher.views.firstOrNull;
    final logicalSize = view == null
        ? Size.zero
        : view.physicalSize / view.devicePixelRatio;
    unawaited(
      _setPreferredOrientations(
        preferredOrientationsFor(logicalSize),
      ).catchError(_reportFailure),
    );
  }

  void _reportFailure(Object error, StackTrace stack) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'orientation lock',
      ),
    );
  }
}
