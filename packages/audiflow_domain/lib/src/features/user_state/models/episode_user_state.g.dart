// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode_user_state.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetEpisodeUserStateCollection on Isar {
  IsarCollection<EpisodeUserState> get episodeUserStates => this.collection();
}

const EpisodeUserStateSchema = CollectionSchema(
  name: r'EpisodeUserState',
  id: 991074460124517647,
  properties: {
    r'completedAt': PropertySchema(
      id: 0,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'completedAtHlc': PropertySchema(
      id: 1,
      name: r'completedAtHlc',
      type: IsarType.long,
    ),
    r'counters': PropertySchema(
      id: 2,
      name: r'counters',
      type: IsarType.objectList,

      target: r'EpisodePlayCounters',
    ),
    r'durationHlc': PropertySchema(
      id: 3,
      name: r'durationHlc',
      type: IsarType.long,
    ),
    r'durationMs': PropertySchema(
      id: 4,
      name: r'durationMs',
      type: IsarType.long,
    ),
    r'episodeKey': PropertySchema(
      id: 5,
      name: r'episodeKey',
      type: IsarType.string,
    ),
    r'favoritedAt': PropertySchema(
      id: 6,
      name: r'favoritedAt',
      type: IsarType.dateTime,
    ),
    r'favoritedAtHlc': PropertySchema(
      id: 7,
      name: r'favoritedAtHlc',
      type: IsarType.long,
    ),
    r'firstPlayedAt': PropertySchema(
      id: 8,
      name: r'firstPlayedAt',
      type: IsarType.dateTime,
    ),
    r'firstPlayedAtHlc': PropertySchema(
      id: 9,
      name: r'firstPlayedAtHlc',
      type: IsarType.long,
    ),
    r'hasPlayback': PropertySchema(
      id: 10,
      name: r'hasPlayback',
      type: IsarType.bool,
    ),
    r'hasPlaybackHlc': PropertySchema(
      id: 11,
      name: r'hasPlaybackHlc',
      type: IsarType.long,
    ),
    r'isReplayFromStart': PropertySchema(
      id: 12,
      name: r'isReplayFromStart',
      type: IsarType.bool,
    ),
    r'isReplaying': PropertySchema(
      id: 13,
      name: r'isReplaying',
      type: IsarType.bool,
    ),
    r'lastPlayedAt': PropertySchema(
      id: 14,
      name: r'lastPlayedAt',
      type: IsarType.dateTime,
    ),
    r'lastPlayedAtHlc': PropertySchema(
      id: 15,
      name: r'lastPlayedAtHlc',
      type: IsarType.long,
    ),
    r'locatorAudioUrl': PropertySchema(
      id: 16,
      name: r'locatorAudioUrl',
      type: IsarType.string,
    ),
    r'locatorGuid': PropertySchema(
      id: 17,
      name: r'locatorGuid',
      type: IsarType.string,
    ),
    r'locatorPublishedAt': PropertySchema(
      id: 18,
      name: r'locatorPublishedAt',
      type: IsarType.dateTime,
    ),
    r'podcastKey': PropertySchema(
      id: 19,
      name: r'podcastKey',
      type: IsarType.string,
    ),
    r'positionHlc': PropertySchema(
      id: 20,
      name: r'positionHlc',
      type: IsarType.long,
    ),
    r'positionMs': PropertySchema(
      id: 21,
      name: r'positionMs',
      type: IsarType.long,
    ),
    r'replayHlc': PropertySchema(
      id: 22,
      name: r'replayHlc',
      type: IsarType.long,
    ),
  },

  estimateSize: _episodeUserStateEstimateSize,
  serialize: _episodeUserStateSerialize,
  deserialize: _episodeUserStateDeserialize,
  deserializeProp: _episodeUserStateDeserializeProp,
  idName: r'id',
  indexes: {
    r'episodeKey': IndexSchema(
      id: 7918532910150633644,
      name: r'episodeKey',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'episodeKey',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'podcastKey': IndexSchema(
      id: -7454521677690852339,
      name: r'podcastKey',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'podcastKey',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {r'EpisodePlayCounters': EpisodePlayCountersSchema},

  getId: _episodeUserStateGetId,
  getLinks: _episodeUserStateGetLinks,
  attach: _episodeUserStateAttach,
  version: '3.3.2',
);

int _episodeUserStateEstimateSize(
  EpisodeUserState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.counters.length * 3;
  {
    final offsets = allOffsets[EpisodePlayCounters]!;
    for (var i = 0; i < object.counters.length; i++) {
      final value = object.counters[i];
      bytesCount += EpisodePlayCountersSchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  bytesCount += 3 + object.episodeKey.length * 3;
  {
    final value = object.locatorAudioUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.locatorGuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.podcastKey.length * 3;
  return bytesCount;
}

void _episodeUserStateSerialize(
  EpisodeUserState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.completedAt);
  writer.writeLong(offsets[1], object.completedAtHlc);
  writer.writeObjectList<EpisodePlayCounters>(
    offsets[2],
    allOffsets,
    EpisodePlayCountersSchema.serialize,
    object.counters,
  );
  writer.writeLong(offsets[3], object.durationHlc);
  writer.writeLong(offsets[4], object.durationMs);
  writer.writeString(offsets[5], object.episodeKey);
  writer.writeDateTime(offsets[6], object.favoritedAt);
  writer.writeLong(offsets[7], object.favoritedAtHlc);
  writer.writeDateTime(offsets[8], object.firstPlayedAt);
  writer.writeLong(offsets[9], object.firstPlayedAtHlc);
  writer.writeBool(offsets[10], object.hasPlayback);
  writer.writeLong(offsets[11], object.hasPlaybackHlc);
  writer.writeBool(offsets[12], object.isReplayFromStart);
  writer.writeBool(offsets[13], object.isReplaying);
  writer.writeDateTime(offsets[14], object.lastPlayedAt);
  writer.writeLong(offsets[15], object.lastPlayedAtHlc);
  writer.writeString(offsets[16], object.locatorAudioUrl);
  writer.writeString(offsets[17], object.locatorGuid);
  writer.writeDateTime(offsets[18], object.locatorPublishedAt);
  writer.writeString(offsets[19], object.podcastKey);
  writer.writeLong(offsets[20], object.positionHlc);
  writer.writeLong(offsets[21], object.positionMs);
  writer.writeLong(offsets[22], object.replayHlc);
}

EpisodeUserState _episodeUserStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EpisodeUserState();
  object.completedAt = reader.readDateTimeOrNull(offsets[0]);
  object.completedAtHlc = reader.readLong(offsets[1]);
  object.counters =
      reader.readObjectList<EpisodePlayCounters>(
        offsets[2],
        EpisodePlayCountersSchema.deserialize,
        allOffsets,
        EpisodePlayCounters(),
      ) ??
      [];
  object.durationHlc = reader.readLong(offsets[3]);
  object.durationMs = reader.readLongOrNull(offsets[4]);
  object.episodeKey = reader.readString(offsets[5]);
  object.favoritedAt = reader.readDateTimeOrNull(offsets[6]);
  object.favoritedAtHlc = reader.readLong(offsets[7]);
  object.firstPlayedAt = reader.readDateTimeOrNull(offsets[8]);
  object.firstPlayedAtHlc = reader.readLong(offsets[9]);
  object.hasPlayback = reader.readBool(offsets[10]);
  object.hasPlaybackHlc = reader.readLong(offsets[11]);
  object.id = id;
  object.isReplayFromStart = reader.readBool(offsets[12]);
  object.isReplaying = reader.readBool(offsets[13]);
  object.lastPlayedAt = reader.readDateTimeOrNull(offsets[14]);
  object.lastPlayedAtHlc = reader.readLong(offsets[15]);
  object.locatorAudioUrl = reader.readStringOrNull(offsets[16]);
  object.locatorGuid = reader.readStringOrNull(offsets[17]);
  object.locatorPublishedAt = reader.readDateTimeOrNull(offsets[18]);
  object.podcastKey = reader.readString(offsets[19]);
  object.positionHlc = reader.readLong(offsets[20]);
  object.positionMs = reader.readLong(offsets[21]);
  object.replayHlc = reader.readLong(offsets[22]);
  return object;
}

P _episodeUserStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readObjectList<EpisodePlayCounters>(
                offset,
                EpisodePlayCountersSchema.deserialize,
                allOffsets,
                EpisodePlayCounters(),
              ) ??
              [])
          as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readBool(offset)) as P;
    case 14:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 19:
      return (reader.readString(offset)) as P;
    case 20:
      return (reader.readLong(offset)) as P;
    case 21:
      return (reader.readLong(offset)) as P;
    case 22:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _episodeUserStateGetId(EpisodeUserState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _episodeUserStateGetLinks(EpisodeUserState object) {
  return [];
}

void _episodeUserStateAttach(
  IsarCollection<dynamic> col,
  Id id,
  EpisodeUserState object,
) {
  object.id = id;
}

extension EpisodeUserStateByIndex on IsarCollection<EpisodeUserState> {
  Future<EpisodeUserState?> getByEpisodeKey(String episodeKey) {
    return getByIndex(r'episodeKey', [episodeKey]);
  }

  EpisodeUserState? getByEpisodeKeySync(String episodeKey) {
    return getByIndexSync(r'episodeKey', [episodeKey]);
  }

  Future<bool> deleteByEpisodeKey(String episodeKey) {
    return deleteByIndex(r'episodeKey', [episodeKey]);
  }

  bool deleteByEpisodeKeySync(String episodeKey) {
    return deleteByIndexSync(r'episodeKey', [episodeKey]);
  }

  Future<List<EpisodeUserState?>> getAllByEpisodeKey(
    List<String> episodeKeyValues,
  ) {
    final values = episodeKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'episodeKey', values);
  }

  List<EpisodeUserState?> getAllByEpisodeKeySync(
    List<String> episodeKeyValues,
  ) {
    final values = episodeKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'episodeKey', values);
  }

  Future<int> deleteAllByEpisodeKey(List<String> episodeKeyValues) {
    final values = episodeKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'episodeKey', values);
  }

  int deleteAllByEpisodeKeySync(List<String> episodeKeyValues) {
    final values = episodeKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'episodeKey', values);
  }

  Future<Id> putByEpisodeKey(EpisodeUserState object) {
    return putByIndex(r'episodeKey', object);
  }

  Id putByEpisodeKeySync(EpisodeUserState object, {bool saveLinks = true}) {
    return putByIndexSync(r'episodeKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByEpisodeKey(List<EpisodeUserState> objects) {
    return putAllByIndex(r'episodeKey', objects);
  }

  List<Id> putAllByEpisodeKeySync(
    List<EpisodeUserState> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'episodeKey', objects, saveLinks: saveLinks);
  }
}

