// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smart_playlist_groups.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSmartPlaylistGroupEntityCollection on Isar {
  IsarCollection<SmartPlaylistGroupEntity> get smartPlaylistGroupEntitys =>
      this.collection();
}

const SmartPlaylistGroupEntitySchema = CollectionSchema(
  name: r'SmartPlaylistGroup',
  id: -5114384559524104655,
  properties: {
    r'displayName': PropertySchema(
      id: 0,
      name: r'displayName',
      type: IsarType.string,
    ),
    r'earliestDate': PropertySchema(
      id: 1,
      name: r'earliestDate',
      type: IsarType.dateTime,
    ),
    r'episodeIds': PropertySchema(
      id: 2,
      name: r'episodeIds',
      type: IsarType.string,
    ),
    r'groupId': PropertySchema(id: 3, name: r'groupId', type: IsarType.string),
    r'latestDate': PropertySchema(
      id: 4,
      name: r'latestDate',
      type: IsarType.dateTime,
    ),
    r'playlistId': PropertySchema(
      id: 5,
      name: r'playlistId',
      type: IsarType.string,
    ),
    r'podcastId': PropertySchema(
      id: 6,
      name: r'podcastId',
      type: IsarType.long,
    ),
    r'sortKey': PropertySchema(id: 7, name: r'sortKey', type: IsarType.long),
    r'thumbnailUrl': PropertySchema(
      id: 8,
      name: r'thumbnailUrl',
      type: IsarType.string,
    ),
    r'totalDurationMs': PropertySchema(
      id: 9,
      name: r'totalDurationMs',
      type: IsarType.long,
    ),
    r'yearOverride': PropertySchema(
      id: 10,
      name: r'yearOverride',
      type: IsarType.string,
    ),
  },

  estimateSize: _smartPlaylistGroupEntityEstimateSize,
  serialize: _smartPlaylistGroupEntitySerialize,
  deserialize: _smartPlaylistGroupEntityDeserialize,
  deserializeProp: _smartPlaylistGroupEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'podcastId_playlistId_groupId': IndexSchema(
      id: 4783415948935367414,
      name: r'podcastId_playlistId_groupId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'podcastId',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'playlistId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'groupId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _smartPlaylistGroupEntityGetId,
  getLinks: _smartPlaylistGroupEntityGetLinks,
  attach: _smartPlaylistGroupEntityAttach,
  version: '3.3.0',
);

int _smartPlaylistGroupEntityEstimateSize(
  SmartPlaylistGroupEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.displayName.length * 3;
  bytesCount += 3 + object.episodeIds.length * 3;
  bytesCount += 3 + object.groupId.length * 3;
  bytesCount += 3 + object.playlistId.length * 3;
  {
    final value = object.thumbnailUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.yearOverride;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _smartPlaylistGroupEntitySerialize(
  SmartPlaylistGroupEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.displayName);
  writer.writeDateTime(offsets[1], object.earliestDate);
  writer.writeString(offsets[2], object.episodeIds);
  writer.writeString(offsets[3], object.groupId);
  writer.writeDateTime(offsets[4], object.latestDate);
  writer.writeString(offsets[5], object.playlistId);
  writer.writeLong(offsets[6], object.podcastId);
  writer.writeLong(offsets[7], object.sortKey);
  writer.writeString(offsets[8], object.thumbnailUrl);
  writer.writeLong(offsets[9], object.totalDurationMs);
  writer.writeString(offsets[10], object.yearOverride);
}

SmartPlaylistGroupEntity _smartPlaylistGroupEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SmartPlaylistGroupEntity();
  object.displayName = reader.readString(offsets[0]);
  object.earliestDate = reader.readDateTimeOrNull(offsets[1]);
  object.episodeIds = reader.readString(offsets[2]);
  object.groupId = reader.readString(offsets[3]);
  object.id = id;
  object.latestDate = reader.readDateTimeOrNull(offsets[4]);
  object.playlistId = reader.readString(offsets[5]);
  object.podcastId = reader.readLong(offsets[6]);
  object.sortKey = reader.readLong(offsets[7]);
  object.thumbnailUrl = reader.readStringOrNull(offsets[8]);
  object.totalDurationMs = reader.readLongOrNull(offsets[9]);
  object.yearOverride = reader.readStringOrNull(offsets[10]);
  return object;
}

P _smartPlaylistGroupEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _smartPlaylistGroupEntityGetId(SmartPlaylistGroupEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _smartPlaylistGroupEntityGetLinks(
  SmartPlaylistGroupEntity object,
) {
  return [];
}

void _smartPlaylistGroupEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  SmartPlaylistGroupEntity object,
) {
  object.id = id;
}

extension SmartPlaylistGroupEntityByIndex
    on IsarCollection<SmartPlaylistGroupEntity> {
  Future<SmartPlaylistGroupEntity?> getByPodcastIdPlaylistIdGroupId(
    int podcastId,
    String playlistId,
    String groupId,
  ) {
    return getByIndex(r'podcastId_playlistId_groupId', [
      podcastId,
      playlistId,
      groupId,
    ]);
  }

  SmartPlaylistGroupEntity? getByPodcastIdPlaylistIdGroupIdSync(
    int podcastId,
    String playlistId,
    String groupId,
  ) {
    return getByIndexSync(r'podcastId_playlistId_groupId', [
      podcastId,
      playlistId,
      groupId,
    ]);
  }

  Future<bool> deleteByPodcastIdPlaylistIdGroupId(
    int podcastId,
    String playlistId,
    String groupId,
  ) {
    return deleteByIndex(r'podcastId_playlistId_groupId', [
      podcastId,
      playlistId,
      groupId,
    ]);
  }

  bool deleteByPodcastIdPlaylistIdGroupIdSync(
    int podcastId,
    String playlistId,
    String groupId,
  ) {
    return deleteByIndexSync(r'podcastId_playlistId_groupId', [
      podcastId,
      playlistId,
      groupId,
    ]);
  }

  Future<List<SmartPlaylistGroupEntity?>> getAllByPodcastIdPlaylistIdGroupId(
    List<int> podcastIdValues,
    List<String> playlistIdValues,
    List<String> groupIdValues,
  ) {
    final len = podcastIdValues.length;
    assert(
      playlistIdValues.length == len && groupIdValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([podcastIdValues[i], playlistIdValues[i], groupIdValues[i]]);
    }

    return getAllByIndex(r'podcastId_playlistId_groupId', values);
  }

  List<SmartPlaylistGroupEntity?> getAllByPodcastIdPlaylistIdGroupIdSync(
    List<int> podcastIdValues,
    List<String> playlistIdValues,
    List<String> groupIdValues,
  ) {
    final len = podcastIdValues.length;
    assert(
      playlistIdValues.length == len && groupIdValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([podcastIdValues[i], playlistIdValues[i], groupIdValues[i]]);
    }

    return getAllByIndexSync(r'podcastId_playlistId_groupId', values);
  }

  Future<int> deleteAllByPodcastIdPlaylistIdGroupId(
    List<int> podcastIdValues,
    List<String> playlistIdValues,
    List<String> groupIdValues,
  ) {
    final len = podcastIdValues.length;
    assert(
      playlistIdValues.length == len && groupIdValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([podcastIdValues[i], playlistIdValues[i], groupIdValues[i]]);
    }

    return deleteAllByIndex(r'podcastId_playlistId_groupId', values);
  }

  int deleteAllByPodcastIdPlaylistIdGroupIdSync(
    List<int> podcastIdValues,
    List<String> playlistIdValues,
    List<String> groupIdValues,
  ) {
    final len = podcastIdValues.length;
    assert(
      playlistIdValues.length == len && groupIdValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([podcastIdValues[i], playlistIdValues[i], groupIdValues[i]]);
    }

    return deleteAllByIndexSync(r'podcastId_playlistId_groupId', values);
  }

  Future<Id> putByPodcastIdPlaylistIdGroupId(SmartPlaylistGroupEntity object) {
    return putByIndex(r'podcastId_playlistId_groupId', object);
  }

  Id putByPodcastIdPlaylistIdGroupIdSync(
    SmartPlaylistGroupEntity object, {
    bool saveLinks = true,
  }) {
    return putByIndexSync(
      r'podcastId_playlistId_groupId',
      object,
      saveLinks: saveLinks,
    );
  }

  Future<List<Id>> putAllByPodcastIdPlaylistIdGroupId(
    List<SmartPlaylistGroupEntity> objects,
  ) {
    return putAllByIndex(r'podcastId_playlistId_groupId', objects);
  }

  List<Id> putAllByPodcastIdPlaylistIdGroupIdSync(
    List<SmartPlaylistGroupEntity> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(
      r'podcastId_playlistId_groupId',
      objects,
      saveLinks: saveLinks,
    );
  }
}

extension SmartPlaylistGroupEntityQueryWhereSort
    on
        QueryBuilder<
          SmartPlaylistGroupEntity,
          SmartPlaylistGroupEntity,
          QWhere
        > {
  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SmartPlaylistGroupEntityQueryWhere
    on
        QueryBuilder<
          SmartPlaylistGroupEntity,
          SmartPlaylistGroupEntity,
          QWhereClause
        > {
  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterWhereClause
  >
  idNotEqualTo(Id id) {
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

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterWhereClause
  >
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterWhereClause
  >
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterWhereClause
  >
  idBetween(
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

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterWhereClause
  >
  podcastIdEqualToAnyPlaylistIdGroupId(int podcastId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'podcastId_playlistId_groupId',
          value: [podcastId],
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterWhereClause
  >
  podcastIdNotEqualToAnyPlaylistIdGroupId(int podcastId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistId_groupId',
                lower: [],
                upper: [podcastId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistId_groupId',
                lower: [podcastId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistId_groupId',
                lower: [podcastId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistId_groupId',
                lower: [],
                upper: [podcastId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterWhereClause
  >
  podcastIdGreaterThanAnyPlaylistIdGroupId(
    int podcastId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'podcastId_playlistId_groupId',
          lower: [podcastId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterWhereClause
  >
  podcastIdLessThanAnyPlaylistIdGroupId(int podcastId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'podcastId_playlistId_groupId',
          lower: [],
          upper: [podcastId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterWhereClause
  >
  podcastIdBetweenAnyPlaylistIdGroupId(
    int lowerPodcastId,
    int upperPodcastId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'podcastId_playlistId_groupId',
          lower: [lowerPodcastId],
          includeLower: includeLower,
          upper: [upperPodcastId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterWhereClause
  >
  podcastIdPlaylistIdEqualToAnyGroupId(int podcastId, String playlistId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'podcastId_playlistId_groupId',
          value: [podcastId, playlistId],
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterWhereClause
  >
  podcastIdEqualToPlaylistIdNotEqualToAnyGroupId(
    int podcastId,
    String playlistId,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistId_groupId',
                lower: [podcastId],
                upper: [podcastId, playlistId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistId_groupId',
                lower: [podcastId, playlistId],
                includeLower: false,
                upper: [podcastId],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistId_groupId',
                lower: [podcastId, playlistId],
                includeLower: false,
                upper: [podcastId],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistId_groupId',
                lower: [podcastId],
                upper: [podcastId, playlistId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterWhereClause
  >
  podcastIdPlaylistIdGroupIdEqualTo(
    int podcastId,
    String playlistId,
    String groupId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'podcastId_playlistId_groupId',
          value: [podcastId, playlistId, groupId],
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterWhereClause
  >
  podcastIdPlaylistIdEqualToGroupIdNotEqualTo(
    int podcastId,
    String playlistId,
    String groupId,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistId_groupId',
                lower: [podcastId, playlistId],
                upper: [podcastId, playlistId, groupId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistId_groupId',
                lower: [podcastId, playlistId, groupId],
                includeLower: false,
                upper: [podcastId, playlistId],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistId_groupId',
                lower: [podcastId, playlistId, groupId],
                includeLower: false,
                upper: [podcastId, playlistId],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId_playlistId_groupId',
                lower: [podcastId, playlistId],
                upper: [podcastId, playlistId, groupId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension SmartPlaylistGroupEntityQueryFilter
    on
        QueryBuilder<
          SmartPlaylistGroupEntity,
          SmartPlaylistGroupEntity,
          QFilterCondition
        > {
  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  displayNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'displayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  displayNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'displayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  displayNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'displayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  displayNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'displayName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  displayNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'displayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  displayNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'displayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  displayNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'displayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  displayNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'displayName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  displayNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'displayName', value: ''),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  displayNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'displayName', value: ''),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  earliestDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'earliestDate'),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  earliestDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'earliestDate'),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  earliestDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'earliestDate', value: value),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  earliestDateGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'earliestDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  earliestDateLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'earliestDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  earliestDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'earliestDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  episodeIdsEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'episodeIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  episodeIdsGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'episodeIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  episodeIdsLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'episodeIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  episodeIdsBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'episodeIds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  episodeIdsStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'episodeIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  episodeIdsEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'episodeIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  episodeIdsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'episodeIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  episodeIdsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'episodeIds',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  episodeIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'episodeIds', value: ''),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  episodeIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'episodeIds', value: ''),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  groupIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  groupIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  groupIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  groupIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'groupId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  groupIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  groupIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  groupIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  groupIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'groupId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  groupIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'groupId', value: ''),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  groupIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'groupId', value: ''),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  idGreaterThan(Id value, {bool include = false}) {
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

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  idLessThan(Id value, {bool include = false}) {
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

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  idBetween(
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

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  latestDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'latestDate'),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  latestDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'latestDate'),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  latestDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'latestDate', value: value),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  latestDateGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'latestDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  latestDateLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'latestDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  latestDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'latestDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  playlistIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'playlistId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  playlistIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'playlistId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  playlistIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'playlistId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  playlistIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'playlistId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  playlistIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'playlistId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  playlistIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'playlistId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  playlistIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'playlistId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  playlistIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'playlistId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  playlistIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'playlistId', value: ''),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  playlistIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'playlistId', value: ''),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  podcastIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'podcastId', value: value),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  podcastIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'podcastId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  podcastIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'podcastId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  podcastIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'podcastId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  sortKeyEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sortKey', value: value),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  sortKeyGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sortKey',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  sortKeyLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sortKey',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  sortKeyBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sortKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  thumbnailUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'thumbnailUrl'),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  thumbnailUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'thumbnailUrl'),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  thumbnailUrlEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'thumbnailUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  thumbnailUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'thumbnailUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  thumbnailUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'thumbnailUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  thumbnailUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'thumbnailUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  thumbnailUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'thumbnailUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  thumbnailUrlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'thumbnailUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  thumbnailUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'thumbnailUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  thumbnailUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'thumbnailUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  thumbnailUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'thumbnailUrl', value: ''),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  thumbnailUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'thumbnailUrl', value: ''),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  totalDurationMsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'totalDurationMs'),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  totalDurationMsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'totalDurationMs'),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  totalDurationMsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'totalDurationMs', value: value),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  totalDurationMsGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'totalDurationMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  totalDurationMsLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'totalDurationMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  totalDurationMsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totalDurationMs',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  yearOverrideIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'yearOverride'),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  yearOverrideIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'yearOverride'),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  yearOverrideEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'yearOverride',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  yearOverrideGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'yearOverride',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  yearOverrideLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'yearOverride',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  yearOverrideBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'yearOverride',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  yearOverrideStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'yearOverride',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  yearOverrideEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'yearOverride',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  yearOverrideContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'yearOverride',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  yearOverrideMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'yearOverride',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  yearOverrideIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'yearOverride', value: ''),
      );
    });
  }

  QueryBuilder<
    SmartPlaylistGroupEntity,
    SmartPlaylistGroupEntity,
    QAfterFilterCondition
  >
  yearOverrideIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'yearOverride', value: ''),
      );
    });
  }
}

extension SmartPlaylistGroupEntityQueryObject
    on
        QueryBuilder<
          SmartPlaylistGroupEntity,
          SmartPlaylistGroupEntity,
          QFilterCondition
        > {}

extension SmartPlaylistGroupEntityQueryLinks
    on
        QueryBuilder<
          SmartPlaylistGroupEntity,
          SmartPlaylistGroupEntity,
          QFilterCondition
        > {}

extension SmartPlaylistGroupEntityQuerySortBy
    on
        QueryBuilder<
          SmartPlaylistGroupEntity,
          SmartPlaylistGroupEntity,
          QSortBy
        > {
  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  sortByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  sortByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  sortByEarliestDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earliestDate', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  sortByEarliestDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earliestDate', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  sortByEpisodeIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeIds', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  sortByEpisodeIdsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeIds', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  sortByGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  sortByGroupIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  sortByLatestDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latestDate', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  sortByLatestDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latestDate', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  sortByPlaylistId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistId', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  sortByPlaylistIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistId', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  sortByPodcastId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastId', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  sortByPodcastIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastId', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  sortBySortKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortKey', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  sortBySortKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortKey', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  sortByThumbnailUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailUrl', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  sortByThumbnailUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailUrl', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  sortByTotalDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDurationMs', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  sortByTotalDurationMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDurationMs', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  sortByYearOverride() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearOverride', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  sortByYearOverrideDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearOverride', Sort.desc);
    });
  }
}

