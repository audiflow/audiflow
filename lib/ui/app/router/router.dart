import 'package:audiflow/ui/app/router/navigator/home_navigator.dart';
import 'package:audiflow/ui/app/router/navigator/library_navigator.dart';
import 'package:audiflow/ui/app/router/navigator/provider.dart';
import 'package:audiflow/ui/app/router/navigator/search_navigator.dart';
import 'package:audiflow/ui/pages/main_page.dart';
import 'package:audiflow/ui/util/custom_app_lifecyle_listerner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';
part 'routes/home/debug_page_route.dart';
part 'routes/home/home_setting_page_route.dart';
part 'routes/home/home_shell_branch.dart';
part 'routes/home/intro_page_route.dart';
part 'routes/library/library_shell_branch.dart';
part 'routes/main_page_shell_route.dart';
part 'routes/search/search_shell_branch.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

@Riverpod(keepAlive: true)
GoRouter router(RouterRef ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    routes: $appRoutes,
    debugLogDiagnostics: kDebugMode,
    initialLocation: HomePageRoute.path,
  );
}
