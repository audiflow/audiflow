import 'package:audiflow_app/features/parental_control/domain/gate_guard.dart';
import 'package:audiflow_app/features/parental_control/providers/gate_guard_provider.dart';
import 'dart:async';

import 'package:audiflow_app/features/settings/presentation/controllers/opml_import_controller.dart';
import 'package:audiflow_app/features/settings/presentation/utils/opml_read_failure.dart';
import 'package:audiflow_app/features/settings/services/opml_file_picker.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _DenyingGateGuard implements GateGuard {
  @override
  Future<bool> requireUnlock(
    BuildContext context, {
    required GateReason reason,
  }) async => false;
}

class _AllowingGateGuard implements GateGuard {
  @override
  Future<bool> requireUnlock(
    BuildContext context, {
    required GateReason reason,
  }) async => true;
}

/// Hands out [file] once [picked] completes, standing in for the system
/// picker being open.
class _FakeOpmlFilePicker implements OpmlFilePicker {
  _FakeOpmlFilePicker({this.file, Future<void>? picked})
    : picked = picked ?? Future<void>.value();

  final PickedOpmlFile? file;
  final Future<void> picked;
  final requestedFilters = <OpmlPickFilter>[];

  @override
  Future<PickedOpmlFile?> pick(OpmlPickFilter filter) async {
    requestedFilters.add(filter);
    await picked;
    return file;
  }
}

class _SubscribedRepository extends FakeSubscriptionRepository {
  _SubscribedRepository(this.subscribedFeedUrls);

  final Set<String> subscribedFeedUrls;

  @override
  Future<bool> isSubscribedByFeedUrl(String feedUrl) async =>
      subscribedFeedUrls.contains(feedUrl);
}

