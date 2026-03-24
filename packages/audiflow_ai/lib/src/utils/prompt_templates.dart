// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

// ignore_for_file: avoid_classes_with_only_static_members
// ignore_for_file: use_setters_to_change_properties

import '../models/summarization_config.dart';

/// Provides podcast-optimized prompt templates for AI operations.
///
/// Templates use `{placeholder}` syntax for variable substitution.
/// Default templates can be overridden via static setters for customization.
abstract final class PromptTemplates {
  // Private storage for custom templates (null means use default)
  static String? _customSummarizationTemplate;
  static String? _customVoiceCommandTemplate;
  static String? _customTopicExtractionTemplate;
  static String? _customSystemInstructions;

  // Default templates
  static const _defaultSummarizationConcise = '''
Summarize the following content in a concise manner, focusing on the key points.
Keep the summary to approximately {maxLength} words.

Content:
{content}

Provide a clear, concise summary that captures the main ideas.''';

  static const _defaultSummarizationDetailed = '''
Provide a detailed summary of the following content, including supporting details and context.
The summary should be approximately {maxLength} words.

Content:
{content}

Include important details, examples, and context that help understand the full scope of the content.''';

  static const _defaultSummarizationBulletPoints = '''
Summarize the following content as a bullet-point list.
Aim for approximately {maxLength} words total across all points.

Content:
{content}

Format your response as clear, organized bullet points covering the main ideas.''';

  static const _defaultEpisodeSummarization = '''
Summarize this podcast episode for a listener who wants to quickly understand what the episode covers.

Episode Title: {title}

Description:
{description}
''';

  static const _defaultEpisodeSummarizationWithTranscript = '''
Summarize this podcast episode for a listener who wants to quickly understand what the episode covers.

Episode Title: {title}

Description:
{description}

Transcript:
{transcript}
''';

  static const _defaultEpisodeSummarizationSuffix = '''

Provide:
1. A brief summary (approximately {maxLength} words)
2. Key topics discussed (as a list)
3. Estimated listening time if discernible

Focus on what makes this episode valuable and what listeners will learn.''';

  static const _defaultVoiceCommand = '''
Parse the following voice command transcription into a structured command for a podcast player app.
The command may be in any language (English, Japanese, etc.).

Transcription: "{transcription}"

Identify the intent from these categories:
- Playback: play, pause, stop, skipForward, skipBackward, seek
- Search: search (extract search terms)
- Navigation: goToLibrary, goToQueue, openSettings
- Queue: addToQueue, removeFromQueue, clearQueue
- Settings: changeSettings (change a preference setting)
- Unknown: if the command doesn't match any category

For "play" commands with a podcast name, extract podcastName parameter.

Respond with exactly this format:
intent: <intent_name>
parameters: {key: value}
confidence: <0.0-1.0>

Example responses:

English:
- "play the podcast" -> intent: play, parameters: {}, confidence: 0.95
- "play The Daily" -> intent: play, parameters: {podcastName: The Daily}, confidence: 0.95
- "search for technology news" -> intent: search, parameters: {query: technology news}, confidence: 0.9

Japanese:
- "再生して" -> intent: play, parameters: {}, confidence: 0.9
- "The Dailyを再生" -> intent: play, parameters: {podcastName: The Daily}, confidence: 0.95
- "The Dailyの最新話を再生して" -> intent: play, parameters: {podcastName: The Daily}, confidence: 0.95
- "一時停止" -> intent: pause, parameters: {}, confidence: 0.95
- "テクノロジーを検索" -> intent: search, parameters: {query: テクノロジー}, confidence: 0.9

For "changeSettings" commands, determine the specific setting to change.
Use the available settings list below to match the user's intent.

{settingsSnapshot}

For absolute changes, respond:
intent: changeSettings
settingsAction: absolute
settingsKey: <key_from_list>
settingsValue: <target_value>
confidence: <0.0-1.0>

For relative changes (e.g. "a bit faster", "もうちょっと速く"), respond:
intent: changeSettings
settingsAction: relative
settingsKey: <key_from_list>
settingsDirection: increase|decrease
settingsMagnitude: small|medium|large
confidence: <0.0-1.0>

If multiple settings could match, respond:
intent: changeSettings
settingsAction: ambiguous
candidates: key1=value1:confidence1, key2=value2:confidence2''';

