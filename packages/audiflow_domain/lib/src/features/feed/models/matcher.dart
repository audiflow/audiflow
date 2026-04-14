/// A regex pattern plus the episode field it is evaluated against.
final class Matcher {
  const Matcher({required this.source, required this.pattern});

  factory Matcher.fromJson(Map<String, dynamic> json) {
    return Matcher(
      source: json['source'] as String,
      pattern: json['pattern'] as String,
    );
  }

  /// Episode field to match against: "title" or "description".
  final String source;

  /// Regex pattern tested against the source field.
  final String pattern;

  Map<String, dynamic> toJson() {
    return {'source': source, 'pattern': pattern};
  }
}
