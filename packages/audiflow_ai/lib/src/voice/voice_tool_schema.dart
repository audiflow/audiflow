import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/voice_command.dart';

/// JSON-schema-shaped definition of one Gemma 4 function-callable tool.
///
/// The schema shape is runtime-agnostic so it can be adapted to whatever
/// serialization `flutter_gemma`'s function-calling API requires. Each tool
/// maps 1:1 to a [VoiceIntent] (excluding [VoiceIntent.unknown], which is the
/// parse-failure fallback rather than an emitted choice).
@immutable
final class VoiceToolDefinition {
  const VoiceToolDefinition({
    required this.intent,
    required this.description,
    required this.parameters,
  });

  /// The [VoiceIntent] this tool dispatches to.
  final VoiceIntent intent;

  /// Human-readable description shown to Gemma 4 alongside the schema.
  final String description;

  /// JSON Schema fragment describing the tool's arguments.
  final Map<String, Object?> parameters;

  /// The function name Gemma 4 emits when calling this tool.
  String get name => intent.name;
}

/// One entry from `SettingsMetadataRegistry.toJson()`'s `settings` list.
typedef SettingsSnapshotEntry = Map<String, Object?>;

/// Builds the full tool list for one voice command turn.
///
/// [settingsSnapshot] comes from `SettingsMetadataRegistry.toJson()` in
/// audiflow_domain; pass `null` only in tests where settings tooling is
/// out of scope (the `changeSettings` tool is then omitted).
List<VoiceToolDefinition> buildVoiceTools({
  List<SettingsSnapshotEntry>? settingsSnapshot,
}) {
  return [
    ..._fixedTools,
    if (settingsSnapshot != null)
      VoiceToolDefinition(
        intent: VoiceIntent.changeSettings,
        description: _changeSettingsDescription,
        parameters: _buildChangeSettingsParameters(settingsSnapshot),
      ),
  ];
}

/// System prompt for Gemma 4 voice command parsing.
///
/// Why each clause exists:
/// - "any language … reason in English": Gemma 4's instruction-following is
///   strong enough to honor a reasoning-language constraint while still
///   transcribing 140 supported languages natively.
/// - "exactly one function call, no prose": prevents free-form text that the
///   parser would have to discard.
/// - "ambiguous variant for unknowns": gives the model a structured way to
///   surface low confidence instead of guessing or staying silent.
const String voiceSystemPrompt = '''
You are the audiflow podcast app's voice command parser.

The user's spoken audio may be in any of the languages you support. Transcribe and understand it natively, but always reason internally in English.

Emit exactly one function call from the provided tools. Never emit prose.

Rules:
- Map the user's intent to the most specific tool that fits.
- For settings changes, call `changeSettings` and pick the variant that matches the user's certainty:
  - `absolute`: the user named a concrete value (e.g. "set speed to 1.5").
  - `relative`: only direction was given (e.g. "speed up a bit").
  - `ambiguous`: more than one setting could plausibly match — list candidates.
- If no tool fits, call `changeSettings` with `variant: ambiguous` and an empty `candidates` list. The caller treats this as an unknown command.
- For `search`, preserve the user's wording in their original language.
- Confidence values are in [0.0, 1.0]; use 0.9 or above only when the mapping is unambiguous.
''';

const Map<String, Object?> _emptyObjectSchema = {
  'type': 'object',
  'properties': <String, Object?>{},
};

