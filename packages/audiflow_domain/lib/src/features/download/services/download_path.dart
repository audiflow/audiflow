import 'package:path/path.dart' as p;

const _maxTitleLength = 50;
const _fallbackExtension = '.mp3';

/// Builds the local file path for an episode download.
///
/// Shared by the foreground and background download services so both derive
/// the same path for an episode: a partial file left by one can then be
/// resumed by the other.
String buildDownloadPath({
  required String downloadsDir,
  required int episodeId,
  required String episodeTitle,
  required String url,
}) {
  final name = _sanitizeTitle(episodeTitle);
  final extension = _extensionFromUrl(url);
  return p.join(downloadsDir, '${episodeId}_$name$extension');
}

String _sanitizeTitle(String title) {
  // Strip:
  //   - filesystem-invalid chars: < > : " / \ | * ?
  //   - URI-reserved chars that break file:// playback when the path is
  //     parsed as a URI by just_audio/ExoPlayer: # (fragment), % (percent
  //     encoding). `?` is already covered above.
  final sanitized = title
      .replaceAll(RegExp(r'[<>:"/\\|?*#%]'), '')
      .replaceAll(RegExp(r'\s+'), '_');
  if (sanitized.length <= _maxTitleLength) return sanitized;
  return sanitized.substring(0, _maxTitleLength);
}

String _extensionFromUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return _fallbackExtension;
  final extension = p.extension(uri.path);
  return extension.isEmpty ? _fallbackExtension : extension;
}
