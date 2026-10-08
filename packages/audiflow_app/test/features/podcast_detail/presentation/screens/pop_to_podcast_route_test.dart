import 'package:audiflow_app/features/podcast_detail/presentation/screens/smart_playlist_group_episodes_screen.dart';
import 'package:audiflow_app/routing/app_router.dart' show AppRoutes;
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('pops past a playlist screen back to the podcast', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(navigatorKey: navigatorKey, home: const Text('library')),
    );
    final navigator = navigatorKey.currentState!;
    for (final name in [
      AppRoutes.podcastDetailChild,
      AppRoutes.smartPlaylistEpisodes,
      AppRoutes.smartPlaylistGroupEpisodesPath,
    ]) {
      unawaitedPush(navigator, name);
    }
    await tester.pumpAndSettle();
    check(find.text('group/:groupId').evaluate()).length.equals(1);

    popToPodcastRoute(navigator);
    await tester.pumpAndSettle();

    check(find.text(AppRoutes.podcastDetailChild).evaluate()).length.equals(1);
    check(navigator.canPop()).isTrue();
  });
}

void unawaitedPush(NavigatorState navigator, String name) {
  navigator.push(
    MaterialPageRoute<void>(
      settings: RouteSettings(name: name),
      builder: (_) => Scaffold(body: Text(name)),
    ),
  );
}
