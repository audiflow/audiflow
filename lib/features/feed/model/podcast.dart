import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/utils/hash.dart';
import 'package:isar/isar.dart';
import 'package:podcast_feed/parsers/feed_entity_parser.dart';
import 'package:podcast_feed/podcast_feed.dart' show ShowType;

part 'podcast.g.dart';

@collection
class Podcast {
  Podcast({
    required this.feedUrl,
    this.collectionId,
    this.newFeedUrl,
    required this.title,
    required this.description,
    required this.language,
    required this.category,
    this.subcategory,
    required this.explicit,
    required this.image,
    this.link,
    this.guid,
    this.author,
    this.copyright,
    this.complete = false,
    this.type = ShowType.episodic,
  });

  factory Podcast.fromFeed(
    ChannelValues values, {
    required String feedUrl,
    String? newFeedUrl,
    int? collectionId,
  }) {
    final podcast = Podcast(
      feedUrl: values.feedUrl.isNotEmpty ? values.feedUrl : feedUrl,
      collectionId: collectionId,
      newFeedUrl: values.newFeedUrl ?? newFeedUrl,
      title: values.title,
      description: values.description,
      language: values.language,
      category: values.category,
      subcategory: values.subcategory,
      explicit: values.explicit,
      image: values.imageUrl,
      link: values.link,
      guid: values.guid,
      author: values.author,
      copyright: values.copyright,
      complete: values.complete,
      type: values.type,
    );
    if (values.locked != null) {
      podcast.locked.add(Locked.fromFeed(values.locked!));
    }
    if (values.funding.isNotEmpty) {
      podcast.funding.addAll(values.funding.map(Funding.fromFeed));
    }
    if (values.value != null) {
      podcast.value.add(Value.fromFeed(values.value!));
    }
    if (values.block.isNotEmpty) {
      podcast.block.addAll(values.block.map(Block.fromFeed));
    }
    if (values.person.isNotEmpty) {
      podcast.person.addAll(values.person.map(Person.fromFeed));
    }

    return podcast;
  }

  static int pidFrom(String feedUrl) => fastHash(feedUrl);

  Id get id => pidFrom(feedUrl);

  /// The declared canonical feed URL for the podcast.
  @Index(unique: true)
  final String feedUrl;

  /// The collection ID(iTunesID).
  @Index()
  final int? collectionId;

  /// The new podcast RSS Feed URL.
  final String? newFeedUrl;

  /// The podcast title. A string containing the name of a podcast and nothing
  /// else.
  final String title;

  /// Text that describes a podcast to potential listeners.
  final String description;

  /// The language that is spoken on the podcast, specified in the ISO 639
  /// format.
  final String language;

  /// The category that best fits a podcast, selected from the list of Apple
  /// Podcasts categories (https://help.apple.com/itc/podcasts_connect/#/itcb54353390).
  final String category;
  final String? subcategory;

  /// The parental advisory information for a podcast.
  /// The value can be true, indicating the presence of explicit content, or
  /// false, indicating that a podcast doesn’t contain explicit language or
  /// adult content.
  final bool explicit;

  /// The artwork for the podcast.
  /// Image must be a minimum size of 1400 x 1400 pixels and a maximum size of
  /// 3000 x 3000 pixels, in JPEG or PNG format, 72 dpi, with appropriate file
  /// extensions (.jpg, .png), and in the RGB color-space. File type extension
  /// must match the actual file type of the image file.
  final String image;

  /// The website or web page associated with a podcast.
  final String? link;

  /// Tells podcast hosting platforms whether they are allowed to import this
  /// feed.
  final locked = IsarLinks<Locked>();

  /// The Podcasting 2.0 GUID value (optional).
  /// https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#guid
  final String? guid;

  /// The group, person, or people responsible for creating the podcast.
  final String? author;

  /// The copyright details for a podcast.
  final String? copyright;

  /// If the podcast supports funding this will contain an instance of [Funding]
  /// that contains the Url and optional description.
  final funding = IsarLinks<Funding>();

