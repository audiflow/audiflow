final _paddingRegExp1 =
    RegExp(r'(</p><br>|</p></br>|<p><br></p>|<p></br></p>)');
final _paddingRegExp2 = RegExp(r'(<p><br></p>|<p></br></p>)');
final _tagRegExp = RegExp(r'<p><br/?>', caseSensitive: false);

/// Remove HTML padding from the content. The padding may look fine within
/// the context of a browser, but can look out of place on a mobile screen.
String removeHtmlPadding(String? input) {
  return input
          ?.trim()
          .replaceAll(_paddingRegExp2, '')
          .replaceAll(_paddingRegExp1, '</p>') ??
      '';
}

String? formatDescriptionHtml(String? input) {
  if (input == null) {
    return null;
  }
  final s = removeHtmlPadding(input);
  if (s.contains(_tagRegExp)) {
    return s;
  } else {
    return s
        .replaceAll(RegExp(r'^', multiLine: true), '<p>')
        .replaceAll(RegExp(r'$', multiLine: true), '</p>');
  }
}