extension EpisodeUserStateQueryWhereSort
    on QueryBuilder<EpisodeUserState, EpisodeUserState, QWhere> {
  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension EpisodeUserStateQueryWhere
    on QueryBuilder<EpisodeUserState, EpisodeUserState, QWhereClause> {
  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterWhereClause>
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

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterWhereClause> idBetween(
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

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterWhereClause>
  episodeKeyEqualTo(String episodeKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'episodeKey', value: [episodeKey]),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterWhereClause>
  episodeKeyNotEqualTo(String episodeKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'episodeKey',
                lower: [],
                upper: [episodeKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'episodeKey',
                lower: [episodeKey],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'episodeKey',
                lower: [episodeKey],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'episodeKey',
                lower: [],
                upper: [episodeKey],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterWhereClause>
  podcastKeyEqualTo(String podcastKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'podcastKey', value: [podcastKey]),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterWhereClause>
  podcastKeyNotEqualTo(String podcastKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastKey',
                lower: [],
                upper: [podcastKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastKey',
                lower: [podcastKey],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastKey',
                lower: [podcastKey],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastKey',
                lower: [],
                upper: [podcastKey],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension EpisodeUserStateQueryFilter
    on QueryBuilder<EpisodeUserState, EpisodeUserState, QFilterCondition> {
  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  completedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'completedAt'),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  completedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'completedAt'),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  completedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'completedAt', value: value),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  completedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'completedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  completedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'completedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  completedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'completedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  completedAtHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'completedAtHlc', value: value),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  completedAtHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'completedAtHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  completedAtHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'completedAtHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  completedAtHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'completedAtHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  countersLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'counters', length, true, length, true);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  countersIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'counters', 0, true, 0, true);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  countersIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'counters', 0, false, 999999, true);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  countersLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'counters', 0, true, length, include);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  countersLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'counters', length, include, 999999, true);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  countersLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'counters',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  durationHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'durationHlc', value: value),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  durationHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'durationHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  durationHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'durationHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  durationHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'durationHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  durationMsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'durationMs'),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  durationMsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'durationMs'),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  durationMsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'durationMs', value: value),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  durationMsGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'durationMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  durationMsLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'durationMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  durationMsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'durationMs',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  episodeKeyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'episodeKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  episodeKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'episodeKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  episodeKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'episodeKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  episodeKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'episodeKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  episodeKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'episodeKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  episodeKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'episodeKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  episodeKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'episodeKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  episodeKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'episodeKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  episodeKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'episodeKey', value: ''),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  episodeKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'episodeKey', value: ''),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  favoritedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'favoritedAt'),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  favoritedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'favoritedAt'),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  favoritedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'favoritedAt', value: value),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  favoritedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'favoritedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  favoritedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'favoritedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  favoritedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'favoritedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  favoritedAtHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'favoritedAtHlc', value: value),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  favoritedAtHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'favoritedAtHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  favoritedAtHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'favoritedAtHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  favoritedAtHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'favoritedAtHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  firstPlayedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'firstPlayedAt'),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  firstPlayedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'firstPlayedAt'),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  firstPlayedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'firstPlayedAt', value: value),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  firstPlayedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'firstPlayedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  firstPlayedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'firstPlayedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  firstPlayedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'firstPlayedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  firstPlayedAtHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'firstPlayedAtHlc', value: value),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  firstPlayedAtHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'firstPlayedAtHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  firstPlayedAtHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'firstPlayedAtHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  firstPlayedAtHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'firstPlayedAtHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  hasPlaybackEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hasPlayback', value: value),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  hasPlaybackHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hasPlaybackHlc', value: value),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  hasPlaybackHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'hasPlaybackHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  hasPlaybackHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'hasPlaybackHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  hasPlaybackHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'hasPlaybackHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
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

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
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

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
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

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  isReplayFromStartEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isReplayFromStart', value: value),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  isReplayingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isReplaying', value: value),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  lastPlayedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastPlayedAt'),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  lastPlayedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastPlayedAt'),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  lastPlayedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastPlayedAt', value: value),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  lastPlayedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastPlayedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  lastPlayedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastPlayedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  lastPlayedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastPlayedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  lastPlayedAtHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastPlayedAtHlc', value: value),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  lastPlayedAtHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastPlayedAtHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  lastPlayedAtHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastPlayedAtHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  lastPlayedAtHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastPlayedAtHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  locatorAudioUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'locatorAudioUrl'),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  locatorAudioUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'locatorAudioUrl'),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  locatorAudioUrlEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'locatorAudioUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  locatorAudioUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'locatorAudioUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  locatorAudioUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'locatorAudioUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  locatorAudioUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'locatorAudioUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  locatorAudioUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'locatorAudioUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  locatorAudioUrlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'locatorAudioUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  locatorAudioUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'locatorAudioUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  locatorAudioUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'locatorAudioUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  locatorAudioUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'locatorAudioUrl', value: ''),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  locatorAudioUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'locatorAudioUrl', value: ''),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  locatorGuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'locatorGuid'),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  locatorGuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'locatorGuid'),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  locatorGuidEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'locatorGuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  locatorGuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'locatorGuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  locatorGuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'locatorGuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  locatorGuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'locatorGuid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  locatorGuidStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'locatorGuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  locatorGuidEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'locatorGuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  locatorGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'locatorGuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  locatorGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'locatorGuid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  locatorGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'locatorGuid', value: ''),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  locatorGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'locatorGuid', value: ''),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  locatorPublishedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'locatorPublishedAt'),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  locatorPublishedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'locatorPublishedAt'),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  locatorPublishedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'locatorPublishedAt', value: value),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  locatorPublishedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'locatorPublishedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  locatorPublishedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'locatorPublishedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  locatorPublishedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'locatorPublishedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  podcastKeyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'podcastKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  podcastKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'podcastKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  podcastKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'podcastKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  podcastKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'podcastKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  podcastKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'podcastKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  podcastKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'podcastKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  podcastKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'podcastKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  podcastKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'podcastKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  podcastKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'podcastKey', value: ''),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  podcastKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'podcastKey', value: ''),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  positionHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'positionHlc', value: value),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  positionHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'positionHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  positionHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'positionHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  positionHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'positionHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  positionMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'positionMs', value: value),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  positionMsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'positionMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  positionMsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'positionMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  positionMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'positionMs',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  replayHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'replayHlc', value: value),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  replayHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'replayHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  replayHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'replayHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  replayHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'replayHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension EpisodeUserStateQueryObject
    on QueryBuilder<EpisodeUserState, EpisodeUserState, QFilterCondition> {
  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterFilterCondition>
  countersElement(FilterQuery<EpisodePlayCounters> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'counters');
    });
  }
}

