sealed class PodcastSearchEvent {}

class NewPodcastSearchEvent implements PodcastSearchEvent {
  const NewPodcastSearchEvent({
    required this.term,
    this.country,
    this.attribute,
    this.limit = 20,
    this.language,
    this.version = 0,
    this.explicit = false,
  });

  final String term;
  final String? country;
  final String? attribute;
  final int limit;
  final String? language;
  final int version;
  final bool explicit;
}

class ClearPodcastSearchEvent implements PodcastSearchEvent {}
