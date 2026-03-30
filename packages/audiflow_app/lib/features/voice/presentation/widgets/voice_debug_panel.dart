import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Debug overlay that shows voice pipeline internals.
///
/// Shown only on non-production builds. Appears when the voice state
/// leaves idle and disappears when it returns to idle.
class VoiceDebugPanel extends ConsumerStatefulWidget {
  const VoiceDebugPanel({super.key});

  @override
  ConsumerState<VoiceDebugPanel> createState() => _VoiceDebugPanelState();
}

class _VoiceDebugPanelState extends ConsumerState<VoiceDebugPanel>
    with SingleTickerProviderStateMixin {
  static const Duration _fadeInDuration = Duration(milliseconds: 200);
  static const Duration _fadeOutDuration = Duration(milliseconds: 150);

  late final AnimationController _visibilityController;
  late final Animation<double> _fadeAnimation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _visibilityController = AnimationController(
      vsync: this,
      duration: _fadeInDuration,
      reverseDuration: _fadeOutDuration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _visibilityController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
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
    final debugInfo = ref.watch(voiceDebugInfoProvider);
    final shouldShow = voiceState is! VoiceIdle;

    if (shouldShow && !_isVisible) {
      _isVisible = true;
      _visibilityController.forward();
    } else if (!shouldShow && _isVisible) {
      _isVisible = false;
      _visibilityController.reverse();
    }

    if (!shouldShow && !_visibilityController.isAnimating) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SizedBox(
        width: 220,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(0, 0, 0, 0.85),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color.fromRGBO(124, 58, 237, 0.4)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Header(),
                const Divider(
                  height: 12,
                  thickness: 0.5,
                  color: Color.fromRGBO(255, 255, 255, 0.1),
                ),
                _Body(voiceState: voiceState, debugInfo: debugInfo),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    bool aiReady;
    try {
      aiReady = AudiflowAi.instance.isInitialized;
    } catch (_) {
      aiReady = false;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'VOICE DEBUG',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color.fromRGBO(124, 58, 237, 1),
          ),
        ),
        Text(
          'AI: ${aiReady ? "ready" : "not init"}',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 9,
            color: aiReady
                ? const Color.fromRGBO(74, 222, 128, 1)
                : const Color.fromRGBO(148, 163, 184, 1),
          ),
        ),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.voiceState, required this.debugInfo});

  final VoiceRecognitionState voiceState;
  final VoiceDebugInfo debugInfo;

  @override
  Widget build(BuildContext context) {
    final command = debugInfo.lastCommand;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DebugRow(
          label: 'State',
          value: _stateName(voiceState),
          valueColor: _stateColor(voiceState),
        ),
        _DebugRow(label: 'Transcript', value: _transcript(voiceState)),
        _DebugRow(
          label: 'Parser',
          value: _parserLabel(debugInfo.parserSource),
          valueColor: const Color.fromRGBO(56, 189, 248, 1),
        ),
        _DebugRow(label: 'Intent', value: command?.intent.name ?? '--'),
        _DebugRow(
          label: 'Confidence',
          value: command != null ? command.confidence.toStringAsFixed(2) : '--',
        ),
        _DebugRow(
          label: 'Params',
          value: _formatParams(command?.parameters),
          valueColor: const Color.fromRGBO(192, 132, 252, 1),
        ),
      ],
    );
  }

  static String _stateName(VoiceRecognitionState state) {
    return switch (state) {
      VoiceIdle() => 'IDLE',
      VoiceListening() => 'LISTENING',
      VoiceProcessing() => 'PROCESSING',
      VoiceExecuting() => 'EXECUTING',
      VoiceSuccess() => 'SUCCESS',
      VoiceError() => 'ERROR',
      VoiceSettingsAutoApplied() => 'SETTINGS_APPLIED',
      VoiceSettingsDisambiguation() => 'DISAMBIGUATION',
      VoiceSettingsLowConfidence() => 'LOW_CONFIDENCE',
    };
  }

  static Color _stateColor(VoiceRecognitionState state) {
    return switch (state) {
      VoiceIdle() => const Color.fromRGBO(148, 163, 184, 1),
      VoiceListening() => const Color.fromRGBO(250, 204, 21, 1),
      VoiceProcessing() => const Color.fromRGBO(250, 204, 21, 1),
      VoiceExecuting() => const Color.fromRGBO(250, 204, 21, 1),
      VoiceSuccess() => const Color.fromRGBO(74, 222, 128, 1),
      VoiceError() => const Color.fromRGBO(248, 113, 113, 1),
      VoiceSettingsAutoApplied() => const Color.fromRGBO(74, 222, 128, 1),
      VoiceSettingsDisambiguation() => const Color.fromRGBO(250, 204, 21, 1),
      VoiceSettingsLowConfidence() => const Color.fromRGBO(250, 204, 21, 1),
    };
  }

  static String _transcript(VoiceRecognitionState state) {
    return switch (state) {
      VoiceListening(:final partialTranscript) => partialTranscript ?? '--',
      VoiceProcessing(:final transcription) => transcription,
      VoiceExecuting(:final command) => command.rawTranscription,
      _ => '--',
    };
  }

  static String _parserLabel(VoiceParserSource source) {
    return switch (source) {
      VoiceParserSource.none => '--',
      VoiceParserSource.simplePattern => 'simple (pattern)',
      VoiceParserSource.platformNlu => 'platform NLU',
      VoiceParserSource.onDeviceAi => 'on-device AI',
    };
  }

  static String _formatParams(Map<String, String>? params) {
    if (params == null || params.isEmpty) return '--';
    return params.entries.map((e) => '${e.key}: "${e.value}"').join(', ');
  }
}

class _DebugRow extends StatelessWidget {
  const _DebugRow({
    required this.label,
    required this.value,
    this.valueColor = const Color.fromRGBO(148, 163, 184, 1),
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                color: Color.fromRGBO(250, 204, 21, 1),
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                color: valueColor,
              ),
            ),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