extension EpisodeUserStateQueryLinks
    on QueryBuilder<EpisodeUserState, EpisodeUserState, QFilterCondition> {}

extension EpisodeUserStateQuerySortBy
    on QueryBuilder<EpisodeUserState, EpisodeUserState, QSortBy> {
  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByCompletedAtHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAtHlc', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByCompletedAtHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAtHlc', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByDurationHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationHlc', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByDurationHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationHlc', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMs', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByDurationMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMs', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByEpisodeKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeKey', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByEpisodeKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeKey', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByFavoritedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'favoritedAt', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByFavoritedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'favoritedAt', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByFavoritedAtHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'favoritedAtHlc', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByFavoritedAtHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'favoritedAtHlc', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByFirstPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstPlayedAt', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByFirstPlayedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstPlayedAt', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByFirstPlayedAtHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstPlayedAtHlc', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByFirstPlayedAtHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstPlayedAtHlc', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByHasPlayback() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPlayback', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByHasPlaybackDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPlayback', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByHasPlaybackHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPlaybackHlc', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByHasPlaybackHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPlaybackHlc', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByIsReplayFromStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReplayFromStart', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByIsReplayFromStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReplayFromStart', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByIsReplaying() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReplaying', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByIsReplayingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReplaying', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByLastPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAt', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByLastPlayedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAt', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByLastPlayedAtHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAtHlc', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByLastPlayedAtHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAtHlc', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByLocatorAudioUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locatorAudioUrl', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByLocatorAudioUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locatorAudioUrl', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByLocatorGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locatorGuid', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByLocatorGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locatorGuid', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByLocatorPublishedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locatorPublishedAt', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByLocatorPublishedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locatorPublishedAt', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByPodcastKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastKey', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByPodcastKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastKey', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByPositionHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionHlc', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByPositionHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionHlc', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByPositionMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionMs', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByPositionMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionMs', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByReplayHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'replayHlc', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  sortByReplayHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'replayHlc', Sort.desc);
    });
  }
}

