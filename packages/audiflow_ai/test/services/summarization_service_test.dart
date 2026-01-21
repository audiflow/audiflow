// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

// ignore_for_file: unnecessary_async

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([TextGenerationService])
import 'summarization_service_test.mocks.dart';

void main() {
  group('SummarizationService', () {
    late SummarizationService service;
    late MockTextGenerationService mockTextGenService;

    setUp(() {
      mockTextGenService = MockTextGenerationService();
      service = SummarizationService(
        textGenerationService: mockTextGenService,
      );

      // Default stub for generateText
      when(
        mockTextGenService.generateText(
          prompt: anyNamed('prompt'),
          config: anyNamed('config'),
        ),
      ).thenAnswer(
        (_) async => const AiResponse(
          text: 'Summarized text content.',
          tokenCount: 10,
          durationMs: 100,
        ),
      );
    });

    group('summarize', () {
      group('basic summarization', () {
        test('generates summary using text generation service', () async {
          const text = 'This is some text content that needs to be summarized.';
          const config = SummarizationConfig();

          await service.summarize(text: text, config: config);

          verify(
            mockTextGenService.generateText(
              prompt: anyNamed('prompt'),
              config: anyNamed('config'),
            ),
          ).called(greaterThanOrEqualTo(1));
        });

        test('returns summarized text', () async {
          const text = 'Content to summarize.';
          const config = SummarizationConfig();

          final result = await service.summarize(text: text, config: config);

          expect(result, isA<String>());
          expect(result, isNotEmpty);
        });

        test('applies concise style from config', () async {
          const config = SummarizationConfig();

          await service.summarize(text: 'Content', config: config);

          final captured = verify(
            mockTextGenService.generateText(
              prompt: captureAnyNamed('prompt'),
              config: anyNamed('config'),
            ),
          ).captured;

          expect(captured.first.toString().toLowerCase(), contains('concise'));
        });

        test('applies detailed style from config', () async {
          const config = SummarizationConfig(
            style: SummarizationStyle.detailed,
          );

          await service.summarize(text: 'Content', config: config);

          final captured = verify(
            mockTextGenService.generateText(
              prompt: captureAnyNamed('prompt'),
              config: anyNamed('config'),
            ),
          ).captured;

          expect(captured.first.toString().toLowerCase(), contains('detailed'));
        });

        test('applies bullet points style from config', () async {
          const config = SummarizationConfig(
            style: SummarizationStyle.bulletPoints,
          );

          await service.summarize(text: 'Content', config: config);

          final captured = verify(
            mockTextGenService.generateText(
              prompt: captureAnyNamed('prompt'),
              config: anyNamed('config'),
            ),
          ).captured;

          expect(captured.first.toString().toLowerCase(), contains('bullet'));
        });
      });

      group('HTML stripping', () {
        test('strips HTML tags from input text', () async {
          const htmlText = '<p>Paragraph with <strong>bold</strong> text.</p>';
          const config = SummarizationConfig();

          await service.summarize(text: htmlText, config: config);

          final captured = verify(
            mockTextGenService.generateText(
              prompt: captureAnyNamed('prompt'),
              config: anyNamed('config'),
            ),
          ).captured;

          final prompt = captured.first as String;
          expect(prompt, isNot(contains('<p>')));
          expect(prompt, isNot(contains('<strong>')));
          expect(prompt, isNot(contains('</p>')));
        });

        test('decodes HTML entities', () async {
          const htmlText = 'Text with &amp; and &lt;entities&gt;';
          const config = SummarizationConfig();

          await service.summarize(text: htmlText, config: config);

          final captured = verify(
            mockTextGenService.generateText(
              prompt: captureAnyNamed('prompt'),
              config: anyNamed('config'),
            ),
          ).captured;

          final prompt = captured.first as String;
          expect(prompt, contains('&'));
          expect(prompt, isNot(contains('&amp;')));
        });
      });

      group('text chunking', () {
        test('chunks long text for processing', () async {
          // Create text longer than default chunk size
          final longText = List.generate(
            100,
            (i) => 'This is sentence number $i with some content.',
          ).join(' ');
          const config = SummarizationConfig();

          // Set up mock to track calls
          var callCount = 0;
          when(
            mockTextGenService.generateText(
              prompt: anyNamed('prompt'),
              config: anyNamed('config'),
            ),
          ).thenAnswer((_) async {
            callCount++;
            return AiResponse(
              text: 'Summary chunk $callCount.',
              tokenCount: 5,
              durationMs: 50,
            );
          });

          await service.summarize(text: longText, config: config);

          // Should call generateText multiple times for chunked text
          expect(callCount, greaterThan(1));
        });

        test('combines chunk summaries into final summary', () async {
          final longText = List.generate(
            100,
            (i) => 'Sentence $i content here.',
          ).join(' ');
          const config = SummarizationConfig();

          var callCount = 0;
          when(
            mockTextGenService.generateText(
              prompt: anyNamed('prompt'),
              config: anyNamed('config'),
            ),
          ).thenAnswer((_) async {
            callCount++;
            return AiResponse(
              text: 'Summary part $callCount.',
              tokenCount: 5,
              durationMs: 50,
            );
          });

          final result = await service.summarize(
            text: longText,
            config: config,
          );

          expect(result, isNotEmpty);
        });
      });

      group('progress callbacks', () {
        test('reports progress at chunk boundaries', () async {
          final longText = List.generate(
            100,
            (i) => 'Content sentence $i here.',
          ).join(' ');
          const config = SummarizationConfig();

          final progressValues = <double>[];

          await service.summarize(
            text: longText,
            config: config,
            onProgress: progressValues.add,
          );

          expect(progressValues, isNotEmpty);
          // Progress should increase monotonically
          for (var i = 1; i < progressValues.length; i++) {
            expect(
              progressValues[i],
              greaterThanOrEqualTo(progressValues[i - 1]),
            );
          }
        });

        test('progress starts at 0 or greater', () async {
          const config = SummarizationConfig();
          final progressValues = <double>[];

          await service.summarize(
            text: 'Short text to summarize.',
            config: config,
            onProgress: progressValues.add,
          );

          if (progressValues.isNotEmpty) {
            expect(progressValues.first, greaterThanOrEqualTo(0.0));
          }
        });

        test('progress ends at 1.0', () async {
          const config = SummarizationConfig();
          final progressValues = <double>[];

          await service.summarize(
            text: 'Short text to summarize.',
            config: config,
            onProgress: progressValues.add,
          );

          expect(progressValues.last, equals(1.0));
        });
      });

      group('error handling', () {
        test('throws AiSummarizationException on generation failure', () async {
          when(
            mockTextGenService.generateText(
              prompt: anyNamed('prompt'),
              config: anyNamed('config'),
            ),
          ).thenThrow(AiGenerationException('Generation failed'));

          expect(
            () => service.summarize(
              text: 'Content',
              config: const SummarizationConfig(),
            ),
            throwsA(isA<AiSummarizationException>()),
          );
        });

        test('handles empty text input', () async {
          const config = SummarizationConfig();

          final result = await service.summarize(text: '', config: config);

          expect(result, isEmpty);
        });

        test('handles whitespace-only text input', () async {
          const config = SummarizationConfig();

          final result = await service.summarize(
            text: '   \n\t  ',
            config: config,
          );

          expect(result, isEmpty);
        });
      });
    });

    group('summarizeEpisode', () {
      group('basic episode summarization', () {
        test(
          'generates summary for episode with title and description',
          () async {
            const title = 'Episode Title';
            const description = 'Episode description content.';
            const config = SummarizationConfig();

            await service.summarizeEpisode(
              title: title,
              description: description,
              config: config,
            );

            verify(
              mockTextGenService.generateText(
                prompt: anyNamed('prompt'),
                config: anyNamed('config'),
              ),
            ).called(greaterThanOrEqualTo(1));
          },
        );

        test('returns EpisodeSummary with summary text', () async {
          when(
            mockTextGenService.generateText(
              prompt: anyNamed('prompt'),
              config: anyNamed('config'),
            ),
          ).thenAnswer(
            (_) async => const AiResponse(
              text: '''
Summary: This episode covers interesting topics.
Key Topics: Technology, Science, Innovation
Estimated Time: 45 minutes
''',
              tokenCount: 20,
              durationMs: 100,
            ),
          );

          final result = await service.summarizeEpisode(
            title: 'Test Episode',
            description: 'A great episode.',
            config: const SummarizationConfig(),
          );

          expect(result, isA<EpisodeSummary>());
          expect(result.summary, isNotEmpty);
        });

        test('extracts key topics from response', () async {
          when(
            mockTextGenService.generateText(
              prompt: anyNamed('prompt'),
              config: anyNamed('config'),
            ),
          ).thenAnswer(
            (_) async => const AiResponse(
              text: '''
Summary: Great episode about tech.
Key Topics: Artificial Intelligence, Machine Learning, Data Science
''',
              tokenCount: 20,
              durationMs: 100,
            ),
          );

          final result = await service.summarizeEpisode(
            title: 'Tech Talk',
            description: 'Tech discussion.',
            config: const SummarizationConfig(),
          );

          expect(result.keyTopics, isNotEmpty);
        });
      });

      group('content validation', () {
        test(
          'throws InsufficientContentException for empty title and description',
          () async {
            expect(
              () => service.summarizeEpisode(
                title: '',
                description: '',
                config: const SummarizationConfig(),
              ),
              throwsA(isA<InsufficientContentException>()),
            );
          },
        );

        test('allows empty title with non-empty description', () async {
          final result = await service.summarizeEpisode(
            title: '',
            description: 'Valid description content.',
            config: const SummarizationConfig(),
          );

          expect(result, isA<EpisodeSummary>());
        });

        test('allows empty description with non-empty title', () async {
          final result = await service.summarizeEpisode(
            title: 'Valid Title',
            description: '',
            config: const SummarizationConfig(),
          );

          expect(result, isA<EpisodeSummary>());
        });
      });

      group('transcript handling', () {
        test('includes transcript in prompt when provided', () async {
          const transcript = 'Transcript content of the episode.';

          await service.summarizeEpisode(
            title: 'Title',
            description: 'Description',
            transcript: transcript,
            config: const SummarizationConfig(),
          );

          final captured = verify(
            mockTextGenService.generateText(
              prompt: captureAnyNamed('prompt'),
              config: anyNamed('config'),
            ),
          ).captured;

          expect(captured.first.toString(), contains(transcript));
        });

        test('omits transcript section when not provided', () async {
          await service.summarizeEpisode(
            title: 'Title',
            description: 'Description',
            config: const SummarizationConfig(),
          );

          final captured = verify(
            mockTextGenService.generateText(
              prompt: captureAnyNamed('prompt'),
              config: anyNamed('config'),
            ),
          ).captured;

          expect(
            captured.first.toString().toLowerCase(),
            isNot(contains('transcript:')),
          );
        });
      });

      group('HTML content handling', () {
        test('strips HTML from description', () async {
          const htmlDescription = '<p>Description with <b>HTML</b> tags.</p>';

          await service.summarizeEpisode(
            title: 'Title',
            description: htmlDescription,
            config: const SummarizationConfig(),
          );

          final captured = verify(
            mockTextGenService.generateText(
              prompt: captureAnyNamed('prompt'),
              config: anyNamed('config'),
            ),
          ).captured;

          final prompt = captured.first as String;
          expect(prompt, isNot(contains('<p>')));
          expect(prompt, isNot(contains('<b>')));
        });
      });

      group('podcast-optimized prompts', () {
        test('uses podcast-specific prompt template', () async {
          await service.summarizeEpisode(
            title: 'Podcast Episode',
            description: 'About podcasting.',
            config: const SummarizationConfig(),
          );

          final captured = verify(
            mockTextGenService.generateText(
              prompt: captureAnyNamed('prompt'),
              config: anyNamed('config'),
            ),
          ).captured;

          final prompt = captured.first as String;
          // Should contain podcast-specific terminology
          expect(
            prompt.toLowerCase(),
            anyOf(
              contains('podcast'),
              contains('episode'),
              contains('listener'),
            ),
          );
        });
      });

      group('progress callbacks', () {
        test('reports progress during episode summarization', () async {
          final progressValues = <double>[];

          await service.summarizeEpisode(
            title: 'Title',
            description: 'Description',
            config: const SummarizationConfig(),
            onProgress: progressValues.add,
          );

          expect(progressValues, isNotEmpty);
          expect(progressValues.last, equals(1.0));
        });
      });
    });
  });
}
