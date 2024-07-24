final descriptionRegExp1 =
    RegExp(r'(</p><br>|</p></br>|<p><br></p>|<p></br></p>)');
final descriptionRegExp2 = RegExp(r'(<p><br></p>|<p></br></p>)');

/// Remove HTML padding from the content. The padding may look fine within
/// the context of a browser, but can look out of place on a mobile screen.
String removeHtmlPadding(String? input) {
  return input
          ?.trim()
          .replaceAll(descriptionRegExp2, '')
          .replaceAll(descriptionRegExp1, '</p>') ??
      '';
}
