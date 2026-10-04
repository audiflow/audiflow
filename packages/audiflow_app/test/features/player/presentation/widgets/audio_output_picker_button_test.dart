import 'package:audiflow_app/features/player/presentation/widgets/audio_output_picker_button.dart';
import 'package:audiflow_app/features/player/services/audio_route_channel.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingAudioRouteChannel extends AudioRouteChannel {
  int showPickerCalls = 0;
  bool opens = true;

  @override
  Future<bool> showPicker() async {
    showPickerCalls++;
    return opens;
  }
}

void main() {
  late _RecordingAudioRouteChannel channel;

  setUp(() => channel = _RecordingAudioRouteChannel());

  Widget host() {
    return ProviderScope(
      overrides: [audioRouteChannelProvider.overrideWithValue(channel)],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: Center(child: AudioOutputPickerButton())),
      ),
    );
  }

  testWidgets(
    'Android: tapping opens the system output switcher',
    variant: TargetPlatformVariant.only(TargetPlatform.android),
    (tester) async {
      await tester.pumpWidget(host());

      expect(find.byTooltip('Audio output'), findsOneWidget);
      await tester.tap(find.byType(IconButton));
      expect(channel.showPickerCalls, 1);
      await tester.pump();
      expect(find.byType(SnackBar), findsNothing);
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

      expect(find.text("Couldn't open audio output settings"), findsOneWidget);
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
      expect(view.viewType, audioRoutePickerViewType);
      expect(view.creationParams, {'label': 'Audio output'});
      // The native view owns the tap, so no Flutter button is drawn.
      expect(find.byType(IconButton), findsNothing);
    },
  );
}