extension EpisodeUserStateQuerySortThenBy
    on QueryBuilder<EpisodeUserState, EpisodeUserState, QSortThenBy> {
  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByCompletedAtHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAtHlc', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByCompletedAtHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAtHlc', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByDurationHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationHlc', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByDurationHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationHlc', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMs', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByDurationMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMs', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByEpisodeKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeKey', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByEpisodeKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeKey', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByFavoritedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'favoritedAt', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByFavoritedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'favoritedAt', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByFavoritedAtHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'favoritedAtHlc', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByFavoritedAtHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'favoritedAtHlc', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByFirstPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstPlayedAt', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByFirstPlayedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstPlayedAt', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByFirstPlayedAtHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstPlayedAtHlc', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByFirstPlayedAtHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstPlayedAtHlc', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByHasPlayback() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPlayback', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByHasPlaybackDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPlayback', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByHasPlaybackHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPlaybackHlc', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByHasPlaybackHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPlaybackHlc', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByIsReplayFromStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReplayFromStart', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByIsReplayFromStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReplayFromStart', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByIsReplaying() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReplaying', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByIsReplayingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReplaying', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByLastPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAt', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByLastPlayedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAt', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByLastPlayedAtHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAtHlc', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByLastPlayedAtHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAtHlc', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByLocatorAudioUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locatorAudioUrl', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByLocatorAudioUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locatorAudioUrl', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByLocatorGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locatorGuid', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByLocatorGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locatorGuid', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByLocatorPublishedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locatorPublishedAt', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByLocatorPublishedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locatorPublishedAt', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByPodcastKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastKey', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByPodcastKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastKey', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByPositionHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionHlc', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByPositionHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionHlc', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByPositionMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionMs', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByPositionMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionMs', Sort.desc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByReplayHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'replayHlc', Sort.asc);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QAfterSortBy>
  thenByReplayHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'replayHlc', Sort.desc);
    });
  }
}

