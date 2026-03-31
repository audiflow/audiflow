import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';

/// Screen for configuring voice command settings.
///
/// Shows an enable/disable toggle and a locale-aware list
/// of available voice commands with their trigger phrases.
class VoiceSettingsScreen extends ConsumerWidget {
  const VoiceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.watch(appSettingsRepositoryProvider);
    final locale = Localizations.localeOf(context);
    final isJapanese = locale.languageCode == 'ja';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsVoiceTitle)),
      body: ListView(
        children: [
          _ExperimentalBanner(l10n: l10n),
          SwitchListTile(
            title: Text(l10n.voiceEnabledTitle),
            subtitle: Text(l10n.voiceEnabledSubtitle),
            value: repo.getVoiceEnabled(),
            onChanged: (v) {
              if (!v) _cancelActiveSession(ref);
              unawaited(_update(ref, () => repo.setVoiceEnabled(v)));
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.voiceAvailableCommands,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          for (final command in _commands)
            ListTile(
              leading: Icon(command.icon),
              title: Text(command.descriptionResolver(l10n)),
              subtitle: Text(
                (isJapanese ? command.phrasesJa : command.phrasesEn)
                    .map((p) => '"$p"')
                    .join(', '),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _update(WidgetRef ref, Future<void> Function() setter) async {
    await setter();
    ref.invalidate(appSettingsRepositoryProvider);
  }

  /// When disabling voice, cancel any in-flight session so the orchestrator
  /// does not continue recording/processing in the background.
  void _cancelActiveSession(WidgetRef ref) {
    final orchestrator = ref.read(voiceCommandOrchestratorProvider.notifier);
    unawaited(orchestrator.cancelVoiceCommand());
  }

  static final _commands = [
    _VoiceCommandInfo(
      icon: Icons.play_arrow,
      descriptionResolver: (l10n) => l10n.voiceCommandPlay,
      phrasesEn: ['play', 'resume', 'start'],
      phrasesJa: ['再生', '再生して', 'プレイ'],
    ),
    _VoiceCommandInfo(
      icon: Icons.pause,
      descriptionResolver: (l10n) => l10n.voiceCommandPause,
      phrasesEn: ['pause', 'hold'],
      phrasesJa: ['一時停止', '止めて'],
    ),
    _VoiceCommandInfo(
      icon: Icons.stop,
      descriptionResolver: (l10n) => l10n.voiceCommandStop,
      phrasesEn: ['stop'],
      phrasesJa: ['停止'],
    ),
    _VoiceCommandInfo(
      icon: Icons.skip_next,
      descriptionResolver: (l10n) => l10n.voiceCommandSkipForward,
      phrasesEn: ['skip', 'skip forward', 'next', 'forward'],
      phrasesJa: ['スキップ', '早送り', '次へ'],
    ),
    _VoiceCommandInfo(
      icon: Icons.skip_previous,
      descriptionResolver: (l10n) => l10n.voiceCommandSkipBackward,
      phrasesEn: ['skip back', 'rewind', 'previous', 'back'],
      phrasesJa: ['戻す', '巻き戻し', '前へ'],
    ),
    _VoiceCommandInfo(
      icon: Icons.search,
      descriptionResolver: (l10n) => l10n.voiceCommandSearch,
      phrasesEn: ['search [query]'],
      phrasesJa: ['[query]を検索'],
    ),
    _VoiceCommandInfo(
      icon: Icons.library_music,
      descriptionResolver: (l10n) => l10n.voiceCommandGoToLibrary,
      phrasesEn: ['go to library', 'open library'],
      phrasesJa: ['ライブラリを開く'],
    ),
    _VoiceCommandInfo(
      icon: Icons.queue_music,
      descriptionResolver: (l10n) => l10n.voiceCommandGoToQueue,
      phrasesEn: ['go to queue', 'open queue'],
      phrasesJa: ['キューを開く'],
    ),
    _VoiceCommandInfo(
      icon: Icons.settings,
      descriptionResolver: (l10n) => l10n.voiceCommandOpenSettings,
      phrasesEn: ['open settings'],
      phrasesJa: ['設定を開く'],
    ),
    _VoiceCommandInfo(
      icon: Icons.tune,
      descriptionResolver: (l10n) => l10n.voiceCommandChangeSettings,
      phrasesEn: ['change [setting] to [value]'],
      phrasesJa: ['[設定]を[値]に変更'],
    ),
  ];
}

class _ExperimentalBanner extends StatelessWidget {
  const _ExperimentalBanner({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.science, color: colorScheme.onErrorContainer, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.voiceExperimentalLabel,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.voiceExperimentalDescription,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceCommandInfo {
  const _VoiceCommandInfo({
    required this.icon,
    required this.descriptionResolver,
    required this.phrasesEn,
    required this.phrasesJa,
  });

  final IconData icon;
  final String Function(AppLocalizations) descriptionResolver;
  final List<String> phrasesEn;
  final List<String> phrasesJa;
}
