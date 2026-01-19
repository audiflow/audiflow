/// Base class for all podcast entities emitted by the parser.
abstract class PodcastEntity {
  const PodcastEntity({required this.parsedAt, required this.sourceUrl});
  final DateTime parsedAt;
  final String sourceUrl;
}
