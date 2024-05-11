import 'package:audiflow/ui/app/router/app_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router_provider.g.dart';

@Riverpod(keepAlive: true)
AppRouter router(RouterRef ref) {
  return AppRouter(ref);
}