extension EpisodeUserStateQueryWhereDistinct
    on QueryBuilder<EpisodeUserState, EpisodeUserState, QDistinct> {
  QueryBuilder<EpisodeUserState, EpisodeUserState, QDistinct>
  distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAt');
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QDistinct>
  distinctByCompletedAtHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAtHlc');
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QDistinct>
  distinctByDurationHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationHlc');
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QDistinct>
  distinctByDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationMs');
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QDistinct>
  distinctByEpisodeKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'episodeKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QDistinct>
  distinctByFavoritedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'favoritedAt');
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QDistinct>
  distinctByFavoritedAtHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'favoritedAtHlc');
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QDistinct>
  distinctByFirstPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'firstPlayedAt');
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QDistinct>
  distinctByFirstPlayedAtHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'firstPlayedAtHlc');
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QDistinct>
  distinctByHasPlayback() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasPlayback');
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QDistinct>
  distinctByHasPlaybackHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasPlaybackHlc');
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QDistinct>
  distinctByIsReplayFromStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isReplayFromStart');
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QDistinct>
  distinctByIsReplaying() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isReplaying');
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QDistinct>
  distinctByLastPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPlayedAt');
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QDistinct>
  distinctByLastPlayedAtHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPlayedAtHlc');
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QDistinct>
  distinctByLocatorAudioUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'locatorAudioUrl',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QDistinct>
  distinctByLocatorGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'locatorGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QDistinct>
  distinctByLocatorPublishedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'locatorPublishedAt');
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QDistinct>
  distinctByPodcastKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'podcastKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QDistinct>
  distinctByPositionHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'positionHlc');
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QDistinct>
  distinctByPositionMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'positionMs');
    });
  }

  QueryBuilder<EpisodeUserState, EpisodeUserState, QDistinct>
  distinctByReplayHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'replayHlc');
    });
  }
}

