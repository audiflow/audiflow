// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscriptions.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSubscriptionCollection on Isar {
  IsarCollection<Subscription> get subscriptions => this.collection();
}

const SubscriptionSchema = CollectionSchema(
  name: r'Subscription',
  id: -3426239935225026138,
  properties: {
    r'artistName': PropertySchema(
      id: 0,
      name: r'artistName',
      type: IsarType.string,
    ),
    r'artworkUrl': PropertySchema(
      id: 1,
      name: r'artworkUrl',
      type: IsarType.string,
    ),
    r'autoDownload': PropertySchema(
      id: 2,
      name: r'autoDownload',
      type: IsarType.bool,
    ),
    r'description': PropertySchema(
      id: 3,
      name: r'description',
      type: IsarType.string,
    ),
    r'explicit': PropertySchema(id: 4, name: r'explicit', type: IsarType.bool),
    r'feedUrl': PropertySchema(id: 5, name: r'feedUrl', type: IsarType.string),
    r'genres': PropertySchema(id: 6, name: r'genres', type: IsarType.string),
    r'httpEtag': PropertySchema(
      id: 7,
      name: r'httpEtag',
      type: IsarType.string,
    ),
    r'httpLastModified': PropertySchema(
      id: 8,
      name: r'httpLastModified',
      type: IsarType.string,
    ),
    r'isCached': PropertySchema(id: 9, name: r'isCached', type: IsarType.bool),
    r'itunesId': PropertySchema(
      id: 10,
      name: r'itunesId',
      type: IsarType.string,
    ),
    r'lastAccessedAt': PropertySchema(
      id: 11,
      name: r'lastAccessedAt',
      type: IsarType.dateTime,
    ),
    r'lastRefreshedAt': PropertySchema(
      id: 12,
      name: r'lastRefreshedAt',
      type: IsarType.dateTime,
    ),
    r'subscribedAt': PropertySchema(
      id: 13,
      name: r'subscribedAt',
      type: IsarType.dateTime,
    ),
    r'title': PropertySchema(id: 14, name: r'title', type: IsarType.string),
  },

  estimateSize: _subscriptionEstimateSize,
  serialize: _subscriptionSerialize,
  deserialize: _subscriptionDeserialize,
  deserializeProp: _subscriptionDeserializeProp,
  idName: r'id',
  indexes: {
    r'itunesId': IndexSchema(
      id: -7698317073018689648,
      name: r'itunesId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'itunesId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _subscriptionGetId,
  getLinks: _subscriptionGetLinks,
  attach: _subscriptionAttach,
  version: '3.3.2',
);

int _subscriptionEstimateSize(
  Subscription object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.artistName.length * 3;
  {
    final value = object.artworkUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.feedUrl.length * 3;
  bytesCount += 3 + object.genres.length * 3;
  {
    final value = object.httpEtag;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.httpLastModified;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.itunesId.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _subscriptionSerialize(
  Subscription object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.artistName);
  writer.writeString(offsets[1], object.artworkUrl);
  writer.writeBool(offsets[2], object.autoDownload);
  writer.writeString(offsets[3], object.description);
  writer.writeBool(offsets[4], object.explicit);
  writer.writeString(offsets[5], object.feedUrl);
  writer.writeString(offsets[6], object.genres);
  writer.writeString(offsets[7], object.httpEtag);
  writer.writeString(offsets[8], object.httpLastModified);
  writer.writeBool(offsets[9], object.isCached);
  writer.writeString(offsets[10], object.itunesId);
  writer.writeDateTime(offsets[11], object.lastAccessedAt);
  writer.writeDateTime(offsets[12], object.lastRefreshedAt);
  writer.writeDateTime(offsets[13], object.subscribedAt);
  writer.writeString(offsets[14], object.title);
}

Subscription _subscriptionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Subscription();
  object.artistName = reader.readString(offsets[0]);
  object.artworkUrl = reader.readStringOrNull(offsets[1]);
  object.autoDownload = reader.readBool(offsets[2]);
  object.description = reader.readStringOrNull(offsets[3]);
  object.explicit = reader.readBool(offsets[4]);
  object.feedUrl = reader.readString(offsets[5]);
  object.genres = reader.readString(offsets[6]);
  object.httpEtag = reader.readStringOrNull(offsets[7]);
  object.httpLastModified = reader.readStringOrNull(offsets[8]);
  object.id = id;
  object.isCached = reader.readBool(offsets[9]);
  object.itunesId = reader.readString(offsets[10]);
  object.lastAccessedAt = reader.readDateTimeOrNull(offsets[11]);
  object.lastRefreshedAt = reader.readDateTimeOrNull(offsets[12]);
  object.subscribedAt = reader.readDateTime(offsets[13]);
  object.title = reader.readString(offsets[14]);
  return object;
}

P _subscriptionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 12:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 13:
      return (reader.readDateTime(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _subscriptionGetId(Subscription object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _subscriptionGetLinks(Subscription object) {
  return [];
}

void _subscriptionAttach(
  IsarCollection<dynamic> col,
  Id id,
  Subscription object,
) {
  object.id = id;
}

extension SubscriptionByIndex on IsarCollection<Subscription> {
  Future<Subscription?> getByItunesId(String itunesId) {
    return getByIndex(r'itunesId', [itunesId]);
  }

  Subscription? getByItunesIdSync(String itunesId) {
    return getByIndexSync(r'itunesId', [itunesId]);
  }

  Future<bool> deleteByItunesId(String itunesId) {
    return deleteByIndex(r'itunesId', [itunesId]);
  }

  bool deleteByItunesIdSync(String itunesId) {
    return deleteByIndexSync(r'itunesId', [itunesId]);
  }

  Future<List<Subscription?>> getAllByItunesId(List<String> itunesIdValues) {
    final values = itunesIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'itunesId', values);
  }

  List<Subscription?> getAllByItunesIdSync(List<String> itunesIdValues) {
    final values = itunesIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'itunesId', values);
  }

  Future<int> deleteAllByItunesId(List<String> itunesIdValues) {
    final values = itunesIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'itunesId', values);
  }

  int deleteAllByItunesIdSync(List<String> itunesIdValues) {
    final values = itunesIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'itunesId', values);
  }

  Future<Id> putByItunesId(Subscription object) {
    return putByIndex(r'itunesId', object);
  }

  Id putByItunesIdSync(Subscription object, {bool saveLinks = true}) {
    return putByIndexSync(r'itunesId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByItunesId(List<Subscription> objects) {
    return putAllByIndex(r'itunesId', objects);
  }

  List<Id> putAllByItunesIdSync(
    List<Subscription> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'itunesId', objects, saveLinks: saveLinks);
  }
}

extension SubscriptionQueryWhereSort
    on QueryBuilder<Subscription, Subscription, QWhere> {
  QueryBuilder<Subscription, Subscription, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SubscriptionQueryWhere
    on QueryBuilder<Subscription, Subscription, QWhereClause> {
  QueryBuilder<Subscription, Subscription, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterWhereClause> itunesIdEqualTo(
    String itunesId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'itunesId', value: [itunesId]),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterWhereClause>
  itunesIdNotEqualTo(String itunesId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'itunesId',
                lower: [],
                upper: [itunesId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'itunesId',
                lower: [itunesId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'itunesId',
                lower: [itunesId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'itunesId',
                lower: [],
                upper: [itunesId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension SubscriptionQueryFilter
    on QueryBuilder<Subscription, Subscription, QFilterCondition> {
  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  artistNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'artistName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  artistNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'artistName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  artistNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'artistName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  artistNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'artistName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  artistNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'artistName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  artistNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'artistName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  artistNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'artistName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  artistNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'artistName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  artistNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'artistName', value: ''),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  artistNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'artistName', value: ''),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  artworkUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'artworkUrl'),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  artworkUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'artworkUrl'),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  artworkUrlEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'artworkUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  artworkUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'artworkUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  artworkUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'artworkUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  artworkUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'artworkUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  artworkUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'artworkUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  artworkUrlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'artworkUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  artworkUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'artworkUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  artworkUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'artworkUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  artworkUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'artworkUrl', value: ''),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  artworkUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'artworkUrl', value: ''),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  autoDownloadEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'autoDownload', value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'description'),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'description'),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  descriptionEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'description',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  descriptionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  descriptionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'description',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  explicitEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'explicit', value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  feedUrlEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'feedUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  feedUrlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'feedUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  feedUrlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'feedUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  feedUrlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'feedUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  feedUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'feedUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  feedUrlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'feedUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  feedUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'feedUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  feedUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'feedUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  feedUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'feedUrl', value: ''),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  feedUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'feedUrl', value: ''),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> genresEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'genres',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  genresGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'genres',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  genresLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'genres',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> genresBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'genres',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  genresStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'genres',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  genresEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'genres',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  genresContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'genres',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> genresMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'genres',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  genresIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'genres', value: ''),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  genresIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'genres', value: ''),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  httpEtagIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'httpEtag'),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  httpEtagIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'httpEtag'),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  httpEtagEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'httpEtag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  httpEtagGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'httpEtag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  httpEtagLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'httpEtag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  httpEtagBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'httpEtag',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  httpEtagStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'httpEtag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  httpEtagEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'httpEtag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  httpEtagContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'httpEtag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  httpEtagMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'httpEtag',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  httpEtagIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'httpEtag', value: ''),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  httpEtagIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'httpEtag', value: ''),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  httpLastModifiedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'httpLastModified'),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  httpLastModifiedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'httpLastModified'),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  httpLastModifiedEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'httpLastModified',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  httpLastModifiedGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'httpLastModified',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  httpLastModifiedLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'httpLastModified',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  httpLastModifiedBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'httpLastModified',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  httpLastModifiedStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'httpLastModified',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  httpLastModifiedEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'httpLastModified',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  httpLastModifiedContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'httpLastModified',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  httpLastModifiedMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'httpLastModified',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  httpLastModifiedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'httpLastModified', value: ''),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  httpLastModifiedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'httpLastModified', value: ''),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  isCachedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isCached', value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  itunesIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'itunesId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  itunesIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'itunesId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  itunesIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'itunesId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  itunesIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'itunesId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  itunesIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'itunesId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  itunesIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'itunesId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  itunesIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'itunesId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  itunesIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'itunesId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  itunesIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'itunesId', value: ''),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  itunesIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'itunesId', value: ''),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  lastAccessedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastAccessedAt'),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  lastAccessedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastAccessedAt'),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  lastAccessedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastAccessedAt', value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  lastAccessedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastAccessedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  lastAccessedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastAccessedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  lastAccessedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastAccessedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  lastRefreshedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastRefreshedAt'),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  lastRefreshedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastRefreshedAt'),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  lastRefreshedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastRefreshedAt', value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  lastRefreshedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastRefreshedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  lastRefreshedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastRefreshedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  lastRefreshedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastRefreshedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  subscribedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'subscribedAt', value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  subscribedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'subscribedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  subscribedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'subscribedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  subscribedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'subscribedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'title',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  titleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> titleContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> titleMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'title',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }
}

