/// Helpers that read text out of raw XML the way `XmlDocument.parse`
/// would, for the regex-based fast paths that avoid building a DOM.
library;

final _xmlEntityRe = RegExp(
  r'&(?:(amp|lt|gt|quot|apos)|#(\d+)|#x([0-9a-fA-F]+));',
);

final _cdataSectionRe = RegExp(r'<!\[CDATA\[([\s\S]*?)\]\]>');

final _elementTextCache = <String, RegExp>{};

bool _isCodePoint(int? code) =>
    code != null &&
    0 <= code &&
    code <= 0x10FFFF &&
    !(0xD800 <= code && code <= 0xDFFF);

/// Decodes XML character references (the five named ones and numeric).
///
/// Decoding is a single pass, so `&amp;lt;` becomes `&lt;`, not `<`.
String decodeXmlEntities(String value) {
  if (!value.contains('&')) return value;
  return value.replaceAllMapped(_xmlEntityRe, _decodeEntity);
}

String _decodeEntity(Match m) {
  final named = m.group(1);
  if (named != null) {
    return switch (named) {
      'amp' => '&',
      'lt' => '<',
      'gt' => '>',
      'quot' => '"',
      'apos' => "'",
      _ => m.group(0)!,
    };
  }
  final decimal = m.group(2);
  final hex = m.group(3);
  final code = decimal != null
      ? int.tryParse(decimal)
      : hex != null
      ? int.tryParse(hex, radix: 16)
      : null;
  // An out-of-range or surrogate reference is left as written: a
  // malformed value must not fail the whole feed.
  return _isCodePoint(code) ? String.fromCharCode(code!) : m.group(0)!;
}

/// Text content of raw element content: character references in plain
/// text are decoded, CDATA sections are kept verbatim.
String decodeXmlText(String raw) {
  if (!raw.contains('<![CDATA[')) return decodeXmlEntities(raw);
  final buffer = StringBuffer();
  var cursor = 0;
  for (final section in _cdataSectionRe.allMatches(raw)) {
    buffer
      ..write(decodeXmlEntities(raw.substring(cursor, section.start)))
      ..write(section.group(1));
    cursor = section.end;
  }
  buffer.write(decodeXmlEntities(raw.substring(cursor)));
  return buffer.toString();
}

/// Trimmed text of the first `<tagName>` element in [xml], or null when
/// there is none. See [decodeXmlText] for how the content is decoded.
String? extractXmlElementText(String xml, String tagName) {
  final re = _elementTextCache.putIfAbsent(
    tagName,
    () => RegExp(
      '<${RegExp.escape(tagName)}(?:\\s[^>]*)?>'
      r'([\s\S]*?)'
      '</${RegExp.escape(tagName)}>',
      caseSensitive: false,
    ),
  );
  final raw = re.firstMatch(xml)?.group(1)?.trim();
  if (raw == null) return null;
  return decodeXmlText(raw);
}
