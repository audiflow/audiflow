part of 'package:audiflow/ui/app/router/router.dart';

class DebugPageRoute extends GoRouteData {
  const DebugPageRoute();

  static const path = 'debug';

  static final $parentNavigatorKey = _rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const DebugPage();
  }
}

class DebugPage extends ConsumerWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Mode'),
      ),
      body: const Center(
        child: Text('Debug Mode'),
      ),
    );
  }
}
