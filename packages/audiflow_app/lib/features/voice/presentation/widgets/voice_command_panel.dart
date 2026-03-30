import 'dart:async';
import 'dart:ui';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/voice_command_controller.dart';
import 'waveform_painter.dart';

/// Compact floating panel that renders all voice command states.
///
/// Glassmorphic panel anchored to the top-right area. Hidden when idle, it expands
/// vertically to fit content and uses animated transitions between states.
class VoiceCommandPanel extends ConsumerStatefulWidget {
  const VoiceCommandPanel({super.key});

  @override
  ConsumerState<VoiceCommandPanel> createState() => _VoiceCommandPanelState();
}

class _VoiceCommandPanelState extends ConsumerState<VoiceCommandPanel>
    with SingleTickerProviderStateMixin {
  static const double _panelWidth = 240;
  static const double _cornerRadius = 16;
  static const Duration _appearDuration = Duration(milliseconds: 200);
  static const Duration _disappearDuration = Duration(milliseconds: 150);
  static const Duration _crossfadeDuration = Duration(milliseconds: 200);

  late final AnimationController _visibilityController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _visibilityController = AnimationController(
      vsync: this,
      duration: _appearDuration,
      reverseDuration: _disappearDuration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _visibilityController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _visibilityController,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _visibilityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceCommandOrchestratorProvider);
    final shouldShow = voiceState is! VoiceIdle;

    // Drive visibility animation
    if (shouldShow && !_isVisible) {
      _isVisible = true;
      _visibilityController.forward();
    } else if (!shouldShow && _isVisible) {
      _isVisible = false;
      _visibilityController.reverse();
    }

    // When idle and animation complete, render nothing
    if (!shouldShow && !_visibilityController.isAnimating) {
      return const SizedBox.shrink();
    }

    final dismissible = voiceState is VoiceSuccess || voiceState is VoiceError;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        alignment: Alignment.topRight,
        child: GestureDetector(
          onTap: dismissible
              ? () => ref
                    .read(voiceCommandOrchestratorProvider.notifier)
                    .resetToIdle()
              : null,
          child: SizedBox(
            width: _panelWidth,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.7,
              ),
              child: DecoratedBox(
                decoration: _panelShadowDecoration(),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_cornerRadius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: DecoratedBox(
                      decoration: _panelSurfaceDecoration(context),
                      child: AnimatedSize(
                        duration: _crossfadeDuration,
                        curve: Curves.easeOut,
                        alignment: Alignment.topCenter,
                        child: AnimatedSwitcher(
                          duration: _crossfadeDuration,
                          child: _buildContent(context, voiceState),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Outer decoration: shadow only, not clipped by [ClipRRect].
  BoxDecoration _panelShadowDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(_cornerRadius),
      boxShadow: const [
        BoxShadow(
          offset: Offset(0, 8),
          blurRadius: 32,
          color: Color.fromRGBO(0, 0, 0, 0.4),
        ),
        BoxShadow(
          offset: Offset(0, 2),
          blurRadius: 8,
          color: Color.fromRGBO(0, 0, 0, 0.2),
        ),
      ],
    );
  }

  /// Inner decoration: surface color and border, rendered inside [ClipRRect].
  BoxDecoration _panelSurfaceDecoration(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BoxDecoration(
      color: colorScheme.surface.withValues(alpha: 0.92),
      border: Border.all(
        color: colorScheme.outlineVariant.withValues(alpha: 0.15),
      ),
    );
  }

  Widget _buildContent(BuildContext context, VoiceRecognitionState state) {
    return switch (state) {
      VoiceIdle() => KeyedSubtree(
        key: const ValueKey('idle'),
        child: const SizedBox.shrink(),
      ),
      VoiceListening() => KeyedSubtree(
        key: const ValueKey('listening'),
        child: _ListeningContent(state: state),
      ),
      VoiceProcessing() => KeyedSubtree(
        key: const ValueKey('processing'),
        child: _ProcessingContent(state: state),
      ),
      VoiceExecuting() => KeyedSubtree(
        key: const ValueKey('executing'),
        child: _ExecutingContent(state: state),
      ),
      VoiceSuccess() => KeyedSubtree(
        key: const ValueKey('success'),
        child: _SuccessContent(state: state),
      ),
      VoiceError() => KeyedSubtree(
        key: const ValueKey('error'),
        child: _ErrorContent(state: state),
      ),
      VoiceSettingsAutoApplied() => KeyedSubtree(
        key: const ValueKey('settingsAutoApplied'),
        child: _SettingsAutoAppliedContent(state: state),
      ),
      VoiceSettingsDisambiguation() => KeyedSubtree(
        key: const ValueKey('settingsDisambiguation'),
        child: _SettingsDisambiguationContent(state: state),
      ),
      VoiceSettingsLowConfidence() => KeyedSubtree(
        key: const ValueKey('settingsLowConfidence'),
        child: _SettingsLowConfidenceContent(state: state),
      ),
    };
  }
}

// ---------------------------------------------------------------------------
// State content widgets
// ---------------------------------------------------------------------------

class _ListeningContent extends ConsumerWidget {
  const _ListeningContent({required this.state});

  final VoiceListening state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final transcript = state.partialTranscript;
    final hasTranscript = transcript != null && transcript.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 48,
            child: WaveformWidget(mode: WaveformAnimationMode.listening),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.voiceListening,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
          ),
          if (hasTranscript) ...[
            const SizedBox(height: 8),
            Text(
              transcript,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => unawaited(
              ref
                  .read(voiceCommandOrchestratorProvider.notifier)
                  .cancelVoiceCommand(),
            ),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}

class _ProcessingContent extends StatelessWidget {
  const _ProcessingContent({required this.state});

  final VoiceProcessing state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 48,
            child: WaveformWidget(mode: WaveformAnimationMode.processing),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.voiceProcessing,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            '"${state.transcription}"',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExecutingContent extends StatelessWidget {
  const _ExecutingContent({required this.state});

  final VoiceExecuting state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 48,
            child: WaveformWidget(mode: WaveformAnimationMode.processing),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.voiceExecuting(_formatIntent(context, state.command.intent)),
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            '"${state.command.rawTranscription}"',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessContent extends StatelessWidget {
  const _SuccessContent({required this.state});

  final VoiceSuccess state;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.tertiary.withValues(alpha: 0.15),
            ),
            alignment: Alignment.center,
            child: Icon(
              Symbols.check_circle,
              size: 24,
              color: colorScheme.tertiary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            state.message,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.tertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  const _ErrorContent({required this.state});

  final VoiceError state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.error.withValues(alpha: 0.15),
            ),
            alignment: Alignment.center,
            child: Icon(Symbols.error, size: 24, color: colorScheme.error),
          ),
          const SizedBox(height: 12),
          Text(
            state.message,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.voiceTapMicToRetry,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsAutoAppliedContent extends ConsumerWidget {
  const _SettingsAutoAppliedContent({required this.state});

  final VoiceSettingsAutoApplied state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final displayName = _resolveDisplayName(context, state.displayNameKey);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.tertiary.withValues(alpha: 0.15),
            ),
            alignment: Alignment.center,
            child: Icon(
              Symbols.check_circle,
              size: 24,
              color: colorScheme.tertiary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$displayName: ${state.oldValue} -> ${state.newValue}',
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              final controller = ref.read(
                voiceCommandControllerProvider.notifier,
              );
              controller.undoSettingsChange(state.key, state.oldValue);
            },
            child: Text(l10n.undo),
          ),
        ],
      ),
    );
  }
}

