import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/locale_controller.dart';
import '../controllers/theme_controller.dart';
import '../widgets/haptics_level_selector.dart';

/// Screen for configuring appearance settings: theme, language,
/// text size, and haptic feedback.
class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeControllerProvider);
    final textScale = ref.watch(textScaleControllerProvider);
    final locale = ref.watch(localeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsAppearanceTitle)),
      body: ListView(
        children: [
          _ThemeModeTile(
            themeMode: themeMode,
            onChanged: (mode) => ref
                .read(themeModeControllerProvider.notifier)
                .setThemeMode(mode),
          ),
          _LanguageTile(
            locale: locale,
            onChanged: (value) =>
                ref.read(localeControllerProvider.notifier).setLocale(value),
          ),
          _TextScaleTile(
            textScale: textScale,
            onChanged: (value) => ref
                .read(textScaleControllerProvider.notifier)
                .setTextScale(value),
          ),
          const _HapticsTile(),
        ],
      ),
    );
  }
}

class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile({required this.themeMode, required this.onChanged});

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.appearanceThemeMode,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(l10n.appearanceThemeLight),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text(l10n.appearanceThemeDark),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(l10n.appearanceThemeSystem),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (set) => onChanged(set.first),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.locale, required this.onChanged});

  final Locale? locale;
  final ValueChanged<Locale?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      title: Text(l10n.appearanceLanguage),
      trailing: DropdownButton<Locale?>(
        value: locale,
        onChanged: onChanged,
        items: [
          DropdownMenuItem(
            value: null,
            child: Text(l10n.appearanceThemeSystem),
          ),
          DropdownMenuItem(
            value: const Locale('en'),
            child: Text(l10n.appearanceLanguageEnglish),
          ),
          DropdownMenuItem(
            value: const Locale('ja'),
            child: Text(l10n.appearanceLanguageJapanese),
          ),
        ],
      ),
    );
  }
}

class _TextScaleTile extends StatelessWidget {
  const _TextScaleTile({required this.textScale, required this.onChanged});

  final double textScale;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.appearanceTextSize,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<double>(
              segments: [
                ButtonSegment(
                  value: 0.85,
                  label: Text(l10n.appearanceTextSmall),
                ),
                ButtonSegment(
                  value: 1.0,
                  label: Text(l10n.appearanceTextMedium),
                ),
                ButtonSegment(
                  value: 1.15,
                  label: Text(l10n.appearanceTextLarge),
                ),
              ],
              selected: {textScale},
              onSelectionChanged: (set) => onChanged(set.first),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.appearancePreviewText,
            style: TextStyle(fontSize: 16 * textScale),
          ),
        ],
      ),
    );
  }
}

class _HapticsTile extends StatelessWidget {
  const _HapticsTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.appearanceHaptics,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          const HapticsLevelSelector(),
        ],
      ),
    );
  }
}
