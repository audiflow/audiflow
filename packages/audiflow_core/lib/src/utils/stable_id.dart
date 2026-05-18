import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Returns a 16-char lowercase-hex prefix of sha256(input).
///
/// Stable across users (deterministic) but opaque (no URL/GUID leak).
/// Use to derive cross-user identifiers for analytics events from
/// values that would otherwise be PII-adjacent (feed URLs) or exceed
/// length limits (full sha256, episode GUIDs).
String stableId(String input) {
  final digest = sha256.convert(utf8.encode(input));
  return digest.toString().substring(0, 16);
}
