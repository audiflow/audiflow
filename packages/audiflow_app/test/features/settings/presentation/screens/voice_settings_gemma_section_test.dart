import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:audiflow_app/features/settings/presentation/controllers/gemma_voice_capability_controller.dart';
import 'package:audiflow_app/features/settings/presentation/screens/voice_settings_screen.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget buildTestWidget(GemmaVoiceCapability capability) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        gemmaVoiceCapabilityProvider.overrideWith((ref) async => capability),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const VoiceSettingsScreen(),
      ),
    );
  }

  group('VoiceSettingsScreen Gemma section', () {
    testWidgets('shows unsupported message when device cannot run any variant', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          const GemmaVoiceCapability.unsupported(
            reason: GemmaVoiceUnsupportedReason.insufficientRam,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('On-device AI not available'), findsOneWidget);
      expect(
        find.text(
          "This device doesn't have enough memory to run the on-device model.",
        ),
        findsOneWidget,
      );
      // Toggle for Gemma opt-in must NOT be rendered.
      expect(find.text('Use on-device AI'), findsNothing);
    });

    testWidgets('renders opt-in toggle when supported', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          GemmaVoiceCapability.supported(
            available: const [GemmaModelVariant.e2b, GemmaModelVariant.e4b],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Use on-device AI'), findsOneWidget);
      // Off by default; variant selector should not be shown yet.
      expect(find.byType(SegmentedButton<GemmaModelVariant>), findsNothing);
    });

    testWidgets('opting in reveals variant selector with available options', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          GemmaVoiceCapability.supported(
            available: const [GemmaModelVariant.e2b, GemmaModelVariant.e4b],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The Gemma toggle is the second SwitchListTile (after voice-enabled).
      final switches = tester.widgetList<SwitchListTile>(
        find.byType(SwitchListTile),
      );
      final gemmaSwitch = switches.firstWhere(
        (s) => (s.title! as Text).data == 'Use on-device AI',
      );
      gemmaSwitch.onChanged!(true);
      await tester.pumpAndSettle();

      expect(find.byType(SegmentedButton<GemmaModelVariant>), findsOneWidget);
    });
  });
}
