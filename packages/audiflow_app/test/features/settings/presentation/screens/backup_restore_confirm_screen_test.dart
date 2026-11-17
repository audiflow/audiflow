import 'dart:typed_data';

import 'package:audiflow_app/features/parental_control/domain/gate_guard.dart';
import 'package:audiflow_app/features/parental_control/providers/gate_guard_provider.dart';
import 'package:audiflow_app/features/settings/presentation/screens/backup_restore_confirm_screen.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeGateGuard implements GateGuard {
  _FakeGateGuard({required this.allows});

  final bool allows;
  GateReason? lastReason;

  @override
  Future<bool> requireUnlock(
    BuildContext context, {
    required GateReason reason,
  }) async {
    lastReason = reason;
    return allows;
  }
}

class _FakeService implements BackupRestoreService {
  _FakeService({this.error});

  final Object? error;
  int restores = 0;

  @override
  SnapshotFile read(Uint8List bytes) => readSnapshotFile(bytes);

  @override
  Future<BackupRestoreResult> restore(SnapshotFile file) async {
    restores++;
    if (error != null) throw error!;
    return BackupRestoreResult(1, Future.value());
  }
}

void main() {
  final file = readSnapshotFile(
    encodeSnapshotFile(
      body: SnapshotBody({}),
      createdAt: DateTime.utc(2026, 11, 17, 9),
      historyId: 'h',
      appVersion: '2.3.0',
      platform: 'android',
      counts: SnapshotCounts(
        podcasts: 52,
        episodes: 3810,
        queue: 14,
        stations: 3,
      ),
    ),
  );

  Future<void> pump(
    WidgetTester tester, {
    required _FakeGateGuard guard,
    required _FakeService service,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gateGuardProvider.overrideWithValue(guard),
          backupRestoreServiceProvider.overrideWithValue(service),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BackupRestoreConfirmScreen(file: file),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the header counts and source', (tester) async {
    await pump(
      tester,
      guard: _FakeGateGuard(allows: true),
      service: _FakeService(),
    );

    expect(find.text('52 podcasts'), findsOneWidget);
    expect(find.text('3810 episodes with progress'), findsOneWidget);
    expect(find.text('14 queued episodes'), findsOneWidget);
    expect(find.text('3 stations'), findsOneWidget);
    expect(find.textContaining('on Android'), findsOneWidget);
  });

  testWidgets('a denied PIN restores nothing', (tester) async {
    final guard = _FakeGateGuard(allows: false);
    final service = _FakeService();
    await pump(tester, guard: guard, service: service);

    await tester.tap(find.widgetWithText(FilledButton, 'Restore'));
    await tester.pumpAndSettle();

    check(guard.lastReason).equals(GateReason.restoreBackup);
    check(service.restores).equals(0);
    expect(find.byType(BackupRestoreConfirmScreen), findsOneWidget);
  });

  testWidgets('a restore closes the screen and says so', (tester) async {
    final service = _FakeService();
    await pump(tester, guard: _FakeGateGuard(allows: true), service: service);

    await tester.tap(find.widgetWithText(FilledButton, 'Restore'));
    await tester.pumpAndSettle();

    check(service.restores).equals(1);
    expect(find.byType(BackupRestoreConfirmScreen), findsNothing);
    expect(
      find.text('Backup restored. Podcasts update as their feeds load'),
      findsOneWidget,
    );
  });

  testWidgets('a failed restore stays and says nothing changed', (
    tester,
  ) async {
    await pump(
      tester,
      guard: _FakeGateGuard(allows: true),
      service: _FakeService(error: Exception('full')),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Restore'));
    await tester.pumpAndSettle();

    expect(find.byType(BackupRestoreConfirmScreen), findsOneWidget);
    expect(
      find.text('Restore failed. Your data was not changed'),
      findsOneWidget,
    );
  });
}