const _feedA = 'https://example.com/a.xml';
const _feedB = 'https://example.com/b.xml';
const _validOpml =
    '''
<opml version="2.0"><body>
  <outline text="A" xmlUrl="$_feedA"/>
  <outline text="B" xmlUrl="$_feedB"/>
</body></opml>
''';

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('OpmlImportController.pickAndParse', () {
    testWidgets('returns false and stays idle when gate denies', (
      tester,
    ) async {
      late ProviderContainer container;
      late bool result;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            subscriptionRepositoryProvider.overrideWithValue(
              FakeSubscriptionRepository(),
            ),
            gateGuardProvider.overrideWithValue(_DenyingGateGuard()),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                container = ProviderScope.containerOf(context);
                return TextButton(
                  onPressed: () async {
                    result = await container
                        .read(opmlImportControllerProvider.notifier)
                        .pickAndParse(context);
                  },
                  child: const Text('tap'),
                );
              },
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.tap(find.text('tap'));
      await tester.pumpAndSettle();

      check(result).isFalse();
      check(container.read(opmlImportControllerProvider)).isA<OpmlPickIdle>();
    });

    group('after the gate allows', () {
      late ProviderContainer container;
      late BuildContext context;

      Future<void> pump(
        WidgetTester tester,
        OpmlFilePicker picker, {
        Set<String> subscribed = const {},
      }) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              subscriptionRepositoryProvider.overrideWithValue(
                _SubscribedRepository(subscribed),
              ),
              gateGuardProvider.overrideWithValue(_AllowingGateGuard()),
              opmlFilePickerProvider.overrideWithValue(picker),
            ],
            child: MaterialApp(
              home: Builder(
                builder: (c) {
                  context = c;
                  container = ProviderScope.containerOf(c);
                  return const SizedBox();
                },
              ),
            ),
          ),
        );
      }

      /// Stands in for OpmlImportFlow, whose listener keeps the auto-disposed
      /// controller alive through the import.
      ProviderSubscription<OpmlPickResult> listen() =>
          container.listen(opmlImportControllerProvider, (_, _) {});

      OpmlImportController notifier() =>
          container.read(opmlImportControllerProvider.notifier);
      OpmlPickResult state() => container.read(opmlImportControllerProvider);

      testWidgets('opens the filtered picker by default', (tester) async {
        final picker = _FakeOpmlFilePicker();
        await pump(tester, picker);

        await notifier().pickAndParse(context);

        check(picker.requestedFilters).deepEquals([OpmlPickFilter.opml]);
      });

      testWidgets('opens the unfiltered picker on request', (tester) async {
        final picker = _FakeOpmlFilePicker();
        await pump(tester, picker);

        await notifier().pickAndParse(context, filter: OpmlPickFilter.allFiles);

        check(picker.requestedFilters).deepEquals([OpmlPickFilter.allFiles]);
      });

      testWidgets('reports which filter a cancelled picker used', (
        tester,
      ) async {
        await pump(tester, _FakeOpmlFilePicker());

        await notifier().pickAndParse(context, filter: OpmlPickFilter.allFiles);

        check(state())
            .isA<OpmlPickCancelled>()
            .has((s) => s.filter, 'filter')
            .equals(OpmlPickFilter.allFiles);
      });

      testWidgets('shows loading only once a file has been chosen', (
        tester,
      ) async {
        final picked = Completer<void>();
        final content = Completer<String>();
        await pump(
          tester,
          _FakeOpmlFilePicker(
            picked: picked.future,
            file: PickedOpmlFile(() => content.future),
          ),
        );

        listen();
        final done = notifier().pickAndParse(context);
        await tester.pump();
        // A spinner here would sit behind the system picker on iOS, where the
        // picker is a sheet over the app.
        check(state()).isA<OpmlPickIdle>();

        picked.complete();
        await tester.pump();
        check(state()).isA<OpmlPickLoading>();

        content.complete(_validOpml);
        await done;
        check(state()).isA<OpmlPickSuccess>();
      });

      for (final (name, finish) in <(String, void Function(Completer<String>))>[
        ('succeeds', (c) => c.complete(_validOpml)),
        ('fails', (c) => c.completeError(const FormatException('x'))),
      ]) {
        testWidgets('ignores a read that $name after the user left', (
          tester,
        ) async {
          final content = Completer<String>();
          await pump(
            tester,
            _FakeOpmlFilePicker(file: PickedOpmlFile(() => content.future)),
          );
          final subscription = listen();
          final done = notifier().pickAndParse(context);
          await tester.pump();

          // Leaving the screen removes the flow's listener; a slow download
          // from Drive can still finish after that.
          subscription.close();
          await tester.pump();
          finish(content);

          check(await done).isTrue();
        });
      }

      testWidgets('returns entries and marks subscribed feeds', (tester) async {
        await pump(
          tester,
          _FakeOpmlFilePicker(file: PickedOpmlFile(() async => _validOpml)),
          subscribed: {_feedB},
        );

        await notifier().pickAndParse(context);

        final success = state() as OpmlPickSuccess;
        check(
          success.entries.map((e) => e.feedUrl),
        ).deepEquals([_feedA, _feedB]);
        check(success.subscribedFeedUrls).deepEquals({_feedB});
      });

      testWidgets('reports a file that cannot be read as unreadable', (
        tester,
      ) async {
        await pump(
          tester,
          _FakeOpmlFilePicker(
            file: PickedOpmlFile(() async => throw const FormatException('x')),
          ),
        );

        await notifier().pickAndParse(context);

        check(state())
            .isA<OpmlPickError>()
            .has((s) => s.failure, 'failure')
            .equals(OpmlReadFailure.unreadableFile);
      });

      testWidgets('leaves loading when reading throws an Error', (
        tester,
      ) async {
        await pump(
          tester,
          _FakeOpmlFilePicker(
            file: PickedOpmlFile(() async => throw StackOverflowError()),
          ),
        );

        await notifier().pickAndParse(context);

        check(state())
            .isA<OpmlPickError>()
            .has((s) => s.failure, 'failure')
            .equals(OpmlReadFailure.unexpected);
      });

      testWidgets('reports a file with no feeds', (tester) async {
        await pump(
          tester,
          _FakeOpmlFilePicker(
            file: PickedOpmlFile(() async => '<opml><body/></opml>'),
          ),
        );

        await notifier().pickAndParse(context);

        check(state())
            .isA<OpmlPickError>()
            .has((s) => s.failure, 'failure')
            .equals(OpmlReadFailure.noFeeds);
      });
    });
  });
}
