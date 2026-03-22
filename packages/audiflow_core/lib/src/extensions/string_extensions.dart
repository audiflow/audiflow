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

    // Match URLs not preceded by =" or >' (i.e. not inside href/src attrs
    // or anchor text). Uses negative lookbehind for common HTML patterns.
    final urlPattern = RegExp(
      r'(?<!=")(?<=\s|^|>|\()'
      r'(https?://|ftp://)'
      r'[^\s<>"\),$]+[^\s<>"\),.;:!?$]',
    );

    final buffer = StringBuffer();
    var lastEnd = 0;

    for (final match in urlPattern.allMatches(this)) {
      final before = substring(0, match.start);
      // Skip if inside an HTML tag attribute or anchor body
      if (_isInsideHtmlTag(before) || _isInsideAnchorBody(before)) {
        continue;
      }

      buffer.write(substring(lastEnd, match.start));
      final url = match.group(0)!;
      buffer.write('<a href="$url">$url</a>');
      lastEnd = match.end;
    }

    buffer.write(substring(lastEnd));
    return buffer.toString();
  }
}

/// Returns true if the position is inside an HTML tag (between < and >).
bool _isInsideHtmlTag(String textBefore) {
  final lastOpen = textBefore.lastIndexOf('<');
  final lastClose = textBefore.lastIndexOf('>');
  return lastClose < lastOpen;
}

/// Returns true if the position is inside an anchor body (<a ...>...</a>).
bool _isInsideAnchorBody(String textBefore) {
  final lastAnchorOpen = textBefore.lastIndexOf(RegExp(r'<a[\s>]'));
  if (lastAnchorOpen != -1) {
    final lastAnchorClose = textBefore.lastIndexOf('</a>');
    return lastAnchorClose < lastAnchorOpen;
  }
  return false;
}
