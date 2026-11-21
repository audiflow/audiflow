import 'package:audiflow_app/features/sync/presentation/screens/sync_add_device_screen.dart';
import 'package:audiflow_app/features/sync/presentation/screens/sync_join_screen.dart';
import 'package:audiflow_app/features/sync/presentation/screens/sync_settings_screen.dart';
import 'package:audiflow_app/routing/app_router.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' hide expect;
import 'package:go_router/go_router.dart';

import 'sync_test_harness.dart';

void main() {
  late SyncHarness harness;

  setUpAll(SyncHarness.initializeIsar);
  setUp(() async => harness = await SyncHarness.open());
  tearDown(() => harness.close());

  List<RouteBase> routes() => [
    GoRoute(
      path: AppRoutes.settingsDeviceSync,
      builder: (_, _) => const SyncSettingsScreen(),
      routes: [
        GoRoute(path: 'add', builder: (_, _) => const SyncAddDeviceScreen()),
        GoRoute(
          path: 'join',
          builder: (_, _) =>
              SyncJoinScreen(scannerBuilder: (_, _) => const SizedBox()),
        ),
      ],
    ),
  ];

  // The controller writes to a real Isar: let its I/O finish, then run
  // the continuations queued in the test zone.
  Future<void> settleIo(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
    }
    await tester.pumpAndSettle();
  }

  Future<void> pumpAt(WidgetTester tester, String location) async {
    await tester.pumpWidget(harness.app(location, routes()));
    await tester.pumpAndSettle();
  }

  testWidgets('off: offers to turn on or join', (tester) async {
    await pumpAt(tester, AppRoutes.settingsDeviceSync);

    check(find.text('Turn On Sync').evaluate()).isNotEmpty();
    check(find.text('Join from Another Device').evaluate()).isNotEmpty();
    check(find.text('Add a Device').evaluate()).isEmpty();
  });

  testWidgets('turning on after confirming shows the on sections', (
    tester,
  ) async {
    await tester.runAsync(() => pumpAt(tester, AppRoutes.settingsDeviceSync));

    await tester.tap(find.text('Turn On Sync'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Turn On Sync'));
    await settleIo(tester);

    check(harness.controller.isOn).isTrue();
    check(find.text('Add a Device').evaluate()).isNotEmpty();
    check(find.text('Turn Off Sync on This Device').evaluate()).isNotEmpty();
  });

  testWidgets('cancelling the confirmation leaves sync off', (tester) async {
    await pumpAt(tester, AppRoutes.settingsDeviceSync);

    await tester.tap(find.text('Turn On Sync'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    check(harness.controller.isOn).isFalse();
  });

  testWidgets('add device shows the QR and hides the recovery code', (
    tester,
  ) async {
    await tester.runAsync(harness.controller.turnOn);
    await pumpAt(tester, AppRoutes.settingsDeviceSyncAdd);

    // QrImageView keeps its data private; the recovery code below checks
    // the same credentials.
    check(find.byKey(SyncAddDeviceScreen.qrKey).evaluate()).isNotEmpty();
    check(find.byKey(SyncAddDeviceScreen.recoveryCodeKey).evaluate()).isEmpty();

    await tester.tap(find.text('Show Recovery Code'));
    await tester.pumpAndSettle();

    final shown = tester
        .widget<SelectableText>(find.byKey(SyncAddDeviceScreen.recoveryCodeKey))
        .data!;
    check(
      PairingCodec.decodeRecoveryCode(shown),
    ).equals(harness.controller.credentials!);
  });

  testWidgets('a mistyped recovery code is refused in place', (tester) async {
    await pumpAt(tester, AppRoutes.settingsDeviceSyncJoin);

    await tester.tap(find.text('Enter Recovery Code'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'ABCD-EFGH');
    await tester.tap(find.widgetWithText(FilledButton, 'Join'));
    await tester.pumpAndSettle();

    check(find.textContaining("doesn't check out").evaluate()).isNotEmpty();
    check(harness.controller.isOn).isFalse();
  });

  testWidgets('a valid recovery code joins after confirming', (tester) async {
    final credentials = SyncCredentials.generate();
    await tester.runAsync(
      () => pumpAt(tester, AppRoutes.settingsDeviceSyncJoin),
    );

    await tester.tap(find.text('Enter Recovery Code'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField),
      PairingCodec.encodeRecoveryCode(credentials).toLowerCase(),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Join'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Join'));
    await settleIo(tester);

    check(harness.controller.credentials).equals(credentials);
    check(find.byType(SyncSettingsScreen).evaluate()).isNotEmpty();
  });
}
