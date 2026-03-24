import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/voice_command_controller.dart';

/// Full-screen overlay displayed during voice command interaction.
///
/// Shows:
/// - Listening indicator with animated microphone
/// - Real-time partial transcription
/// - Processing/executing status
/// - Success/error messages
/// - Settings confirmation, disambiguation, and undo UI
/// - Cancel button
class VoiceListeningOverlay extends ConsumerWidget {
  const VoiceListeningOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceState = ref.watch(voiceCommandOrchestratorProvider);

    // Only show overlay when not idle
    if (voiceState is VoiceIdle) {
      return const SizedBox.shrink();
    }

    final dismissible = voiceState is VoiceSuccess || voiceState is VoiceError;

    return GestureDetector(
      onTap: dismissible
          ? () => ref
                .read(voiceCommandOrchestratorProvider.notifier)
                .resetToIdle()
          : null,
      child: Material(
        color: Colors.black54,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: switch (voiceState) {
              VoiceSettingsAutoApplied() => _buildSettingsAutoAppliedContent(
                context,
                ref,
                voiceState,
              ),
              VoiceSettingsDisambiguation() =>
                _buildSettingsDisambiguationContent(context, ref, voiceState),
              VoiceSettingsLowConfidence() =>
                _buildSettingsLowConfidenceContent(context, ref, voiceState),
              _ => _buildStandardContent(context, ref, voiceState),
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStandardContent(
    BuildContext context,
    WidgetRef ref,
    VoiceRecognitionState state,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        _buildStateIndicator(context, state),
        const SizedBox(height: 32),
        _buildStatusText(context, state),
        const SizedBox(height: 16),
        _buildTranscriptText(context, state),
        const Spacer(),
        if (_showCancelButton(state)) _buildCancelButton(context, ref),
        const SizedBox(height: 48),
      ],
    );
  }

  /// Renders the auto-applied settings state with undo option.
  Widget _buildSettingsAutoAppliedContent(
    BuildContext context,
    WidgetRef ref,
    VoiceSettingsAutoApplied state,
  ) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final displayName = _resolveDisplayName(context, state.displayNameKey);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Icon(Symbols.check_circle, size: 48, color: colorScheme.tertiary),
        const SizedBox(height: 24),
        Text(
          '$displayName: ${state.oldValue} -> ${state.newValue}',
          style: textTheme.titleMedium?.copyWith(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () {
            final controller = ref.read(
              voiceCommandControllerProvider.notifier,
            );
            controller.undoSettingsChange(state.key, state.oldValue);
          },
          child: Text(
            l10n.undo,
            style: textTheme.labelLarge?.copyWith(color: Colors.white70),
          ),
        ),
        const Spacer(),
        const SizedBox(height: 48),
      ],
    );
  }

  /// Renders the disambiguation state with candidate selection cards.
  Widget _buildSettingsDisambiguationContent(
    BuildContext context,
    WidgetRef ref,
    VoiceSettingsDisambiguation state,
  ) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Text(
          l10n.voiceSettingsWhichSetting,
          style: textTheme.headlineSmall?.copyWith(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ...state.candidates.map(
          (candidate) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: FilledButton.tonal(
              onPressed: () {
                final controller = ref.read(
                  voiceCommandControllerProvider.notifier,
                );
                controller.selectSettingsCandidate(candidate);
              },
              child: Text(
                '${_resolveDisplayName(context, candidate.key)}: ${candidate.newValue}',
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () {
            final controller = ref.read(
              voiceCommandControllerProvider.notifier,
            );
            controller.reset();
          },
          child: Text(
            l10n.cancel,
            style: textTheme.labelLarge?.copyWith(color: Colors.white70),
          ),
        ),
        const Spacer(),
        const SizedBox(height: 48),
      ],
    );
  }

  /// Renders the low-confidence state with confirm/cancel buttons.
  Widget _buildSettingsLowConfidenceContent(
    BuildContext context,
    WidgetRef ref,
    VoiceSettingsLowConfidence state,
  ) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final displayName = _resolveDisplayName(context, state.displayNameKey);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Icon(Symbols.help, size: 48, color: colorScheme.tertiary),
        const SizedBox(height: 24),
        Text(
          '$displayName: ${state.oldValue} -> ${state.newValue}?',
          style: textTheme.titleMedium?.copyWith(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
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
              child: Text(
                l10n.cancel,
                style: textTheme.labelLarge?.copyWith(color: Colors.white70),
              ),
            ),
            const SizedBox(width: 16),
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
        const Spacer(),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildStateIndicator(
    BuildContext context,
    VoiceRecognitionState state,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return switch (state) {
      VoiceListening() => _PulsingMicIndicator(color: colorScheme.primary),
      VoiceProcessing() => CircularProgressIndicator(
        color: colorScheme.primary,
        strokeWidth: 3,
      ),
      VoiceExecuting() => CircularProgressIndicator(
        color: colorScheme.tertiary,
        strokeWidth: 3,
      ),
      VoiceSuccess() => Icon(
        Symbols.check_circle,
        size: 80,
        color: colorScheme.tertiary,
      ),
      VoiceError() => Icon(Symbols.error, size: 80, color: colorScheme.error),
      VoiceIdle() => const SizedBox.shrink(),
      // Settings states are rendered via dedicated content builders above.
      VoiceSettingsAutoApplied() => const SizedBox.shrink(),
      VoiceSettingsDisambiguation() => const SizedBox.shrink(),
      VoiceSettingsLowConfidence() => const SizedBox.shrink(),
    };
  }

  Widget _buildStatusText(BuildContext context, VoiceRecognitionState state) {
    final textTheme = Theme.of(context).textTheme;

    final text = switch (state) {
      VoiceListening() => 'Listening...',
      VoiceProcessing() => 'Processing...',
      VoiceExecuting(command: final cmd) =>
        'Executing: ${_formatIntent(cmd.intent)}',
      VoiceSuccess(message: final msg) => msg,
      VoiceError(message: final msg) => msg,
      VoiceIdle() => '',
      // Settings states are rendered via dedicated content builders above.
      VoiceSettingsAutoApplied() => '',
      VoiceSettingsDisambiguation() => '',
      VoiceSettingsLowConfidence() => '',
    };

    final color = switch (state) {
      VoiceError() => Theme.of(context).colorScheme.error,
      _ => Colors.white,
    };

    return Text(
      text,
      style: textTheme.headlineSmall?.copyWith(color: color),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildTranscriptText(
    BuildContext context,
    VoiceRecognitionState state,
  ) {
    final textTheme = Theme.of(context).textTheme;

    final transcript = switch (state) {
      VoiceListening(partialTranscript: final text) => text ?? '',
      VoiceProcessing(transcription: final text) => '"$text"',
      _ => '',
    };

    if (transcript.isEmpty) {
      return const SizedBox(height: 24);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        transcript,
        style: textTheme.bodyLarge?.copyWith(
          color: Colors.white70,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  bool _showCancelButton(VoiceRecognitionState state) {
    return state is VoiceListening || state is VoiceProcessing;
  }

  Widget _buildCancelButton(BuildContext context, WidgetRef ref) {
    return TextButton.icon(
      onPressed: () {
        final orchestrator = ref.read(
          voiceCommandOrchestratorProvider.notifier,
        );
        orchestrator.cancelVoiceCommand();
      },
      icon: const Icon(Symbols.close, color: Colors.white70),
      label: Text(
        'Cancel',
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: Colors.white70),
      ),
    );
  }

  String _formatIntent(VoiceIntent intent) {
    return switch (intent) {
      VoiceIntent.play => 'Play',
      VoiceIntent.pause => 'Pause',
      VoiceIntent.stop => 'Stop',
      VoiceIntent.skipForward => 'Skip forward',
      VoiceIntent.skipBackward => 'Skip backward',
      VoiceIntent.seek => 'Seek',
      VoiceIntent.search => 'Search',
      VoiceIntent.goToLibrary => 'Library',
      VoiceIntent.goToQueue => 'Queue',
      VoiceIntent.openSettings => 'Settings',
      VoiceIntent.addToQueue => 'Add to queue',
      VoiceIntent.removeFromQueue => 'Remove from queue',
      VoiceIntent.clearQueue => 'Clear queue',
      VoiceIntent.changeSettings => 'Change setting',
      VoiceIntent.unknown => 'Unknown',
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
      _ => displayNameKey,
    };
  }
}

/// Animated pulsing microphone indicator for listening state.
class _PulsingMicIndicator extends StatefulWidget {
  const _PulsingMicIndicator({required this.color});

  final Color color;

  @override
  State<_PulsingMicIndicator> createState() => _PulsingMicIndicatorState();
}

class _PulsingMicIndicatorState extends State<_PulsingMicIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(
      begin: 0.6,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulsing rings
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.color.withValues(
                        alpha: _opacityAnimation.value,
                      ),
                      width: 3,
                    ),
                  ),
                ),
              );
            },
          ),
          // Static microphone icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
            ),
            child: const Icon(
              Symbols.mic,
              size: 40,
              color: Colors.white,
              fill: 1,
            ),
          ),
        ],
      ),
    );
  }
}