  static const _defaultTopicExtraction = '''
Extract the main topics and themes from the following podcast content.

Content:
{content}

Identify and list the key topics discussed. For each topic:
- Provide a concise label (2-4 words)
- Topics should be distinct and meaningful

Return a list of topics, ordered by importance/prominence in the content.''';

  static const _defaultSystemInstructions = '''
You are an AI assistant for the Audiflow podcast player app.
Your role is to help users with:
- Summarizing podcast episodes and content
- Parsing voice commands for playback control
- Extracting key topics and themes from podcast content

Guidelines:
- Be concise and direct in your responses
- Use language appropriate for podcast listeners
- When summarizing, focus on what makes content valuable
- For voice commands, prioritize accuracy over assumptions
- If uncertain, indicate lower confidence rather than guessing''';

  /// Substitutes `{placeholder}` variables in [text] with values
  /// from [variables].
  ///
  /// Unknown placeholders are left unchanged.
  static String substituteVariables(
    String text,
    Map<String, String> variables,
  ) {
    if (text.isEmpty || variables.isEmpty) {
      return text;
    }

    var result = text;
    for (final entry in variables.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value);
    }
    return result;
  }

  /// Returns a summarization prompt template for the given [config].
  ///
  /// The template includes a `{content}` placeholder for the text to summarize
  /// and `{maxLength}` placeholder for the target length.
  static String summarization(SummarizationConfig config) {
    if (_customSummarizationTemplate != null) {
      return _customSummarizationTemplate!;
    }

    final template = switch (config.style) {
      SummarizationStyle.concise => _defaultSummarizationConcise,
      SummarizationStyle.detailed => _defaultSummarizationDetailed,
      SummarizationStyle.bulletPoints => _defaultSummarizationBulletPoints,
    };

    return substituteVariables(template, {'maxLength': '${config.maxLength}'});
  }

  /// Returns an episode summarization prompt template for the given [config].
  ///
  /// The template includes `{title}` and `{description}` placeholders.
  /// If [includeTranscript] is true, also includes a `{transcript}`
  /// placeholder.
  static String episodeSummarization(
    SummarizationConfig config, {
    bool includeTranscript = false,
  }) {
    final baseTemplate = includeTranscript
        ? _defaultEpisodeSummarizationWithTranscript
        : _defaultEpisodeSummarization;

    final suffix = substituteVariables(
      _defaultEpisodeSummarizationSuffix,
      {'maxLength': '${config.maxLength}'},
    );

    return '$baseTemplate$suffix';
  }

  /// Returns the voice command parsing prompt template.
  ///
  /// The template includes a `{transcription}` placeholder for the user's
  /// voice command text.
  static String get voiceCommand =>
      _customVoiceCommandTemplate ?? _defaultVoiceCommand;

  /// Returns the topic extraction prompt template.
  ///
  /// The template includes a `{content}` placeholder for the text to analyze.
  static String get topicExtraction =>
      _customTopicExtractionTemplate ?? _defaultTopicExtraction;

  /// Returns the default system instructions for AI initialization.
  static String get systemInstructions =>
      _customSystemInstructions ?? _defaultSystemInstructions;

  /// Sets a custom summarization template.
  ///
  /// Set to null or call [resetToDefaults] to restore the default template.
  static void setSummarizationTemplate(String? template) {
    _customSummarizationTemplate = template;
  }

  /// Sets a custom voice command template.
  ///
  /// Set to null or call [resetToDefaults] to restore the default template.
  static void setVoiceCommandTemplate(String? template) {
    _customVoiceCommandTemplate = template;
  }

  /// Sets a custom topic extraction template.
  ///
  /// Set to null or call [resetToDefaults] to restore the default template.
  static void setTopicExtractionTemplate(String? template) {
    _customTopicExtractionTemplate = template;
  }

  /// Sets custom system instructions.
  ///
  /// Set to null or call [resetToDefaults] to restore the default instructions.
  static void setSystemInstructions(String? instructions) {
    _customSystemInstructions = instructions;
  }

  /// Resets all templates to their default values.
  static void resetToDefaults() {
    _customSummarizationTemplate = null;
    _customVoiceCommandTemplate = null;
    _customTopicExtractionTemplate = null;
    _customSystemInstructions = null;
  }
}
