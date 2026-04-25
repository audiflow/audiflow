import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:audiflow_app/features/settings/presentation/controllers/gemma_voice_capability_controller.dart';
import 'package:audiflow_app/features/settings/presentation/screens/voice_settings_screen.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_core/audiflow_core.dart';
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

    testWidgets('toggling off hides the selector and persists false', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        SettingsKeys.voiceGemmaEnabled: true,
      });
      prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        buildTestWidget(
          GemmaVoiceCapability.supported(
            available: const [GemmaModelVariant.e2b, GemmaModelVariant.e4b],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Selector is visible because we pre-seeded enabled=true.
      expect(find.byType(SegmentedButton<GemmaModelVariant>), findsOneWidget);

      final gemmaSwitch = tester
          .widgetList<SwitchListTile>(find.byType(SwitchListTile))
          .firstWhere((s) => (s.title! as Text).data == 'Use on-device AI');
      gemmaSwitch.onChanged!(false);
      await tester.pumpAndSettle();

      expect(find.byType(SegmentedButton<GemmaModelVariant>), findsNothing);
      expect(prefs.getBool(SettingsKeys.voiceGemmaEnabled), isFalse);
    });

    testWidgets(
      'tapping a variant segment persists the choice to SharedPreferences',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          SettingsKeys.voiceGemmaEnabled: true,
          SettingsKeys.voiceGemmaVariant: 'e2b',
        });
        prefs = await SharedPreferences.getInstance();

        await tester.pumpWidget(
          buildTestWidget(
            GemmaVoiceCapability.supported(
              available: const [GemmaModelVariant.e2b, GemmaModelVariant.e4b],
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Larger (2500 MB)'));
        await tester.pumpAndSettle();

        expect(prefs.getString(SettingsKeys.voiceGemmaVariant), equals('e4b'));
      },
    );

    testWidgets(
      'persisted variant unavailable on this device is rewritten to fallback',
      (tester) async {
        // Persisted E4B from a previous device; current device only offers
        // E2B. The selector must show E2B AND re-persist E2B so the next
        // read isn't stale.
        SharedPreferences.setMockInitialValues({
          SettingsKeys.voiceGemmaEnabled: true,
          SettingsKeys.voiceGemmaVariant: 'e4b',
        });
        prefs = await SharedPreferences.getInstance();

        await tester.pumpWidget(
          buildTestWidget(
            GemmaVoiceCapability.supported(
              available: const [GemmaModelVariant.e2b],
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(prefs.getString(SettingsKeys.voiceGemmaVariant), equals('e2b'));
      },
    );

    testWidgets('error state still renders the unsupported tile', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            gemmaVoiceCapabilityProvider.overrideWith(
              (ref) async => throw Exception('plugin failed'),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const VoiceSettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('On-device AI not available'), findsOneWidget);
    });
  });
}
