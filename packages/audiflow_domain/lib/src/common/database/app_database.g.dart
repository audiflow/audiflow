// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SubscriptionsTable extends Subscriptions
    with TableInfo<$SubscriptionsTable, Subscription> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscriptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _itunesIdMeta = const VerificationMeta(
    'itunesId',
  );
  @override
  late final GeneratedColumn<String> itunesId = GeneratedColumn<String>(
    'itunes_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _feedUrlMeta = const VerificationMeta(
    'feedUrl',
  );
  @override
  late final GeneratedColumn<String> feedUrl = GeneratedColumn<String>(
    'feed_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistNameMeta = const VerificationMeta(
    'artistName',
  );
  @override
  late final GeneratedColumn<String> artistName = GeneratedColumn<String>(
    'artist_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artworkUrlMeta = const VerificationMeta(
    'artworkUrl',
  );
  @override
  late final GeneratedColumn<String> artworkUrl = GeneratedColumn<String>(
    'artwork_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genresMeta = const VerificationMeta('genres');
  @override
  late final GeneratedColumn<String> genres = GeneratedColumn<String>(
    'genres',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _explicitMeta = const VerificationMeta(
    'explicit',
  );
  @override
  late final GeneratedColumn<bool> explicit = GeneratedColumn<bool>(
    'explicit',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("explicit" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _subscribedAtMeta = const VerificationMeta(
    'subscribedAt',
  );
  @override
  late final GeneratedColumn<DateTime> subscribedAt = GeneratedColumn<DateTime>(
    'subscribed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastRefreshedAtMeta = const VerificationMeta(
    'lastRefreshedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastRefreshedAt =
      GeneratedColumn<DateTime>(
        'last_refreshed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itunesId,
    feedUrl,
    title,
    artistName,
    artworkUrl,
    description,
    genres,
    explicit,
    subscribedAt,
    lastRefreshedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscriptions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Subscription> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('itunes_id')) {
      context.handle(
        _itunesIdMeta,
        itunesId.isAcceptableOrUnknown(data['itunes_id']!, _itunesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itunesIdMeta);
    }
    if (data.containsKey('feed_url')) {
      context.handle(
        _feedUrlMeta,
        feedUrl.isAcceptableOrUnknown(data['feed_url']!, _feedUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_feedUrlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist_name')) {
      context.handle(
        _artistNameMeta,
        artistName.isAcceptableOrUnknown(data['artist_name']!, _artistNameMeta),
      );
    } else if (isInserting) {
      context.missing(_artistNameMeta);
    }
    if (data.containsKey('artwork_url')) {
      context.handle(
        _artworkUrlMeta,
        artworkUrl.isAcceptableOrUnknown(data['artwork_url']!, _artworkUrlMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('genres')) {
      context.handle(
        _genresMeta,
        genres.isAcceptableOrUnknown(data['genres']!, _genresMeta),
      );
    }
    if (data.containsKey('explicit')) {
      context.handle(
        _explicitMeta,
        explicit.isAcceptableOrUnknown(data['explicit']!, _explicitMeta),
      );
    }
    if (data.containsKey('subscribed_at')) {
      context.handle(
        _subscribedAtMeta,
        subscribedAt.isAcceptableOrUnknown(
          data['subscribed_at']!,
          _subscribedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subscribedAtMeta);
    }
    if (data.containsKey('last_refreshed_at')) {
      context.handle(
        _lastRefreshedAtMeta,
        lastRefreshedAt.isAcceptableOrUnknown(
          data['last_refreshed_at']!,
          _lastRefreshedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subscription map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subscription(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      itunesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}itunes_id'],
      )!,
      feedUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_url'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artistName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_name'],
      )!,
      artworkUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artwork_url'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      genres: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genres'],
      )!,
      explicit: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}explicit'],
      )!,
      subscribedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}subscribed_at'],
      )!,
      lastRefreshedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_refreshed_at'],
      ),
    );
  }

  @override
  $SubscriptionsTable createAlias(String alias) {
    return $SubscriptionsTable(attachedDatabase, alias);
  }
}

class Subscription extends DataClass implements Insertable<Subscription> {
  /// Auto-incrementing primary key.
  final int id;

  /// iTunes collection/track ID (unique identifier from iTunes API).
  final String itunesId;

  /// RSS feed URL for the podcast.
  final String feedUrl;

  /// The name/title of the podcast.
  final String title;

  /// Name of the podcast creator or host.
  final String artistName;

  /// URL to podcast artwork image (nullable).
  final String? artworkUrl;

  /// Text description of the podcast (nullable).
  final String? description;

  /// Comma-separated list of genres (stored as empty string by default).
  final String genres;

  /// Whether this podcast contains explicit content.
  final bool explicit;

  /// When the user subscribed to this podcast.
  final DateTime subscribedAt;

  /// Last time the podcast feed was refreshed (nullable).
  final DateTime? lastRefreshedAt;
  const Subscription({
    required this.id,
    required this.itunesId,
    required this.feedUrl,
    required this.title,
    required this.artistName,
    this.artworkUrl,
    this.description,
    required this.genres,
    required this.explicit,
    required this.subscribedAt,
    this.lastRefreshedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['itunes_id'] = Variable<String>(itunesId);
    map['feed_url'] = Variable<String>(feedUrl);
    map['title'] = Variable<String>(title);
    map['artist_name'] = Variable<String>(artistName);
    if (!nullToAbsent || artworkUrl != null) {
      map['artwork_url'] = Variable<String>(artworkUrl);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['genres'] = Variable<String>(genres);
    map['explicit'] = Variable<bool>(explicit);
    map['subscribed_at'] = Variable<DateTime>(subscribedAt);
    if (!nullToAbsent || lastRefreshedAt != null) {
      map['last_refreshed_at'] = Variable<DateTime>(lastRefreshedAt);
    }
    return map;
  }

  SubscriptionsCompanion toCompanion(bool nullToAbsent) {
    return SubscriptionsCompanion(
      id: Value(id),
      itunesId: Value(itunesId),
      feedUrl: Value(feedUrl),
      title: Value(title),
      artistName: Value(artistName),
      artworkUrl: artworkUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkUrl),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      genres: Value(genres),
      explicit: Value(explicit),
      subscribedAt: Value(subscribedAt),
      lastRefreshedAt: lastRefreshedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastRefreshedAt),
    );
  }

  factory Subscription.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subscription(
      id: serializer.fromJson<int>(json['id']),
      itunesId: serializer.fromJson<String>(json['itunesId']),
      feedUrl: serializer.fromJson<String>(json['feedUrl']),
      title: serializer.fromJson<String>(json['title']),
      artistName: serializer.fromJson<String>(json['artistName']),
      artworkUrl: serializer.fromJson<String?>(json['artworkUrl']),
      description: serializer.fromJson<String?>(json['description']),
      genres: serializer.fromJson<String>(json['genres']),
      explicit: serializer.fromJson<bool>(json['explicit']),
      subscribedAt: serializer.fromJson<DateTime>(json['subscribedAt']),
      lastRefreshedAt: serializer.fromJson<DateTime?>(json['lastRefreshedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'itunesId': serializer.toJson<String>(itunesId),
      'feedUrl': serializer.toJson<String>(feedUrl),
      'title': serializer.toJson<String>(title),
      'artistName': serializer.toJson<String>(artistName),
      'artworkUrl': serializer.toJson<String?>(artworkUrl),
      'description': serializer.toJson<String?>(description),
      'genres': serializer.toJson<String>(genres),
      'explicit': serializer.toJson<bool>(explicit),
      'subscribedAt': serializer.toJson<DateTime>(subscribedAt),
      'lastRefreshedAt': serializer.toJson<DateTime?>(lastRefreshedAt),
    };
  }

  Subscription copyWith({
    int? id,
    String? itunesId,
    String? feedUrl,
    String? title,
    String? artistName,
    Value<String?> artworkUrl = const Value.absent(),
    Value<String?> description = const Value.absent(),
    String? genres,
    bool? explicit,
    DateTime? subscribedAt,
    Value<DateTime?> lastRefreshedAt = const Value.absent(),
  }) => Subscription(
    id: id ?? this.id,
    itunesId: itunesId ?? this.itunesId,
    feedUrl: feedUrl ?? this.feedUrl,
    title: title ?? this.title,
    artistName: artistName ?? this.artistName,
    artworkUrl: artworkUrl.present ? artworkUrl.value : this.artworkUrl,
    description: description.present ? description.value : this.description,
    genres: genres ?? this.genres,
    explicit: explicit ?? this.explicit,
    subscribedAt: subscribedAt ?? this.subscribedAt,
    lastRefreshedAt: lastRefreshedAt.present
        ? lastRefreshedAt.value
        : this.lastRefreshedAt,
  );
  Subscription copyWithCompanion(SubscriptionsCompanion data) {
    return Subscription(
      id: data.id.present ? data.id.value : this.id,
      itunesId: data.itunesId.present ? data.itunesId.value : this.itunesId,
      feedUrl: data.feedUrl.present ? data.feedUrl.value : this.feedUrl,
      title: data.title.present ? data.title.value : this.title,
      artistName: data.artistName.present
          ? data.artistName.value
          : this.artistName,
      artworkUrl: data.artworkUrl.present
          ? data.artworkUrl.value
          : this.artworkUrl,
      description: data.description.present
          ? data.description.value
          : this.description,
      genres: data.genres.present ? data.genres.value : this.genres,
      explicit: data.explicit.present ? data.explicit.value : this.explicit,
      subscribedAt: data.subscribedAt.present
          ? data.subscribedAt.value
          : this.subscribedAt,
      lastRefreshedAt: data.lastRefreshedAt.present
          ? data.lastRefreshedAt.value
          : this.lastRefreshedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subscription(')
          ..write('id: $id, ')
          ..write('itunesId: $itunesId, ')
          ..write('feedUrl: $feedUrl, ')
          ..write('title: $title, ')
          ..write('artistName: $artistName, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('description: $description, ')
          ..write('genres: $genres, ')
          ..write('explicit: $explicit, ')
          ..write('subscribedAt: $subscribedAt, ')
          ..write('lastRefreshedAt: $lastRefreshedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    itunesId,
    feedUrl,
    title,
    artistName,
    artworkUrl,
    description,
    genres,
    explicit,
    subscribedAt,
    lastRefreshedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subscription &&
          other.id == this.id &&
          other.itunesId == this.itunesId &&
          other.feedUrl == this.feedUrl &&
          other.title == this.title &&
          other.artistName == this.artistName &&
          other.artworkUrl == this.artworkUrl &&
          other.description == this.description &&
          other.genres == this.genres &&
          other.explicit == this.explicit &&
          other.subscribedAt == this.subscribedAt &&
          other.lastRefreshedAt == this.lastRefreshedAt);
}

class SubscriptionsCompanion extends UpdateCompanion<Subscription> {
  final Value<int> id;
  final Value<String> itunesId;
  final Value<String> feedUrl;
  final Value<String> title;
  final Value<String> artistName;
  final Value<String?> artworkUrl;
  final Value<String?> description;
  final Value<String> genres;
  final Value<bool> explicit;
  final Value<DateTime> subscribedAt;
  final Value<DateTime?> lastRefreshedAt;
  const SubscriptionsCompanion({
    this.id = const Value.absent(),
    this.itunesId = const Value.absent(),
    this.feedUrl = const Value.absent(),
    this.title = const Value.absent(),
    this.artistName = const Value.absent(),
    this.artworkUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.genres = const Value.absent(),
    this.explicit = const Value.absent(),
    this.subscribedAt = const Value.absent(),
    this.lastRefreshedAt = const Value.absent(),
  });
  SubscriptionsCompanion.insert({
    this.id = const Value.absent(),
    required String itunesId,
    required String feedUrl,
    required String title,
    required String artistName,
    this.artworkUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.genres = const Value.absent(),
    this.explicit = const Value.absent(),
    required DateTime subscribedAt,
    this.lastRefreshedAt = const Value.absent(),
  }) : itunesId = Value(itunesId),
       feedUrl = Value(feedUrl),
       title = Value(title),
       artistName = Value(artistName),
       subscribedAt = Value(subscribedAt);
  static Insertable<Subscription> custom({
    Expression<int>? id,
    Expression<String>? itunesId,
    Expression<String>? feedUrl,
    Expression<String>? title,
    Expression<String>? artistName,
    Expression<String>? artworkUrl,
    Expression<String>? description,
    Expression<String>? genres,
    Expression<bool>? explicit,
    Expression<DateTime>? subscribedAt,
    Expression<DateTime>? lastRefreshedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itunesId != null) 'itunes_id': itunesId,
      if (feedUrl != null) 'feed_url': feedUrl,
      if (title != null) 'title': title,
      if (artistName != null) 'artist_name': artistName,
      if (artworkUrl != null) 'artwork_url': artworkUrl,
      if (description != null) 'description': description,
      if (genres != null) 'genres': genres,
      if (explicit != null) 'explicit': explicit,
      if (subscribedAt != null) 'subscribed_at': subscribedAt,
      if (lastRefreshedAt != null) 'last_refreshed_at': lastRefreshedAt,
    });
  }

  SubscriptionsCompanion copyWith({
    Value<int>? id,
    Value<String>? itunesId,
    Value<String>? feedUrl,
    Value<String>? title,
    Value<String>? artistName,
    Value<String?>? artworkUrl,
    Value<String?>? description,
    Value<String>? genres,
    Value<bool>? explicit,
    Value<DateTime>? subscribedAt,
    Value<DateTime?>? lastRefreshedAt,
  }) {
    return SubscriptionsCompanion(
      id: id ?? this.id,
      itunesId: itunesId ?? this.itunesId,
      feedUrl: feedUrl ?? this.feedUrl,
      title: title ?? this.title,
      artistName: artistName ?? this.artistName,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      description: description ?? this.description,
      genres: genres ?? this.genres,
      explicit: explicit ?? this.explicit,
      subscribedAt: subscribedAt ?? this.subscribedAt,
      lastRefreshedAt: lastRefreshedAt ?? this.lastRefreshedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (itunesId.present) {
      map['itunes_id'] = Variable<String>(itunesId.value);
    }
    if (feedUrl.present) {
      map['feed_url'] = Variable<String>(feedUrl.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artistName.present) {
      map['artist_name'] = Variable<String>(artistName.value);
    }
    if (artworkUrl.present) {
      map['artwork_url'] = Variable<String>(artworkUrl.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (genres.present) {
      map['genres'] = Variable<String>(genres.value);
    }
    if (explicit.present) {
      map['explicit'] = Variable<bool>(explicit.value);
    }
    if (subscribedAt.present) {
      map['subscribed_at'] = Variable<DateTime>(subscribedAt.value);
    }
    if (lastRefreshedAt.present) {
      map['last_refreshed_at'] = Variable<DateTime>(lastRefreshedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionsCompanion(')
          ..write('id: $id, ')
          ..write('itunesId: $itunesId, ')
          ..write('feedUrl: $feedUrl, ')
          ..write('title: $title, ')
          ..write('artistName: $artistName, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('description: $description, ')
          ..write('genres: $genres, ')
          ..write('explicit: $explicit, ')
          ..write('subscribedAt: $subscribedAt, ')
          ..write('lastRefreshedAt: $lastRefreshedAt')
          ..write(')'))
        .toString();
  }
}

class $EpisodesTable extends Episodes with TableInfo<$EpisodesTable, Episode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EpisodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _podcastIdMeta = const VerificationMeta(
    'podcastId',
  );
  @override
  late final GeneratedColumn<int> podcastId = GeneratedColumn<int>(
    'podcast_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES subscriptions (id)',
    ),
  );
  static const VerificationMeta _guidMeta = const VerificationMeta('guid');
  @override
  late final GeneratedColumn<String> guid = GeneratedColumn<String>(
    'guid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioUrlMeta = const VerificationMeta(
    'audioUrl',
  );
  @override
  late final GeneratedColumn<String> audioUrl = GeneratedColumn<String>(
    'audio_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publishedAtMeta = const VerificationMeta(
    'publishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> publishedAt = GeneratedColumn<DateTime>(
    'published_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _episodeNumberMeta = const VerificationMeta(
    'episodeNumber',
  );
  @override
  late final GeneratedColumn<int> episodeNumber = GeneratedColumn<int>(
    'episode_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seasonNumberMeta = const VerificationMeta(
    'seasonNumber',
  );
  @override
  late final GeneratedColumn<int> seasonNumber = GeneratedColumn<int>(
    'season_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    podcastId,
    guid,
    title,
    description,
    audioUrl,
    durationMs,
    publishedAt,
    imageUrl,
    episodeNumber,
    seasonNumber,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'episodes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Episode> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('podcast_id')) {
      context.handle(
        _podcastIdMeta,
        podcastId.isAcceptableOrUnknown(data['podcast_id']!, _podcastIdMeta),
      );
    } else if (isInserting) {
      context.missing(_podcastIdMeta);
    }
    if (data.containsKey('guid')) {
      context.handle(
        _guidMeta,
        guid.isAcceptableOrUnknown(data['guid']!, _guidMeta),
      );
    } else if (isInserting) {
      context.missing(_guidMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('audio_url')) {
      context.handle(
        _audioUrlMeta,
        audioUrl.isAcceptableOrUnknown(data['audio_url']!, _audioUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_audioUrlMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('published_at')) {
      context.handle(
        _publishedAtMeta,
        publishedAt.isAcceptableOrUnknown(
          data['published_at']!,
          _publishedAtMeta,
        ),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('episode_number')) {
      context.handle(
        _episodeNumberMeta,
        episodeNumber.isAcceptableOrUnknown(
          data['episode_number']!,
          _episodeNumberMeta,
        ),
      );
    }
    if (data.containsKey('season_number')) {
      context.handle(
        _seasonNumberMeta,
        seasonNumber.isAcceptableOrUnknown(
          data['season_number']!,
          _seasonNumberMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {podcastId, guid},
  ];
  @override
  Episode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Episode(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      podcastId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}podcast_id'],
      )!,
      guid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guid'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      audioUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_url'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      publishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}published_at'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      episodeNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode_number'],
      ),
      seasonNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}season_number'],
      ),
    );
  }

  @override
  $EpisodesTable createAlias(String alias) {
    return $EpisodesTable(attachedDatabase, alias);
  }
}

class Episode extends DataClass implements Insertable<Episode> {
  /// Auto-incrementing primary key.
  final int id;

  /// Foreign key to Subscriptions table.
  final int podcastId;

  /// Unique identifier from RSS feed (guid element).
  final String guid;

  /// Episode title.
  final String title;

  /// Episode description/show notes (nullable).
  final String? description;

  /// URL to the audio file.
  final String audioUrl;

  /// Duration in milliseconds (nullable, may not be in feed).
  final int? durationMs;

  /// Publication date (nullable).
  final DateTime? publishedAt;

  /// Episode artwork URL (nullable, falls back to podcast artwork).
  final String? imageUrl;

  /// Episode number within season (nullable).
  final int? episodeNumber;

  /// Season number (nullable).
  final int? seasonNumber;
  const Episode({
    required this.id,
    required this.podcastId,
    required this.guid,
    required this.title,
    this.description,
    required this.audioUrl,
    this.durationMs,
    this.publishedAt,
    this.imageUrl,
    this.episodeNumber,
    this.seasonNumber,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['podcast_id'] = Variable<int>(podcastId);
    map['guid'] = Variable<String>(guid);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['audio_url'] = Variable<String>(audioUrl);
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || publishedAt != null) {
      map['published_at'] = Variable<DateTime>(publishedAt);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || episodeNumber != null) {
      map['episode_number'] = Variable<int>(episodeNumber);
    }
    if (!nullToAbsent || seasonNumber != null) {
      map['season_number'] = Variable<int>(seasonNumber);
    }
    return map;
  }

  EpisodesCompanion toCompanion(bool nullToAbsent) {
    return EpisodesCompanion(
      id: Value(id),
      podcastId: Value(podcastId),
      guid: Value(guid),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      audioUrl: Value(audioUrl),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      publishedAt: publishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(publishedAt),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      episodeNumber: episodeNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(episodeNumber),
      seasonNumber: seasonNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(seasonNumber),
    );
  }

  factory Episode.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Episode(
      id: serializer.fromJson<int>(json['id']),
      podcastId: serializer.fromJson<int>(json['podcastId']),
      guid: serializer.fromJson<String>(json['guid']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      audioUrl: serializer.fromJson<String>(json['audioUrl']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      publishedAt: serializer.fromJson<DateTime?>(json['publishedAt']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      episodeNumber: serializer.fromJson<int?>(json['episodeNumber']),
      seasonNumber: serializer.fromJson<int?>(json['seasonNumber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'podcastId': serializer.toJson<int>(podcastId),
      'guid': serializer.toJson<String>(guid),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'audioUrl': serializer.toJson<String>(audioUrl),
      'durationMs': serializer.toJson<int?>(durationMs),
      'publishedAt': serializer.toJson<DateTime?>(publishedAt),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'episodeNumber': serializer.toJson<int?>(episodeNumber),
      'seasonNumber': serializer.toJson<int?>(seasonNumber),
    };
  }

  Episode copyWith({
    int? id,
    int? podcastId,
    String? guid,
    String? title,
    Value<String?> description = const Value.absent(),
    String? audioUrl,
    Value<int?> durationMs = const Value.absent(),
    Value<DateTime?> publishedAt = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    Value<int?> episodeNumber = const Value.absent(),
    Value<int?> seasonNumber = const Value.absent(),
  }) => Episode(
    id: id ?? this.id,
    podcastId: podcastId ?? this.podcastId,
    guid: guid ?? this.guid,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    audioUrl: audioUrl ?? this.audioUrl,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    publishedAt: publishedAt.present ? publishedAt.value : this.publishedAt,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    episodeNumber: episodeNumber.present
        ? episodeNumber.value
        : this.episodeNumber,
    seasonNumber: seasonNumber.present ? seasonNumber.value : this.seasonNumber,
  );
  Episode copyWithCompanion(EpisodesCompanion data) {
    return Episode(
      id: data.id.present ? data.id.value : this.id,
      podcastId: data.podcastId.present ? data.podcastId.value : this.podcastId,
      guid: data.guid.present ? data.guid.value : this.guid,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      audioUrl: data.audioUrl.present ? data.audioUrl.value : this.audioUrl,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      publishedAt: data.publishedAt.present
          ? data.publishedAt.value
          : this.publishedAt,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      episodeNumber: data.episodeNumber.present
          ? data.episodeNumber.value
          : this.episodeNumber,
      seasonNumber: data.seasonNumber.present
          ? data.seasonNumber.value
          : this.seasonNumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Episode(')
          ..write('id: $id, ')
          ..write('podcastId: $podcastId, ')
          ..write('guid: $guid, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('durationMs: $durationMs, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('episodeNumber: $episodeNumber, ')
          ..write('seasonNumber: $seasonNumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    podcastId,
    guid,
    title,
    description,
    audioUrl,
    durationMs,
    publishedAt,
    imageUrl,
    episodeNumber,
    seasonNumber,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Episode &&
          other.id == this.id &&
          other.podcastId == this.podcastId &&
          other.guid == this.guid &&
          other.title == this.title &&
          other.description == this.description &&
          other.audioUrl == this.audioUrl &&
          other.durationMs == this.durationMs &&
          other.publishedAt == this.publishedAt &&
          other.imageUrl == this.imageUrl &&
          other.episodeNumber == this.episodeNumber &&
          other.seasonNumber == this.seasonNumber);
}

class EpisodesCompanion extends UpdateCompanion<Episode> {
  final Value<int> id;
  final Value<int> podcastId;
  final Value<String> guid;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> audioUrl;
  final Value<int?> durationMs;
  final Value<DateTime?> publishedAt;
  final Value<String?> imageUrl;
  final Value<int?> episodeNumber;
  final Value<int?> seasonNumber;
  const EpisodesCompanion({
    this.id = const Value.absent(),
    this.podcastId = const Value.absent(),
    this.guid = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.episodeNumber = const Value.absent(),
    this.seasonNumber = const Value.absent(),
  });
  EpisodesCompanion.insert({
    this.id = const Value.absent(),
    required int podcastId,
    required String guid,
    required String title,
    this.description = const Value.absent(),
    required String audioUrl,
    this.durationMs = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.episodeNumber = const Value.absent(),
    this.seasonNumber = const Value.absent(),
  }) : podcastId = Value(podcastId),
       guid = Value(guid),
       title = Value(title),
       audioUrl = Value(audioUrl);
  static Insertable<Episode> custom({
    Expression<int>? id,
    Expression<int>? podcastId,
    Expression<String>? guid,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? audioUrl,
    Expression<int>? durationMs,
    Expression<DateTime>? publishedAt,
    Expression<String>? imageUrl,
    Expression<int>? episodeNumber,
    Expression<int>? seasonNumber,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (podcastId != null) 'podcast_id': podcastId,
      if (guid != null) 'guid': guid,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (audioUrl != null) 'audio_url': audioUrl,
      if (durationMs != null) 'duration_ms': durationMs,
      if (publishedAt != null) 'published_at': publishedAt,
      if (imageUrl != null) 'image_url': imageUrl,
      if (episodeNumber != null) 'episode_number': episodeNumber,
      if (seasonNumber != null) 'season_number': seasonNumber,
    });
  }

  EpisodesCompanion copyWith({
    Value<int>? id,
    Value<int>? podcastId,
    Value<String>? guid,
    Value<String>? title,
    Value<String?>? description,
    Value<String>? audioUrl,
    Value<int?>? durationMs,
    Value<DateTime?>? publishedAt,
    Value<String?>? imageUrl,
    Value<int?>? episodeNumber,
    Value<int?>? seasonNumber,
  }) {
    return EpisodesCompanion(
      id: id ?? this.id,
      podcastId: podcastId ?? this.podcastId,
      guid: guid ?? this.guid,
      title: title ?? this.title,
      description: description ?? this.description,
      audioUrl: audioUrl ?? this.audioUrl,
      durationMs: durationMs ?? this.durationMs,
      publishedAt: publishedAt ?? this.publishedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      seasonNumber: seasonNumber ?? this.seasonNumber,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (podcastId.present) {
      map['podcast_id'] = Variable<int>(podcastId.value);
    }
    if (guid.present) {
      map['guid'] = Variable<String>(guid.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (audioUrl.present) {
      map['audio_url'] = Variable<String>(audioUrl.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (publishedAt.present) {
      map['published_at'] = Variable<DateTime>(publishedAt.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (episodeNumber.present) {
      map['episode_number'] = Variable<int>(episodeNumber.value);
    }
    if (seasonNumber.present) {
      map['season_number'] = Variable<int>(seasonNumber.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EpisodesCompanion(')
          ..write('id: $id, ')
          ..write('podcastId: $podcastId, ')
          ..write('guid: $guid, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('durationMs: $durationMs, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('episodeNumber: $episodeNumber, ')
          ..write('seasonNumber: $seasonNumber')
          ..write(')'))
        .toString();
  }
}

class $PlaybackHistoriesTable extends PlaybackHistories
    with TableInfo<$PlaybackHistoriesTable, PlaybackHistory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaybackHistoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _episodeIdMeta = const VerificationMeta(
    'episodeId',
  );
  @override
  late final GeneratedColumn<int> episodeId = GeneratedColumn<int>(
    'episode_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES episodes (id)',
    ),
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firstPlayedAtMeta = const VerificationMeta(
    'firstPlayedAt',
  );
  @override
  late final GeneratedColumn<DateTime> firstPlayedAt =
      GeneratedColumn<DateTime>(
        'first_played_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastPlayedAtMeta = const VerificationMeta(
    'lastPlayedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPlayedAt = GeneratedColumn<DateTime>(
    'last_played_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _playCountMeta = const VerificationMeta(
    'playCount',
  );
  @override
  late final GeneratedColumn<int> playCount = GeneratedColumn<int>(
    'play_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    episodeId,
    positionMs,
    durationMs,
    completedAt,
    firstPlayedAt,
    lastPlayedAt,
    playCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playback_histories';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaybackHistory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('episode_id')) {
      context.handle(
        _episodeIdMeta,
        episodeId.isAcceptableOrUnknown(data['episode_id']!, _episodeIdMeta),
      );
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('first_played_at')) {
      context.handle(
        _firstPlayedAtMeta,
        firstPlayedAt.isAcceptableOrUnknown(
          data['first_played_at']!,
          _firstPlayedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_played_at')) {
      context.handle(
        _lastPlayedAtMeta,
        lastPlayedAt.isAcceptableOrUnknown(
          data['last_played_at']!,
          _lastPlayedAtMeta,
        ),
      );
    }
    if (data.containsKey('play_count')) {
      context.handle(
        _playCountMeta,
        playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {episodeId};
  @override
  PlaybackHistory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaybackHistory(
      episodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode_id'],
      )!,
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      firstPlayedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_played_at'],
      ),
      lastPlayedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_played_at'],
      ),
      playCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_count'],
      )!,
    );
  }

  @override
  $PlaybackHistoriesTable createAlias(String alias) {
    return $PlaybackHistoriesTable(attachedDatabase, alias);
  }
}

class PlaybackHistory extends DataClass implements Insertable<PlaybackHistory> {
  /// Foreign key to Episodes table (also serves as primary key).
  final int episodeId;

  /// Current playback position in milliseconds.
  final int positionMs;

  /// Episode duration in milliseconds (cached from playback).
  final int? durationMs;

  /// When the episode was marked as completed (null = not completed).
  final DateTime? completedAt;

  /// When the user first started playing this episode.
  final DateTime? firstPlayedAt;

  /// When the user last played this episode.
  final DateTime? lastPlayedAt;

  /// Number of times the episode was started from the beginning.
  final int playCount;
  const PlaybackHistory({
    required this.episodeId,
    required this.positionMs,
    this.durationMs,
    this.completedAt,
    this.firstPlayedAt,
    this.lastPlayedAt,
    required this.playCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['episode_id'] = Variable<int>(episodeId);
    map['position_ms'] = Variable<int>(positionMs);
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || firstPlayedAt != null) {
      map['first_played_at'] = Variable<DateTime>(firstPlayedAt);
    }
    if (!nullToAbsent || lastPlayedAt != null) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt);
    }
    map['play_count'] = Variable<int>(playCount);
    return map;
  }

  PlaybackHistoriesCompanion toCompanion(bool nullToAbsent) {
    return PlaybackHistoriesCompanion(
      episodeId: Value(episodeId),
      positionMs: Value(positionMs),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      firstPlayedAt: firstPlayedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(firstPlayedAt),
      lastPlayedAt: lastPlayedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayedAt),
      playCount: Value(playCount),
    );
  }

  factory PlaybackHistory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaybackHistory(
      episodeId: serializer.fromJson<int>(json['episodeId']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      firstPlayedAt: serializer.fromJson<DateTime?>(json['firstPlayedAt']),
      lastPlayedAt: serializer.fromJson<DateTime?>(json['lastPlayedAt']),
      playCount: serializer.fromJson<int>(json['playCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'episodeId': serializer.toJson<int>(episodeId),
      'positionMs': serializer.toJson<int>(positionMs),
      'durationMs': serializer.toJson<int?>(durationMs),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'firstPlayedAt': serializer.toJson<DateTime?>(firstPlayedAt),
      'lastPlayedAt': serializer.toJson<DateTime?>(lastPlayedAt),
      'playCount': serializer.toJson<int>(playCount),
    };
  }

  PlaybackHistory copyWith({
    int? episodeId,
    int? positionMs,
    Value<int?> durationMs = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
    Value<DateTime?> firstPlayedAt = const Value.absent(),
    Value<DateTime?> lastPlayedAt = const Value.absent(),
    int? playCount,
  }) => PlaybackHistory(
    episodeId: episodeId ?? this.episodeId,
    positionMs: positionMs ?? this.positionMs,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    firstPlayedAt: firstPlayedAt.present
        ? firstPlayedAt.value
        : this.firstPlayedAt,
    lastPlayedAt: lastPlayedAt.present ? lastPlayedAt.value : this.lastPlayedAt,
    playCount: playCount ?? this.playCount,
  );
  PlaybackHistory copyWithCompanion(PlaybackHistoriesCompanion data) {
    return PlaybackHistory(
      episodeId: data.episodeId.present ? data.episodeId.value : this.episodeId,
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      firstPlayedAt: data.firstPlayedAt.present
          ? data.firstPlayedAt.value
          : this.firstPlayedAt,
      lastPlayedAt: data.lastPlayedAt.present
          ? data.lastPlayedAt.value
          : this.lastPlayedAt,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackHistory(')
          ..write('episodeId: $episodeId, ')
          ..write('positionMs: $positionMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('completedAt: $completedAt, ')
          ..write('firstPlayedAt: $firstPlayedAt, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('playCount: $playCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    episodeId,
    positionMs,
    durationMs,
    completedAt,
    firstPlayedAt,
    lastPlayedAt,
    playCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaybackHistory &&
          other.episodeId == this.episodeId &&
          other.positionMs == this.positionMs &&
          other.durationMs == this.durationMs &&
          other.completedAt == this.completedAt &&
          other.firstPlayedAt == this.firstPlayedAt &&
          other.lastPlayedAt == this.lastPlayedAt &&
          other.playCount == this.playCount);
}

class PlaybackHistoriesCompanion extends UpdateCompanion<PlaybackHistory> {
  final Value<int> episodeId;
  final Value<int> positionMs;
  final Value<int?> durationMs;
  final Value<DateTime?> completedAt;
  final Value<DateTime?> firstPlayedAt;
  final Value<DateTime?> lastPlayedAt;
  final Value<int> playCount;
  const PlaybackHistoriesCompanion({
    this.episodeId = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.firstPlayedAt = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.playCount = const Value.absent(),
  });
  PlaybackHistoriesCompanion.insert({
    this.episodeId = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.firstPlayedAt = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.playCount = const Value.absent(),
  });
  static Insertable<PlaybackHistory> custom({
    Expression<int>? episodeId,
    Expression<int>? positionMs,
    Expression<int>? durationMs,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? firstPlayedAt,
    Expression<DateTime>? lastPlayedAt,
    Expression<int>? playCount,
  }) {
    return RawValuesInsertable({
      if (episodeId != null) 'episode_id': episodeId,
      if (positionMs != null) 'position_ms': positionMs,
      if (durationMs != null) 'duration_ms': durationMs,
      if (completedAt != null) 'completed_at': completedAt,
      if (firstPlayedAt != null) 'first_played_at': firstPlayedAt,
      if (lastPlayedAt != null) 'last_played_at': lastPlayedAt,
      if (playCount != null) 'play_count': playCount,
    });
  }

  PlaybackHistoriesCompanion copyWith({
    Value<int>? episodeId,
    Value<int>? positionMs,
    Value<int?>? durationMs,
    Value<DateTime?>? completedAt,
    Value<DateTime?>? firstPlayedAt,
    Value<DateTime?>? lastPlayedAt,
    Value<int>? playCount,
  }) {
    return PlaybackHistoriesCompanion(
      episodeId: episodeId ?? this.episodeId,
      positionMs: positionMs ?? this.positionMs,
      durationMs: durationMs ?? this.durationMs,
      completedAt: completedAt ?? this.completedAt,
      firstPlayedAt: firstPlayedAt ?? this.firstPlayedAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      playCount: playCount ?? this.playCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (episodeId.present) {
      map['episode_id'] = Variable<int>(episodeId.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (firstPlayedAt.present) {
      map['first_played_at'] = Variable<DateTime>(firstPlayedAt.value);
    }
    if (lastPlayedAt.present) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt.value);
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackHistoriesCompanion(')
          ..write('episodeId: $episodeId, ')
          ..write('positionMs: $positionMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('completedAt: $completedAt, ')
          ..write('firstPlayedAt: $firstPlayedAt, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('playCount: $playCount')
          ..write(')'))
        .toString();
  }
}

class $SmartPlaylistsTable extends SmartPlaylists
    with TableInfo<$SmartPlaylistsTable, SmartPlaylistEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SmartPlaylistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _podcastIdMeta = const VerificationMeta(
    'podcastId',
  );
  @override
  late final GeneratedColumn<int> podcastId = GeneratedColumn<int>(
    'podcast_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES subscriptions (id)',
    ),
  );
  static const VerificationMeta _playlistNumberMeta = const VerificationMeta(
    'playlistNumber',
  );
  @override
  late final GeneratedColumn<int> playlistNumber = GeneratedColumn<int>(
    'season_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortKeyMeta = const VerificationMeta(
    'sortKey',
  );
  @override
  late final GeneratedColumn<int> sortKey = GeneratedColumn<int>(
    'sort_key',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolverTypeMeta = const VerificationMeta(
    'resolverType',
  );
  @override
  late final GeneratedColumn<String> resolverType = GeneratedColumn<String>(
    'resolver_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thumbnailUrlMeta = const VerificationMeta(
    'thumbnailUrl',
  );
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
    'thumbnail_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearGroupedMeta = const VerificationMeta(
    'yearGrouped',
  );
  @override
  late final GeneratedColumn<bool> yearGrouped = GeneratedColumn<bool>(
    'year_grouped',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("year_grouped" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    podcastId,
    playlistNumber,
    displayName,
    sortKey,
    resolverType,
    thumbnailUrl,
    yearGrouped,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'seasons';
  @override
  VerificationContext validateIntegrity(
    Insertable<SmartPlaylistEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('podcast_id')) {
      context.handle(
        _podcastIdMeta,
        podcastId.isAcceptableOrUnknown(data['podcast_id']!, _podcastIdMeta),
      );
    } else if (isInserting) {
      context.missing(_podcastIdMeta);
    }
    if (data.containsKey('season_number')) {
      context.handle(
        _playlistNumberMeta,
        playlistNumber.isAcceptableOrUnknown(
          data['season_number']!,
          _playlistNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_playlistNumberMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('sort_key')) {
      context.handle(
        _sortKeyMeta,
        sortKey.isAcceptableOrUnknown(data['sort_key']!, _sortKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_sortKeyMeta);
    }
    if (data.containsKey('resolver_type')) {
      context.handle(
        _resolverTypeMeta,
        resolverType.isAcceptableOrUnknown(
          data['resolver_type']!,
          _resolverTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_resolverTypeMeta);
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
        _thumbnailUrlMeta,
        thumbnailUrl.isAcceptableOrUnknown(
          data['thumbnail_url']!,
          _thumbnailUrlMeta,
        ),
      );
    }
    if (data.containsKey('year_grouped')) {
      context.handle(
        _yearGroupedMeta,
        yearGrouped.isAcceptableOrUnknown(
          data['year_grouped']!,
          _yearGroupedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {podcastId, playlistNumber};
  @override
  SmartPlaylistEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SmartPlaylistEntity(
      podcastId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}podcast_id'],
      )!,
      playlistNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}season_number'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      sortKey: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_key'],
      )!,
      resolverType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolver_type'],
      )!,
      thumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_url'],
      ),
      yearGrouped: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}year_grouped'],
      )!,
    );
  }

  @override
  $SmartPlaylistsTable createAlias(String alias) {
    return $SmartPlaylistsTable(attachedDatabase, alias);
  }
}

class SmartPlaylistEntity extends DataClass
    implements Insertable<SmartPlaylistEntity> {
  /// Foreign key to Subscriptions table (part of composite PK).
  final int podcastId;

  /// Playlist number matching episode.seasonNumber (part of
  /// composite PK).
  /// Use 0 for ungrouped/extras playlists like "bangai-hen".
  final int playlistNumber;

  /// Display name (e.g., "Lincoln arc", "bangai-hen").
  final String displayName;

  /// Sort key for ordering smart playlists (typically max
  /// episodeNumber in playlist).
  final int sortKey;

  /// Resolver type that generated this smart playlist (e.g., "rss").
  final String resolverType;

  /// Thumbnail URL from the latest episode in this smart playlist.
  final String? thumbnailUrl;

  /// Whether this smart playlist groups episodes by year.
  final bool yearGrouped;
  const SmartPlaylistEntity({
    required this.podcastId,
    required this.playlistNumber,
    required this.displayName,
    required this.sortKey,
    required this.resolverType,
    this.thumbnailUrl,
    required this.yearGrouped,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['podcast_id'] = Variable<int>(podcastId);
    map['season_number'] = Variable<int>(playlistNumber);
    map['display_name'] = Variable<String>(displayName);
    map['sort_key'] = Variable<int>(sortKey);
    map['resolver_type'] = Variable<String>(resolverType);
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
    map['year_grouped'] = Variable<bool>(yearGrouped);
    return map;
  }

  SmartPlaylistsCompanion toCompanion(bool nullToAbsent) {
    return SmartPlaylistsCompanion(
      podcastId: Value(podcastId),
      playlistNumber: Value(playlistNumber),
      displayName: Value(displayName),
      sortKey: Value(sortKey),
      resolverType: Value(resolverType),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      yearGrouped: Value(yearGrouped),
    );
  }

  factory SmartPlaylistEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SmartPlaylistEntity(
      podcastId: serializer.fromJson<int>(json['podcastId']),
      playlistNumber: serializer.fromJson<int>(json['playlistNumber']),
      displayName: serializer.fromJson<String>(json['displayName']),
      sortKey: serializer.fromJson<int>(json['sortKey']),
      resolverType: serializer.fromJson<String>(json['resolverType']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      yearGrouped: serializer.fromJson<bool>(json['yearGrouped']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'podcastId': serializer.toJson<int>(podcastId),
      'playlistNumber': serializer.toJson<int>(playlistNumber),
      'displayName': serializer.toJson<String>(displayName),
      'sortKey': serializer.toJson<int>(sortKey),
      'resolverType': serializer.toJson<String>(resolverType),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'yearGrouped': serializer.toJson<bool>(yearGrouped),
    };
  }

  SmartPlaylistEntity copyWith({
    int? podcastId,
    int? playlistNumber,
    String? displayName,
    int? sortKey,
    String? resolverType,
    Value<String?> thumbnailUrl = const Value.absent(),
    bool? yearGrouped,
  }) => SmartPlaylistEntity(
    podcastId: podcastId ?? this.podcastId,
    playlistNumber: playlistNumber ?? this.playlistNumber,
    displayName: displayName ?? this.displayName,
    sortKey: sortKey ?? this.sortKey,
    resolverType: resolverType ?? this.resolverType,
    thumbnailUrl: thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
    yearGrouped: yearGrouped ?? this.yearGrouped,
  );
  SmartPlaylistEntity copyWithCompanion(SmartPlaylistsCompanion data) {
    return SmartPlaylistEntity(
      podcastId: data.podcastId.present ? data.podcastId.value : this.podcastId,
      playlistNumber: data.playlistNumber.present
          ? data.playlistNumber.value
          : this.playlistNumber,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      sortKey: data.sortKey.present ? data.sortKey.value : this.sortKey,
      resolverType: data.resolverType.present
          ? data.resolverType.value
          : this.resolverType,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      yearGrouped: data.yearGrouped.present
          ? data.yearGrouped.value
          : this.yearGrouped,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SmartPlaylistEntity(')
          ..write('podcastId: $podcastId, ')
          ..write('playlistNumber: $playlistNumber, ')
          ..write('displayName: $displayName, ')
          ..write('sortKey: $sortKey, ')
          ..write('resolverType: $resolverType, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('yearGrouped: $yearGrouped')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    podcastId,
    playlistNumber,
    displayName,
    sortKey,
    resolverType,
    thumbnailUrl,
    yearGrouped,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SmartPlaylistEntity &&
          other.podcastId == this.podcastId &&
          other.playlistNumber == this.playlistNumber &&
          other.displayName == this.displayName &&
          other.sortKey == this.sortKey &&
          other.resolverType == this.resolverType &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.yearGrouped == this.yearGrouped);
}

class SmartPlaylistsCompanion extends UpdateCompanion<SmartPlaylistEntity> {
  final Value<int> podcastId;
  final Value<int> playlistNumber;
  final Value<String> displayName;
  final Value<int> sortKey;
  final Value<String> resolverType;
  final Value<String?> thumbnailUrl;
  final Value<bool> yearGrouped;
  final Value<int> rowid;
  const SmartPlaylistsCompanion({
    this.podcastId = const Value.absent(),
    this.playlistNumber = const Value.absent(),
    this.displayName = const Value.absent(),
    this.sortKey = const Value.absent(),
    this.resolverType = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.yearGrouped = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SmartPlaylistsCompanion.insert({
    required int podcastId,
    required int playlistNumber,
    required String displayName,
    required int sortKey,
    required String resolverType,
    this.thumbnailUrl = const Value.absent(),
    this.yearGrouped = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : podcastId = Value(podcastId),
       playlistNumber = Value(playlistNumber),
       displayName = Value(displayName),
       sortKey = Value(sortKey),
       resolverType = Value(resolverType);
  static Insertable<SmartPlaylistEntity> custom({
    Expression<int>? podcastId,
    Expression<int>? playlistNumber,
    Expression<String>? displayName,
    Expression<int>? sortKey,
    Expression<String>? resolverType,
    Expression<String>? thumbnailUrl,
    Expression<bool>? yearGrouped,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (podcastId != null) 'podcast_id': podcastId,
      if (playlistNumber != null) 'season_number': playlistNumber,
      if (displayName != null) 'display_name': displayName,
      if (sortKey != null) 'sort_key': sortKey,
      if (resolverType != null) 'resolver_type': resolverType,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (yearGrouped != null) 'year_grouped': yearGrouped,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SmartPlaylistsCompanion copyWith({
    Value<int>? podcastId,
    Value<int>? playlistNumber,
    Value<String>? displayName,
    Value<int>? sortKey,
    Value<String>? resolverType,
    Value<String?>? thumbnailUrl,
    Value<bool>? yearGrouped,
    Value<int>? rowid,
  }) {
    return SmartPlaylistsCompanion(
      podcastId: podcastId ?? this.podcastId,
      playlistNumber: playlistNumber ?? this.playlistNumber,
      displayName: displayName ?? this.displayName,
      sortKey: sortKey ?? this.sortKey,
      resolverType: resolverType ?? this.resolverType,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      yearGrouped: yearGrouped ?? this.yearGrouped,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (podcastId.present) {
      map['podcast_id'] = Variable<int>(podcastId.value);
    }
    if (playlistNumber.present) {
      map['season_number'] = Variable<int>(playlistNumber.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (sortKey.present) {
      map['sort_key'] = Variable<int>(sortKey.value);
    }
    if (resolverType.present) {
      map['resolver_type'] = Variable<String>(resolverType.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (yearGrouped.present) {
      map['year_grouped'] = Variable<bool>(yearGrouped.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SmartPlaylistsCompanion(')
          ..write('podcastId: $podcastId, ')
          ..write('playlistNumber: $playlistNumber, ')
          ..write('displayName: $displayName, ')
          ..write('sortKey: $sortKey, ')
          ..write('resolverType: $resolverType, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('yearGrouped: $yearGrouped, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PodcastViewPreferencesTable extends PodcastViewPreferences
    with TableInfo<$PodcastViewPreferencesTable, PodcastViewPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PodcastViewPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _podcastIdMeta = const VerificationMeta(
    'podcastId',
  );
  @override
  late final GeneratedColumn<int> podcastId = GeneratedColumn<int>(
    'podcast_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES subscriptions (id)',
    ),
  );
  static const VerificationMeta _viewModeMeta = const VerificationMeta(
    'viewMode',
  );
  @override
  late final GeneratedColumn<String> viewMode = GeneratedColumn<String>(
    'view_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('episodes'),
  );
  static const VerificationMeta _episodeFilterMeta = const VerificationMeta(
    'episodeFilter',
  );
  @override
  late final GeneratedColumn<String> episodeFilter = GeneratedColumn<String>(
    'episode_filter',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('all'),
  );
  static const VerificationMeta _episodeSortOrderMeta = const VerificationMeta(
    'episodeSortOrder',
  );
  @override
  late final GeneratedColumn<String> episodeSortOrder = GeneratedColumn<String>(
    'episode_sort_order',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('desc'),
  );
  static const VerificationMeta _seasonSortFieldMeta = const VerificationMeta(
    'seasonSortField',
  );
  @override
  late final GeneratedColumn<String> seasonSortField = GeneratedColumn<String>(
    'season_sort_field',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('seasonNumber'),
  );
  static const VerificationMeta _seasonSortOrderMeta = const VerificationMeta(
    'seasonSortOrder',
  );
  @override
  late final GeneratedColumn<String> seasonSortOrder = GeneratedColumn<String>(
    'season_sort_order',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('desc'),
  );
  static const VerificationMeta _selectedPlaylistIdMeta =
      const VerificationMeta('selectedPlaylistId');
  @override
  late final GeneratedColumn<String> selectedPlaylistId =
      GeneratedColumn<String>(
        'selected_playlist_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    podcastId,
    viewMode,
    episodeFilter,
    episodeSortOrder,
    seasonSortField,
    seasonSortOrder,
    selectedPlaylistId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'podcast_view_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<PodcastViewPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('podcast_id')) {
      context.handle(
        _podcastIdMeta,
        podcastId.isAcceptableOrUnknown(data['podcast_id']!, _podcastIdMeta),
      );
    }
    if (data.containsKey('view_mode')) {
      context.handle(
        _viewModeMeta,
        viewMode.isAcceptableOrUnknown(data['view_mode']!, _viewModeMeta),
      );
    }
    if (data.containsKey('episode_filter')) {
      context.handle(
        _episodeFilterMeta,
        episodeFilter.isAcceptableOrUnknown(
          data['episode_filter']!,
          _episodeFilterMeta,
        ),
      );
    }
    if (data.containsKey('episode_sort_order')) {
      context.handle(
        _episodeSortOrderMeta,
        episodeSortOrder.isAcceptableOrUnknown(
          data['episode_sort_order']!,
          _episodeSortOrderMeta,
        ),
      );
    }
    if (data.containsKey('season_sort_field')) {
      context.handle(
        _seasonSortFieldMeta,
        seasonSortField.isAcceptableOrUnknown(
          data['season_sort_field']!,
          _seasonSortFieldMeta,
        ),
      );
    }
    if (data.containsKey('season_sort_order')) {
      context.handle(
        _seasonSortOrderMeta,
        seasonSortOrder.isAcceptableOrUnknown(
          data['season_sort_order']!,
          _seasonSortOrderMeta,
        ),
      );
    }
    if (data.containsKey('selected_playlist_id')) {
      context.handle(
        _selectedPlaylistIdMeta,
        selectedPlaylistId.isAcceptableOrUnknown(
          data['selected_playlist_id']!,
          _selectedPlaylistIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {podcastId};
  @override
  PodcastViewPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PodcastViewPreference(
      podcastId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}podcast_id'],
      )!,
      viewMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}view_mode'],
      )!,
      episodeFilter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}episode_filter'],
      )!,
      episodeSortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}episode_sort_order'],
      )!,
      seasonSortField: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}season_sort_field'],
      )!,
      seasonSortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}season_sort_order'],
      )!,
      selectedPlaylistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_playlist_id'],
      ),
    );
  }

  @override
  $PodcastViewPreferencesTable createAlias(String alias) {
    return $PodcastViewPreferencesTable(attachedDatabase, alias);
  }
}

class PodcastViewPreference extends DataClass
    implements Insertable<PodcastViewPreference> {
  /// Foreign key to Subscriptions table.
  final int podcastId;

  /// View mode: 'episodes' or 'seasons'.
  final String viewMode;

  /// Episode filter: 'all', 'unplayed', or 'inProgress'.
  final String episodeFilter;

  /// Episode sort order: 'asc' or 'desc'.
  final String episodeSortOrder;

  /// Season sort field: 'seasonNumber', 'newestEpisodeDate', 'progress', 'alphabetical'.
  final String seasonSortField;

  /// Season sort order: 'asc' or 'desc'.
  final String seasonSortOrder;

  /// Selected smart playlist ID for inline display.
  final String? selectedPlaylistId;
  const PodcastViewPreference({
    required this.podcastId,
    required this.viewMode,
    required this.episodeFilter,
    required this.episodeSortOrder,
    required this.seasonSortField,
    required this.seasonSortOrder,
    this.selectedPlaylistId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['podcast_id'] = Variable<int>(podcastId);
    map['view_mode'] = Variable<String>(viewMode);
    map['episode_filter'] = Variable<String>(episodeFilter);
    map['episode_sort_order'] = Variable<String>(episodeSortOrder);
    map['season_sort_field'] = Variable<String>(seasonSortField);
    map['season_sort_order'] = Variable<String>(seasonSortOrder);
    if (!nullToAbsent || selectedPlaylistId != null) {
      map['selected_playlist_id'] = Variable<String>(selectedPlaylistId);
    }
    return map;
  }

  PodcastViewPreferencesCompanion toCompanion(bool nullToAbsent) {
    return PodcastViewPreferencesCompanion(
      podcastId: Value(podcastId),
      viewMode: Value(viewMode),
      episodeFilter: Value(episodeFilter),
      episodeSortOrder: Value(episodeSortOrder),
      seasonSortField: Value(seasonSortField),
      seasonSortOrder: Value(seasonSortOrder),
      selectedPlaylistId: selectedPlaylistId == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedPlaylistId),
    );
  }

  factory PodcastViewPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PodcastViewPreference(
      podcastId: serializer.fromJson<int>(json['podcastId']),
      viewMode: serializer.fromJson<String>(json['viewMode']),
      episodeFilter: serializer.fromJson<String>(json['episodeFilter']),
      episodeSortOrder: serializer.fromJson<String>(json['episodeSortOrder']),
      seasonSortField: serializer.fromJson<String>(json['seasonSortField']),
      seasonSortOrder: serializer.fromJson<String>(json['seasonSortOrder']),
      selectedPlaylistId: serializer.fromJson<String?>(
        json['selectedPlaylistId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'podcastId': serializer.toJson<int>(podcastId),
      'viewMode': serializer.toJson<String>(viewMode),
      'episodeFilter': serializer.toJson<String>(episodeFilter),
      'episodeSortOrder': serializer.toJson<String>(episodeSortOrder),
      'seasonSortField': serializer.toJson<String>(seasonSortField),
      'seasonSortOrder': serializer.toJson<String>(seasonSortOrder),
      'selectedPlaylistId': serializer.toJson<String?>(selectedPlaylistId),
    };
  }

  PodcastViewPreference copyWith({
    int? podcastId,
    String? viewMode,
    String? episodeFilter,
    String? episodeSortOrder,
    String? seasonSortField,
    String? seasonSortOrder,
    Value<String?> selectedPlaylistId = const Value.absent(),
  }) => PodcastViewPreference(
    podcastId: podcastId ?? this.podcastId,
    viewMode: viewMode ?? this.viewMode,
    episodeFilter: episodeFilter ?? this.episodeFilter,
    episodeSortOrder: episodeSortOrder ?? this.episodeSortOrder,
    seasonSortField: seasonSortField ?? this.seasonSortField,
    seasonSortOrder: seasonSortOrder ?? this.seasonSortOrder,
    selectedPlaylistId: selectedPlaylistId.present
        ? selectedPlaylistId.value
        : this.selectedPlaylistId,
  );
  PodcastViewPreference copyWithCompanion(
    PodcastViewPreferencesCompanion data,
  ) {
    return PodcastViewPreference(
      podcastId: data.podcastId.present ? data.podcastId.value : this.podcastId,
      viewMode: data.viewMode.present ? data.viewMode.value : this.viewMode,
      episodeFilter: data.episodeFilter.present
          ? data.episodeFilter.value
          : this.episodeFilter,
      episodeSortOrder: data.episodeSortOrder.present
          ? data.episodeSortOrder.value
          : this.episodeSortOrder,
      seasonSortField: data.seasonSortField.present
          ? data.seasonSortField.value
          : this.seasonSortField,
      seasonSortOrder: data.seasonSortOrder.present
          ? data.seasonSortOrder.value
          : this.seasonSortOrder,
      selectedPlaylistId: data.selectedPlaylistId.present
          ? data.selectedPlaylistId.value
          : this.selectedPlaylistId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PodcastViewPreference(')
          ..write('podcastId: $podcastId, ')
          ..write('viewMode: $viewMode, ')
          ..write('episodeFilter: $episodeFilter, ')
          ..write('episodeSortOrder: $episodeSortOrder, ')
          ..write('seasonSortField: $seasonSortField, ')
          ..write('seasonSortOrder: $seasonSortOrder, ')
          ..write('selectedPlaylistId: $selectedPlaylistId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    podcastId,
    viewMode,
    episodeFilter,
    episodeSortOrder,
    seasonSortField,
    seasonSortOrder,
    selectedPlaylistId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PodcastViewPreference &&
          other.podcastId == this.podcastId &&
          other.viewMode == this.viewMode &&
          other.episodeFilter == this.episodeFilter &&
          other.episodeSortOrder == this.episodeSortOrder &&
          other.seasonSortField == this.seasonSortField &&
          other.seasonSortOrder == this.seasonSortOrder &&
          other.selectedPlaylistId == this.selectedPlaylistId);
}

class PodcastViewPreferencesCompanion
    extends UpdateCompanion<PodcastViewPreference> {
  final Value<int> podcastId;
  final Value<String> viewMode;
  final Value<String> episodeFilter;
  final Value<String> episodeSortOrder;
  final Value<String> seasonSortField;
  final Value<String> seasonSortOrder;
  final Value<String?> selectedPlaylistId;
  const PodcastViewPreferencesCompanion({
    this.podcastId = const Value.absent(),
    this.viewMode = const Value.absent(),
    this.episodeFilter = const Value.absent(),
    this.episodeSortOrder = const Value.absent(),
    this.seasonSortField = const Value.absent(),
    this.seasonSortOrder = const Value.absent(),
    this.selectedPlaylistId = const Value.absent(),
  });
  PodcastViewPreferencesCompanion.insert({
    this.podcastId = const Value.absent(),
    this.viewMode = const Value.absent(),
    this.episodeFilter = const Value.absent(),
    this.episodeSortOrder = const Value.absent(),
    this.seasonSortField = const Value.absent(),
    this.seasonSortOrder = const Value.absent(),
    this.selectedPlaylistId = const Value.absent(),
  });
  static Insertable<PodcastViewPreference> custom({
    Expression<int>? podcastId,
    Expression<String>? viewMode,
    Expression<String>? episodeFilter,
    Expression<String>? episodeSortOrder,
    Expression<String>? seasonSortField,
    Expression<String>? seasonSortOrder,
    Expression<String>? selectedPlaylistId,
  }) {
    return RawValuesInsertable({
      if (podcastId != null) 'podcast_id': podcastId,
      if (viewMode != null) 'view_mode': viewMode,
      if (episodeFilter != null) 'episode_filter': episodeFilter,
      if (episodeSortOrder != null) 'episode_sort_order': episodeSortOrder,
      if (seasonSortField != null) 'season_sort_field': seasonSortField,
      if (seasonSortOrder != null) 'season_sort_order': seasonSortOrder,
      if (selectedPlaylistId != null)
        'selected_playlist_id': selectedPlaylistId,
    });
  }

  PodcastViewPreferencesCompanion copyWith({
    Value<int>? podcastId,
    Value<String>? viewMode,
    Value<String>? episodeFilter,
    Value<String>? episodeSortOrder,
    Value<String>? seasonSortField,
    Value<String>? seasonSortOrder,
    Value<String?>? selectedPlaylistId,
  }) {
    return PodcastViewPreferencesCompanion(
      podcastId: podcastId ?? this.podcastId,
      viewMode: viewMode ?? this.viewMode,
      episodeFilter: episodeFilter ?? this.episodeFilter,
      episodeSortOrder: episodeSortOrder ?? this.episodeSortOrder,
      seasonSortField: seasonSortField ?? this.seasonSortField,
      seasonSortOrder: seasonSortOrder ?? this.seasonSortOrder,
      selectedPlaylistId: selectedPlaylistId ?? this.selectedPlaylistId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (podcastId.present) {
      map['podcast_id'] = Variable<int>(podcastId.value);
    }
    if (viewMode.present) {
      map['view_mode'] = Variable<String>(viewMode.value);
    }
    if (episodeFilter.present) {
      map['episode_filter'] = Variable<String>(episodeFilter.value);
    }
    if (episodeSortOrder.present) {
      map['episode_sort_order'] = Variable<String>(episodeSortOrder.value);
    }
    if (seasonSortField.present) {
      map['season_sort_field'] = Variable<String>(seasonSortField.value);
    }
    if (seasonSortOrder.present) {
      map['season_sort_order'] = Variable<String>(seasonSortOrder.value);
    }
    if (selectedPlaylistId.present) {
      map['selected_playlist_id'] = Variable<String>(selectedPlaylistId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PodcastViewPreferencesCompanion(')
          ..write('podcastId: $podcastId, ')
          ..write('viewMode: $viewMode, ')
          ..write('episodeFilter: $episodeFilter, ')
          ..write('episodeSortOrder: $episodeSortOrder, ')
          ..write('seasonSortField: $seasonSortField, ')
          ..write('seasonSortOrder: $seasonSortOrder, ')
          ..write('selectedPlaylistId: $selectedPlaylistId')
          ..write(')'))
        .toString();
  }
}

class $DownloadTasksTable extends DownloadTasks
    with TableInfo<$DownloadTasksTable, DownloadTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _episodeIdMeta = const VerificationMeta(
    'episodeId',
  );
  @override
  late final GeneratedColumn<int> episodeId = GeneratedColumn<int>(
    'episode_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES episodes (id)',
    ),
  );
  static const VerificationMeta _audioUrlMeta = const VerificationMeta(
    'audioUrl',
  );
  @override
  late final GeneratedColumn<String> audioUrl = GeneratedColumn<String>(
    'audio_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalBytesMeta = const VerificationMeta(
    'totalBytes',
  );
  @override
  late final GeneratedColumn<int> totalBytes = GeneratedColumn<int>(
    'total_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _downloadedBytesMeta = const VerificationMeta(
    'downloadedBytes',
  );
  @override
  late final GeneratedColumn<int> downloadedBytes = GeneratedColumn<int>(
    'downloaded_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _wifiOnlyMeta = const VerificationMeta(
    'wifiOnly',
  );
  @override
  late final GeneratedColumn<bool> wifiOnly = GeneratedColumn<bool>(
    'wifi_only',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("wifi_only" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    episodeId,
    audioUrl,
    localPath,
    totalBytes,
    downloadedBytes,
    status,
    wifiOnly,
    retryCount,
    lastError,
    createdAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadTask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('episode_id')) {
      context.handle(
        _episodeIdMeta,
        episodeId.isAcceptableOrUnknown(data['episode_id']!, _episodeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_episodeIdMeta);
    }
    if (data.containsKey('audio_url')) {
      context.handle(
        _audioUrlMeta,
        audioUrl.isAcceptableOrUnknown(data['audio_url']!, _audioUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_audioUrlMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    if (data.containsKey('total_bytes')) {
      context.handle(
        _totalBytesMeta,
        totalBytes.isAcceptableOrUnknown(data['total_bytes']!, _totalBytesMeta),
      );
    }
    if (data.containsKey('downloaded_bytes')) {
      context.handle(
        _downloadedBytesMeta,
        downloadedBytes.isAcceptableOrUnknown(
          data['downloaded_bytes']!,
          _downloadedBytesMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('wifi_only')) {
      context.handle(
        _wifiOnlyMeta,
        wifiOnly.isAcceptableOrUnknown(data['wifi_only']!, _wifiOnlyMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {episodeId},
  ];
  @override
  DownloadTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadTask(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      episodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode_id'],
      )!,
      audioUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_url'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
      totalBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_bytes'],
      ),
      downloadedBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}downloaded_bytes'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      wifiOnly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}wifi_only'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $DownloadTasksTable createAlias(String alias) {
    return $DownloadTasksTable(attachedDatabase, alias);
  }
}

class DownloadTask extends DataClass implements Insertable<DownloadTask> {
  /// Auto-incrementing primary key.
  final int id;

  /// Foreign key to Episodes table.
  final int episodeId;

  /// Original audio URL (cached for offline reference).
  final String audioUrl;

  /// Local file path when download completes.
  final String? localPath;

  /// Total file size in bytes (from Content-Length header).
  final int? totalBytes;

  /// Bytes downloaded so far.
  final int downloadedBytes;

  /// Download status (stored as int, see [DownloadStatus]).
  final int status;

  /// Whether to only download on WiFi.
  final bool wifiOnly;

  /// Number of retry attempts.
  final int retryCount;

  /// Last error message for debugging.
  final String? lastError;

  /// When the download was requested.
  final DateTime createdAt;

  /// When the download completed successfully.
  final DateTime? completedAt;
  const DownloadTask({
    required this.id,
    required this.episodeId,
    required this.audioUrl,
    this.localPath,
    this.totalBytes,
    required this.downloadedBytes,
    required this.status,
    required this.wifiOnly,
    required this.retryCount,
    this.lastError,
    required this.createdAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['episode_id'] = Variable<int>(episodeId);
    map['audio_url'] = Variable<String>(audioUrl);
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    if (!nullToAbsent || totalBytes != null) {
      map['total_bytes'] = Variable<int>(totalBytes);
    }
    map['downloaded_bytes'] = Variable<int>(downloadedBytes);
    map['status'] = Variable<int>(status);
    map['wifi_only'] = Variable<bool>(wifiOnly);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  DownloadTasksCompanion toCompanion(bool nullToAbsent) {
    return DownloadTasksCompanion(
      id: Value(id),
      episodeId: Value(episodeId),
      audioUrl: Value(audioUrl),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      totalBytes: totalBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(totalBytes),
      downloadedBytes: Value(downloadedBytes),
      status: Value(status),
      wifiOnly: Value(wifiOnly),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory DownloadTask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadTask(
      id: serializer.fromJson<int>(json['id']),
      episodeId: serializer.fromJson<int>(json['episodeId']),
      audioUrl: serializer.fromJson<String>(json['audioUrl']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      totalBytes: serializer.fromJson<int?>(json['totalBytes']),
      downloadedBytes: serializer.fromJson<int>(json['downloadedBytes']),
      status: serializer.fromJson<int>(json['status']),
      wifiOnly: serializer.fromJson<bool>(json['wifiOnly']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'episodeId': serializer.toJson<int>(episodeId),
      'audioUrl': serializer.toJson<String>(audioUrl),
      'localPath': serializer.toJson<String?>(localPath),
      'totalBytes': serializer.toJson<int?>(totalBytes),
      'downloadedBytes': serializer.toJson<int>(downloadedBytes),
      'status': serializer.toJson<int>(status),
      'wifiOnly': serializer.toJson<bool>(wifiOnly),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  DownloadTask copyWith({
    int? id,
    int? episodeId,
    String? audioUrl,
    Value<String?> localPath = const Value.absent(),
    Value<int?> totalBytes = const Value.absent(),
    int? downloadedBytes,
    int? status,
    bool? wifiOnly,
    int? retryCount,
    Value<String?> lastError = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => DownloadTask(
    id: id ?? this.id,
    episodeId: episodeId ?? this.episodeId,
    audioUrl: audioUrl ?? this.audioUrl,
    localPath: localPath.present ? localPath.value : this.localPath,
    totalBytes: totalBytes.present ? totalBytes.value : this.totalBytes,
    downloadedBytes: downloadedBytes ?? this.downloadedBytes,
    status: status ?? this.status,
    wifiOnly: wifiOnly ?? this.wifiOnly,
    retryCount: retryCount ?? this.retryCount,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  DownloadTask copyWithCompanion(DownloadTasksCompanion data) {
    return DownloadTask(
      id: data.id.present ? data.id.value : this.id,
      episodeId: data.episodeId.present ? data.episodeId.value : this.episodeId,
      audioUrl: data.audioUrl.present ? data.audioUrl.value : this.audioUrl,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      totalBytes: data.totalBytes.present
          ? data.totalBytes.value
          : this.totalBytes,
      downloadedBytes: data.downloadedBytes.present
          ? data.downloadedBytes.value
          : this.downloadedBytes,
      status: data.status.present ? data.status.value : this.status,
      wifiOnly: data.wifiOnly.present ? data.wifiOnly.value : this.wifiOnly,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadTask(')
          ..write('id: $id, ')
          ..write('episodeId: $episodeId, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('localPath: $localPath, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('downloadedBytes: $downloadedBytes, ')
          ..write('status: $status, ')
          ..write('wifiOnly: $wifiOnly, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    episodeId,
    audioUrl,
    localPath,
    totalBytes,
    downloadedBytes,
    status,
    wifiOnly,
    retryCount,
    lastError,
    createdAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadTask &&
          other.id == this.id &&
          other.episodeId == this.episodeId &&
          other.audioUrl == this.audioUrl &&
          other.localPath == this.localPath &&
          other.totalBytes == this.totalBytes &&
          other.downloadedBytes == this.downloadedBytes &&
          other.status == this.status &&
          other.wifiOnly == this.wifiOnly &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt);
}

class DownloadTasksCompanion extends UpdateCompanion<DownloadTask> {
  final Value<int> id;
  final Value<int> episodeId;
  final Value<String> audioUrl;
  final Value<String?> localPath;
  final Value<int?> totalBytes;
  final Value<int> downloadedBytes;
  final Value<int> status;
  final Value<bool> wifiOnly;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  const DownloadTasksCompanion({
    this.id = const Value.absent(),
    this.episodeId = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.localPath = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.downloadedBytes = const Value.absent(),
    this.status = const Value.absent(),
    this.wifiOnly = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  DownloadTasksCompanion.insert({
    this.id = const Value.absent(),
    required int episodeId,
    required String audioUrl,
    this.localPath = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.downloadedBytes = const Value.absent(),
    this.status = const Value.absent(),
    this.wifiOnly = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
  }) : episodeId = Value(episodeId),
       audioUrl = Value(audioUrl),
       createdAt = Value(createdAt);
  static Insertable<DownloadTask> custom({
    Expression<int>? id,
    Expression<int>? episodeId,
    Expression<String>? audioUrl,
    Expression<String>? localPath,
    Expression<int>? totalBytes,
    Expression<int>? downloadedBytes,
    Expression<int>? status,
    Expression<bool>? wifiOnly,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (episodeId != null) 'episode_id': episodeId,
      if (audioUrl != null) 'audio_url': audioUrl,
      if (localPath != null) 'local_path': localPath,
      if (totalBytes != null) 'total_bytes': totalBytes,
      if (downloadedBytes != null) 'downloaded_bytes': downloadedBytes,
      if (status != null) 'status': status,
      if (wifiOnly != null) 'wifi_only': wifiOnly,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  DownloadTasksCompanion copyWith({
    Value<int>? id,
    Value<int>? episodeId,
    Value<String>? audioUrl,
    Value<String?>? localPath,
    Value<int?>? totalBytes,
    Value<int>? downloadedBytes,
    Value<int>? status,
    Value<bool>? wifiOnly,
    Value<int>? retryCount,
    Value<String?>? lastError,
    Value<DateTime>? createdAt,
    Value<DateTime?>? completedAt,
  }) {
    return DownloadTasksCompanion(
      id: id ?? this.id,
      episodeId: episodeId ?? this.episodeId,
      audioUrl: audioUrl ?? this.audioUrl,
      localPath: localPath ?? this.localPath,
      totalBytes: totalBytes ?? this.totalBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      status: status ?? this.status,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (episodeId.present) {
      map['episode_id'] = Variable<int>(episodeId.value);
    }
    if (audioUrl.present) {
      map['audio_url'] = Variable<String>(audioUrl.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (totalBytes.present) {
      map['total_bytes'] = Variable<int>(totalBytes.value);
    }
    if (downloadedBytes.present) {
      map['downloaded_bytes'] = Variable<int>(downloadedBytes.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (wifiOnly.present) {
      map['wifi_only'] = Variable<bool>(wifiOnly.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadTasksCompanion(')
          ..write('id: $id, ')
          ..write('episodeId: $episodeId, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('localPath: $localPath, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('downloadedBytes: $downloadedBytes, ')
          ..write('status: $status, ')
          ..write('wifiOnly: $wifiOnly, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

class $QueueItemsTable extends QueueItems
    with TableInfo<$QueueItemsTable, QueueItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueueItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _episodeIdMeta = const VerificationMeta(
    'episodeId',
  );
  @override
  late final GeneratedColumn<int> episodeId = GeneratedColumn<int>(
    'episode_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES episodes (id)',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isAdhocMeta = const VerificationMeta(
    'isAdhoc',
  );
  @override
  late final GeneratedColumn<bool> isAdhoc = GeneratedColumn<bool>(
    'is_adhoc',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_adhoc" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sourceContextMeta = const VerificationMeta(
    'sourceContext',
  );
  @override
  late final GeneratedColumn<String> sourceContext = GeneratedColumn<String>(
    'source_context',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    episodeId,
    position,
    isAdhoc,
    sourceContext,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'queue_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<QueueItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('episode_id')) {
      context.handle(
        _episodeIdMeta,
        episodeId.isAcceptableOrUnknown(data['episode_id']!, _episodeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_episodeIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('is_adhoc')) {
      context.handle(
        _isAdhocMeta,
        isAdhoc.isAcceptableOrUnknown(data['is_adhoc']!, _isAdhocMeta),
      );
    }
    if (data.containsKey('source_context')) {
      context.handle(
        _sourceContextMeta,
        sourceContext.isAcceptableOrUnknown(
          data['source_context']!,
          _sourceContextMeta,
        ),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QueueItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueueItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      episodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      isAdhoc: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_adhoc'],
      )!,
      sourceContext: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_context'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $QueueItemsTable createAlias(String alias) {
    return $QueueItemsTable(attachedDatabase, alias);
  }
}

class QueueItem extends DataClass implements Insertable<QueueItem> {
  /// Auto-incrementing primary key.
  final int id;

  /// Reference to the episode in the queue.
  final int episodeId;

  /// Position in the queue (sparse values: 0, 10, 20... for easy insertion).
  final int position;

  /// Whether this is an adhoc queue item (true) or manual (false).
  final bool isAdhoc;

  /// Source context for adhoc items (e.g., "Season 2").
  final String? sourceContext;

  /// When this item was added to the queue.
  final DateTime addedAt;
  const QueueItem({
    required this.id,
    required this.episodeId,
    required this.position,
    required this.isAdhoc,
    this.sourceContext,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['episode_id'] = Variable<int>(episodeId);
    map['position'] = Variable<int>(position);
    map['is_adhoc'] = Variable<bool>(isAdhoc);
    if (!nullToAbsent || sourceContext != null) {
      map['source_context'] = Variable<String>(sourceContext);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  QueueItemsCompanion toCompanion(bool nullToAbsent) {
    return QueueItemsCompanion(
      id: Value(id),
      episodeId: Value(episodeId),
      position: Value(position),
      isAdhoc: Value(isAdhoc),
      sourceContext: sourceContext == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceContext),
      addedAt: Value(addedAt),
    );
  }

  factory QueueItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueueItem(
      id: serializer.fromJson<int>(json['id']),
      episodeId: serializer.fromJson<int>(json['episodeId']),
      position: serializer.fromJson<int>(json['position']),
      isAdhoc: serializer.fromJson<bool>(json['isAdhoc']),
      sourceContext: serializer.fromJson<String?>(json['sourceContext']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'episodeId': serializer.toJson<int>(episodeId),
      'position': serializer.toJson<int>(position),
      'isAdhoc': serializer.toJson<bool>(isAdhoc),
      'sourceContext': serializer.toJson<String?>(sourceContext),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  QueueItem copyWith({
    int? id,
    int? episodeId,
    int? position,
    bool? isAdhoc,
    Value<String?> sourceContext = const Value.absent(),
    DateTime? addedAt,
  }) => QueueItem(
    id: id ?? this.id,
    episodeId: episodeId ?? this.episodeId,
    position: position ?? this.position,
    isAdhoc: isAdhoc ?? this.isAdhoc,
    sourceContext: sourceContext.present
        ? sourceContext.value
        : this.sourceContext,
    addedAt: addedAt ?? this.addedAt,
  );
  QueueItem copyWithCompanion(QueueItemsCompanion data) {
    return QueueItem(
      id: data.id.present ? data.id.value : this.id,
      episodeId: data.episodeId.present ? data.episodeId.value : this.episodeId,
      position: data.position.present ? data.position.value : this.position,
      isAdhoc: data.isAdhoc.present ? data.isAdhoc.value : this.isAdhoc,
      sourceContext: data.sourceContext.present
          ? data.sourceContext.value
          : this.sourceContext,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueueItem(')
          ..write('id: $id, ')
          ..write('episodeId: $episodeId, ')
          ..write('position: $position, ')
          ..write('isAdhoc: $isAdhoc, ')
          ..write('sourceContext: $sourceContext, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, episodeId, position, isAdhoc, sourceContext, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueueItem &&
          other.id == this.id &&
          other.episodeId == this.episodeId &&
          other.position == this.position &&
          other.isAdhoc == this.isAdhoc &&
          other.sourceContext == this.sourceContext &&
          other.addedAt == this.addedAt);
}

class QueueItemsCompanion extends UpdateCompanion<QueueItem> {
  final Value<int> id;
  final Value<int> episodeId;
  final Value<int> position;
  final Value<bool> isAdhoc;
  final Value<String?> sourceContext;
  final Value<DateTime> addedAt;
  const QueueItemsCompanion({
    this.id = const Value.absent(),
    this.episodeId = const Value.absent(),
    this.position = const Value.absent(),
    this.isAdhoc = const Value.absent(),
    this.sourceContext = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  QueueItemsCompanion.insert({
    this.id = const Value.absent(),
    required int episodeId,
    required int position,
    this.isAdhoc = const Value.absent(),
    this.sourceContext = const Value.absent(),
    required DateTime addedAt,
  }) : episodeId = Value(episodeId),
       position = Value(position),
       addedAt = Value(addedAt);
  static Insertable<QueueItem> custom({
    Expression<int>? id,
    Expression<int>? episodeId,
    Expression<int>? position,
    Expression<bool>? isAdhoc,
    Expression<String>? sourceContext,
    Expression<DateTime>? addedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (episodeId != null) 'episode_id': episodeId,
      if (position != null) 'position': position,
      if (isAdhoc != null) 'is_adhoc': isAdhoc,
      if (sourceContext != null) 'source_context': sourceContext,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  QueueItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? episodeId,
    Value<int>? position,
    Value<bool>? isAdhoc,
    Value<String?>? sourceContext,
    Value<DateTime>? addedAt,
  }) {
    return QueueItemsCompanion(
      id: id ?? this.id,
      episodeId: episodeId ?? this.episodeId,
      position: position ?? this.position,
      isAdhoc: isAdhoc ?? this.isAdhoc,
      sourceContext: sourceContext ?? this.sourceContext,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (episodeId.present) {
      map['episode_id'] = Variable<int>(episodeId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (isAdhoc.present) {
      map['is_adhoc'] = Variable<bool>(isAdhoc.value);
    }
    if (sourceContext.present) {
      map['source_context'] = Variable<String>(sourceContext.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueueItemsCompanion(')
          ..write('id: $id, ')
          ..write('episodeId: $episodeId, ')
          ..write('position: $position, ')
          ..write('isAdhoc: $isAdhoc, ')
          ..write('sourceContext: $sourceContext, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SubscriptionsTable subscriptions = $SubscriptionsTable(this);
  late final $EpisodesTable episodes = $EpisodesTable(this);
  late final $PlaybackHistoriesTable playbackHistories =
      $PlaybackHistoriesTable(this);
  late final $SmartPlaylistsTable smartPlaylists = $SmartPlaylistsTable(this);
  late final $PodcastViewPreferencesTable podcastViewPreferences =
      $PodcastViewPreferencesTable(this);
  late final $DownloadTasksTable downloadTasks = $DownloadTasksTable(this);
  late final $QueueItemsTable queueItems = $QueueItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    subscriptions,
    episodes,
    playbackHistories,
    smartPlaylists,
    podcastViewPreferences,
    downloadTasks,
    queueItems,
  ];
}

typedef $$SubscriptionsTableCreateCompanionBuilder =
    SubscriptionsCompanion Function({
      Value<int> id,
      required String itunesId,
      required String feedUrl,
      required String title,
      required String artistName,
      Value<String?> artworkUrl,
      Value<String?> description,
      Value<String> genres,
      Value<bool> explicit,
      required DateTime subscribedAt,
      Value<DateTime?> lastRefreshedAt,
    });
typedef $$SubscriptionsTableUpdateCompanionBuilder =
    SubscriptionsCompanion Function({
      Value<int> id,
      Value<String> itunesId,
      Value<String> feedUrl,
      Value<String> title,
      Value<String> artistName,
      Value<String?> artworkUrl,
      Value<String?> description,
      Value<String> genres,
      Value<bool> explicit,
      Value<DateTime> subscribedAt,
      Value<DateTime?> lastRefreshedAt,
    });

final class $$SubscriptionsTableReferences
    extends BaseReferences<_$AppDatabase, $SubscriptionsTable, Subscription> {
  $$SubscriptionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$EpisodesTable, List<Episode>> _episodesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.episodes,
    aliasName: $_aliasNameGenerator(db.subscriptions.id, db.episodes.podcastId),
  );

  $$EpisodesTableProcessedTableManager get episodesRefs {
    final manager = $$EpisodesTableTableManager(
      $_db,
      $_db.episodes,
    ).filter((f) => f.podcastId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_episodesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SmartPlaylistsTable, List<SmartPlaylistEntity>>
  _smartPlaylistsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.smartPlaylists,
    aliasName: $_aliasNameGenerator(
      db.subscriptions.id,
      db.smartPlaylists.podcastId,
    ),
  );

  $$SmartPlaylistsTableProcessedTableManager get smartPlaylistsRefs {
    final manager = $$SmartPlaylistsTableTableManager(
      $_db,
      $_db.smartPlaylists,
    ).filter((f) => f.podcastId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_smartPlaylistsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $PodcastViewPreferencesTable,
    List<PodcastViewPreference>
  >
  _podcastViewPreferencesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.podcastViewPreferences,
        aliasName: $_aliasNameGenerator(
          db.subscriptions.id,
          db.podcastViewPreferences.podcastId,
        ),
      );

  $$PodcastViewPreferencesTableProcessedTableManager
  get podcastViewPreferencesRefs {
    final manager = $$PodcastViewPreferencesTableTableManager(
      $_db,
      $_db.podcastViewPreferences,
    ).filter((f) => f.podcastId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _podcastViewPreferencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SubscriptionsTableFilterComposer
    extends Composer<_$AppDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itunesId => $composableBuilder(
    column: $table.itunesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedUrl => $composableBuilder(
    column: $table.feedUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistName => $composableBuilder(
    column: $table.artistName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genres => $composableBuilder(
    column: $table.genres,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get explicit => $composableBuilder(
    column: $table.explicit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get subscribedAt => $composableBuilder(
    column: $table.subscribedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastRefreshedAt => $composableBuilder(
    column: $table.lastRefreshedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> episodesRefs(
    Expression<bool> Function($$EpisodesTableFilterComposer f) f,
  ) {
    final $$EpisodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.podcastId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableFilterComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> smartPlaylistsRefs(
    Expression<bool> Function($$SmartPlaylistsTableFilterComposer f) f,
  ) {
    final $$SmartPlaylistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.smartPlaylists,
      getReferencedColumn: (t) => t.podcastId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SmartPlaylistsTableFilterComposer(
            $db: $db,
            $table: $db.smartPlaylists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> podcastViewPreferencesRefs(
    Expression<bool> Function($$PodcastViewPreferencesTableFilterComposer f) f,
  ) {
    final $$PodcastViewPreferencesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.podcastViewPreferences,
          getReferencedColumn: (t) => t.podcastId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PodcastViewPreferencesTableFilterComposer(
                $db: $db,
                $table: $db.podcastViewPreferences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SubscriptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itunesId => $composableBuilder(
    column: $table.itunesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedUrl => $composableBuilder(
    column: $table.feedUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistName => $composableBuilder(
    column: $table.artistName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genres => $composableBuilder(
    column: $table.genres,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get explicit => $composableBuilder(
    column: $table.explicit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get subscribedAt => $composableBuilder(
    column: $table.subscribedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastRefreshedAt => $composableBuilder(
    column: $table.lastRefreshedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubscriptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itunesId =>
      $composableBuilder(column: $table.itunesId, builder: (column) => column);

  GeneratedColumn<String> get feedUrl =>
      $composableBuilder(column: $table.feedUrl, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artistName => $composableBuilder(
    column: $table.artistName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get genres =>
      $composableBuilder(column: $table.genres, builder: (column) => column);

  GeneratedColumn<bool> get explicit =>
      $composableBuilder(column: $table.explicit, builder: (column) => column);

  GeneratedColumn<DateTime> get subscribedAt => $composableBuilder(
    column: $table.subscribedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastRefreshedAt => $composableBuilder(
    column: $table.lastRefreshedAt,
    builder: (column) => column,
  );

  Expression<T> episodesRefs<T extends Object>(
    Expression<T> Function($$EpisodesTableAnnotationComposer a) f,
  ) {
    final $$EpisodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.podcastId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableAnnotationComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> smartPlaylistsRefs<T extends Object>(
    Expression<T> Function($$SmartPlaylistsTableAnnotationComposer a) f,
  ) {
    final $$SmartPlaylistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.smartPlaylists,
      getReferencedColumn: (t) => t.podcastId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SmartPlaylistsTableAnnotationComposer(
            $db: $db,
            $table: $db.smartPlaylists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> podcastViewPreferencesRefs<T extends Object>(
    Expression<T> Function($$PodcastViewPreferencesTableAnnotationComposer a) f,
  ) {
    final $$PodcastViewPreferencesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.podcastViewPreferences,
          getReferencedColumn: (t) => t.podcastId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PodcastViewPreferencesTableAnnotationComposer(
                $db: $db,
                $table: $db.podcastViewPreferences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SubscriptionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubscriptionsTable,
          Subscription,
          $$SubscriptionsTableFilterComposer,
          $$SubscriptionsTableOrderingComposer,
          $$SubscriptionsTableAnnotationComposer,
          $$SubscriptionsTableCreateCompanionBuilder,
          $$SubscriptionsTableUpdateCompanionBuilder,
          (Subscription, $$SubscriptionsTableReferences),
          Subscription,
          PrefetchHooks Function({
            bool episodesRefs,
            bool smartPlaylistsRefs,
            bool podcastViewPreferencesRefs,
          })
        > {
  $$SubscriptionsTableTableManager(_$AppDatabase db, $SubscriptionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubscriptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubscriptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubscriptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> itunesId = const Value.absent(),
                Value<String> feedUrl = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> artistName = const Value.absent(),
                Value<String?> artworkUrl = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> genres = const Value.absent(),
                Value<bool> explicit = const Value.absent(),
                Value<DateTime> subscribedAt = const Value.absent(),
                Value<DateTime?> lastRefreshedAt = const Value.absent(),
              }) => SubscriptionsCompanion(
                id: id,
                itunesId: itunesId,
                feedUrl: feedUrl,
                title: title,
                artistName: artistName,
                artworkUrl: artworkUrl,
                description: description,
                genres: genres,
                explicit: explicit,
                subscribedAt: subscribedAt,
                lastRefreshedAt: lastRefreshedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String itunesId,
                required String feedUrl,
                required String title,
                required String artistName,
                Value<String?> artworkUrl = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> genres = const Value.absent(),
                Value<bool> explicit = const Value.absent(),
                required DateTime subscribedAt,
                Value<DateTime?> lastRefreshedAt = const Value.absent(),
              }) => SubscriptionsCompanion.insert(
                id: id,
                itunesId: itunesId,
                feedUrl: feedUrl,
                title: title,
                artistName: artistName,
                artworkUrl: artworkUrl,
                description: description,
                genres: genres,
                explicit: explicit,
                subscribedAt: subscribedAt,
                lastRefreshedAt: lastRefreshedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SubscriptionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                episodesRefs = false,
                smartPlaylistsRefs = false,
                podcastViewPreferencesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (episodesRefs) db.episodes,
                    if (smartPlaylistsRefs) db.smartPlaylists,
                    if (podcastViewPreferencesRefs) db.podcastViewPreferences,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (episodesRefs)
                        await $_getPrefetchedData<
                          Subscription,
                          $SubscriptionsTable,
                          Episode
                        >(
                          currentTable: table,
                          referencedTable: $$SubscriptionsTableReferences
                              ._episodesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SubscriptionsTableReferences(
                                db,
                                table,
                                p0,
                              ).episodesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.podcastId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (smartPlaylistsRefs)
                        await $_getPrefetchedData<
                          Subscription,
                          $SubscriptionsTable,
                          SmartPlaylistEntity
                        >(
                          currentTable: table,
                          referencedTable: $$SubscriptionsTableReferences
                              ._smartPlaylistsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SubscriptionsTableReferences(
                                db,
                                table,
                                p0,
                              ).smartPlaylistsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.podcastId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (podcastViewPreferencesRefs)
                        await $_getPrefetchedData<
                          Subscription,
                          $SubscriptionsTable,
                          PodcastViewPreference
                        >(
                          currentTable: table,
                          referencedTable: $$SubscriptionsTableReferences
                              ._podcastViewPreferencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SubscriptionsTableReferences(
                                db,
                                table,
                                p0,
                              ).podcastViewPreferencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.podcastId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SubscriptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubscriptionsTable,
      Subscription,
      $$SubscriptionsTableFilterComposer,
      $$SubscriptionsTableOrderingComposer,
      $$SubscriptionsTableAnnotationComposer,
      $$SubscriptionsTableCreateCompanionBuilder,
      $$SubscriptionsTableUpdateCompanionBuilder,
      (Subscription, $$SubscriptionsTableReferences),
      Subscription,
      PrefetchHooks Function({
        bool episodesRefs,
        bool smartPlaylistsRefs,
        bool podcastViewPreferencesRefs,
      })
    >;
typedef $$EpisodesTableCreateCompanionBuilder =
    EpisodesCompanion Function({
      Value<int> id,
      required int podcastId,
      required String guid,
      required String title,
      Value<String?> description,
      required String audioUrl,
      Value<int?> durationMs,
      Value<DateTime?> publishedAt,
      Value<String?> imageUrl,
      Value<int?> episodeNumber,
      Value<int?> seasonNumber,
    });
typedef $$EpisodesTableUpdateCompanionBuilder =
    EpisodesCompanion Function({
      Value<int> id,
      Value<int> podcastId,
      Value<String> guid,
      Value<String> title,
      Value<String?> description,
      Value<String> audioUrl,
      Value<int?> durationMs,
      Value<DateTime?> publishedAt,
      Value<String?> imageUrl,
      Value<int?> episodeNumber,
      Value<int?> seasonNumber,
    });

final class $$EpisodesTableReferences
    extends BaseReferences<_$AppDatabase, $EpisodesTable, Episode> {
  $$EpisodesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SubscriptionsTable _podcastIdTable(_$AppDatabase db) =>
      db.subscriptions.createAlias(
        $_aliasNameGenerator(db.episodes.podcastId, db.subscriptions.id),
      );

  $$SubscriptionsTableProcessedTableManager get podcastId {
    final $_column = $_itemColumn<int>('podcast_id')!;

    final manager = $$SubscriptionsTableTableManager(
      $_db,
      $_db.subscriptions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_podcastIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PlaybackHistoriesTable, List<PlaybackHistory>>
  _playbackHistoriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.playbackHistories,
        aliasName: $_aliasNameGenerator(
          db.episodes.id,
          db.playbackHistories.episodeId,
        ),
      );

  $$PlaybackHistoriesTableProcessedTableManager get playbackHistoriesRefs {
    final manager = $$PlaybackHistoriesTableTableManager(
      $_db,
      $_db.playbackHistories,
    ).filter((f) => f.episodeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playbackHistoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DownloadTasksTable, List<DownloadTask>>
  _downloadTasksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.downloadTasks,
    aliasName: $_aliasNameGenerator(db.episodes.id, db.downloadTasks.episodeId),
  );

  $$DownloadTasksTableProcessedTableManager get downloadTasksRefs {
    final manager = $$DownloadTasksTableTableManager(
      $_db,
      $_db.downloadTasks,
    ).filter((f) => f.episodeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_downloadTasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$QueueItemsTable, List<QueueItem>>
  _queueItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.queueItems,
    aliasName: $_aliasNameGenerator(db.episodes.id, db.queueItems.episodeId),
  );

  $$QueueItemsTableProcessedTableManager get queueItemsRefs {
    final manager = $$QueueItemsTableTableManager(
      $_db,
      $_db.queueItems,
    ).filter((f) => f.episodeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_queueItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EpisodesTableFilterComposer
    extends Composer<_$AppDatabase, $EpisodesTable> {
  $$EpisodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guid => $composableBuilder(
    column: $table.guid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get episodeNumber => $composableBuilder(
    column: $table.episodeNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seasonNumber => $composableBuilder(
    column: $table.seasonNumber,
    builder: (column) => ColumnFilters(column),
  );

  $$SubscriptionsTableFilterComposer get podcastId {
    final $$SubscriptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.podcastId,
      referencedTable: $db.subscriptions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscriptionsTableFilterComposer(
            $db: $db,
            $table: $db.subscriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> playbackHistoriesRefs(
    Expression<bool> Function($$PlaybackHistoriesTableFilterComposer f) f,
  ) {
    final $$PlaybackHistoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playbackHistories,
      getReferencedColumn: (t) => t.episodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaybackHistoriesTableFilterComposer(
            $db: $db,
            $table: $db.playbackHistories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> downloadTasksRefs(
    Expression<bool> Function($$DownloadTasksTableFilterComposer f) f,
  ) {
    final $$DownloadTasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.downloadTasks,
      getReferencedColumn: (t) => t.episodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DownloadTasksTableFilterComposer(
            $db: $db,
            $table: $db.downloadTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> queueItemsRefs(
    Expression<bool> Function($$QueueItemsTableFilterComposer f) f,
  ) {
    final $$QueueItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.queueItems,
      getReferencedColumn: (t) => t.episodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueItemsTableFilterComposer(
            $db: $db,
            $table: $db.queueItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EpisodesTableOrderingComposer
    extends Composer<_$AppDatabase, $EpisodesTable> {
  $$EpisodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guid => $composableBuilder(
    column: $table.guid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get episodeNumber => $composableBuilder(
    column: $table.episodeNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seasonNumber => $composableBuilder(
    column: $table.seasonNumber,
    builder: (column) => ColumnOrderings(column),
  );

  $$SubscriptionsTableOrderingComposer get podcastId {
    final $$SubscriptionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.podcastId,
      referencedTable: $db.subscriptions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscriptionsTableOrderingComposer(
            $db: $db,
            $table: $db.subscriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EpisodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EpisodesTable> {
  $$EpisodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get guid =>
      $composableBuilder(column: $table.guid, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audioUrl =>
      $composableBuilder(column: $table.audioUrl, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<int> get episodeNumber => $composableBuilder(
    column: $table.episodeNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seasonNumber => $composableBuilder(
    column: $table.seasonNumber,
    builder: (column) => column,
  );

  $$SubscriptionsTableAnnotationComposer get podcastId {
    final $$SubscriptionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.podcastId,
      referencedTable: $db.subscriptions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscriptionsTableAnnotationComposer(
            $db: $db,
            $table: $db.subscriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> playbackHistoriesRefs<T extends Object>(
    Expression<T> Function($$PlaybackHistoriesTableAnnotationComposer a) f,
  ) {
    final $$PlaybackHistoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.playbackHistories,
          getReferencedColumn: (t) => t.episodeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlaybackHistoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.playbackHistories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> downloadTasksRefs<T extends Object>(
    Expression<T> Function($$DownloadTasksTableAnnotationComposer a) f,
  ) {
    final $$DownloadTasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.downloadTasks,
      getReferencedColumn: (t) => t.episodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DownloadTasksTableAnnotationComposer(
            $db: $db,
            $table: $db.downloadTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> queueItemsRefs<T extends Object>(
    Expression<T> Function($$QueueItemsTableAnnotationComposer a) f,
  ) {
    final $$QueueItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.queueItems,
      getReferencedColumn: (t) => t.episodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.queueItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EpisodesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EpisodesTable,
          Episode,
          $$EpisodesTableFilterComposer,
          $$EpisodesTableOrderingComposer,
          $$EpisodesTableAnnotationComposer,
          $$EpisodesTableCreateCompanionBuilder,
          $$EpisodesTableUpdateCompanionBuilder,
          (Episode, $$EpisodesTableReferences),
          Episode,
          PrefetchHooks Function({
            bool podcastId,
            bool playbackHistoriesRefs,
            bool downloadTasksRefs,
            bool queueItemsRefs,
          })
        > {
  $$EpisodesTableTableManager(_$AppDatabase db, $EpisodesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EpisodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EpisodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EpisodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> podcastId = const Value.absent(),
                Value<String> guid = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> audioUrl = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<DateTime?> publishedAt = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<int?> episodeNumber = const Value.absent(),
                Value<int?> seasonNumber = const Value.absent(),
              }) => EpisodesCompanion(
                id: id,
                podcastId: podcastId,
                guid: guid,
                title: title,
                description: description,
                audioUrl: audioUrl,
                durationMs: durationMs,
                publishedAt: publishedAt,
                imageUrl: imageUrl,
                episodeNumber: episodeNumber,
                seasonNumber: seasonNumber,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int podcastId,
                required String guid,
                required String title,
                Value<String?> description = const Value.absent(),
                required String audioUrl,
                Value<int?> durationMs = const Value.absent(),
                Value<DateTime?> publishedAt = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<int?> episodeNumber = const Value.absent(),
                Value<int?> seasonNumber = const Value.absent(),
              }) => EpisodesCompanion.insert(
                id: id,
                podcastId: podcastId,
                guid: guid,
                title: title,
                description: description,
                audioUrl: audioUrl,
                durationMs: durationMs,
                publishedAt: publishedAt,
                imageUrl: imageUrl,
                episodeNumber: episodeNumber,
                seasonNumber: seasonNumber,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EpisodesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                podcastId = false,
                playbackHistoriesRefs = false,
                downloadTasksRefs = false,
                queueItemsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (playbackHistoriesRefs) db.playbackHistories,
                    if (downloadTasksRefs) db.downloadTasks,
                    if (queueItemsRefs) db.queueItems,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (podcastId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.podcastId,
                                    referencedTable: $$EpisodesTableReferences
                                        ._podcastIdTable(db),
                                    referencedColumn: $$EpisodesTableReferences
                                        ._podcastIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (playbackHistoriesRefs)
                        await $_getPrefetchedData<
                          Episode,
                          $EpisodesTable,
                          PlaybackHistory
                        >(
                          currentTable: table,
                          referencedTable: $$EpisodesTableReferences
                              ._playbackHistoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EpisodesTableReferences(
                                db,
                                table,
                                p0,
                              ).playbackHistoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.episodeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (downloadTasksRefs)
                        await $_getPrefetchedData<
                          Episode,
                          $EpisodesTable,
                          DownloadTask
                        >(
                          currentTable: table,
                          referencedTable: $$EpisodesTableReferences
                              ._downloadTasksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EpisodesTableReferences(
                                db,
                                table,
                                p0,
                              ).downloadTasksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.episodeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (queueItemsRefs)
                        await $_getPrefetchedData<
                          Episode,
                          $EpisodesTable,
                          QueueItem
                        >(
                          currentTable: table,
                          referencedTable: $$EpisodesTableReferences
                              ._queueItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EpisodesTableReferences(
                                db,
                                table,
                                p0,
                              ).queueItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.episodeId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$EpisodesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EpisodesTable,
      Episode,
      $$EpisodesTableFilterComposer,
      $$EpisodesTableOrderingComposer,
      $$EpisodesTableAnnotationComposer,
      $$EpisodesTableCreateCompanionBuilder,
      $$EpisodesTableUpdateCompanionBuilder,
      (Episode, $$EpisodesTableReferences),
      Episode,
      PrefetchHooks Function({
        bool podcastId,
        bool playbackHistoriesRefs,
        bool downloadTasksRefs,
        bool queueItemsRefs,
      })
    >;
typedef $$PlaybackHistoriesTableCreateCompanionBuilder =
    PlaybackHistoriesCompanion Function({
      Value<int> episodeId,
      Value<int> positionMs,
      Value<int?> durationMs,
      Value<DateTime?> completedAt,
      Value<DateTime?> firstPlayedAt,
      Value<DateTime?> lastPlayedAt,
      Value<int> playCount,
    });
typedef $$PlaybackHistoriesTableUpdateCompanionBuilder =
    PlaybackHistoriesCompanion Function({
      Value<int> episodeId,
      Value<int> positionMs,
      Value<int?> durationMs,
      Value<DateTime?> completedAt,
      Value<DateTime?> firstPlayedAt,
      Value<DateTime?> lastPlayedAt,
      Value<int> playCount,
    });

final class $$PlaybackHistoriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PlaybackHistoriesTable,
          PlaybackHistory
        > {
  $$PlaybackHistoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EpisodesTable _episodeIdTable(_$AppDatabase db) =>
      db.episodes.createAlias(
        $_aliasNameGenerator(db.playbackHistories.episodeId, db.episodes.id),
      );

  $$EpisodesTableProcessedTableManager get episodeId {
    final $_column = $_itemColumn<int>('episode_id')!;

    final manager = $$EpisodesTableTableManager(
      $_db,
      $_db.episodes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_episodeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlaybackHistoriesTableFilterComposer
    extends Composer<_$AppDatabase, $PlaybackHistoriesTable> {
  $$PlaybackHistoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstPlayedAt => $composableBuilder(
    column: $table.firstPlayedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnFilters(column),
  );

  $$EpisodesTableFilterComposer get episodeId {
    final $$EpisodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.episodeId,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableFilterComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaybackHistoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaybackHistoriesTable> {
  $$PlaybackHistoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstPlayedAt => $composableBuilder(
    column: $table.firstPlayedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnOrderings(column),
  );

  $$EpisodesTableOrderingComposer get episodeId {
    final $$EpisodesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.episodeId,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableOrderingComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaybackHistoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaybackHistoriesTable> {
  $$PlaybackHistoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get firstPlayedAt => $composableBuilder(
    column: $table.firstPlayedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get playCount =>
      $composableBuilder(column: $table.playCount, builder: (column) => column);

  $$EpisodesTableAnnotationComposer get episodeId {
    final $$EpisodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.episodeId,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableAnnotationComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaybackHistoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaybackHistoriesTable,
          PlaybackHistory,
          $$PlaybackHistoriesTableFilterComposer,
          $$PlaybackHistoriesTableOrderingComposer,
          $$PlaybackHistoriesTableAnnotationComposer,
          $$PlaybackHistoriesTableCreateCompanionBuilder,
          $$PlaybackHistoriesTableUpdateCompanionBuilder,
          (PlaybackHistory, $$PlaybackHistoriesTableReferences),
          PlaybackHistory,
          PrefetchHooks Function({bool episodeId})
        > {
  $$PlaybackHistoriesTableTableManager(
    _$AppDatabase db,
    $PlaybackHistoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaybackHistoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaybackHistoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaybackHistoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> episodeId = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> firstPlayedAt = const Value.absent(),
                Value<DateTime?> lastPlayedAt = const Value.absent(),
                Value<int> playCount = const Value.absent(),
              }) => PlaybackHistoriesCompanion(
                episodeId: episodeId,
                positionMs: positionMs,
                durationMs: durationMs,
                completedAt: completedAt,
                firstPlayedAt: firstPlayedAt,
                lastPlayedAt: lastPlayedAt,
                playCount: playCount,
              ),
          createCompanionCallback:
              ({
                Value<int> episodeId = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> firstPlayedAt = const Value.absent(),
                Value<DateTime?> lastPlayedAt = const Value.absent(),
                Value<int> playCount = const Value.absent(),
              }) => PlaybackHistoriesCompanion.insert(
                episodeId: episodeId,
                positionMs: positionMs,
                durationMs: durationMs,
                completedAt: completedAt,
                firstPlayedAt: firstPlayedAt,
                lastPlayedAt: lastPlayedAt,
                playCount: playCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaybackHistoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({episodeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (episodeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.episodeId,
                                referencedTable:
                                    $$PlaybackHistoriesTableReferences
                                        ._episodeIdTable(db),
                                referencedColumn:
                                    $$PlaybackHistoriesTableReferences
                                        ._episodeIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlaybackHistoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaybackHistoriesTable,
      PlaybackHistory,
      $$PlaybackHistoriesTableFilterComposer,
      $$PlaybackHistoriesTableOrderingComposer,
      $$PlaybackHistoriesTableAnnotationComposer,
      $$PlaybackHistoriesTableCreateCompanionBuilder,
      $$PlaybackHistoriesTableUpdateCompanionBuilder,
      (PlaybackHistory, $$PlaybackHistoriesTableReferences),
      PlaybackHistory,
      PrefetchHooks Function({bool episodeId})
    >;
typedef $$SmartPlaylistsTableCreateCompanionBuilder =
    SmartPlaylistsCompanion Function({
      required int podcastId,
      required int playlistNumber,
      required String displayName,
      required int sortKey,
      required String resolverType,
      Value<String?> thumbnailUrl,
      Value<bool> yearGrouped,
      Value<int> rowid,
    });
typedef $$SmartPlaylistsTableUpdateCompanionBuilder =
    SmartPlaylistsCompanion Function({
      Value<int> podcastId,
      Value<int> playlistNumber,
      Value<String> displayName,
      Value<int> sortKey,
      Value<String> resolverType,
      Value<String?> thumbnailUrl,
      Value<bool> yearGrouped,
      Value<int> rowid,
    });

final class $$SmartPlaylistsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SmartPlaylistsTable,
          SmartPlaylistEntity
        > {
  $$SmartPlaylistsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SubscriptionsTable _podcastIdTable(_$AppDatabase db) =>
      db.subscriptions.createAlias(
        $_aliasNameGenerator(db.smartPlaylists.podcastId, db.subscriptions.id),
      );

  $$SubscriptionsTableProcessedTableManager get podcastId {
    final $_column = $_itemColumn<int>('podcast_id')!;

    final manager = $$SubscriptionsTableTableManager(
      $_db,
      $_db.subscriptions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_podcastIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SmartPlaylistsTableFilterComposer
    extends Composer<_$AppDatabase, $SmartPlaylistsTable> {
  $$SmartPlaylistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get playlistNumber => $composableBuilder(
    column: $table.playlistNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortKey => $composableBuilder(
    column: $table.sortKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolverType => $composableBuilder(
    column: $table.resolverType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get yearGrouped => $composableBuilder(
    column: $table.yearGrouped,
    builder: (column) => ColumnFilters(column),
  );

  $$SubscriptionsTableFilterComposer get podcastId {
    final $$SubscriptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.podcastId,
      referencedTable: $db.subscriptions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscriptionsTableFilterComposer(
            $db: $db,
            $table: $db.subscriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SmartPlaylistsTableOrderingComposer
    extends Composer<_$AppDatabase, $SmartPlaylistsTable> {
  $$SmartPlaylistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get playlistNumber => $composableBuilder(
    column: $table.playlistNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortKey => $composableBuilder(
    column: $table.sortKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolverType => $composableBuilder(
    column: $table.resolverType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get yearGrouped => $composableBuilder(
    column: $table.yearGrouped,
    builder: (column) => ColumnOrderings(column),
  );

  $$SubscriptionsTableOrderingComposer get podcastId {
    final $$SubscriptionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.podcastId,
      referencedTable: $db.subscriptions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscriptionsTableOrderingComposer(
            $db: $db,
            $table: $db.subscriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SmartPlaylistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SmartPlaylistsTable> {
  $$SmartPlaylistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get playlistNumber => $composableBuilder(
    column: $table.playlistNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortKey =>
      $composableBuilder(column: $table.sortKey, builder: (column) => column);

  GeneratedColumn<String> get resolverType => $composableBuilder(
    column: $table.resolverType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get yearGrouped => $composableBuilder(
    column: $table.yearGrouped,
    builder: (column) => column,
  );

  $$SubscriptionsTableAnnotationComposer get podcastId {
    final $$SubscriptionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.podcastId,
      referencedTable: $db.subscriptions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscriptionsTableAnnotationComposer(
            $db: $db,
            $table: $db.subscriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SmartPlaylistsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SmartPlaylistsTable,
          SmartPlaylistEntity,
          $$SmartPlaylistsTableFilterComposer,
          $$SmartPlaylistsTableOrderingComposer,
          $$SmartPlaylistsTableAnnotationComposer,
          $$SmartPlaylistsTableCreateCompanionBuilder,
          $$SmartPlaylistsTableUpdateCompanionBuilder,
          (SmartPlaylistEntity, $$SmartPlaylistsTableReferences),
          SmartPlaylistEntity,
          PrefetchHooks Function({bool podcastId})
        > {
  $$SmartPlaylistsTableTableManager(
    _$AppDatabase db,
    $SmartPlaylistsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SmartPlaylistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SmartPlaylistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SmartPlaylistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> podcastId = const Value.absent(),
                Value<int> playlistNumber = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<int> sortKey = const Value.absent(),
                Value<String> resolverType = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<bool> yearGrouped = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SmartPlaylistsCompanion(
                podcastId: podcastId,
                playlistNumber: playlistNumber,
                displayName: displayName,
                sortKey: sortKey,
                resolverType: resolverType,
                thumbnailUrl: thumbnailUrl,
                yearGrouped: yearGrouped,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int podcastId,
                required int playlistNumber,
                required String displayName,
                required int sortKey,
                required String resolverType,
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<bool> yearGrouped = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SmartPlaylistsCompanion.insert(
                podcastId: podcastId,
                playlistNumber: playlistNumber,
                displayName: displayName,
                sortKey: sortKey,
                resolverType: resolverType,
                thumbnailUrl: thumbnailUrl,
                yearGrouped: yearGrouped,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SmartPlaylistsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({podcastId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (podcastId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.podcastId,
                                referencedTable: $$SmartPlaylistsTableReferences
                                    ._podcastIdTable(db),
                                referencedColumn:
                                    $$SmartPlaylistsTableReferences
                                        ._podcastIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SmartPlaylistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SmartPlaylistsTable,
      SmartPlaylistEntity,
      $$SmartPlaylistsTableFilterComposer,
      $$SmartPlaylistsTableOrderingComposer,
      $$SmartPlaylistsTableAnnotationComposer,
      $$SmartPlaylistsTableCreateCompanionBuilder,
      $$SmartPlaylistsTableUpdateCompanionBuilder,
      (SmartPlaylistEntity, $$SmartPlaylistsTableReferences),
      SmartPlaylistEntity,
      PrefetchHooks Function({bool podcastId})
    >;
typedef $$PodcastViewPreferencesTableCreateCompanionBuilder =
    PodcastViewPreferencesCompanion Function({
      Value<int> podcastId,
      Value<String> viewMode,
      Value<String> episodeFilter,
      Value<String> episodeSortOrder,
      Value<String> seasonSortField,
      Value<String> seasonSortOrder,
      Value<String?> selectedPlaylistId,
    });
typedef $$PodcastViewPreferencesTableUpdateCompanionBuilder =
    PodcastViewPreferencesCompanion Function({
      Value<int> podcastId,
      Value<String> viewMode,
      Value<String> episodeFilter,
      Value<String> episodeSortOrder,
      Value<String> seasonSortField,
      Value<String> seasonSortOrder,
      Value<String?> selectedPlaylistId,
    });

final class $$PodcastViewPreferencesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PodcastViewPreferencesTable,
          PodcastViewPreference
        > {
  $$PodcastViewPreferencesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SubscriptionsTable _podcastIdTable(_$AppDatabase db) =>
      db.subscriptions.createAlias(
        $_aliasNameGenerator(
          db.podcastViewPreferences.podcastId,
          db.subscriptions.id,
        ),
      );

  $$SubscriptionsTableProcessedTableManager get podcastId {
    final $_column = $_itemColumn<int>('podcast_id')!;

    final manager = $$SubscriptionsTableTableManager(
      $_db,
      $_db.subscriptions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_podcastIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PodcastViewPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $PodcastViewPreferencesTable> {
  $$PodcastViewPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get viewMode => $composableBuilder(
    column: $table.viewMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get episodeFilter => $composableBuilder(
    column: $table.episodeFilter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get episodeSortOrder => $composableBuilder(
    column: $table.episodeSortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seasonSortField => $composableBuilder(
    column: $table.seasonSortField,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seasonSortOrder => $composableBuilder(
    column: $table.seasonSortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedPlaylistId => $composableBuilder(
    column: $table.selectedPlaylistId,
    builder: (column) => ColumnFilters(column),
  );

  $$SubscriptionsTableFilterComposer get podcastId {
    final $$SubscriptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.podcastId,
      referencedTable: $db.subscriptions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscriptionsTableFilterComposer(
            $db: $db,
            $table: $db.subscriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PodcastViewPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $PodcastViewPreferencesTable> {
  $$PodcastViewPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get viewMode => $composableBuilder(
    column: $table.viewMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get episodeFilter => $composableBuilder(
    column: $table.episodeFilter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get episodeSortOrder => $composableBuilder(
    column: $table.episodeSortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seasonSortField => $composableBuilder(
    column: $table.seasonSortField,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seasonSortOrder => $composableBuilder(
    column: $table.seasonSortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedPlaylistId => $composableBuilder(
    column: $table.selectedPlaylistId,
    builder: (column) => ColumnOrderings(column),
  );

  $$SubscriptionsTableOrderingComposer get podcastId {
    final $$SubscriptionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.podcastId,
      referencedTable: $db.subscriptions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscriptionsTableOrderingComposer(
            $db: $db,
            $table: $db.subscriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PodcastViewPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PodcastViewPreferencesTable> {
  $$PodcastViewPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get viewMode =>
      $composableBuilder(column: $table.viewMode, builder: (column) => column);

  GeneratedColumn<String> get episodeFilter => $composableBuilder(
    column: $table.episodeFilter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get episodeSortOrder => $composableBuilder(
    column: $table.episodeSortOrder,
    builder: (column) => column,
  );

  GeneratedColumn<String> get seasonSortField => $composableBuilder(
    column: $table.seasonSortField,
    builder: (column) => column,
  );

  GeneratedColumn<String> get seasonSortOrder => $composableBuilder(
    column: $table.seasonSortOrder,
    builder: (column) => column,
  );

  GeneratedColumn<String> get selectedPlaylistId => $composableBuilder(
    column: $table.selectedPlaylistId,
    builder: (column) => column,
  );

  $$SubscriptionsTableAnnotationComposer get podcastId {
    final $$SubscriptionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.podcastId,
      referencedTable: $db.subscriptions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscriptionsTableAnnotationComposer(
            $db: $db,
            $table: $db.subscriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PodcastViewPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PodcastViewPreferencesTable,
          PodcastViewPreference,
          $$PodcastViewPreferencesTableFilterComposer,
          $$PodcastViewPreferencesTableOrderingComposer,
          $$PodcastViewPreferencesTableAnnotationComposer,
          $$PodcastViewPreferencesTableCreateCompanionBuilder,
          $$PodcastViewPreferencesTableUpdateCompanionBuilder,
          (PodcastViewPreference, $$PodcastViewPreferencesTableReferences),
          PodcastViewPreference,
          PrefetchHooks Function({bool podcastId})
        > {
  $$PodcastViewPreferencesTableTableManager(
    _$AppDatabase db,
    $PodcastViewPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PodcastViewPreferencesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PodcastViewPreferencesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PodcastViewPreferencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> podcastId = const Value.absent(),
                Value<String> viewMode = const Value.absent(),
                Value<String> episodeFilter = const Value.absent(),
                Value<String> episodeSortOrder = const Value.absent(),
                Value<String> seasonSortField = const Value.absent(),
                Value<String> seasonSortOrder = const Value.absent(),
                Value<String?> selectedPlaylistId = const Value.absent(),
              }) => PodcastViewPreferencesCompanion(
                podcastId: podcastId,
                viewMode: viewMode,
                episodeFilter: episodeFilter,
                episodeSortOrder: episodeSortOrder,
                seasonSortField: seasonSortField,
                seasonSortOrder: seasonSortOrder,
                selectedPlaylistId: selectedPlaylistId,
              ),
          createCompanionCallback:
              ({
                Value<int> podcastId = const Value.absent(),
                Value<String> viewMode = const Value.absent(),
                Value<String> episodeFilter = const Value.absent(),
                Value<String> episodeSortOrder = const Value.absent(),
                Value<String> seasonSortField = const Value.absent(),
                Value<String> seasonSortOrder = const Value.absent(),
                Value<String?> selectedPlaylistId = const Value.absent(),
              }) => PodcastViewPreferencesCompanion.insert(
                podcastId: podcastId,
                viewMode: viewMode,
                episodeFilter: episodeFilter,
                episodeSortOrder: episodeSortOrder,
                seasonSortField: seasonSortField,
                seasonSortOrder: seasonSortOrder,
                selectedPlaylistId: selectedPlaylistId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PodcastViewPreferencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({podcastId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (podcastId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.podcastId,
                                referencedTable:
                                    $$PodcastViewPreferencesTableReferences
                                        ._podcastIdTable(db),
                                referencedColumn:
                                    $$PodcastViewPreferencesTableReferences
                                        ._podcastIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PodcastViewPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PodcastViewPreferencesTable,
      PodcastViewPreference,
      $$PodcastViewPreferencesTableFilterComposer,
      $$PodcastViewPreferencesTableOrderingComposer,
      $$PodcastViewPreferencesTableAnnotationComposer,
      $$PodcastViewPreferencesTableCreateCompanionBuilder,
      $$PodcastViewPreferencesTableUpdateCompanionBuilder,
      (PodcastViewPreference, $$PodcastViewPreferencesTableReferences),
      PodcastViewPreference,
      PrefetchHooks Function({bool podcastId})
    >;
typedef $$DownloadTasksTableCreateCompanionBuilder =
    DownloadTasksCompanion Function({
      Value<int> id,
      required int episodeId,
      required String audioUrl,
      Value<String?> localPath,
      Value<int?> totalBytes,
      Value<int> downloadedBytes,
      Value<int> status,
      Value<bool> wifiOnly,
      Value<int> retryCount,
      Value<String?> lastError,
      required DateTime createdAt,
      Value<DateTime?> completedAt,
    });
typedef $$DownloadTasksTableUpdateCompanionBuilder =
    DownloadTasksCompanion Function({
      Value<int> id,
      Value<int> episodeId,
      Value<String> audioUrl,
      Value<String?> localPath,
      Value<int?> totalBytes,
      Value<int> downloadedBytes,
      Value<int> status,
      Value<bool> wifiOnly,
      Value<int> retryCount,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<DateTime?> completedAt,
    });

final class $$DownloadTasksTableReferences
    extends BaseReferences<_$AppDatabase, $DownloadTasksTable, DownloadTask> {
  $$DownloadTasksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EpisodesTable _episodeIdTable(_$AppDatabase db) =>
      db.episodes.createAlias(
        $_aliasNameGenerator(db.downloadTasks.episodeId, db.episodes.id),
      );

  $$EpisodesTableProcessedTableManager get episodeId {
    final $_column = $_itemColumn<int>('episode_id')!;

    final manager = $$EpisodesTableTableManager(
      $_db,
      $_db.episodes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_episodeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DownloadTasksTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadTasksTable> {
  $$DownloadTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wifiOnly => $composableBuilder(
    column: $table.wifiOnly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$EpisodesTableFilterComposer get episodeId {
    final $$EpisodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.episodeId,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableFilterComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DownloadTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadTasksTable> {
  $$DownloadTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wifiOnly => $composableBuilder(
    column: $table.wifiOnly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$EpisodesTableOrderingComposer get episodeId {
    final $$EpisodesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.episodeId,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableOrderingComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DownloadTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadTasksTable> {
  $$DownloadTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get audioUrl =>
      $composableBuilder(column: $table.audioUrl, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get wifiOnly =>
      $composableBuilder(column: $table.wifiOnly, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  $$EpisodesTableAnnotationComposer get episodeId {
    final $$EpisodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.episodeId,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableAnnotationComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DownloadTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadTasksTable,
          DownloadTask,
          $$DownloadTasksTableFilterComposer,
          $$DownloadTasksTableOrderingComposer,
          $$DownloadTasksTableAnnotationComposer,
          $$DownloadTasksTableCreateCompanionBuilder,
          $$DownloadTasksTableUpdateCompanionBuilder,
          (DownloadTask, $$DownloadTasksTableReferences),
          DownloadTask,
          PrefetchHooks Function({bool episodeId})
        > {
  $$DownloadTasksTableTableManager(_$AppDatabase db, $DownloadTasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> episodeId = const Value.absent(),
                Value<String> audioUrl = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<int?> totalBytes = const Value.absent(),
                Value<int> downloadedBytes = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<bool> wifiOnly = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
              }) => DownloadTasksCompanion(
                id: id,
                episodeId: episodeId,
                audioUrl: audioUrl,
                localPath: localPath,
                totalBytes: totalBytes,
                downloadedBytes: downloadedBytes,
                status: status,
                wifiOnly: wifiOnly,
                retryCount: retryCount,
                lastError: lastError,
                createdAt: createdAt,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int episodeId,
                required String audioUrl,
                Value<String?> localPath = const Value.absent(),
                Value<int?> totalBytes = const Value.absent(),
                Value<int> downloadedBytes = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<bool> wifiOnly = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> completedAt = const Value.absent(),
              }) => DownloadTasksCompanion.insert(
                id: id,
                episodeId: episodeId,
                audioUrl: audioUrl,
                localPath: localPath,
                totalBytes: totalBytes,
                downloadedBytes: downloadedBytes,
                status: status,
                wifiOnly: wifiOnly,
                retryCount: retryCount,
                lastError: lastError,
                createdAt: createdAt,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DownloadTasksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({episodeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (episodeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.episodeId,
                                referencedTable: $$DownloadTasksTableReferences
                                    ._episodeIdTable(db),
                                referencedColumn: $$DownloadTasksTableReferences
                                    ._episodeIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DownloadTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadTasksTable,
      DownloadTask,
      $$DownloadTasksTableFilterComposer,
      $$DownloadTasksTableOrderingComposer,
      $$DownloadTasksTableAnnotationComposer,
      $$DownloadTasksTableCreateCompanionBuilder,
      $$DownloadTasksTableUpdateCompanionBuilder,
      (DownloadTask, $$DownloadTasksTableReferences),
      DownloadTask,
      PrefetchHooks Function({bool episodeId})
    >;
typedef $$QueueItemsTableCreateCompanionBuilder =
    QueueItemsCompanion Function({
      Value<int> id,
      required int episodeId,
      required int position,
      Value<bool> isAdhoc,
      Value<String?> sourceContext,
      required DateTime addedAt,
    });
typedef $$QueueItemsTableUpdateCompanionBuilder =
    QueueItemsCompanion Function({
      Value<int> id,
      Value<int> episodeId,
      Value<int> position,
      Value<bool> isAdhoc,
      Value<String?> sourceContext,
      Value<DateTime> addedAt,
    });

final class $$QueueItemsTableReferences
    extends BaseReferences<_$AppDatabase, $QueueItemsTable, QueueItem> {
  $$QueueItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EpisodesTable _episodeIdTable(_$AppDatabase db) =>
      db.episodes.createAlias(
        $_aliasNameGenerator(db.queueItems.episodeId, db.episodes.id),
      );

  $$EpisodesTableProcessedTableManager get episodeId {
    final $_column = $_itemColumn<int>('episode_id')!;

    final manager = $$EpisodesTableTableManager(
      $_db,
      $_db.episodes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_episodeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$QueueItemsTableFilterComposer
    extends Composer<_$AppDatabase, $QueueItemsTable> {
  $$QueueItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAdhoc => $composableBuilder(
    column: $table.isAdhoc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceContext => $composableBuilder(
    column: $table.sourceContext,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$EpisodesTableFilterComposer get episodeId {
    final $$EpisodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.episodeId,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableFilterComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QueueItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $QueueItemsTable> {
  $$QueueItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAdhoc => $composableBuilder(
    column: $table.isAdhoc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceContext => $composableBuilder(
    column: $table.sourceContext,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$EpisodesTableOrderingComposer get episodeId {
    final $$EpisodesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.episodeId,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableOrderingComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QueueItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QueueItemsTable> {
  $$QueueItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<bool> get isAdhoc =>
      $composableBuilder(column: $table.isAdhoc, builder: (column) => column);

  GeneratedColumn<String> get sourceContext => $composableBuilder(
    column: $table.sourceContext,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$EpisodesTableAnnotationComposer get episodeId {
    final $$EpisodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.episodeId,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableAnnotationComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QueueItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QueueItemsTable,
          QueueItem,
          $$QueueItemsTableFilterComposer,
          $$QueueItemsTableOrderingComposer,
          $$QueueItemsTableAnnotationComposer,
          $$QueueItemsTableCreateCompanionBuilder,
          $$QueueItemsTableUpdateCompanionBuilder,
          (QueueItem, $$QueueItemsTableReferences),
          QueueItem,
          PrefetchHooks Function({bool episodeId})
        > {
  $$QueueItemsTableTableManager(_$AppDatabase db, $QueueItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QueueItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QueueItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QueueItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> episodeId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<bool> isAdhoc = const Value.absent(),
                Value<String?> sourceContext = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => QueueItemsCompanion(
                id: id,
                episodeId: episodeId,
                position: position,
                isAdhoc: isAdhoc,
                sourceContext: sourceContext,
                addedAt: addedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int episodeId,
                required int position,
                Value<bool> isAdhoc = const Value.absent(),
                Value<String?> sourceContext = const Value.absent(),
                required DateTime addedAt,
              }) => QueueItemsCompanion.insert(
                id: id,
                episodeId: episodeId,
                position: position,
                isAdhoc: isAdhoc,
                sourceContext: sourceContext,
                addedAt: addedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$QueueItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({episodeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (episodeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.episodeId,
                                referencedTable: $$QueueItemsTableReferences
                                    ._episodeIdTable(db),
                                referencedColumn: $$QueueItemsTableReferences
                                    ._episodeIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$QueueItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QueueItemsTable,
      QueueItem,
      $$QueueItemsTableFilterComposer,
      $$QueueItemsTableOrderingComposer,
      $$QueueItemsTableAnnotationComposer,
      $$QueueItemsTableCreateCompanionBuilder,
      $$QueueItemsTableUpdateCompanionBuilder,
      (QueueItem, $$QueueItemsTableReferences),
      QueueItem,
      PrefetchHooks Function({bool episodeId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SubscriptionsTableTableManager get subscriptions =>
      $$SubscriptionsTableTableManager(_db, _db.subscriptions);
  $$EpisodesTableTableManager get episodes =>
      $$EpisodesTableTableManager(_db, _db.episodes);
  $$PlaybackHistoriesTableTableManager get playbackHistories =>
      $$PlaybackHistoriesTableTableManager(_db, _db.playbackHistories);
  $$SmartPlaylistsTableTableManager get smartPlaylists =>
      $$SmartPlaylistsTableTableManager(_db, _db.smartPlaylists);
  $$PodcastViewPreferencesTableTableManager get podcastViewPreferences =>
      $$PodcastViewPreferencesTableTableManager(
        _db,
        _db.podcastViewPreferences,
      );
  $$DownloadTasksTableTableManager get downloadTasks =>
      $$DownloadTasksTableTableManager(_db, _db.downloadTasks);
  $$QueueItemsTableTableManager get queueItems =>
      $$QueueItemsTableTableManager(_db, _db.queueItems);
}
