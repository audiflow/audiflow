import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seasoning/l10n/L.dart';
import 'package:seasoning/providers/theme_provider.dart';
import 'package:seasoning/services/podcast/podcast_service_provider.dart';
import 'package:seasoning/ui/app/navigation_helper.dart';
import 'package:seasoning/ui/pages/podcast_chart_page.dart';

ThemeData theme = Themes.lightTheme().themeData;

class SeasoningApp extends StatelessWidget {
  const SeasoningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: NavigationHelper.router,
      localizationsDelegates: const <LocalizationsDelegate<Object>>[
        AnytimeLocalisationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('de', ''),
      ],
      theme: theme,
    );
  }
}

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    useEffect(
      () {
        ref.read(podcastServiceProvider).setup();
        return null;
      },
      [],
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: CustomScrollView(
        shrinkWrap: true,
        controller: scrollController,
        slivers: const [
//          SliverPinnedHeader(child: PodcastSearchBar()),
          PodcastChartPage(),
        ],
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
      ),
    );
  }
}

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SignUp'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                NavigationHelper.router.push(
                  NavigationHelper.signInPath,
                );
              },
              child: const Text('Push SignIn'),
            ),
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Using push method of router enable us to go back functionality',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SignIn'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                NavigationHelper.router.push(
                  NavigationHelper.homePath,
                );
              },
              child: const Text('Push Home Page'),
            ),
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Using push method of router enable us to push that page as standalone page instead of showing with Shell',
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                NavigationHelper.router.go(
                  NavigationHelper.homePath,
                );
              },
              child: const Text('Go Home Page'),
            ),
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Instead if we use go method of router we will have the home page with the Shell',
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                NavigationHelper.router.go(
                  NavigationHelper.searchPath,
                );
              },
              child: const Text('Go Search Page'),
            ),
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Or instead we can launch the bottom navigation page(with shell) for different tab with only changing the path',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchPage1 extends StatelessWidget {
  const SearchPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                NavigationHelper.router.go(NavigationHelper.homePath);
                NavigationHelper.router.push(NavigationHelper.detailPath);
              },
              child: const Text('Go Home Tab -> Push Detail Page'),
            ),
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'It will change the tab without loosing the state',
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                NavigationHelper.router.go(
                  NavigationHelper.settingsPath,
                );
              },
              child: const Text('Go Settings Tab'),
            ),
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Or instead we can launch the bottom navigation page(with shell) for different tab with only changing the path',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                NavigationHelper.router.go(
                  NavigationHelper.signInPath,
                );
              },
              child: const Text('Go SignIn Page'),
            ),
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Or instead we can launch the bottom navigation page(with shell) for different tab with only changing the path',
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                NavigationHelper.router.push(
                  NavigationHelper.signUpPath,
                );
              },
              child: const Text('Push SignIn Page'),
            ),
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Or instead we can launch the bottom navigation page(with shell) for different tab with only changing the path',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
