// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

import '../audiflow_ai.dart' show AiProgressCallback;
import '../exceptions/audiflow_ai_exception.dart';
import '../models/episode_summary.dart';
import '../models/generation_config.dart';
import '../models/summarization_config.dart';
import '../utils/prompt_templates.dart';
import '../utils/text_chunker.dart';
import '../utils/text_utils.dart';
import 'text_generation_service.dart';

/// Service that provides text and podcast episode summarization.
///
/// Uses [TextGenerationService] for AI generation and includes:
/// - HTML stripping for podcast descriptions
/// - Text chunking for long content
/// - Progress callbacks for UI feedback
class SummarizationService {
  /// Creates a [SummarizationService] with the given dependencies.
  SummarizationService({
    required TextGenerationService textGenerationService,
    TextChunker? chunker,
  }) : _textGenService = textGenerationService,
       _chunker = chunker ?? const TextChunker();

  final TextGenerationService _textGenService;
  final TextChunker _chunker;

  /// Summarizes arbitrary text content.
  ///
  /// [text] is the content to summarize. HTML tags will be stripped.
  /// [config] specifies summarization style and length.
  /// [onProgress] receives progress updates from 0.0 to 1.0.
  ///
  /// Returns the summarized text.
  ///
  /// Throws [AiSummarizationException] on failure.
  Future<String> summarize({
    required String text,
    required SummarizationConfig config,
    AiProgressCallback? onProgress,
  }) async {
    // Normalize and strip HTML
    final normalizedText = TextUtils.normalizeText(text);

    // Handle empty input
    if (normalizedText.isEmpty) {
      onProgress?.call(1);
      return '';
    }

    try {
      // Chunk the text for processing
      final chunks = _chunker.chunkText(normalizedText);

      if (chunks.isEmpty) {
        onProgress?.call(1);
        return '';
      }

      // Single chunk - simple summarization
      if (chunks.length == 1) {
        final result = await _summarizeChunk(chunks.first, config);
        onProgress?.call(1);
        return result;
      }

      // Multiple chunks - summarize each and combine
      return _summarizeChunks(chunks, config, onProgress);
    } on AiGenerationException catch (e) {
      throw AiSummarizationException('Summarization failed', e);
    }
  }

  /// Summarizes a podcast episode with context.
  ///
  /// [title] is the episode title.
  /// [description] is the episode description (HTML will be stripped).
  /// [transcript] is the optional episode transcript for better summarization.
  /// [config] specifies summarization style and length.
  /// [onProgress] receives progress updates from 0.0 to 1.0.
  ///
  /// Returns an [EpisodeSummary] with summary, topics, and duration estimate.
  ///
  /// Throws [InsufficientContentException] if both title and description
  /// are empty.
  /// Throws [AiSummarizationException] on failure.
  Future<EpisodeSummary> summarizeEpisode({
    required String title,
    required String description,
    String? transcript,
    required SummarizationConfig config,
    AiProgressCallback? onProgress,
  }) async {
    // Validate content
    final normalizedTitle = title.trim();
    final normalizedDescription = TextUtils.normalizeText(description);

    if (normalizedTitle.isEmpty && normalizedDescription.isEmpty) {
      throw InsufficientContentException(
        'Episode title and description cannot both be empty',
      );
    }

    try {
      // Build prompt using template
      final promptTemplate = PromptTemplates.episodeSummarization(
        config,
        includeTranscript: transcript != null && transcript.isNotEmpty,
      );

      final variables = <String, String>{
        'title': normalizedTitle,
        'description': normalizedDescription,
        if (transcript != null && transcript.isNotEmpty)
          'transcript': transcript,
      };

      final prompt = PromptTemplates.substituteVariables(
        promptTemplate,
        variables,
      );

      // Generate summary
      final response = await _textGenService.generateText(
        prompt: prompt,
        config: GenerationConfig(maxOutputTokens: config.maxLength * 2),
      );

      onProgress?.call(1);

      // Parse the response into EpisodeSummary
      return _parseEpisodeSummaryResponse(response.text);
    } on AiGenerationException catch (e) {
      throw AiSummarizationException('Episode summarization failed', e);
    }
  }

  Future<String> _summarizeChunk(
    String chunk,
    SummarizationConfig config,
  ) async {
    final promptTemplate = PromptTemplates.summarization(config);
    final prompt = PromptTemplates.substituteVariables(
      promptTemplate,
      {'content': chunk},
    );

    final response = await _textGenService.generateText(
      prompt: prompt,
      config: GenerationConfig(maxOutputTokens: config.maxLength * 2),
    );

    return response.text;
  }

  Future<String> _summarizeChunks(
    List<String> chunks,
    SummarizationConfig config,
    AiProgressCallback? onProgress,
  ) async {
    final summaries = <String>[];
    final totalChunks = chunks.length;

    for (var i = 0; i < chunks.length; i++) {
      final summary = await _summarizeChunk(chunks[i], config);
      summaries.add(summary);

      // Report progress at chunk boundaries
      final progress = (i + 1) / totalChunks;
      onProgress?.call(progress);
    }

    // If we have multiple summaries, combine them
    if (1 < summaries.length) {
      final combinedSummaries = summaries.join('\n\n');
      final finalSummary = await _summarizeChunk(combinedSummaries, config);
      onProgress?.call(1);
      return finalSummary;
    }

    return summaries.first;
  }

  EpisodeSummary _parseEpisodeSummaryResponse(String response) {
    // Parse the structured response
    // Expected format:
    // Summary: <text>
    // Key Topics: <topic1>, <topic2>, ...
    // Estimated Time: <minutes> minutes (optional)

    final lines = response.split('\n');
    var summary = '';
    var keyTopics = <String>[];
    int? estimatedMinutes;

    for (final line in lines) {
      final trimmedLine = line.trim();

      if (trimmedLine.toLowerCase().startsWith('summary:')) {
        summary = trimmedLine.substring(8).trim();
      } else if (trimmedLine.toLowerCase().startsWith('key topics:')) {
        final topicsStr = trimmedLine.substring(11).trim();
        keyTopics = topicsStr
            .split(RegExp(r'[,;]'))
            .map((t) => t.trim())
            .where((t) => t.isNotEmpty)
            .toList();
      } else if (trimmedLine.toLowerCase().startsWith('estimated time:') ||
          trimmedLine.toLowerCase().startsWith('estimated listening')) {
        final match = RegExp(r'(\d+)').firstMatch(trimmedLine);
        if (match != null) {
          estimatedMinutes = int.tryParse(match.group(1)!);
        }
      }
    }

    // If structured parsing failed, use the whole response as summary
    if (summary.isEmpty) {
      summary = response.trim();
    }

    return EpisodeSummary(
      summary: summary,
      keyTopics: keyTopics,
      estimatedListeningMinutes: estimatedMinutes,
    );
  }
}
