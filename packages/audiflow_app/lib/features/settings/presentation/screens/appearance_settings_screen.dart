import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/theme_controller.dart';

/// Screen for configuring appearance settings: theme, language,
/// and text size.
class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(appSettingsRepositoryProvider);
    final themeMode = ref.watch(themeModeControllerProvider);
    final locale = repo.getLocale();
    final textScale = ref.watch(textScaleControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
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
            onChanged: (value) async {
              await repo.setLocale(value);
              ref.invalidate(appSettingsRepositoryProvider);
            },
          ),
          _TextScaleTile(
            textScale: textScale,
            onChanged: (value) => ref
                .read(textScaleControllerProvider.notifier)
                .setTextScale(value),
          ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Theme Mode', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                ButtonSegment(value: ThemeMode.system, label: Text('System')),
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

  final String? locale;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Language'),
      trailing: DropdownButton<String?>(
        value: locale,
        onChanged: onChanged,
        items: const [
          DropdownMenuItem(value: null, child: Text('System')),
          DropdownMenuItem(value: 'en', child: Text('English')),
          DropdownMenuItem(value: 'ja', child: Text('Japanese')),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Text Size', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<double>(
              segments: const [
                ButtonSegment(value: 0.85, label: Text('Small')),
                ButtonSegment(value: 1.0, label: Text('Medium')),
                ButtonSegment(value: 1.15, label: Text('Large')),
              ],
              selected: {textScale},
              onSelectionChanged: (set) => onChanged(set.first),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Preview text at current size',
            style: TextStyle(fontSize: 16 * textScale),
          ),
        ],
      ),
    );
  }
}
