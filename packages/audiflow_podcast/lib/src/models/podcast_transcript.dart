/// Represents transcript information for podcast episodes.
///
/// Supports multiple transcript formats (plain text, HTML, SRT, VTT)
/// and distinguishes between captions and full transcripts.
class PodcastTranscript {
  final String url;
  final String type;
  final String? language;
  final String? rel;

  const PodcastTranscript({
    required this.url,
    required this.type,
    this.language,
    this.rel,
  });

  bool get isPlainText => type == 'text/plain';
  bool get isHtml => type == 'text/html';
  bool get isSrt => type == 'application/srt' || type == 'text/srt';
  bool get isVtt => type == 'text/vtt';
  bool get hasLanguage => language != null && language!.isNotEmpty;
  bool get isCaptions => rel == 'captions';
  bool get isTranscript => rel == 'transcript';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PodcastTranscript &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          type == other.type &&
          language == other.language &&
          rel == other.rel;

  @override
  int get hashCode =>
      url.hashCode ^ type.hashCode ^ language.hashCode ^ rel.hashCode;

  @override
  String toString() {
    return 'PodcastTranscript{url: $url, type: $type, language: $language, rel: $rel}';
  }
}
