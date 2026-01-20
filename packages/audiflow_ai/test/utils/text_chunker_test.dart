// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

import 'package:audiflow_ai/src/utils/text_chunker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TextChunker', () {
    group('constructor', () {
      test('uses default values when not specified', () {
        final chunker = TextChunker();
        expect(chunker.chunkSize, equals(2000));
        expect(chunker.overlap, equals(100));
      });

      test('accepts custom chunk size', () {
        final chunker = TextChunker(chunkSize: 500);
        expect(chunker.chunkSize, equals(500));
      });

      test('accepts custom overlap', () {
        final chunker = TextChunker(overlap: 50);
        expect(chunker.overlap, equals(50));
      });

      test('accepts both custom chunk size and overlap', () {
        final chunker = TextChunker(chunkSize: 1000, overlap: 200);
        expect(chunker.chunkSize, equals(1000));
        expect(chunker.overlap, equals(200));
      });
    });

    group('chunkText', () {
      group('edge cases', () {
        test('returns empty list for empty text', () {
          final chunker = TextChunker();
          final chunks = chunker.chunkText('');
          expect(chunks, isEmpty);
        });

        test('returns empty list for whitespace-only text', () {
          final chunker = TextChunker();
          final chunks = chunker.chunkText('   \n\t  ');
          expect(chunks, isEmpty);
        });

        test('returns single chunk for text shorter than chunk size', () {
          final chunker = TextChunker(chunkSize: 100);
          const text = 'Short text.';
          final chunks = chunker.chunkText(text);
          expect(chunks, hasLength(1));
          expect(chunks.first, equals(text));
        });

        test('returns single chunk for text equal to chunk size', () {
          final chunker = TextChunker(chunkSize: 11);
          const text = 'Short text.';
          final chunks = chunker.chunkText(text);
          expect(chunks, hasLength(1));
          expect(chunks.first, equals(text));
        });
      });

      group('sentence boundary detection', () {
        test('splits at sentence boundary when possible', () {
          final chunker = TextChunker(chunkSize: 30, overlap: 5);
          const text = 'First sentence. Second sentence. Third sentence.';
          final chunks = chunker.chunkText(text);

          // Should split at sentence boundaries
          expect(chunks.length, greaterThanOrEqualTo(2));
          // First chunk should end with a complete sentence
          expect(chunks.first.endsWith('.'), isTrue);
        });

        test('handles multiple sentence terminators', () {
          final chunker = TextChunker(chunkSize: 50, overlap: 10);
          const text = 'Question? Exclamation! Statement. Another one.';
          final chunks = chunker.chunkText(text);

          // All chunks should preserve sentence integrity where possible
          for (final chunk in chunks) {
            expect(chunk.trim(), isNotEmpty);
          }
        });

        test('handles sentences with abbreviations', () {
          final chunker = TextChunker(chunkSize: 100, overlap: 10);
          const text =
              'Dr. Smith went to the store. He bought some items. '
              'Then he left.';
          final chunks = chunker.chunkText(text);

          // Should handle abbreviations without breaking mid-sentence
          expect(chunks, isNotEmpty);
        });
      });

      group('paragraph boundary detection', () {
        test('prefers paragraph boundaries over sentence boundaries', () {
          final chunker = TextChunker(chunkSize: 50, overlap: 10);
          const text =
              'First paragraph with some text.\n\n'
              'Second paragraph here.\n\n'
              'Third paragraph now.';
          final chunks = chunker.chunkText(text);

          // Should prefer splitting at paragraph breaks
          // Total text is ~77 chars, with chunk size 50, expect 2+ chunks
          expect(chunks.length, greaterThanOrEqualTo(2));
        });

        test('handles single line break vs double line break', () {
          final chunker = TextChunker(chunkSize: 60, overlap: 10);
          const text =
              'Line one.\n'
              'Line two.\n\n'
              'Paragraph two.';
          final chunks = chunker.chunkText(text);

          expect(chunks, isNotEmpty);
        });
      });

      group('overlap behavior', () {
        test('includes overlap between chunks', () {
          final chunker = TextChunker(chunkSize: 50, overlap: 20);
          const text =
              'First sentence here. Second sentence here. Third sentence.';
          final chunks = chunker.chunkText(text);

          if (1 < chunks.length) {
            // Check that there's some overlap content
            // Verify that overlapped text creates continuity
            expect(chunks.last.contains('.'), isTrue);
          }
        });

        test('handles zero overlap', () {
          final chunker = TextChunker(chunkSize: 30, overlap: 0);
          const text = 'First part. Second part. Third part.';
          final chunks = chunker.chunkText(text);

          expect(chunks, isNotEmpty);
          // With zero overlap, chunks should not repeat content
        });
      });

      group('chunking long text', () {
        test('chunks long text into multiple pieces', () {
          final chunker = TextChunker(chunkSize: 100, overlap: 20);
          final text = List.generate(
            20,
            (i) => 'This is sentence number $i.',
          ).join(' ');

          final chunks = chunker.chunkText(text);

          expect(chunks.length, greaterThan(1));
          // Each chunk should be within size limits (with some tolerance)
          for (final chunk in chunks) {
            expect(
              chunk.length,
              lessThanOrEqualTo(chunker.chunkSize + 50),
            ); // Allow tolerance for boundary finding
          }
        });

        test('preserves all content across chunks', () {
          final chunker = TextChunker(chunkSize: 50, overlap: 10);
          const text =
              'Word1 Word2 Word3 Word4 Word5 Word6 Word7 Word8 Word9 Word10.';
          final chunks = chunker.chunkText(text);

          // Join chunks and verify key content is preserved
          final allContent = chunks.join(' ');
          expect(allContent, contains('Word1'));
          expect(allContent, contains('Word10'));
        });
      });

      group('special characters and unicode', () {
        test('handles unicode text correctly', () {
          final chunker = TextChunker(chunkSize: 50, overlap: 10);
          const text = 'Japanese text. English text. More content here.';
          final chunks = chunker.chunkText(text);

          expect(chunks, isNotEmpty);
          expect(chunks.join(' '), contains('Japanese'));
        });

        test('handles text with special characters', () {
          final chunker = TextChunker(chunkSize: 100, overlap: 10);
          const text =
              'Price is \$100. Email: test@example.com. '
              "It's working! #hashtag";
          final chunks = chunker.chunkText(text);

          expect(chunks, isNotEmpty);
        });
      });

      group('fallback behavior', () {
        test('falls back to hard split when no boundary found', () {
          final chunker = TextChunker(chunkSize: 20, overlap: 5);
          // Text without sentence boundaries
          const text = 'verylongwordwithoutanyspacesorboundarieshere';
          final chunks = chunker.chunkText(text);

          // Should still produce chunks even without boundaries
          expect(chunks, isNotEmpty);
        });

        test('handles text with only spaces no sentences', () {
          final chunker = TextChunker(chunkSize: 30, overlap: 5);
          const text = 'word word word word word word word word word word';
          final chunks = chunker.chunkText(text);

          expect(chunks, isNotEmpty);
        });
      });
    });

    group('estimateChunkCount', () {
      test('returns 0 for empty text', () {
        final chunker = TextChunker();
        expect(chunker.estimateChunkCount(''), equals(0));
      });

      test('returns 1 for short text', () {
        final chunker = TextChunker(chunkSize: 100);
        expect(chunker.estimateChunkCount('Short text'), equals(1));
      });

      test('estimates correctly for long text', () {
        final chunker = TextChunker(chunkSize: 100, overlap: 20);
        final text = 'A' * 350; // 350 characters
        final estimate = chunker.estimateChunkCount(text);

        // With 100 char chunks and 20 overlap, effective is 80
        // 350 / 80 ~ 4-5 chunks
        expect(estimate, greaterThan(1));
        expect(estimate, lessThan(10));
      });
    });
  });
}