extension EpisodeUserStateQueryProperty
    on QueryBuilder<EpisodeUserState, EpisodeUserState, QQueryProperty> {
  QueryBuilder<EpisodeUserState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<EpisodeUserState, DateTime?, QQueryOperations>
  completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAt');
    });
  }

  QueryBuilder<EpisodeUserState, int, QQueryOperations>
  completedAtHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAtHlc');
    });
  }

  QueryBuilder<EpisodeUserState, List<EpisodePlayCounters>, QQueryOperations>
  countersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'counters');
    });
  }

  QueryBuilder<EpisodeUserState, int, QQueryOperations> durationHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationHlc');
    });
  }

  QueryBuilder<EpisodeUserState, int?, QQueryOperations> durationMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationMs');
    });
  }

  QueryBuilder<EpisodeUserState, String, QQueryOperations>
  episodeKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodeKey');
    });
  }

  QueryBuilder<EpisodeUserState, DateTime?, QQueryOperations>
  favoritedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'favoritedAt');
    });
  }

  QueryBuilder<EpisodeUserState, int, QQueryOperations>
  favoritedAtHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'favoritedAtHlc');
    });
  }

  QueryBuilder<EpisodeUserState, DateTime?, QQueryOperations>
  firstPlayedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'firstPlayedAt');
    });
  }

  QueryBuilder<EpisodeUserState, int, QQueryOperations>
  firstPlayedAtHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'firstPlayedAtHlc');
    });
  }

  QueryBuilder<EpisodeUserState, bool, QQueryOperations> hasPlaybackProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasPlayback');
    });
  }

  QueryBuilder<EpisodeUserState, int, QQueryOperations>
  hasPlaybackHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasPlaybackHlc');
    });
  }

  QueryBuilder<EpisodeUserState, bool, QQueryOperations>
  isReplayFromStartProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isReplayFromStart');
    });
  }

  QueryBuilder<EpisodeUserState, bool, QQueryOperations> isReplayingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isReplaying');
    });
  }

  QueryBuilder<EpisodeUserState, DateTime?, QQueryOperations>
  lastPlayedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPlayedAt');
    });
  }

  QueryBuilder<EpisodeUserState, int, QQueryOperations>
  lastPlayedAtHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPlayedAtHlc');
    });
  }

  QueryBuilder<EpisodeUserState, String?, QQueryOperations>
  locatorAudioUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'locatorAudioUrl');
    });
  }

  QueryBuilder<EpisodeUserState, String?, QQueryOperations>
  locatorGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'locatorGuid');
    });
  }

  QueryBuilder<EpisodeUserState, DateTime?, QQueryOperations>
  locatorPublishedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'locatorPublishedAt');
    });
  }

  QueryBuilder<EpisodeUserState, String, QQueryOperations>
  podcastKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'podcastKey');
    });
  }

  QueryBuilder<EpisodeUserState, int, QQueryOperations> positionHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'positionHlc');
    });
  }

  QueryBuilder<EpisodeUserState, int, QQueryOperations> positionMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'positionMs');
    });
  }

  QueryBuilder<EpisodeUserState, int, QQueryOperations> replayHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'replayHlc');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

