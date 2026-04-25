import 'dart:async';

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/gemma_voice_capability_controller.dart';
import '../widgets/dev_gemma_model_install_panel.dart';

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
          const _SectionHeader(),
          _GemmaVoiceSection(repo: repo),
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
      icon: Symbols.play_arrow,
      descriptionResolver: (l10n) => l10n.voiceCommandPlay,
      phrasesEn: ['play', 'resume', 'start'],
      phrasesJa: ['再生', '再生して', 'プレイ'],
    ),
    _VoiceCommandInfo(
      icon: Symbols.pause,
      descriptionResolver: (l10n) => l10n.voiceCommandPause,
      phrasesEn: ['pause', 'hold'],
      phrasesJa: ['一時停止', '止めて'],
    ),
    _VoiceCommandInfo(
      icon: Symbols.stop,
      descriptionResolver: (l10n) => l10n.voiceCommandStop,
      phrasesEn: ['stop'],
      phrasesJa: ['停止'],
    ),
    _VoiceCommandInfo(
      icon: Symbols.skip_next,
      descriptionResolver: (l10n) => l10n.voiceCommandSkipForward,
      phrasesEn: ['skip', 'skip forward', 'next', 'forward'],
      phrasesJa: ['スキップ', '早送り', '次へ'],
    ),
    _VoiceCommandInfo(
      icon: Symbols.skip_previous,
      descriptionResolver: (l10n) => l10n.voiceCommandSkipBackward,
      phrasesEn: ['skip back', 'rewind', 'previous', 'back'],
      phrasesJa: ['戻す', '巻き戻し', '前へ'],
    ),
    _VoiceCommandInfo(
      icon: Symbols.search,
      descriptionResolver: (l10n) => l10n.voiceCommandSearch,
      phrasesEn: ['search [query]'],
      phrasesJa: ['[query]を検索'],
    ),
    _VoiceCommandInfo(
      icon: Symbols.library_music,
      descriptionResolver: (l10n) => l10n.voiceCommandGoToLibrary,
      phrasesEn: ['go to library', 'open library'],
      phrasesJa: ['ライブラリを開く'],
    ),
    _VoiceCommandInfo(
      icon: Symbols.queue_music,
      descriptionResolver: (l10n) => l10n.voiceCommandGoToQueue,
      phrasesEn: ['go to queue', 'open queue'],
      phrasesJa: ['キューを開く'],
    ),
    _VoiceCommandInfo(
      icon: Symbols.settings,
      descriptionResolver: (l10n) => l10n.voiceCommandOpenSettings,
      phrasesEn: ['open settings'],
      phrasesJa: ['設定を開く'],
    ),
    _VoiceCommandInfo(
      icon: Symbols.tune,
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
          Icon(Symbols.science, color: colorScheme.onErrorContainer, size: 20),
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

/// Header label introducing the on-device Gemma 4 section.
class _SectionHeader extends ConsumerWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        l10n.voiceGemmaSectionTitle,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

/// Gemma 4 opt-in toggle + variant selector. Capability detection is async
/// (device_info_plus), so we render the section based on the resolved
/// capability and gracefully degrade when the device isn't supported.
class _GemmaVoiceSection extends ConsumerWidget {
  const _GemmaVoiceSection({required this.repo});

  final AppSettingsRepository repo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final capability = ref.watch(gemmaVoiceCapabilityProvider);
    final enabled = repo.getVoiceGemmaEnabled();

    return capability.when(
      loading: () => const ListTile(title: LinearProgressIndicator()),
      // device_info_plus failures are rare but real (missing plugin during
      // integration tests, OEM channel quirks). Log the cause so they don't
      // get conflated with legitimate-unsupported devices in telemetry.
      error: (err, stack) {
        ref
            .read(namedLoggerProvider('GemmaVoiceCapability'))
            .e(
              'capability detection failed; treating as unsupported',
              error: err,
              stackTrace: stack,
            );
        return ListTile(
          leading: const Icon(Symbols.error),
          title: Text(l10n.voiceGemmaUnsupported),
        );
      },
      data: (cap) => switch (cap) {
        GemmaVoiceCapabilityUnsupported(:final reason) => ListTile(
          leading: const Icon(Symbols.do_not_disturb),
          title: Text(l10n.voiceGemmaUnsupported),
          subtitle: Text(_unsupportedSubtitle(l10n, reason)),
        ),
        GemmaVoiceCapabilitySupported(:final available) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text(l10n.voiceGemmaEnabledTitle),
              subtitle: Text(l10n.voiceGemmaEnabledSubtitle),
              value: enabled,
              onChanged: (v) =>
                  unawaited(_update(ref, () => repo.setVoiceGemmaEnabled(v))),
            ),
            if (enabled) ...[
              _VariantSelector(repo: repo, available: available),
              if (kDebugMode)
                DevGemmaModelInstallPanel(
                  variant: resolveCurrentGemmaVariant(repo, available),
                ),
            ],
          ],
        ),
      },
    );
  }

  String _unsupportedSubtitle(
    AppLocalizations l10n,
    GemmaVoiceUnsupportedReason reason,
  ) => switch (reason) {
    GemmaVoiceUnsupportedReason.nonMobile =>
      l10n.voiceGemmaUnsupportedNonMobile,
    GemmaVoiceUnsupportedReason.insufficientRam =>
      l10n.voiceGemmaUnsupportedRam,
  };

  Future<void> _update(WidgetRef ref, Future<void> Function() setter) async {
    try {
      await setter();
      ref.invalidate(appSettingsRepositoryProvider);
    } on Exception catch (e, s) {
      ref
          .read(namedLoggerProvider('VoiceSettings'))
          .e('failed to persist Gemma voice setting', error: e, stackTrace: s);
    }
  }
}