const List<VoiceToolDefinition> _fixedTools = [
  VoiceToolDefinition(
    intent: VoiceIntent.play,
    description: 'Resume playback of the current episode.',
    parameters: _emptyObjectSchema,
  ),
  VoiceToolDefinition(
    intent: VoiceIntent.pause,
    description: 'Pause playback.',
    parameters: _emptyObjectSchema,
  ),
  VoiceToolDefinition(
    intent: VoiceIntent.stop,
    description: 'Stop playback and clear now-playing state.',
    parameters: _emptyObjectSchema,
  ),
  VoiceToolDefinition(
    intent: VoiceIntent.skipForward,
    description:
        'Skip forward by the user-configured number of seconds. '
        'Use for "skip ahead", "jump forward", etc. without an '
        'explicit duration.',
    parameters: _emptyObjectSchema,
  ),
  VoiceToolDefinition(
    intent: VoiceIntent.skipBackward,
    description:
        'Skip backward by the user-configured number of seconds. '
        'Use for "go back", "rewind", etc. without an explicit duration.',
    parameters: _emptyObjectSchema,
  ),
  VoiceToolDefinition(
    intent: VoiceIntent.seek,
    description:
        'Seek to an absolute position in the current episode '
        '(e.g. "seek to two minutes" -> seconds: 120).',
    parameters: {
      'type': 'object',
      'properties': {
        'seconds': {
          'type': 'integer',
          'minimum': 0,
          'description': 'Position in whole seconds from start of episode.',
        },
      },
      'required': ['seconds'],
    },
  ),
  VoiceToolDefinition(
    intent: VoiceIntent.search,
    description: 'Search the podcast catalog.',
    parameters: {
      'type': 'object',
      'properties': {
        'query': {
          'type': 'string',
          'description':
              'Search query as the user spoke it, in their original language.',
        },
      },
      'required': ['query'],
    },
  ),
  VoiceToolDefinition(
    intent: VoiceIntent.goToLibrary,
    description: 'Navigate to the library tab.',
    parameters: _emptyObjectSchema,
  ),
  VoiceToolDefinition(
    intent: VoiceIntent.goToQueue,
    description: 'Navigate to the queue tab.',
    parameters: _emptyObjectSchema,
  ),
  VoiceToolDefinition(
    intent: VoiceIntent.openSettings,
    description: 'Open the settings screen.',
    parameters: _emptyObjectSchema,
  ),
  VoiceToolDefinition(
    intent: VoiceIntent.addToQueue,
    description:
        'Add an episode to the queue. Omit `query` to add the currently '
        'playing episode.',
    parameters: {
      'type': 'object',
      'properties': {
        'query': {
          'type': 'string',
          'description': 'Episode or podcast name to add, free text.',
        },
      },
    },
  ),
  VoiceToolDefinition(
    intent: VoiceIntent.removeFromQueue,
    description:
        'Remove an episode from the queue. Omit `query` to remove the '
        'currently playing episode.',
    parameters: {
      'type': 'object',
      'properties': {
        'query': {
          'type': 'string',
          'description': 'Episode or podcast name to remove, free text.',
        },
      },
    },
  ),
  VoiceToolDefinition(
    intent: VoiceIntent.clearQueue,
    description: 'Remove all episodes from the queue.',
    parameters: _emptyObjectSchema,
  ),
];

const String _changeSettingsDescription =
    'Change an app setting. Pick a `variant`:\n'
    '- absolute: user named a specific value. '
    'Required: key, value, confidence.\n'
    '- relative: user gave a direction only. '
    'Required: key, direction, magnitude, confidence.\n'
    '- ambiguous: multiple settings could match. Required: candidates.';

Map<String, Object?> _buildChangeSettingsParameters(
  List<SettingsSnapshotEntry> snapshot,
) {
  // Discriminated-union shape (rather than JSON Schema `oneOf`) because models
  // handle a single object with a `variant` discriminator more reliably than
  // they handle nested oneOf branches.
  final keys = snapshot
      .map((e) => e['key'])
      .whereType<String>()
      .toList(growable: false);

  return UnmodifiableMapView<String, Object?>({
    'type': 'object',
    'properties': {
      'variant': {
        'type': 'string',
        'enum': ['absolute', 'relative', 'ambiguous'],
        'description': 'Which payload shape this call uses.',
      },
      'key': {
        'type': 'string',
        'enum': keys,
        'description':
            'Settings key to change. '
            'Required for absolute and relative variants.',
      },
      'value': {
        'type': 'string',
        'description':
            'New value as a string. Required for the absolute variant.',
      },
      'direction': {
        'type': 'string',
        'enum': ['increase', 'decrease'],
        'description': 'Required for the relative variant.',
      },
      'magnitude': {
        'type': 'string',
        'enum': ['small', 'medium', 'large'],
        'description': 'Required for the relative variant.',
      },
      'confidence': {
        'type': 'number',
        'minimum': 0,
        'maximum': 1,
        'description':
            'Confidence in [0.0, 1.0]. '
            'Required for absolute and relative variants.',
      },
      'candidates': {
        'type': 'array',
        'description':
            'Plausible interpretations ordered by descending confidence. '
            'Required for the ambiguous variant; pass an empty list to '
            'signal "no command recognized".',
        'items': {
          'type': 'object',
          'properties': {
            'key': {'type': 'string', 'enum': keys},
            'value': {'type': 'string'},
            'confidence': {'type': 'number', 'minimum': 0, 'maximum': 1},
          },
          'required': ['key', 'value', 'confidence'],
        },
      },
    },
    'required': ['variant'],
  });
}
