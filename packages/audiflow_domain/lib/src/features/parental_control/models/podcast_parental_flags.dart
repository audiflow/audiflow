import 'package:isar_community/isar.dart';

part 'podcast_parental_flags.g.dart';

@collection
class PodcastParentalFlags {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late int itunesId;

  bool hideExplicitEpisodes = false;
}
