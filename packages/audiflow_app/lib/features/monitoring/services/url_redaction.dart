import 'package:sentry_flutter/sentry_flutter.dart';

final _urlPattern = RegExp(r'[a-zA-Z][a-zA-Z0-9+.-]*://[^\s\x27"<>]+');

/// [text] with every URL reduced to scheme and host.
///
/// Feed and media URLs can carry credentials or tokens in their user info,
/// path or query (private feeds, signed CDN links).
String redactUrls(String text) => text.replaceAllMapped(_urlPattern, (match) {
  final url = match[0]!;
  // Prose punctuation right after a URL, e.g. "(url: https://...)", is not
  // part of it; keep it so the surrounding text stays intact.
  final trailing = _trailingPunctuation.stringMatch(url) ?? '';
  final uri = Uri.tryParse(url.substring(0, url.length - trailing.length));
  if (uri == null || uri.host.isEmpty) return '<url>$trailing';
  return '${Uri(scheme: uri.scheme, host: uri.host)}$trailing';
});

final _trailingPunctuation = RegExp(r'[)\]},.;:!?]+$');

/// [event] with URLs in exception values, the event message, breadcrumb
/// messages and data, and custom contexts reduced to scheme and host.
///
/// Used as `beforeSend`: exception values come from `toString()` (e.g.
/// `PodcastException` appends its feed URL) and HTTP breadcrumbs record
/// full request URLs, so tokens would otherwise leave the device.
SentryEvent scrubEventUrls(SentryEvent event) {
  for (final exception in event.exceptions ?? const <SentryException>[]) {
    exception.value = _redactNullable(exception.value);
  }
  final message = event.message;
  if (message != null) {
    message
      ..formatted = redactUrls(message.formatted)
      ..template = _redactNullable(message.template);
  }
  for (final breadcrumb in event.breadcrumbs ?? const <Breadcrumb>[]) {
    breadcrumb.message = _redactNullable(breadcrumb.message);
    final data = breadcrumb.data;
    if (data != null) breadcrumb.data = _redactMap(data);
  }
  // Custom contexts (e.g. `player_interruption`) carry raw diagnostic data;
  // the SDK's typed contexts (device, app, ...) are not strings or maps
  // and pass through unchanged.
  final contexts = event.contexts;
  for (final key in contexts.keys.toList()) {
    contexts[key] = _redactValue(contexts[key]);
  }
  return event;
}

String? _redactNullable(String? text) => text == null ? null : redactUrls(text);

Map<String, dynamic> _redactMap(Map<dynamic, dynamic> map) => {
  for (final MapEntry(:key, :value) in map.entries) '$key': _redactValue(value),
};

Object? _redactValue(Object? value) => switch (value) {
  final String text => redactUrls(text),
  final Map<dynamic, dynamic> map => _redactMap(map),
  final List<dynamic> list => list.map(_redactValue).toList(),
  _ => value,
};