class _SettingsDisambiguationContent extends ConsumerWidget {
  const _SettingsDisambiguationContent({required this.state});

  final VoiceSettingsDisambiguation state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Find highest confidence index
    var highestIndex = 0;
    var highestConfidence = 0.0;
    for (var i = 0; i < state.candidates.length; i++) {
      if (highestConfidence < state.candidates[i].confidence) {
        highestConfidence = state.candidates[i].confidence;
        highestIndex = i;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.voiceSettingsWhichSetting,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < state.candidates.length; i++) ...[
                    if (0 < i) const SizedBox(height: 8),
                    _DisambiguationCandidate(
                      candidate: state.candidates[i],
                      isHighlighted: i == highestIndex,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              final controller = ref.read(
                voiceCommandControllerProvider.notifier,
              );
              controller.reset();
            },
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}

class _DisambiguationCandidate extends ConsumerWidget {
  const _DisambiguationCandidate({
    required this.candidate,
    required this.isHighlighted,
  });

  final SettingsResolutionCandidate candidate;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final displayName = _resolveDisplayName(context, candidate.displayNameKey);
    final hasValue = candidate.newValue.isNotEmpty;

    final confidencePercent = (candidate.confidence * 100).toInt();

    return GestureDetector(
      onTap: hasValue
          ? () {
              final controller = ref.read(
                voiceCommandControllerProvider.notifier,
              );
              controller.selectSettingsCandidate(candidate);
            }
          : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isHighlighted
              ? colorScheme.primary.withValues(alpha: 0.1)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasValue ? '$displayName: ${candidate.newValue}' : displayName,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$confidencePercent%',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsLowConfidenceContent extends ConsumerWidget {
  const _SettingsLowConfidenceContent({required this.state});

  final VoiceSettingsLowConfidence state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final displayName = _resolveDisplayName(context, state.displayNameKey);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Symbols.help, size: 24, color: colorScheme.tertiary),
          const SizedBox(height: 8),
          Text(
            '$displayName: ${state.oldValue} -> ${state.newValue}?',
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  final controller = ref.read(
                    voiceCommandControllerProvider.notifier,
                  );
                  controller.reset();
                },
                child: Text(l10n.cancel),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  final controller = ref.read(
                    voiceCommandControllerProvider.notifier,
                  );
                  controller.confirmSettingsChange(state.key, state.newValue);
                },
                child: Text(l10n.confirm),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

String _formatIntent(BuildContext context, VoiceIntent intent) {
  final l10n = AppLocalizations.of(context);
  return switch (intent) {
    VoiceIntent.play => l10n.voiceIntentPlay,
    VoiceIntent.pause => l10n.voiceIntentPause,
    VoiceIntent.stop => l10n.voiceIntentStop,
    VoiceIntent.skipForward => l10n.voiceIntentSkipForward,
    VoiceIntent.skipBackward => l10n.voiceIntentSkipBackward,
    VoiceIntent.seek => l10n.voiceIntentSeek,
    VoiceIntent.search => l10n.voiceIntentSearch,
    VoiceIntent.goToLibrary => l10n.voiceIntentGoToLibrary,
    VoiceIntent.goToQueue => l10n.voiceIntentGoToQueue,
    VoiceIntent.openSettings => l10n.voiceIntentOpenSettings,
    VoiceIntent.addToQueue => l10n.voiceIntentAddToQueue,
    VoiceIntent.removeFromQueue => l10n.voiceIntentRemoveFromQueue,
    VoiceIntent.clearQueue => l10n.voiceIntentClearQueue,
    VoiceIntent.changeSettings => l10n.voiceIntentChangeSettings,
    VoiceIntent.unknown => l10n.voiceIntentUnknown,
  };
}

/// Resolves a displayNameKey (ARB key) to its localized string.
String _resolveDisplayName(BuildContext context, String displayNameKey) {
  final l10n = AppLocalizations.of(context);
  return switch (displayNameKey) {
    'appearanceThemeMode' => l10n.appearanceThemeMode,
    'appearanceLanguage' => l10n.appearanceLanguage,
    'appearanceTextSize' => l10n.appearanceTextSize,
    'playbackDefaultSpeed' => l10n.playbackDefaultSpeed,
    'playbackSkipForward' => l10n.playbackSkipForward,
    'playbackSkipBackward' => l10n.playbackSkipBackward,
    'playbackAutoCompleteThreshold' => l10n.playbackAutoCompleteThreshold,
    'playbackContinuousTitle' => l10n.playbackContinuousTitle,
    'playbackAutoPlayOrderTitle' => l10n.playbackAutoPlayOrderTitle,
    'downloadsWifiOnlyTitle' => l10n.downloadsWifiOnlyTitle,
    'downloadsAutoDeleteTitle' => l10n.downloadsAutoDeleteTitle,
    'downloadsMaxConcurrent' => l10n.downloadsMaxConcurrent,
    'feedSyncAutoSyncTitle' => l10n.feedSyncAutoSyncTitle,
    'feedSyncInterval' => l10n.feedSyncInterval,
    'feedSyncWifiOnlyTitle' => l10n.feedSyncWifiOnlyTitle,
    'feedSyncNotifyNewEpisodesTitle' => l10n.feedSyncNotifyNewEpisodesTitle,
    'searchRegionLabel' => l10n.searchRegionLabel,
    _ => displayNameKey,
  };
}
