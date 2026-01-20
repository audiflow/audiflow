// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

/// Splits long text into processable chunks respecting boundaries.
///
/// The chunker attempts to split text at natural boundaries in this order:
/// 1. Paragraph boundaries (double newlines)
/// 2. Sentence boundaries (., !, ?)
/// 3. Word boundaries (spaces)
/// 4. Hard split at chunk size (fallback)
class TextChunker {
  /// Creates a [TextChunker] with configurable chunk size and overlap.
  ///
  /// [chunkSize] is the maximum size of each chunk in characters
  /// (default 2000).
  /// [overlap] is the number of characters to overlap between chunks
  /// (default 100).
  const TextChunker({
    this.chunkSize = 2000,
    this.overlap = 100,
  });

  /// Maximum size of each chunk in characters.
  final int chunkSize;

  /// Number of characters to overlap between consecutive chunks.
  final int overlap;

  /// Splits [text] into chunks respecting natural boundaries.
  ///
  /// Returns an empty list if [text] is empty or whitespace-only.
  /// Returns a single-element list if [text] fits within [chunkSize].
  List<String> chunkText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return [];
    }

    if (trimmed.length <= chunkSize) {
      return [trimmed];
    }

    final chunks = <String>[];
    var startIndex = 0;

    while (startIndex < trimmed.length) {
      final endIndex = startIndex + chunkSize;

      // If we've reached the end, take the rest
      if (trimmed.length <= endIndex) {
        final chunk = trimmed.substring(startIndex).trim();
        if (chunk.isNotEmpty) {
          chunks.add(chunk);
        }
        break;
      }

      // Find the best split point
      final splitIndex = _findBestSplitPoint(trimmed, startIndex, endIndex);

      final chunk = trimmed.substring(startIndex, splitIndex).trim();
      if (chunk.isNotEmpty) {
        chunks.add(chunk);
      }

      // Move start index, accounting for overlap
      startIndex = _calculateNextStart(splitIndex, trimmed.length);
    }

    return chunks;
  }

  /// Estimates the number of chunks for a given text.
  ///
  /// This is an approximation; actual chunk count may vary based on
  /// boundary detection.
  int estimateChunkCount(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return 0;
    }
    if (trimmed.length <= chunkSize) {
      return 1;
    }

    final effectiveChunkSize = chunkSize - overlap;
    if (effectiveChunkSize <= 0) {
      return 1;
    }

    return ((trimmed.length - overlap) / effectiveChunkSize).ceil();
  }

  /// Finds the best split point within the search range.
  int _findBestSplitPoint(String text, int startIndex, int maxEndIndex) {
    // Search backwards from maxEndIndex to find the best boundary

    // 1. Try paragraph boundary (double newline)
    final paragraphIndex = _findParagraphBoundary(
      text,
      startIndex,
      maxEndIndex,
    );
    if (paragraphIndex != null) {
      return paragraphIndex;
    }

    // 2. Try sentence boundary
    final sentenceIndex = _findSentenceBoundary(text, startIndex, maxEndIndex);
    if (sentenceIndex != null) {
      return sentenceIndex;
    }

    // 3. Try word boundary
    final wordIndex = _findWordBoundary(text, startIndex, maxEndIndex);
    if (wordIndex != null) {
      return wordIndex;
    }

    // 4. Fall back to hard split
    return maxEndIndex;
  }

  /// Finds a paragraph boundary (double newline) within the search range.
  int? _findParagraphBoundary(String text, int startIndex, int maxEndIndex) {
    // Search from maxEndIndex backwards
    final searchText = text.substring(startIndex, maxEndIndex);
    final paragraphPattern = RegExp(r'\n\n');

    final matches = paragraphPattern.allMatches(searchText).toList();
    if (matches.isEmpty) {
      return null;
    }

    // Get the last paragraph boundary
    final lastMatch = matches.last;
    final boundaryIndex = startIndex + lastMatch.end;

    // Ensure we're not too close to the start
    if (boundaryIndex - startIndex < chunkSize ~/ 4) {
      return null;
    }

    return boundaryIndex;
  }

  /// Finds a sentence boundary within the search range.
  int? _findSentenceBoundary(String text, int startIndex, int maxEndIndex) {
    final searchText = text.substring(startIndex, maxEndIndex);

    // Match sentence-ending punctuation followed by space or end of string
    // Avoid matching abbreviations like "Dr." or "Mr." by checking for
    // lowercase letter before the period
    final sentencePattern = RegExp(r'[.!?](?:\s|$)');

    final matches = sentencePattern.allMatches(searchText).toList();
    if (matches.isEmpty) {
      return null;
    }

    // Get the last sentence boundary
    final lastMatch = matches.last;
    final boundaryIndex = startIndex + lastMatch.end;

    // Ensure we're not too close to the start
    if (boundaryIndex - startIndex < chunkSize ~/ 4) {
      // If only boundary is too close, still use it but look for earlier ones
      if (1 < matches.length) {
        final secondLastMatch = matches[matches.length - 2];
        final altBoundary = startIndex + secondLastMatch.end;
        if (chunkSize ~/ 4 <= altBoundary - startIndex) {
          return altBoundary;
        }
      }
      // Use it anyway if it's all we have
      return boundaryIndex;
    }

    return boundaryIndex;
  }

  /// Finds a word boundary (space) within the search range.
  int? _findWordBoundary(String text, int startIndex, int maxEndIndex) {
    final searchText = text.substring(startIndex, maxEndIndex);

    // Find last space
    final lastSpaceIndex = searchText.lastIndexOf(' ');
    if (0 > lastSpaceIndex) {
      return null;
    }

    final boundaryIndex = startIndex + lastSpaceIndex + 1;

    // Ensure we're not too close to the start
    if (boundaryIndex - startIndex < chunkSize ~/ 4) {
      return null;
    }

    return boundaryIndex;
  }

  /// Calculates the next start index accounting for overlap.
  int _calculateNextStart(int currentSplitIndex, int textLength) {
    if (overlap <= 0) {
      return currentSplitIndex;
    }

    // Move back by overlap amount, but don't go before the current split
    final nextStart = currentSplitIndex - overlap;
    if (nextStart <= 0 || textLength <= nextStart) {
      return currentSplitIndex;
    }

    return nextStart;
  }
}