const EpisodePlayCountersSchema = Schema(
  name: r'EpisodePlayCounters',
  id: 6820696752923658368,
  properties: {
    r'completedCount': PropertySchema(
      id: 0,
      name: r'completedCount',
      type: IsarType.long,
    ),
    r'deviceId': PropertySchema(
      id: 1,
      name: r'deviceId',
      type: IsarType.string,
    ),
    r'listenedMs': PropertySchema(
      id: 2,
      name: r'listenedMs',
      type: IsarType.long,
    ),
    r'playCount': PropertySchema(
      id: 3,
      name: r'playCount',
      type: IsarType.long,
    ),
    r'realtimeMs': PropertySchema(
      id: 4,
      name: r'realtimeMs',
      type: IsarType.long,
    ),
  },

  estimateSize: _episodePlayCountersEstimateSize,
  serialize: _episodePlayCountersSerialize,
  deserialize: _episodePlayCountersDeserialize,
  deserializeProp: _episodePlayCountersDeserializeProp,
);

int _episodePlayCountersEstimateSize(
  EpisodePlayCounters object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.deviceId.length * 3;
  return bytesCount;
}

void _episodePlayCountersSerialize(
  EpisodePlayCounters object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.completedCount);
  writer.writeString(offsets[1], object.deviceId);
  writer.writeLong(offsets[2], object.listenedMs);
  writer.writeLong(offsets[3], object.playCount);
  writer.writeLong(offsets[4], object.realtimeMs);
}

