// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

import 'package:audiflow_ai/src/models/summarization_config.dart';
import 'package:audiflow_ai/src/utils/prompt_templates.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PromptTemplates', () {
    tearDown(PromptTemplates.resetToDefaults);

    group('substituteVariables', () {
      test('returns text unchanged when no variables', () {
        const text = 'Hello world';
        expect(
          PromptTemplates.substituteVariables(text, {}),
          equals(text),
        );
      });

      test('substitutes single variable', () {
        const text = 'Hello {name}';
        final result = PromptTemplates.substituteVariables(
          text,
          {'name': 'World'},
        );
        expect(result, equals('Hello World'));
      });

      test('substitutes multiple variables', () {
        const text = 'Hello {name}, you are {age} years old';
        final result = PromptTemplates.substituteVariables(
          text,
          {'name': 'Alice', 'age': '30'},
        );
        expect(result, equals('Hello Alice, you are 30 years old'));
      });

      test('substitutes same variable multiple times', () {
        const text = '{name} likes {name}';
        final result = PromptTemplates.substituteVariables(
          text,
          {'name': 'Bob'},
        );
        expect(result, equals('Bob likes Bob'));
      });

      test('leaves unknown variables unchanged', () {
        const text = 'Hello {name}, your {unknown} is ready';
        final result = PromptTemplates.substituteVariables(
          text,
          {'name': 'Alice'},
        );
        expect(result, equals('Hello Alice, your {unknown} is ready'));
      });

      test('handles empty variables map', () {
        const text = 'Hello {name}';
        final result = PromptTemplates.substituteVariables(text, {});
        expect(result, equals(text));
      });

      test('handles empty text', () {
        final result = PromptTemplates.substituteVariables('', {
          'name': 'Test',
        });
        expect(result, equals(''));
      });
    });

    group('summarization', () {
      test('returns template for concise style', () {
        final template = PromptTemplates.summarization(
          const SummarizationConfig(),
        );
        expect(template, contains('{content}'));
        expect(template.toLowerCase(), contains('summary'));
        expect(template.toLowerCase(), contains('concise'));
      });

      test('returns template for detailed style', () {
        final template = PromptTemplates.summarization(
          const SummarizationConfig(style: SummarizationStyle.detailed),
        );
        expect(template, contains('{content}'));
        expect(template.toLowerCase(), contains('detail'));
      });

      test('returns template for bulletPoints style', () {
        final template = PromptTemplates.summarization(
          const SummarizationConfig(style: SummarizationStyle.bulletPoints),
        );
        expect(template, contains('{content}'));
        expect(template.toLowerCase(), contains('bullet'));
      });

      test('includes max length in template', () {
        final template = PromptTemplates.summarization(
          const SummarizationConfig(maxLength: 100),
        );
        expect(template, contains('100'));
      });

      test('template substitutes content correctly', () {
        final template = PromptTemplates.summarization(
          const SummarizationConfig(),
        );
        final prompt = PromptTemplates.substituteVariables(
          template,
          {'content': 'Sample podcast content'},
        );
        expect(prompt, contains('Sample podcast content'));
        expect(prompt, isNot(contains('{content}')));
      });
    });

    group('episodeSummarization', () {
      test('returns template with required placeholders', () {
        final template = PromptTemplates.episodeSummarization(
          const SummarizationConfig(),
        );
        expect(template, contains('{title}'));
        expect(template, contains('{description}'));
      });

      test('includes optional transcript placeholder', () {
        final template = PromptTemplates.episodeSummarization(
          const SummarizationConfig(),
          includeTranscript: true,
        );
        expect(template, contains('{transcript}'));
      });

      test('excludes transcript placeholder when not needed', () {
        final template = PromptTemplates.episodeSummarization(
          const SummarizationConfig(),
        );
        expect(template, isNot(contains('{transcript}')));
      });

      test('includes podcast-specific terminology', () {
        final template = PromptTemplates.episodeSummarization(
          const SummarizationConfig(),
        );
        final lower = template.toLowerCase();
        // Should mention podcast-related terms
        expect(
          lower.contains('episode') ||
              lower.contains('podcast') ||
              lower.contains('listening'),
          isTrue,
        );
      });

      test('requests key topics extraction', () {
        final template = PromptTemplates.episodeSummarization(
          const SummarizationConfig(),
        );
        final lower = template.toLowerCase();
        expect(lower.contains('topic') || lower.contains('theme'), isTrue);
      });
    });

    group('voiceCommand', () {
      test('returns template with transcription placeholder', () {
        final template = PromptTemplates.voiceCommand;
        expect(template, contains('{transcription}'));
      });

      test('includes supported intents', () {
        final template = PromptTemplates.voiceCommand;
        final lower = template.toLowerCase();
        // Should mention various intent types
        expect(lower.contains('play'), isTrue);
        expect(lower.contains('pause') || lower.contains('stop'), isTrue);
        expect(lower.contains('search'), isTrue);
      });

      test('includes output format instructions', () {
        final template = PromptTemplates.voiceCommand;
        final lower = template.toLowerCase();
        // Should mention how to format output
        expect(
          lower.contains('intent') ||
              lower.contains('command') ||
              lower.contains('json'),
          isTrue,
        );
      });

      test('includes confidence expectation', () {
        final template = PromptTemplates.voiceCommand;
        final lower = template.toLowerCase();
        expect(lower.contains('confidence'), isTrue);
      });

      test('includes changeSettings intent category', () {
        final template = PromptTemplates.voiceCommand;
        expect(template, contains('changeSettings'));
      });
    });

    group('topicExtraction', () {
      test('returns template with content placeholder', () {
        final template = PromptTemplates.topicExtraction;
        expect(template, contains('{content}'));
      });

      test('requests topic/theme extraction', () {
        final template = PromptTemplates.topicExtraction;
        final lower = template.toLowerCase();
        expect(lower.contains('topic') || lower.contains('theme'), isTrue);
      });

      test('includes format instructions', () {
        final template = PromptTemplates.topicExtraction;
        final lower = template.toLowerCase();
        // Should have some format guidance
        expect(
          lower.contains('list') ||
              lower.contains('extract') ||
              lower.contains('identify'),
          isTrue,
        );
      });
    });

    group('systemInstructions', () {
      test('provides default system instructions', () {
        final instructions = PromptTemplates.systemInstructions;
        expect(instructions, isNotEmpty);
      });

      test('mentions podcast context', () {
        final instructions = PromptTemplates.systemInstructions;
        final lower = instructions.toLowerCase();
        expect(lower.contains('podcast'), isTrue);
      });
    });

    group('custom template overrides', () {
      test('allows overriding summarization template', () {
        const customTemplate = 'Custom: {content}';
        PromptTemplates.setSummarizationTemplate(customTemplate);

        final template = PromptTemplates.summarization(
          const SummarizationConfig(),
        );
        expect(template, equals(customTemplate));
      });

      test('allows overriding voice command template', () {
        const customTemplate = 'Custom voice: {transcription}';
        PromptTemplates.setVoiceCommandTemplate(customTemplate);

        expect(PromptTemplates.voiceCommand, equals(customTemplate));
      });

      test('allows overriding topic extraction template', () {
        const customTemplate = 'Custom topics: {content}';
        PromptTemplates.setTopicExtractionTemplate(customTemplate);

        expect(PromptTemplates.topicExtraction, equals(customTemplate));
      });

      test('allows overriding system instructions', () {
        const customInstructions = 'Custom instructions';
        PromptTemplates.setSystemInstructions(customInstructions);

        expect(PromptTemplates.systemInstructions, equals(customInstructions));
      });

      test('resetToDefaults restores all templates', () {
        PromptTemplates.setSummarizationTemplate('Custom');
        PromptTemplates.setVoiceCommandTemplate('Custom');
        PromptTemplates.setTopicExtractionTemplate('Custom');
        PromptTemplates.setSystemInstructions('Custom');

        PromptTemplates.resetToDefaults();

        // Templates should be back to defaults (contain expected placeholders)
        final summary = PromptTemplates.summarization(
          const SummarizationConfig(),
        );
        expect(summary, contains('{content}'));
        expect(PromptTemplates.voiceCommand, contains('{transcription}'));
        expect(PromptTemplates.topicExtraction, contains('{content}'));
      });
    });

    group('template quality', () {
      test('all templates are non-empty', () {
        expect(
          PromptTemplates.summarization(const SummarizationConfig()),
          isNotEmpty,
        );
        expect(
          PromptTemplates.episodeSummarization(const SummarizationConfig()),
          isNotEmpty,
        );
        expect(PromptTemplates.voiceCommand, isNotEmpty);
        expect(PromptTemplates.topicExtraction, isNotEmpty);
        expect(PromptTemplates.systemInstructions, isNotEmpty);
      });

      test('templates use clear instructions', () {
        // Templates should have reasonable length (not too short, not too long)
        final summary = PromptTemplates.summarization(
          const SummarizationConfig(),
        );
        expect(summary.length, greaterThan(50));
        expect(summary.length, lessThan(2000));
      });
    });
  });
}
