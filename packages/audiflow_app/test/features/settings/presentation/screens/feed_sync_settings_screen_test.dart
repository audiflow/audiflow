import 'dart:async';

import 'package:audiflow_app/features/settings/presentation/screens/feed_sync_settings_screen.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_core/audiflow_core.dart';
import 'package:checks/checks.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const FeedSyncSettingsScreen(),
      ),
    );
  }

  group('FeedSyncSettingsScreen', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(FeedSyncSettingsScreen), findsOneWidget);
    });

    testWidgets('displays AppBar with Feed Sync title', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      final title = appBar.title! as Text;
      expect(title.data, equals('Feed Sync'));
    });

    testWidgets('shows auto-sync enabled by default', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Auto-Sync'), findsOneWidget);

      final tiles = tester
          .widgetList<SwitchListTile>(find.byType(SwitchListTile))
          .toList();
      // First SwitchListTile is auto-sync
      expect(tiles[0].value, isTrue);
    });

    testWidgets('shows sync interval visible when auto-sync is on', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Sync Interval'), findsOneWidget);
      // Default should be 60 min = "1 hour"
      expect(find.text('1 hour'), findsOneWidget);
    });

    testWidgets('shows WiFi-only sync disabled by default', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('WiFi-Only Sync'), findsOneWidget);

      final tiles = tester
          .widgetList<SwitchListTile>(find.byType(SwitchListTile))
          .toList();
      // Second SwitchListTile is WiFi-only sync
      expect(tiles[1].value, isFalse);
    });

    testWidgets('hides sync interval when auto-sync is off', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Toggle auto-sync off
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      // Sync Interval should now be hidden via Visibility (first Visibility widget)
      final visibility = tester.firstWidget<Visibility>(
        find.byType(Visibility),
      );
      expect(visibility.visible, isFalse);
    });

    testWidgets('toggling auto-sync updates state', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      final tiles = tester
          .widgetList<SwitchListTile>(find.byType(SwitchListTile))
          .toList();
      expect(tiles[0].value, isFalse);
    });
  });

  group('FeedSyncSettingsScreen notification permission', () {
    late PermissionHandlerPlatform originalPlatform;
    late _FakePermissionHandler fakePermissions;

    setUp(() async {
      // Notifications default to on; start from off so the tap requests.
      SharedPreferences.setMockInitialValues({
        SettingsKeys.notifyNewEpisodes: false,
      });
      prefs = await SharedPreferences.getInstance();
      originalPlatform = PermissionHandlerPlatform.instance;
    });

    tearDown(() {
      PermissionHandlerPlatform.instance = originalPlatform;
    });

    Future<void> tapNotifySwitch(WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.byType(Switch).last);
      await tester.pumpAndSettle();
    }

    bool notifySwitchValue(WidgetTester tester) {
      return tester
          .widgetList<SwitchListTile>(find.byType(SwitchListTile))
          .last
          .value;
    }

    testWidgets('enables notifications when the request is granted', (
      tester,
    ) async {
      fakePermissions = _FakePermissionHandler(
        status: PermissionStatus.denied,
        requestResult: PermissionStatus.granted,
      );
      PermissionHandlerPlatform.instance = fakePermissions;

      await tapNotifySwitch(tester);

      check(fakePermissions.requestCount).equals(1);
      check(notifySwitchValue(tester)).isTrue();
      check(find.text('Permission required').evaluate()).isEmpty();
    });

    testWidgets(
      'shows settings dialog when the request is permanently denied',
      (tester) async {
        // Android reports a permanently denied permission as `denied` from
        // `status`; only the request result reveals it.
        fakePermissions = _FakePermissionHandler(
          status: PermissionStatus.denied,
          requestResult: PermissionStatus.permanentlyDenied,
        );
        PermissionHandlerPlatform.instance = fakePermissions;

        await tapNotifySwitch(tester);

        check(fakePermissions.requestCount).equals(1);
        check(notifySwitchValue(tester)).isFalse();
        check(find.text('Permission required').evaluate().length).equals(1);
      },
    );

    testWidgets('skips the request when status is already permanently denied', (
      tester,
    ) async {
      fakePermissions = _FakePermissionHandler(
        status: PermissionStatus.permanentlyDenied,
        requestResult: PermissionStatus.permanentlyDenied,
      );
      PermissionHandlerPlatform.instance = fakePermissions;

      await tapNotifySwitch(tester);

      check(fakePermissions.requestCount).equals(0);
      check(notifySwitchValue(tester)).isFalse();
      check(find.text('Permission required').evaluate().length).equals(1);
    });
  });

  group(
    'FeedSyncSettingsScreen notification toggle reflects OS permission',
    () {
      late PermissionHandlerPlatform originalPlatform;

      setUp(() {
        originalPlatform = PermissionHandlerPlatform.instance;
      });

      tearDown(() {
        PermissionHandlerPlatform.instance = originalPlatform;
      });

      bool notifySwitchValue(WidgetTester tester) {
        return tester
            .widgetList<SwitchListTile>(find.byType(SwitchListTile))
            .last
            .value;
      }

      testWidgets('shows OFF when the preference is on but permission is not', (
        tester,
      ) async {
        PermissionHandlerPlatform.instance = _FakePermissionHandler(
          status: PermissionStatus.denied,
          requestResult: PermissionStatus.granted,
        );

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        check(notifySwitchValue(tester)).isFalse();
      });

      testWidgets('shows ON when the preference is on and permission granted', (
        tester,
      ) async {
        PermissionHandlerPlatform.instance = _FakePermissionHandler(
          status: PermissionStatus.granted,
          requestResult: PermissionStatus.granted,
        );

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        check(notifySwitchValue(tester)).isTrue();
      });

      testWidgets('re-checks permission when the app resumes', (tester) async {
        final fake = _FakePermissionHandler(
          status: PermissionStatus.granted,
          requestResult: PermissionStatus.granted,
        );
        PermissionHandlerPlatform.instance = fake;
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // User revokes permission in system settings, then returns.
        fake.status = PermissionStatus.denied;
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pumpAndSettle();

        check(notifySwitchValue(tester)).isFalse();
      });

      testWidgets('turns ON after granting from the effectively-OFF state', (
        tester,
      ) async {
        final fake = _FakePermissionHandler(
          status: PermissionStatus.denied,
          requestResult: PermissionStatus.granted,
        );
        PermissionHandlerPlatform.instance = fake;
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.byType(Switch).last);
        await tester.pumpAndSettle();

        check(fake.requestCount).equals(1);
        check(notifySwitchValue(tester)).isTrue();
      });

      testWidgets('ignores taps while a permission request is pending', (
        tester,
      ) async {
        final pending = Completer<void>();
        final fake = _FakePermissionHandler(
          status: PermissionStatus.denied,
          requestResult: PermissionStatus.granted,
          pendingRequest: pending,
        );
        PermissionHandlerPlatform.instance = fake;
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.byType(Switch).last);
        await tester.pump();
        await tester.tap(find.byType(Switch).last);
        await tester.pump();
        pending.complete();
        await tester.pumpAndSettle();

        check(fake.requestCount).equals(1);
        check(notifySwitchValue(tester)).isTrue();
      });
    },
  );
}

class _FakePermissionHandler extends PermissionHandlerPlatform
    with MockPlatformInterfaceMixin {
  _FakePermissionHandler({
    required this.status,
    required this.requestResult,
    this.pendingRequest,
  });

  PermissionStatus status;
  final PermissionStatus requestResult;

  /// When set, requests stay pending until this completes, like an open
  /// OS permission dialog.
  final Completer<void>? pendingRequest;
  int requestCount = 0;

  @override
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    return status;
  }

  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(
    List<Permission> permissions,
  ) async {
    requestCount += 1;
    await pendingRequest?.future;
    return {for (final permission in permissions) permission: requestResult};
  }
}
