part of 'package:audiflow/ui/app/router/router.dart';

class HomeSettingPageRoute extends GoRouteData {
  const HomeSettingPageRoute();

  static const path = 'setting';
  static const name = 'homeSetting';

  // static final $parentNavigatorKey = _rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ProviderScope(
      overrides: [
        homeNavigatorProvider.overrideWithValue(const HomeNavigator()),
      ],
      child: const HomeSettingPage(),
    );
  }
}

class HomeSettingPage extends ConsumerWidget {
  const HomeSettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeSetting Mode'),
      ),
      body: Center(
        child: TextButton(
          onPressed: () {
            ref.read(homeNavigatorProvider).pushSettingPage(context);
          },
          child: const Text('Setting'),
        ),
      ),
    );
  }
}
