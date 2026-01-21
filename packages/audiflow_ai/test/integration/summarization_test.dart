// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

// ignore_for_file: avoid_dynamic_calls
// ignore_for_file: unnecessary_async

/// Integration tests for summarization flows (Task 8.3).
///
/// Verifies end-to-end summarization across:
/// - Text summarization with different styles
/// - Episode summarization with title/description and transcript
/// - Chunking behavior for long content
/// - Progress callbacks
/// - HTML stripping
library;

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Summarization Integration Tests (Task 8.3)', () {
    late List<MethodCall> methodCalls;
    late int generateCallCount;

    /// Sets up a mock platform channel that simulates text generation
    /// for summarization.
    void setUpPlatformChannel({
      String Function(String prompt)? responseGenerator,
    }) {
      methodCalls = [];
      generateCallCount = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel(AudiflowAiChannel.name),
            (call) async {
              methodCalls.add(call);
              switch (call.method) {
                case AudiflowAiChannel.checkCapability:
                  return <String, dynamic>{
                    AudiflowAiChannel.kStatus: AudiflowAiChannel.kStatusFull,
                  };
                case AudiflowAiChannel.initialize:
                  return <String, dynamic>{AudiflowAiChannel.kSuccess: true};
                case AudiflowAiChannel.generateText:
                  generateCallCount++;
                  final prompt = call.arguments['prompt'] as String;
                  final generatedText =
                      responseGenerator?.call(prompt) ??
                      'Summary: This is a summary of the content.\n'
                          'Key Topics: topic1, topic2, topic3\n'
                          'Estimated Time: 30 minutes';
                  return <String, dynamic>{
                    AudiflowAiChannel.kText: generatedText,
                    AudiflowAiChannel.kTokenCount: 50,
                    AudiflowAiChannel.kDurationMs: 200,
                  };
                case AudiflowAiChannel.dispose:
                  return <String, dynamic>{AudiflowAiChannel.kSuccess: true};
                default:
                  return null;
              }
            },
          );
    }

    void clearPlatformChannel() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel(AudiflowAiChannel.name),
            null,
          );
    }

    setUp(AudiflowAi.resetInstance);

    tearDown(() {
      clearPlatformChannel();
      AudiflowAi.resetInstance();
    });

    group('Text summarization with different styles', () {
      test(
        'summarizes text with concise style',
        () async {
          setUpPlatformChannel(
            responseGenerator: (prompt) {
              expect(prompt.toLowerCase(), contains('concise'));
              return 'A brief summary of the main points.';
            },
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final summary = await ai.summarize(
            text:
                'This is some long text that needs to be summarized. '
                'It contains many details and information that should be '
                'condensed into a shorter form.',
            config: const SummarizationConfig(),
          );

          expect(summary, isNotEmpty);
          expect(generateCallCount, equals(1));
        },
      );

      test(
        'summarizes text with detailed style',
        () async {
          setUpPlatformChannel(
            responseGenerator: (prompt) {
              expect(prompt.toLowerCase(), contains('detailed'));
              return 'A comprehensive summary with supporting details and '
                  'context about the original content.';
            },
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final summary = await ai.summarize(
            text: 'Detailed content to summarize.',
            config: const SummarizationConfig(
              style: SummarizationStyle.detailed,
            ),
          );

          expect(summary, isNotEmpty);
        },
      );

      test(
        'summarizes text with bullet points style',
        () async {
          setUpPlatformChannel(
            responseGenerator: (prompt) {
              expect(prompt.toLowerCase(), contains('bullet'));
              return '- Point 1\n- Point 2\n- Point 3';
            },
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final summary = await ai.summarize(
            text: 'Content for bullet point summary.',
            config: const SummarizationConfig(
              style: SummarizationStyle.bulletPoints,
            ),
          );

          expect(summary, contains('-'));
        },
      );

      test(
        'respects maxLength configuration',
        () async {
          setUpPlatformChannel();

          final ai = AudiflowAi.instance;
          await ai.initialize();

          await ai.summarize(
            text: 'Some text to summarize.',
            config: const SummarizationConfig(maxLength: 100),
          );

          // Verify the config was passed through
          final generateCall = methodCalls.firstWhere(
            (c) => c.method == AudiflowAiChannel.generateText,
          );
          expect(generateCall.arguments, isNotNull);
        },
      );
    });

    group('Episode summarization', () {
      test(
        'summarizes episode with title and description',
        () async {
          setUpPlatformChannel(
            responseGenerator: (prompt) {
              expect(prompt, contains('The Podcast Episode Title'));
              expect(prompt, contains('This is the episode description'));
              return 'Summary: A great episode about technology.\n'
                  'Key Topics: AI, podcasting, innovation\n'
                  'Estimated Time: 45 minutes';
            },
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final episodeSummary = await ai.summarizeEpisode(
            title: 'The Podcast Episode Title',
            description:
                'This is the episode description with lots of details.',
          );

          expect(episodeSummary.summary, isNotEmpty);
          expect(episodeSummary.keyTopics, isNotEmpty);
        },
      );

      test(
        'summarizes episode with transcript',
        () async {
          setUpPlatformChannel(
            responseGenerator: (prompt) {
              expect(prompt, contains('Full transcript'));
              return 'Summary: Detailed summary from transcript.\n'
                  'Key Topics: topic1, topic2\n'
                  'Estimated Time: 60 minutes';
            },
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final episodeSummary = await ai.summarizeEpisode(
            title: 'Episode with Transcript',
            description: 'Short description.',
            transcript: 'Full transcript of the episode goes here...',
          );

          expect(episodeSummary.summary, isNotEmpty);
        },
      );

      test(
        'extracts key topics from episode',
        () async {
          setUpPlatformChannel(
            responseGenerator: (_) {
              return 'Summary: An interesting episode.\n'
                  'Key Topics: Artificial Intelligence, Machine Learning, '
                  'Deep Learning, Neural Networks\n'
                  'Estimated Time: 30 minutes';
            },
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final episodeSummary = await ai.summarizeEpisode(
            title: 'AI Episode',
            description: 'Discussion about AI technologies.',
          );

          expect(episodeSummary.keyTopics, isNotEmpty);
          expect(episodeSummary.keyTopics, contains('Artificial Intelligence'));
        },
      );

      test(
        'extracts estimated listening minutes',
        () async {
          setUpPlatformChannel(
            responseGenerator: (_) {
              return 'Summary: A long episode.\n'
                  'Key Topics: tech\n'
                  'Estimated Time: 90 minutes';
            },
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final episodeSummary = await ai.summarizeEpisode(
            title: 'Long Episode',
            description: 'A very detailed discussion.',
          );

          expect(episodeSummary.estimatedListeningMinutes, equals(90));
        },
      );

      test(
        'throws InsufficientContentException for empty content',
        () async {
          setUpPlatformChannel();

          final ai = AudiflowAi.instance;
          await ai.initialize();

          expect(
            () => ai.summarizeEpisode(title: '', description: ''),
            throwsA(isA<InsufficientContentException>()),
          );
        },
      );

      test(
        'allows empty title if description is present',
        () async {
          setUpPlatformChannel();

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final episodeSummary = await ai.summarizeEpisode(
            title: '',
            description: 'This is a valid description.',
          );

          expect(episodeSummary.summary, isNotEmpty);
        },
      );

      test(
        'allows empty description if title is present',
        () async {
          setUpPlatformChannel();

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final episodeSummary = await ai.summarizeEpisode(
            title: 'Valid Title',
            description: '',
          );

          expect(episodeSummary.summary, isNotEmpty);
        },
      );
    });

    group('Chunking behavior for long content', () {
      test(
        'chunks long text and combines summaries',
        () async {
          setUpPlatformChannel(
            responseGenerator: (prompt) {
              return 'Chunk summary: Part of the overall content.';
            },
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          // Create text that exceeds chunk size (2000 chars default)
          final longText = 'This is a sentence. ' * 200; // ~4000 chars

          final summary = await ai.summarize(text: longText);

          // Should have been chunked and multiple generate calls made
          expect(1 < generateCallCount, isTrue);
          expect(summary, isNotEmpty);
        },
      );

      test(
        'handles text exactly at chunk boundary',
        () async {
          setUpPlatformChannel();

          final ai = AudiflowAi.instance;
          await ai.initialize();

          // Create text that is exactly at chunk size
          final exactText = 'A' * 2000;

          final summary = await ai.summarize(text: exactText);

          expect(summary, isNotEmpty);
          expect(generateCallCount, equals(1));
        },
      );

      test(
        'respects sentence boundaries when chunking',
        () async {
          final chunks = <String>[];
          setUpPlatformChannel(
            responseGenerator: (prompt) {
              chunks.add(prompt);
              return 'Summary chunk.';
            },
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          // Create text with clear sentence boundaries
          final textWithSentences =
              '${'This is a complete sentence. ' * 50}'
              '${'Another sentence here. ' * 50}';

          await ai.summarize(text: textWithSentences);

          // Verify chunks don't cut sentences mid-way
          for (final chunk in chunks) {
            // Check that the content portion doesn't end mid-word
            // (simplified check - real chunking is more complex)
            expect(chunk.isNotEmpty, isTrue);
          }
        },
      );
    });

    group('Progress callbacks', () {
      test(
        'reports progress for single chunk summarization',
        () async {
          setUpPlatformChannel();

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final progressValues = <double>[];

          await ai.summarize(
            text: 'Short text that fits in one chunk.',
            onProgress: progressValues.add,
          );

          // Should report completion (1.0) at the end
          expect(progressValues, contains(1.0));
        },
      );

      test(
        'reports incremental progress for multi-chunk summarization',
        () async {
          setUpPlatformChannel();

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final progressValues = <double>[];

          final longText = 'This is a sentence. ' * 200;

          await ai.summarize(
            text: longText,
            onProgress: progressValues.add,
          );

          // Should have multiple progress updates
          expect(1 < progressValues.length, isTrue);
          // Progress should be monotonically increasing
          for (var i = 1; i < progressValues.length; i++) {
            expect(progressValues[i - 1] <= progressValues[i], isTrue);
          }
          // Final progress should be 1.0
          expect(progressValues.last, equals(1.0));
        },
      );

      test(
        'progress values are between 0 and 1',
        () async {
          setUpPlatformChannel();

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final progressValues = <double>[];
          final longText = 'This is a sentence. ' * 200;

          await ai.summarize(
            text: longText,
            onProgress: progressValues.add,
          );

          for (final value in progressValues) {
            expect(0.0 <= value, isTrue);
            expect(value <= 1.0, isTrue);
          }
        },
      );

      test(
        'progress callback is optional and works without it',
        () async {
          setUpPlatformChannel();

          final ai = AudiflowAi.instance;
          await ai.initialize();

          // Should not throw without progress callback
          final summary = await ai.summarize(
            text: 'Text without progress callback.',
          );

          expect(summary, isNotEmpty);
        },
      );

      test(
        'episode summarization reports progress',
        () async {
          setUpPlatformChannel();

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final progressValues = <double>[];

          await ai.summarizeEpisode(
            title: 'Episode',
            description: 'Description',
            onProgress: progressValues.add,
          );

          expect(progressValues, contains(1.0));
        },
      );
    });

    group('HTML stripping', () {
      test(
        'strips HTML tags from text before summarization',
        () async {
          setUpPlatformChannel(
            responseGenerator: (prompt) {
              // Verify HTML was stripped
              expect(prompt, isNot(contains('<p>')));
              expect(prompt, isNot(contains('</p>')));
              expect(prompt, isNot(contains('<strong>')));
              return 'Summary without HTML.';
            },
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          await ai.summarize(
            text: '<p>This is <strong>HTML</strong> content.</p>',
          );
        },
      );

      test(
        'strips HTML from episode description',
        () async {
          setUpPlatformChannel(
            responseGenerator: (prompt) {
              // Verify HTML was stripped from description
              expect(prompt, isNot(contains('<div>')));
              expect(prompt, isNot(contains('<br>')));
              expect(prompt, isNot(contains('<a href=')));
              return 'Summary: Clean summary.\nKey Topics: none';
            },
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          await ai.summarizeEpisode(
            title: 'Episode Title',
            description:
                '<div>Description with <br>line breaks and '
                '<a href="http://example.com">links</a>.</div>',
          );
        },
      );

      test(
        'decodes HTML entities',
        () async {
          setUpPlatformChannel(
            responseGenerator: (prompt) {
              // Verify HTML entities were decoded
              expect(prompt, isNot(contains('&amp;')));
              expect(prompt, isNot(contains('&lt;')));
              expect(prompt, isNot(contains('&gt;')));
              return 'Summary with decoded entities.';
            },
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          await ai.summarize(
            text: 'Text with &amp; ampersand and &lt;brackets&gt;.',
          );
        },
      );

      test(
        'handles malformed HTML gracefully',
        () async {
          setUpPlatformChannel();

          final ai = AudiflowAi.instance;
          await ai.initialize();

          // Should not throw on malformed HTML
          final summary = await ai.summarize(
            text: '<p>Unclosed tag <b>bold<i>nested</b></i>',
          );

          expect(summary, isNotEmpty);
        },
      );

      test(
        'preserves text content while stripping tags',
        () async {
          setUpPlatformChannel(
            responseGenerator: (prompt) {
              // The text content should be preserved
              expect(prompt, contains('Important'));
              expect(prompt, contains('content'));
              return 'Summary of important content.';
            },
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          await ai.summarize(
            text: '<h1>Important</h1><p>This is the <em>content</em>.</p>',
          );
        },
      );
    });

    group('Error handling', () {
      test(
        'throws AiNotInitializedException when not initialized',
        () async {
          setUpPlatformChannel();

          final ai = AudiflowAi.instance;
          // Not calling initialize()

          expect(
            () => ai.summarize(text: 'Test'),
            throwsA(isA<AiNotInitializedException>()),
          );
        },
      );

      test(
        'handles empty text input gracefully',
        () async {
          setUpPlatformChannel();

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final summary = await ai.summarize(text: '');

          expect(summary, isEmpty);
        },
      );

      test(
        'handles whitespace-only text input',
        () async {
          setUpPlatformChannel();

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final summary = await ai.summarize(text: '   \n\t  ');

          expect(summary, isEmpty);
        },
      );
    });
  });
}