extension SmartPlaylistGroupEntityQuerySortThenBy
    on
        QueryBuilder<
          SmartPlaylistGroupEntity,
          SmartPlaylistGroupEntity,
          QSortThenBy
        > {
  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  thenByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  thenByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  thenByEarliestDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earliestDate', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  thenByEarliestDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earliestDate', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  thenByEpisodeIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeIds', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  thenByEpisodeIdsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeIds', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  thenByGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  thenByGroupIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  thenByLatestDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latestDate', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  thenByLatestDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latestDate', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  thenByPlaylistId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistId', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  thenByPlaylistIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistId', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  thenByPodcastId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastId', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  thenByPodcastIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastId', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  thenBySortKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortKey', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  thenBySortKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortKey', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  thenByThumbnailUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailUrl', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  thenByThumbnailUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailUrl', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  thenByTotalDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDurationMs', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  thenByTotalDurationMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDurationMs', Sort.desc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  thenByYearOverride() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearOverride', Sort.asc);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QAfterSortBy>
  thenByYearOverrideDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearOverride', Sort.desc);
    });
  }
}

extension SmartPlaylistGroupEntityQueryWhereDistinct
    on
        QueryBuilder<
          SmartPlaylistGroupEntity,
          SmartPlaylistGroupEntity,
          QDistinct
        > {
  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QDistinct>
  distinctByDisplayName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QDistinct>
  distinctByEarliestDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earliestDate');
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QDistinct>
  distinctByEpisodeIds({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'episodeIds', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QDistinct>
  distinctByGroupId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'groupId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QDistinct>
  distinctByLatestDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'latestDate');
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QDistinct>
  distinctByPlaylistId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playlistId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QDistinct>
  distinctByPodcastId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'podcastId');
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QDistinct>
  distinctBySortKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortKey');
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QDistinct>
  distinctByThumbnailUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'thumbnailUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QDistinct>
  distinctByTotalDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalDurationMs');
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, SmartPlaylistGroupEntity, QDistinct>
  distinctByYearOverride({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'yearOverride', caseSensitive: caseSensitive);
    });
  }
}

extension SmartPlaylistGroupEntityQueryProperty
    on
        QueryBuilder<
          SmartPlaylistGroupEntity,
          SmartPlaylistGroupEntity,
          QQueryProperty
        > {
  QueryBuilder<SmartPlaylistGroupEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, String, QQueryOperations>
  displayNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayName');
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, DateTime?, QQueryOperations>
  earliestDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earliestDate');
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, String, QQueryOperations>
  episodeIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodeIds');
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, String, QQueryOperations>
  groupIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'groupId');
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, DateTime?, QQueryOperations>
  latestDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latestDate');
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, String, QQueryOperations>
  playlistIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playlistId');
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, int, QQueryOperations>
  podcastIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'podcastId');
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, int, QQueryOperations>
  sortKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortKey');
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, String?, QQueryOperations>
  thumbnailUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'thumbnailUrl');
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, int?, QQueryOperations>
  totalDurationMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalDurationMs');
    });
  }

  QueryBuilder<SmartPlaylistGroupEntity, String?, QQueryOperations>
  yearOverrideProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'yearOverride');
    });
  }
}
