import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Creates a [GoRoute] whose page is a Flutter [MaterialPage].
///
/// go_router 18 detects the app type by looking for `material_ui`'s
/// `MaterialApp`, which is a different class from the `flutter/material`
/// one this app uses. Detection fails, and plain `builder:` routes fall
/// back to `NoTransitionPage`: no push/pop animation and no iOS
/// swipe-to-back. Building the [MaterialPage] explicitly restores the
/// theme's [PageTransitionsTheme] (Cupertino transition + back-swipe on
/// iOS, platform default on Android).
GoRoute materialRoute({
  required String path,
  required GoRouterWidgetBuilder builder,
  GlobalKey<NavigatorState>? parentNavigatorKey,
  List<RouteBase> routes = const <RouteBase>[],
}) {
  return GoRoute(
    path: path,
    parentNavigatorKey: parentNavigatorKey,
    routes: routes,
    pageBuilder: (context, state) => MaterialPage<void>(
      key: state.pageKey,
      name: state.name ?? state.path,
      arguments: <String, String>{
        ...state.pathParameters,
        ...state.uri.queryParameters,
      },
      restorationId: state.pageKey.value,
      child: builder(context, state),
    ),
  );
}
