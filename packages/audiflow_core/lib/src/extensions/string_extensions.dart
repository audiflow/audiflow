/// Extensions for String class
extension StringExtensions on String {
  /// Check if string is empty or contains only whitespace
  bool get isBlank => trim().isEmpty;

  /// Check if string is not empty and contains non-whitespace characters
  bool get isNotBlank => !isBlank;

  /// Capitalize first letter
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Convert to title case
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  /// Converts plain text to HTML with paragraph breaks.
  ///
  /// Splits on double newlines or triple+ spaces into `<p>` blocks.
  /// Single newlines become `<br>`. If the text already contains HTML
  /// tags, it is returned unchanged.
  String get plainTextToHtml {
    if (isEmpty) return this;

    // Already has HTML tags — skip conversion
    if (RegExp(r'<[a-z][\s\S]*>', caseSensitive: false).hasMatch(this)) {
      return this;
    }

    // Normalize CRLF to LF
    final normalized = replaceAll('\r\n', '\n');

    // Split into paragraphs on double+ newlines or triple+ spaces
    final paragraphs = normalized
        .split(RegExp(r'\n{2,}|[ ]{3,}'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    if (paragraphs.length <= 1) {
      // No paragraph breaks found — just convert single newlines to <br>
      return normalized.replaceAll('\n', '<br>');
    }

    // Wrap each paragraph in <p> tags, converting inner newlines to <br>
    return paragraphs
        .map((p) => '<p>${p.replaceAll('\n', '<br>')}</p>')
        .join('');
  }

  /// Wraps plain-text URLs (http, https, ftp) in HTML anchor tags.
  ///
  /// URLs already inside HTML attributes (href, src) or anchor tag
  /// content are left unchanged.
  String get linkifyUrls {
    if (isEmpty) return this;

    // Capture an optional prefix character before the URL scheme.
    // No lookbehind needed — the prefix group handles boundary detection.
    final urlPattern = RegExp(
      r'([\s>(\x00]|^)'
      r'((?:https?://|ftp://)[^\s<>"\),$]+[^\s<>"\),.;:!?$])',
      multiLine: true,
    );

    final buffer = StringBuffer();
    var lastEnd = 0;

    for (final match in urlPattern.allMatches(this)) {
      final prefix = match.group(1) ?? '';
      final url = match.group(2)!;
      final urlStart = match.start + prefix.length;

      // Skip if inside an HTML tag attribute or anchor body
      if (_isInsideHtmlTag(this, urlStart) ||
          _isInsideAnchorBody(this, urlStart)) {
        continue;
      }

      buffer.write(substring(lastEnd, match.start));
      final escapedUrl = url.replaceAll('&', '&amp;');
      buffer.write('$prefix<a href="$escapedUrl">$url</a>');
      lastEnd = match.end;
    }

    buffer.write(substring(lastEnd));
    return buffer.toString();
  }
}

/// Returns true if [position] is inside an HTML tag (between < and >).
bool _isInsideHtmlTag(String text, int position) {
  final lastOpen = text.lastIndexOf('<', position);
  if (0 <= lastOpen) {
    final lastClose = text.lastIndexOf('>', position);
    return lastClose < lastOpen;
  }
  return false;
}

/// Returns true if [position] is inside an anchor body (<a ...>...</a>).
bool _isInsideAnchorBody(String text, int position) {
  final lastAnchorOpen = text.lastIndexOf(RegExp(r'<a[\s>]'), position);
  if (0 <= lastAnchorOpen) {
    final lastAnchorClose = text.lastIndexOf('</a>', position);
    return lastAnchorClose < lastAnchorOpen;
  }
  return false;
}
