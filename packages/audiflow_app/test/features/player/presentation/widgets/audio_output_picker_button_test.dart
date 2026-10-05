import 'dart:async';

import 'package:audiflow_app/features/player/presentation/widgets/audio_output_picker_button.dart';
import 'package:audiflow_app/features/player/services/audio_route_channel.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingAudioRouteChannel extends AudioRouteChannel {
  int showPickerCalls = 0;
  bool opens = true;

  /// When set, showPicker() waits for this instead of answering at once.
  Completer<bool>? pending;

  @override
  Future<bool> showPicker() async {
    showPickerCalls++;
    return pending?.future ?? opens;
  }
}

void main() {
  late _RecordingAudioRouteChannel channel;

  setUp(() => channel = _RecordingAudioRouteChannel());

  Widget host({bool showButton = true}) {
    return ProviderScope(
      overrides: [audioRouteChannelProvider.overrideWithValue(channel)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: showButton ? const AudioOutputPickerButton() : null,
          ),
        ),
      ),
    );
  }

  testWidgets(
    'Android: tapping opens the system output switcher',
    variant: TargetPlatformVariant.only(TargetPlatform.android),
    (tester) async {
      await tester.pumpWidget(host());

      check(find.byTooltip('Audio output').evaluate()).length.equals(1);
      await tester.tap(find.byType(IconButton));
      check(channel.showPickerCalls).equals(1);
      await tester.pump();
      check(find.byType(SnackBar).evaluate()).isEmpty();
    },
  );

  testWidgets(
    'Android: tells the listener when nothing could be opened',
    variant: TargetPlatformVariant.only(TargetPlatform.android),
    (tester) async {
      channel.opens = false;
      await tester.pumpWidget(host());

      await tester.tap(find.byType(IconButton));
      await tester.pump();

      check(
        find.text("Couldn't open audio output settings").evaluate(),
      ).length.equals(1);
    },
  );

  testWidgets(
    'Android: stays quiet when the player closed before the answer',
    variant: TargetPlatformVariant.only(TargetPlatform.android),
    (tester) async {
      channel.pending = Completer<bool>();
      await tester.pumpWidget(host());
      await tester.tap(find.byType(IconButton));

      await tester.pumpWidget(host(showButton: false));
      channel.pending!.complete(false);
      await tester.pump();

      check(find.byType(SnackBar).evaluate()).isEmpty();
    },
  );

  testWidgets(
    'iOS: native route picker sits over the Flutter icon',
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    (tester) async {
      final messenger = tester.binding.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        SystemChannels.platform_views,
        (_) async => null,
      );
      addTearDown(
        () => messenger.setMockMethodCallHandler(
          SystemChannels.platform_views,
          null,
        ),
      );
      await tester.pumpWidget(host());

      final view = tester.widget<UiKitView>(find.byType(UiKitView));
      check(view.viewType).equals(audioRoutePickerViewType);
      check(
        view.creationParams as Map<Object?, Object?>?,
      ).isNotNull().deepEquals({'label': 'Audio output'});
      // The native view owns the tap, so no Flutter button is drawn.
      check(find.byType(IconButton).evaluate()).isEmpty();
    },
  );
}