EpisodePlayCounters _episodePlayCountersDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EpisodePlayCounters();
  object.completedCount = reader.readLong(offsets[0]);
  object.deviceId = reader.readString(offsets[1]);
  object.listenedMs = reader.readLong(offsets[2]);
  object.playCount = reader.readLong(offsets[3]);
  object.realtimeMs = reader.readLong(offsets[4]);
  return object;
}

P _episodePlayCountersDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension EpisodePlayCountersQueryFilter
    on
        QueryBuilder<
          EpisodePlayCounters,
          EpisodePlayCounters,
          QFilterCondition
        > {
  QueryBuilder<EpisodePlayCounters, EpisodePlayCounters, QAfterFilterCondition>
  completedCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'completedCount', value: value),
      );
    });
  }

  QueryBuilder<EpisodePlayCounters, EpisodePlayCounters, QAfterFilterCondition>
  completedCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'completedCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodePlayCounters, EpisodePlayCounters, QAfterFilterCondition>
  completedCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'completedCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodePlayCounters, EpisodePlayCounters, QAfterFilterCondition>
  completedCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'completedCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EpisodePlayCounters, EpisodePlayCounters, QAfterFilterCondition>
  deviceIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodePlayCounters, EpisodePlayCounters, QAfterFilterCondition>
  deviceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodePlayCounters, EpisodePlayCounters, QAfterFilterCondition>
  deviceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodePlayCounters, EpisodePlayCounters, QAfterFilterCondition>
  deviceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'deviceId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodePlayCounters, EpisodePlayCounters, QAfterFilterCondition>
  deviceIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodePlayCounters, EpisodePlayCounters, QAfterFilterCondition>
  deviceIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodePlayCounters, EpisodePlayCounters, QAfterFilterCondition>
  deviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodePlayCounters, EpisodePlayCounters, QAfterFilterCondition>
  deviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'deviceId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodePlayCounters, EpisodePlayCounters, QAfterFilterCondition>
  deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deviceId', value: ''),
      );
    });
  }

  QueryBuilder<EpisodePlayCounters, EpisodePlayCounters, QAfterFilterCondition>
  deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'deviceId', value: ''),
      );
    });
  }

  QueryBuilder<EpisodePlayCounters, EpisodePlayCounters, QAfterFilterCondition>
  listenedMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'listenedMs', value: value),
      );
    });
  }

  QueryBuilder<EpisodePlayCounters, EpisodePlayCounters, QAfterFilterCondition>
  listenedMsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'listenedMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodePlayCounters, EpisodePlayCounters, QAfterFilterCondition>
  listenedMsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'listenedMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodePlayCounters, EpisodePlayCounters, QAfterFilterCondition>
  listenedMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'listenedMs',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EpisodePlayCounters, EpisodePlayCounters, QAfterFilterCondition>
  playCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'playCount', value: value),
      );
    });
  }

  QueryBuilder<EpisodePlayCounters, EpisodePlayCounters, QAfterFilterCondition>
  playCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'playCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodePlayCounters, EpisodePlayCounters, QAfterFilterCondition>
  playCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'playCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodePlayCounters, EpisodePlayCounters, QAfterFilterCondition>
  playCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'playCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EpisodePlayCounters, EpisodePlayCounters, QAfterFilterCondition>
  realtimeMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'realtimeMs', value: value),
      );
    });
  }

  QueryBuilder<EpisodePlayCounters, EpisodePlayCounters, QAfterFilterCondition>
  realtimeMsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'realtimeMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodePlayCounters, EpisodePlayCounters, QAfterFilterCondition>
  realtimeMsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'realtimeMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodePlayCounters, EpisodePlayCounters, QAfterFilterCondition>
  realtimeMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'realtimeMs',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension EpisodePlayCountersQueryObject
    on
        QueryBuilder<
          EpisodePlayCounters,
          EpisodePlayCounters,
          QFilterCondition
        > {}
