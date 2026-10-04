import 'package:audiflow_app/features/player/presentation/widgets/audio_output_picker_button.dart';
import 'package:audiflow_app/features/player/services/audio_route_channel.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingAudioRouteChannel extends AudioRouteChannel {
  int showPickerCalls = 0;

  @override
  Future<bool> showPicker() async {
    showPickerCalls++;
    return true;
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

  testWidgets('Android: tapping opens the system output switcher', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(host());

    expect(find.byTooltip('Audio output'), findsOneWidget);
    await tester.tap(find.byType(IconButton));
    expect(channel.showPickerCalls, 1);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('iOS: native route picker sits over the Flutter icon', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
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
    debugDefaultTargetPlatformOverride = null;
  });
}