extension SubscriptionQueryObject
    on QueryBuilder<Subscription, Subscription, QFilterCondition> {}

extension SubscriptionQueryLinks
    on QueryBuilder<Subscription, Subscription, QFilterCondition> {}

extension SubscriptionQuerySortBy
    on QueryBuilder<Subscription, Subscription, QSortBy> {
  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByArtistName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artistName', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  sortByArtistNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artistName', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByArtworkUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artworkUrl', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  sortByArtworkUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artworkUrl', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByAutoDownload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoDownload', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  sortByAutoDownloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoDownload', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByExplicit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'explicit', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByExplicitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'explicit', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByFeedUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedUrl', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByFeedUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedUrl', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByGenres() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genres', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByGenresDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genres', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByHttpEtag() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'httpEtag', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByHttpEtagDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'httpEtag', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  sortByHttpLastModified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'httpLastModified', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  sortByHttpLastModifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'httpLastModified', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByIsCached() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCached', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByIsCachedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCached', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByItunesId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesId', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByItunesIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesId', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  sortByLastAccessedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAccessedAt', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  sortByLastAccessedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAccessedAt', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  sortByLastRefreshedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRefreshedAt', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  sortByLastRefreshedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRefreshedAt', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortBySubscribedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subscribedAt', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  sortBySubscribedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subscribedAt', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension SubscriptionQuerySortThenBy
    on QueryBuilder<Subscription, Subscription, QSortThenBy> {
  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByArtistName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artistName', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  thenByArtistNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artistName', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByArtworkUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artworkUrl', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  thenByArtworkUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artworkUrl', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByAutoDownload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoDownload', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  thenByAutoDownloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoDownload', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByExplicit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'explicit', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByExplicitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'explicit', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByFeedUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedUrl', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByFeedUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedUrl', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByGenres() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genres', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByGenresDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genres', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByHttpEtag() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'httpEtag', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByHttpEtagDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'httpEtag', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  thenByHttpLastModified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'httpLastModified', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  thenByHttpLastModifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'httpLastModified', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByIsCached() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCached', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByIsCachedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCached', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByItunesId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesId', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByItunesIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesId', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  thenByLastAccessedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAccessedAt', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  thenByLastAccessedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAccessedAt', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  thenByLastRefreshedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRefreshedAt', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  thenByLastRefreshedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRefreshedAt', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenBySubscribedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subscribedAt', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  thenBySubscribedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subscribedAt', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension SubscriptionQueryWhereDistinct
    on QueryBuilder<Subscription, Subscription, QDistinct> {
  QueryBuilder<Subscription, Subscription, QDistinct> distinctByArtistName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artistName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct> distinctByArtworkUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artworkUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct> distinctByAutoDownload() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoDownload');
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct> distinctByDescription({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct> distinctByExplicit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'explicit');
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct> distinctByFeedUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'feedUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct> distinctByGenres({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'genres', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct> distinctByHttpEtag({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'httpEtag', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct>
  distinctByHttpLastModified({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'httpLastModified',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct> distinctByIsCached() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCached');
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct> distinctByItunesId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itunesId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct>
  distinctByLastAccessedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastAccessedAt');
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct>
  distinctByLastRefreshedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastRefreshedAt');
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct> distinctBySubscribedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subscribedAt');
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension SubscriptionQueryProperty
    on QueryBuilder<Subscription, Subscription, QQueryProperty> {
  QueryBuilder<Subscription, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Subscription, String, QQueryOperations> artistNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artistName');
    });
  }

  QueryBuilder<Subscription, String?, QQueryOperations> artworkUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artworkUrl');
    });
  }

  QueryBuilder<Subscription, bool, QQueryOperations> autoDownloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoDownload');
    });
  }

  QueryBuilder<Subscription, String?, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<Subscription, bool, QQueryOperations> explicitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'explicit');
    });
  }

  QueryBuilder<Subscription, String, QQueryOperations> feedUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'feedUrl');
    });
  }

  QueryBuilder<Subscription, String, QQueryOperations> genresProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'genres');
    });
  }

  QueryBuilder<Subscription, String?, QQueryOperations> httpEtagProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'httpEtag');
    });
  }

  QueryBuilder<Subscription, String?, QQueryOperations>
  httpLastModifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'httpLastModified');
    });
  }

  QueryBuilder<Subscription, bool, QQueryOperations> isCachedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCached');
    });
  }

  QueryBuilder<Subscription, String, QQueryOperations> itunesIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itunesId');
    });
  }

  QueryBuilder<Subscription, DateTime?, QQueryOperations>
  lastAccessedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastAccessedAt');
    });
  }

  QueryBuilder<Subscription, DateTime?, QQueryOperations>
  lastRefreshedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastRefreshedAt');
    });
  }

  QueryBuilder<Subscription, DateTime, QQueryOperations>
  subscribedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subscribedAt');
    });
  }

  QueryBuilder<Subscription, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}