  /// The type of show.
  @enumerated
  final ShowType type;

  /// Specifies that a podcast is complete and will not post any more episodes
  /// in the future.
  final bool complete;

  /// A value block designates single or multiple destinations for these
  /// micro-payments.
  final value = IsarLinks<Value>();

  /// A list of [Block] tags.
  final block = IsarLinks<Block>();

  /// A list of [Person] tags.
  final person = IsarLinks<Person>();

  @override
  String toString() {
    return '''Podcast(title: '$title', feedUrl: '$feedUrl')''';
  }
}

@collection
class PodcastStats {
  PodcastStats({
    required this.id,
    this.subscribedDate,
    this.latestPubDate,
    required this.lastCheckedAt,
    required this.hasLoadedAll,
    required this.totalEpisodes,
    required this.totalPlayed,
  });

  final Id id;

  /// The date the podcast was subscribed to.
  ///
  /// null means the podcast is not subscribed.
  @Index()
  final DateTime? subscribedDate;

  /// The latest published date of the podcast episodes.
  ///
  /// This could be null if the podcast has not been loaded any episodes yet.
  @Index()
  final DateTime? latestPubDate;

  /// The last time the podcast was checked for new episodes.
  final DateTime lastCheckedAt;

  /// Flag indicating if all episodes have been loaded at least once.
  ///
  /// This is used to determine if a full feed read is needed in cases where
  /// the initial load was interrupted, ensuring incremental updates can be
  /// applied correctly in future loads.
  final bool hasLoadedAll;

  /// The total number of episodes in the podcast.
  final int totalEpisodes;

  /// The total number of episodes played.
  final int totalPlayed;

  PodcastStats copyWith({
    DateTime? subscribedDate,
    DateTime? latestPubDate,
    DateTime? lastCheckedAt,
    bool? hasLoadedAll,
    int? totalEpisodes,
    int? totalPlayed,
  }) {
    return PodcastStats(
      id: id,
      subscribedDate: subscribedDate ?? this.subscribedDate,
      latestPubDate: latestPubDate ?? this.latestPubDate,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      hasLoadedAll: hasLoadedAll ?? this.hasLoadedAll,
      totalEpisodes: totalEpisodes ?? this.totalEpisodes,
      totalPlayed: totalPlayed ?? this.totalPlayed,
    );
  }
}

extension PodcastStatsExt on PodcastStats {
  bool get subscribed => subscribedDate != null;
}

class PodcastStatsUpdateParam {
  const PodcastStatsUpdateParam({
    required this.id,
    this.subscribed,
    this.latestPubDate,
    this.lastCheckedAt,
    this.hasLoadedAll,
    this.deltaTotalEpisodes,
    this.deltaTotalPlayed,
  });

  final Id id;
  final bool? subscribed;
  final DateTime? latestPubDate;
  final DateTime? lastCheckedAt;
  final bool? hasLoadedAll;
  final int? deltaTotalEpisodes;
  final int? deltaTotalPlayed;

  PodcastStatsUpdateParam copyWith({
    bool? subscribed,
    DateTime? lastCheckedAt,
    DateTime? latestPubDate,
    bool? hasLoadedAll,
    int? deltaTotalEpisodes,
    int? deltaTotalPlayed,
  }) {
    return PodcastStatsUpdateParam(
      id: id,
      subscribed: subscribed ?? this.subscribed,
      latestPubDate: latestPubDate ?? this.latestPubDate,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      hasLoadedAll: hasLoadedAll ?? this.hasLoadedAll,
      deltaTotalEpisodes: deltaTotalEpisodes ?? this.deltaTotalEpisodes,
      deltaTotalPlayed: deltaTotalPlayed ?? this.deltaTotalPlayed,
    );
  }
}

@collection
class FeedUrl {
  FeedUrl({
    required this.collectionId,
    required this.feedUrl,
  });

  Id get id => collectionId;
  @Index(unique: true)
  final int collectionId;
  @Index(unique: true)
  final String feedUrl;
}
