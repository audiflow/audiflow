/// Base class for all podcast entities emitted by the parser.
abstract class PodcastEntity {
  final DateTime parsedAt;
  final String sourceUrl;

  const PodcastEntity({required this.parsedAt, required this.sourceUrl});
}
