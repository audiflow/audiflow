part of 'package:audiflow/ui/app/router/router.dart';

class IntroPageRoute extends GoRouteData {
  const IntroPageRoute();

  static const name = 'intro';

  static final $parentNavigatorKey = _rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const IntroPage();
  }
}

class IntroPage extends ConsumerWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intro Mode'),
      ),
      body: const Center(
        child: Text('Intro Mode'),
      ),
    );
  }
}
