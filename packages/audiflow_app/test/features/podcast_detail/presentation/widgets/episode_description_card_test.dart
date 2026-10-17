import 'package:audiflow_app/features/podcast_detail/presentation/widgets/episode_description_card.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_app/l10n/app_localizations_en.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

void main() {
  final l10n = AppLocalizationsEn();
  const link = 'https://example.com/notes';
  final long = List.generate(30, (i) => 'Line $i of the notes.').join('\n');
  final longWithLink = '$link\n$long';

  late _FakeUrlLauncher launcher;

  setUp(() {
    launcher = _FakeUrlLauncher();
    final original = UrlLauncherPlatform.instance;
    UrlLauncherPlatform.instance = launcher;
    addTearDown(() => UrlLauncherPlatform.instance = original);
  });

  Future<void> pump(WidgetTester tester, String content) async {
    await tester.binding.setSurfaceSize(const Size(400, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: EpisodeDescriptionCard(content: content),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  double cardHeight(WidgetTester tester) =>
      tester.getSize(find.byType(EpisodeDescriptionCard)).height;

  // The first line of the notes: the link when the content starts with one.
  Future<void> tapFirstLine(WidgetTester tester) async {
    await tester.tapAt(
      tester.getTopLeft(find.byType(Html)) + const Offset(8, 8),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapShowMore(WidgetTester tester) async {
    // While clamped the card absorbs the tap above the button itself.
    await tester.tap(
      find.text(l10n.episodeDetailShowMore),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
  }

  group('EpisodeDescriptionCard', () {
    testWidgets('short notes show no toggle', (tester) async {
      await pump(tester, 'One short line.');

      check(find.text(l10n.episodeDetailAbout).evaluate()).length.equals(1);
      check(find.text(l10n.episodeDetailShowMore).evaluate()).isEmpty();
    });

    testWidgets('long notes clamp and expand with the toggle', (tester) async {
      await pump(tester, long);
      final collapsed = cardHeight(tester);

      await tapShowMore(tester);
      check(cardHeight(tester)).isGreaterThan(collapsed);

      await tester.tap(find.text(l10n.episodeDetailShowLess));
      await tester.pumpAndSettle();
      check(cardHeight(tester)).equals(collapsed);
      check(find.text(l10n.episodeDetailShowMore).evaluate()).length.equals(1);
    });

    testWidgets('tapping the clamped text expands it', (tester) async {
      await pump(tester, long);
      final collapsed = cardHeight(tester);

      await tapFirstLine(tester);

      check(cardHeight(tester)).isGreaterThan(collapsed);
      check(find.text(l10n.episodeDetailShowLess).evaluate()).length.equals(1);
    });

    testWidgets('tapping a link while clamped expands without opening it', (
      tester,
    ) async {
      await pump(tester, longWithLink);
      final collapsed = cardHeight(tester);

      await tapFirstLine(tester);

      check(cardHeight(tester)).isGreaterThan(collapsed);
      check(launcher.launchedUrls).isEmpty();
    });

    testWidgets('links open once expanded', (tester) async {
      await pump(tester, longWithLink);
      await tapShowMore(tester);

      await tapFirstLine(tester);

      check(launcher.launchedUrls).deepEquals([link]);
    });

    testWidgets('tapping the expanded text does not collapse it', (
      tester,
    ) async {
      await pump(tester, long);
      await tapShowMore(tester);
      final expanded = cardHeight(tester);

      await tapFirstLine(tester);

      check(cardHeight(tester)).equals(expanded);
      check(find.text(l10n.episodeDetailShowLess).evaluate()).length.equals(1);
    });

    testWidgets('short notes keep links live and have no tap target', (
      tester,
    ) async {
      await pump(tester, link);
      final height = cardHeight(tester);

      await tapFirstLine(tester);

      check(launcher.launchedUrls).deepEquals([link]);
      check(cardHeight(tester)).equals(height);
      check(
        find.bySemanticsLabel(l10n.episodeDetailShowMore).evaluate(),
      ).isEmpty();
    });

    testWidgets('clamped card exposes a single Show more button', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pump(tester, long);

      final buttons = find.bySemanticsLabel(l10n.episodeDetailShowMore);
      check(buttons.evaluate()).length.equals(1);
      expect(
        tester.getSemantics(buttons),
        isSemantics(
          label: l10n.episodeDetailShowMore,
          isButton: true,
          hasTapAction: true,
        ),
      );
      check(find.bySemanticsLabel(RegExp('Line 0')).evaluate()).isEmpty();
      semantics.dispose();
    });
  });
}

class _FakeUrlLauncher extends UrlLauncherPlatform
    with MockPlatformInterfaceMixin {
  final List<String> launchedUrls = [];

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launchedUrls.add(url);
    return true;
  }
}
