const _namedEntities = <String, String>{
  'amp': '&',
  'lt': '<',
  'gt': '>',
  'quot': '"',
  'apos': "'",
  'nbsp': '\u00A0',
  'copy': '\u00A9',
  'reg': '\u00AE',
  'trade': '\u2122',
  'mdash': '\u2014',
  'ndash': '\u2013',
  'hellip': '\u2026',
  'lsquo': '\u2018',
  'rsquo': '\u2019',
  'ldquo': '\u201C',
  'rdquo': '\u201D',
  'bull': '\u2022',
  'middot': '\u00B7',
  'laquo': '\u00AB',
  'raquo': '\u00BB',
};

final _htmlTagPattern = RegExp(r'<[^>]*>');
final _whitespacePattern = RegExp(r'\s+');
final _lineBreakTagPattern = RegExp(
  r'<br\b[^>]*>|</(?:p|div|li|h[1-6]|blockquote|tr)\s*>',
  caseSensitive: false,
);
final _horizontalSpacePattern = RegExp(r'[^\S\n]+');

final _entityPattern = RegExp(r'&(?:#[xX]([0-9a-fA-F]+)|#(\d+)|(\w+));');

/// Parses a numeric code point string and returns the character, or null if
/// the value is out of the valid Unicode range or in the surrogate range.
String? _parseCodePoint(String digits, {int radix = 10}) {
  final value = int.tryParse(digits, radix: radix);
  if (value == null) return null;
  // Valid Unicode: 0..0x10FFFF, excluding surrogates 0xD800..0xDFFF.
  if (value < 0) return null;
  if (0xD800 <= value && value <= 0xDFFF) return null;
  if (0x10FFFF < value) return null;
  return String.fromCharCode(value);
}

const _ruleCharacters = r'[:=\-_*~#+・─━―＝＊]';
final _separatorRun = RegExp('($_ruleCharacters)\\1{4,}');

// Spacing and inline formatting allowed around a rule on its own line.
const _ruleDecoration = r'(?:\s|&nbsp;|</?(?:strong|b|em|i|u|span)\b[^>]*>)*';

/// A run that fills a whole line or paragraph: it marks a section break.
final _standaloneRun = RegExp(
  '(^|<p>|<br\\s*/?>|\\n)$_ruleDecoration'
  '(?<rule>$_ruleCharacters)\\k<rule>{4,}'
  '$_ruleDecoration(?=</p>|<br\\s*/?>|\\n|\$)',
  caseSensitive: false,
);
final _ruleInParagraph = RegExp(r'<p>\s*<hr>\s*</p>', caseSensitive: false);
final _breaksAroundRule = RegExp(
  r'(?:<br\s*/?>\s*)*<hr>(?:\s*<br\s*/?>)*',
  caseSensitive: false,
);
final _ruleRun = RegExp(r'<hr>(?:\s*<hr>)+');
final _edgeRules = RegExp(r'^(?:\s*<hr>)+|(?:<hr>\s*)+$');
final _emptyParagraph = RegExp(
  r'<p>(?:\s|&nbsp;|<br\s*/?>)*</p>',
  caseSensitive: false,
);
final _blankLine = RegExp(r'^[ \t　]+$', multiLine: true);
final _breakRun = RegExp(r'(?:<br\s*/?>\s*){3,}', caseSensitive: false);
final _newlineRun = RegExp(r'\n{3,}');
// Whitespace, `&nbsp;`, and zero-width characters (ZWSP, ZWNJ, ZWJ, word
// joiner, BOM) that render nothing but still carry a link underline, both
// literal and as named, decimal or hex entities.
const _invisibleText =
    r'(?:\s|[\u200B-\u200D\u2060\uFEFF]'
    r'|&(?:nbsp|zwsp|zwnj|zwj|NoBreak);'
    r'|&#(?:0*(?:160|820[3-5]|8288|65279));'
    r'|&#[xX]0*(?:[aA]0|200[bBcCdD]|2060|[fF][eE][fF][fF]);)';
