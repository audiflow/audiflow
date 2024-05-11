import 'package:audiflow/entities/country.dart';

sealed class PodcastChartEvent {}

class NewPodcastChartEvent implements PodcastChartEvent {
  const NewPodcastChartEvent({
    this.size = 20,
    this.genre,
    this.country,
    this.refresh = false,
  });

  final int size;
  final String? genre;
  final Country? country;
  final bool refresh;

  @override
  String toString() {
    return 'NewPodcastChartEvent('
        'size: $size, genre: $genre, country: $country, refresh: $refresh)';
  }
}
