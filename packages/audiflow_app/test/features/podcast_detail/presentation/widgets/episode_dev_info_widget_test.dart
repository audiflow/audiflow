import 'package:audiflow_app/features/podcast_detail/presentation/widgets/episode_dev_info_widget.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

MaterialApp _localizedApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );
}

void main() {
  group('EpisodeDevInfoWidget', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    testWidgets('hidden when toggle is off', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: _localizedApp(
            const EpisodeDevInfoWidget(feedUrl: 'https://example.com/feed.xml'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      check(find.text('Developer').evaluate()).isEmpty();
      check(find.text('RSS Feed URL').evaluate()).isEmpty();
    });

    testWidgets('shows RSS URL when toggle is on', (tester) async {
      await prefs.setBool('dev_show_developer_info', true);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: _localizedApp(
            const EpisodeDevInfoWidget(feedUrl: 'https://example.com/feed.xml'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      check(find.text('Developer').evaluate()).isNotEmpty();
      check(find.text('https://example.com/feed.xml').evaluate()).isNotEmpty();
      check(find.byType(IconButton).evaluate()).isNotEmpty();
    });

    testWidgets('shows "Not defined" when no pattern matches', (tester) async {
      await prefs.setBool('dev_show_developer_info', true);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            patternSummariesProvider.overrideWith(
              () => _EmptyPatternSummaries(),
            ),
          ],
          child: _localizedApp(
            const EpisodeDevInfoWidget(feedUrl: 'https://unknown.com/feed.xml'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The exact text uses an em dash
      check(find.textContaining('Not defined').evaluate()).isNotEmpty();
    });

    testWidgets('shows pattern name when matched', (tester) async {
      await prefs.setBool('dev_show_developer_info', true);
      final summaries = [
        PatternSummary(
          id: 'coten_radio',
          dataVersion: 1,
          displayName: 'Coten Radio',
          feedUrlHint: 'anchor.fm/s/8c2088c',
          playlistCount: 3,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            patternSummariesProvider.overrideWith(
              () => _PreloadedPatternSummaries(summaries),
            ),
          ],
          child: _localizedApp(
            const EpisodeDevInfoWidget(
              feedUrl: 'https://anchor.fm/s/8c2088c/podcast/rss',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      check(find.text('Coten Radio').evaluate()).isNotEmpty();
    });
  });
}

class _EmptyPatternSummaries extends PatternSummaries {
  @override
  List<PatternSummary> build() => [];
}

class _PreloadedPatternSummaries extends PatternSummaries {
  _PreloadedPatternSummaries(this._initial);
  final List<PatternSummary> _initial;

  @override
  List<PatternSummary> build() => _initial;
}
