import 'srt_parser.dart';
import 'transcript_segment.dart';
import 'vtt_parser.dart';

/// Facade that selects the right transcript parser based on MIME type.
class TranscriptFileParser {
  final _srtParser = const SrtParser();
  final _vttParser = const VttParser();

  /// Parses transcript content using the parser matching [mimeType].
  ///
  /// Supported types: `application/srt`, `text/srt`, `text/vtt`.
  /// Throws [UnsupportedError] for unknown types.
  List<TranscriptSegment> parse(
    String content, {
    required String mimeType,
  }) {
    return switch (mimeType) {
      'application/srt' || 'text/srt' => _srtParser.parse(content),
      'text/vtt' => _vttParser.parse(content),
      _ => throw UnsupportedError(
        'Unsupported transcript type: $mimeType',
      ),
    };
  }

  /// Whether the given MIME type is supported for parsing.
  static bool isSupported(String mimeType) {
    return mimeType == 'application/srt' ||
        mimeType == 'text/srt' ||
        mimeType == 'text/vtt';
  }
}