/// Resolve the persisted Gemma variant against the device-specific
/// [available] list, falling back to the first offerable when the persisted
/// name is gone (e.g. RAM tier changed across an OS upgrade).
GemmaModelVariant resolveCurrentGemmaVariant(
  AppSettingsRepository repo,
  List<GemmaModelVariant> available,
) {
  final currentName = repo.getVoiceGemmaVariant();
  for (final v in available) {
    if (v.name == currentName) return v;
  }
  return available.first;
}

class _VariantSelector extends ConsumerWidget {
  const _VariantSelector({required this.repo, required this.available});

  final AppSettingsRepository repo;
  final List<GemmaModelVariant> available;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentName = repo.getVoiceGemmaVariant();
    final wasOfferable = available.any((v) => v.name == currentName);
    final current = resolveCurrentGemmaVariant(repo, available);

    // Persisted variant is no longer offerable (e.g. RAM tier changed across
    // OS upgrade or backup-restore). Re-persist after the current frame so
    // storage and UI stay in sync; otherwise the next read silently
    // substitutes again and downstream consumers see the stale value.
    if (!wasOfferable) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => unawaited(_persist(ref, current.name)),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SegmentedButton<GemmaModelVariant>(
        segments: [
          for (final variant in available)
            ButtonSegment(
              value: variant,
              label: Text(_variantLabel(l10n, variant)),
            ),
        ],
        selected: {current},
        onSelectionChanged: (selected) {
          final picked = selected.single;
          unawaited(_persist(ref, picked.name));
        },
      ),
    );
  }

  String _variantLabel(AppLocalizations l10n, GemmaModelVariant variant) =>
      switch (variant) {
        GemmaModelVariant.e2b => l10n.voiceGemmaVariantE2b(
          variant.approximateSizeMb,
        ),
        GemmaModelVariant.e4b => l10n.voiceGemmaVariantE4b(
          variant.approximateSizeMb,
        ),
      };

  Future<void> _persist(WidgetRef ref, String name) async {
    try {
      final repo = ref.read(appSettingsRepositoryProvider);
      await repo.setVoiceGemmaVariant(name);
      ref.invalidate(appSettingsRepositoryProvider);
    } on Exception catch (e, s) {
      ref
          .read(namedLoggerProvider('VoiceSettings'))
          .e('failed to persist voice variant', error: e, stackTrace: s);
    }
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