final _invisibleLink = RegExp(
  '<a\\b[^>]*>$_invisibleText*</a>',
  caseSensitive: false,
);
// Tags and URLs: separator cleanup leaves them untouched so attributes,
// link addresses and URL text (e.g. `/a-----b`) keep their characters,
// while decorations in link labels are still removed.
final _markupOrUrl = RegExp(
  r'<[^>]*>|(?:https?://|www\.)[^\s<>"]+',
  caseSensitive: false,
);

/// Extensions for String class
extension StringExtensions on String {
  /// Decodes HTML entities (named, numeric, and hex) to their characters.
  /// Malformed or out-of-range numeric entities are preserved as-is.
  String get htmlEntityDecode {
    if (isEmpty || !contains('&')) return this;
    return replaceAllMapped(_entityPattern, (match) {
      final hex = match.group(1);
      if (hex != null) {
        return _parseCodePoint(hex, radix: 16) ?? match.group(0)!;
      }
      final decimal = match.group(2);
      if (decimal != null) return _parseCodePoint(decimal) ?? match.group(0)!;
      final named = match.group(3)!.toLowerCase();
      return _namedEntities[named] ?? match.group(0)!;
    });
  }

  /// Strips HTML tags, decodes entities, and collapses whitespace for
  /// plain-text display.
  String get htmlToPlainText => replaceAll(
    _htmlTagPattern,
    ' ',
  ).htmlEntityDecode.replaceAll(_whitespacePattern, ' ').trim();

  /// Like [htmlToPlainText], but keeps paragraph and line breaks as single
  /// newlines, for surfaces that render multi-line text.
  String get htmlToMultilinePlainText => replaceAll('\r\n', '\n')
      .replaceAll(_lineBreakTagPattern, '\n')
      .replaceAll(_htmlTagPattern, ' ')
      .htmlEntityDecode
      .split('\n')
      .map((line) => line.replaceAll(_horizontalSpacePattern, ' ').trim())
      .where((line) => line.isNotEmpty)
      .join('\n');

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

  /// Removes decorative separator runs (redesign section 5): five or more
  /// of the same rule character in a row, such as `:::::`, `=====`,
  /// `-----` or `・・・・・`. Lines and HTML paragraphs left empty by the
  /// removal are dropped. Tags and URLs are left as they are, so link
  /// addresses keep their characters.
  String get withoutSeparatorRuns {
    if (isEmpty) return this;
    return splitMapJoin(
          _markupOrUrl,
          onMatch: (match) => match[0]!,
          onNonMatch: (text) => text.replaceAll(_separatorRun, ''),
        )
        .replaceAll(_emptyParagraph, '')
        .replaceAll(_blankLine, '')
        .replaceAll(_breakRun, '<br><br>')
        .replaceAll(_newlineRun, '\n\n')
        .trim();
  }

  /// Like [withoutSeparatorRuns], but a run standing alone on its line or
  /// in its paragraph becomes an `<hr>`, keeping the publisher's section
  /// break while dropping the characters. Runs that decorate text (such
  /// as `::::: Guests :::::`) are removed. Apply to HTML, i.e. after
  /// [plainTextToHtml]; rules at the start or end are dropped.
  String get separatorRunsAsRules {
    if (isEmpty) return this;
    final ruled = replaceAllMapped(_standaloneRun, (m) => '${m[1]}<hr>')
        .replaceAll(_ruleInParagraph, '<hr>')
        .replaceAll(_breaksAroundRule, '<hr>')
        .replaceAll(_ruleRun, '<hr>');
    return ruled.withoutSeparatorRuns.replaceAll(_edgeRules, '').trim();
  }

  /// Removes links whose text is empty or only invisible characters
  /// (e.g. word joiners left by a feed's editor). They show nothing but
  /// their underline, which reads as a stray mark.
  String get withoutInvisibleLinks {
    if (isEmpty) return this;
    return replaceAll(_invisibleLink, '');
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
