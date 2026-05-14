import 'package:audiflow_app/features/settings/presentation/screens/about_screen.dart';
import 'package:audiflow_app/features/settings/presentation/utils/rate_app_service.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

class _FakeRateAppService implements RateAppService {
  int calls = 0;
  Object? errorToThrow;

  @override
  Future<void> openStoreListing() async {
    calls++;
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
  }
}

class _FakeReviewPromptRepository implements ReviewPromptRepository {
  ReviewPromptStats _stats = const ReviewPromptStats();
  int markUserRatedCalls = 0;

  @override
  ReviewPromptStats getStats() => _stats;

  @override
  Future<void> addListenedMs(int deltaMs) async {}

  @override
  Future<void> markOptedOut() async {
    _stats = _stats.copyWith(userOptedOut: true);
  }

  @override
  Future<void> markUserRated() async {
    markUserRatedCalls++;
    _stats = _stats.copyWith(userTappedRateNow: true);
  }

  @override
  Future<void> recordPromptShown(DateTime shownAt) async {}

  @override
  Future<void> reset() async {
    _stats = const ReviewPromptStats();
  }
}

void main() {
  late PackageInfo packageInfo;
  late _FakeRateAppService rateAppService;
  late _FakeReviewPromptRepository reviewPromptRepository;

  setUp(() {
    packageInfo = PackageInfo(
      appName: 'audiflow',
      packageName: 'com.audiflow.app',
      version: '1.0.0',
      buildNumber: '42',
    );
    rateAppService = _FakeRateAppService();
    reviewPromptRepository = _FakeReviewPromptRepository();
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        packageInfoProvider.overrideWithValue(packageInfo),
        rateAppServiceProvider.overrideWithValue(rateAppService),
        reviewPromptRepositoryProvider.overrideWithValue(
          reviewPromptRepository,
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AboutScreen(),
      ),
    );
  }

  group('AboutScreen', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(AboutScreen), findsOneWidget);
    });

    testWidgets('displays AppBar with About title', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      final title = appBar.title! as Text;
      expect(title.data, equals('About'));
    });

    testWidgets('shows app name in header', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('audiflow'), findsOneWidget);
      expect(find.text('Your podcast companion'), findsOneWidget);
    });

    testWidgets('shows version info', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Version'), findsOneWidget);
      expect(find.text('1.0.0 (42)'), findsOneWidget);
    });

    testWidgets('shows Open Source Licenses tile', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Open Source Licenses'), findsOneWidget);
    });

    testWidgets('shows Send Feedback tile', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Send Feedback'), findsOneWidget);
    });

    testWidgets('shows Rate the App tile', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Rate the App'), findsOneWidget);
    });

    testWidgets('tapping Send Feedback shows coming soon snackbar', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Send Feedback'));
      await tester.pumpAndSettle();

      expect(find.text('Coming soon'), findsOneWidget);
    });

    testWidgets('tapping Rate the App opens store listing', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Rate the App'));
      await tester.pumpAndSettle();

      check(rateAppService.calls).equals(1);
    });

    testWidgets('tapping Rate the App marks the user as rated', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Rate the App'));
      await tester.pumpAndSettle();

      check(reviewPromptRepository.markUserRatedCalls).equals(1);
      check(reviewPromptRepository.getStats().userTappedRateNow).isTrue();
    });

    testWidgets('shows failure snackbar when openStoreListing throws', (
      tester,
    ) async {
      rateAppService.errorToThrow = Exception('boom');
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Rate the App'));
      await tester.pumpAndSettle();

      expect(find.text('Could not open the store'), findsOneWidget);
    });
  });
}
