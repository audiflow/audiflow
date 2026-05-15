import 'package:audiflow_app/features/settings/presentation/screens/about_screen.dart';
import 'package:audiflow_app/features/settings/presentation/utils/feedback_service.dart';
import 'package:audiflow_app/features/settings/presentation/utils/rate_app_service.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _FakeFeedbackService implements FeedbackService {
  int calls = 0;
  bool result = true;
  Object? errorToThrow;

  @override
  Future<bool> openFeedback() async {
    calls++;
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return result;
  }
}

class _FakeReviewPromptRepository implements ReviewPromptRepository {
  ReviewPromptStats _stats = const ReviewPromptStats();
  int markRatedCalls = 0;
  int recordPromptShownCalls = 0;

  @override
  ReviewPromptStats getStats() => _stats;

  @override
  Future<void> addListened(Duration delta) async {}

  @override
  Future<void> markOptedOut() async {
    _stats = _stats.copyWith(status: ReviewPromptStatus.optedOut);
  }

  @override
  Future<void> markRated() async {
    markRatedCalls++;
    _stats = _stats.copyWith(status: ReviewPromptStatus.rated);
  }

  @override
  Future<void> recordPromptShown() async {
    recordPromptShownCalls++;
  }

  @override
  Future<void> reset() async {
    _stats = const ReviewPromptStats();
  }
}

void main() {
  late PackageInfo packageInfo;
  late _FakeRateAppService rateAppService;
  late _FakeFeedbackService feedbackService;
  late _FakeReviewPromptRepository reviewPromptRepository;

  setUp(() {
    packageInfo = PackageInfo(
      appName: 'audiflow',
      packageName: 'com.audiflow.app',
      version: '1.0.0',
      buildNumber: '42',
    );
    rateAppService = _FakeRateAppService();
    feedbackService = _FakeFeedbackService();
    reviewPromptRepository = _FakeReviewPromptRepository();
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        packageInfoProvider.overrideWithValue(packageInfo),
        rateAppServiceProvider.overrideWithValue(rateAppService),
        feedbackServiceProvider.overrideWithValue(feedbackService),
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

    testWidgets('tapping Send Feedback opens feedback page', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('Send Feedback'));
      await tester.pumpAndSettle();
      check(feedbackService.calls).equals(1);
      expect(find.text('Could not open the feedback page'), findsNothing);
    });

    testWidgets('shows failure snackbar when openFeedback returns false', (
      tester,
    ) async {
      feedbackService.result = false;
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('Send Feedback'));
      await tester.pumpAndSettle();
      expect(find.text('Could not open the feedback page'), findsOneWidget);
    });

    testWidgets('shows failure snackbar when openFeedback throws', (
      tester,
    ) async {
      feedbackService.errorToThrow = PlatformException(code: 'X');
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('Send Feedback'));
      await tester.pumpAndSettle();
      expect(find.text('Could not open the feedback page'), findsOneWidget);
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
      check(reviewPromptRepository.markRatedCalls).equals(1);
      check(
        reviewPromptRepository.getStats().status,
      ).equals(ReviewPromptStatus.rated);
    });

    testWidgets('tapping Rate the App does not advance threshold', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('Rate the App'));
      await tester.pumpAndSettle();
      check(reviewPromptRepository.recordPromptShownCalls).equals(0);
    });

    testWidgets('shows failure snackbar when openStoreListing throws', (
      tester,
    ) async {
      rateAppService.errorToThrow = PlatformException(code: 'X');
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('Rate the App'));
      await tester.pumpAndSettle();
      expect(find.text('Could not open the store'), findsOneWidget);
    });
  });
}
