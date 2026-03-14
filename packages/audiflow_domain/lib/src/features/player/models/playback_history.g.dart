// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_history.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPlaybackHistoryCollection on Isar {
  IsarCollection<PlaybackHistory> get playbackHistorys => this.collection();
}

const PlaybackHistorySchema = CollectionSchema(
  name: r'PlaybackHistory',
  id: 7697439866406454766,
  properties: {
    r'completedAt': PropertySchema(
      id: 0,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'durationMs': PropertySchema(
      id: 1,
      name: r'durationMs',
      type: IsarType.long,
    ),
    r'episodeId': PropertySchema(
      id: 2,
      name: r'episodeId',
      type: IsarType.long,
    ),
    r'firstPlayedAt': PropertySchema(
      id: 3,
      name: r'firstPlayedAt',
      type: IsarType.dateTime,
    ),
    r'lastPlayedAt': PropertySchema(
      id: 4,
      name: r'lastPlayedAt',
      type: IsarType.dateTime,
    ),
    r'playCount': PropertySchema(
      id: 5,
      name: r'playCount',
      type: IsarType.long,
    ),
    r'positionMs': PropertySchema(
      id: 6,
      name: r'positionMs',
      type: IsarType.long,
    ),
  },

  estimateSize: _playbackHistoryEstimateSize,
  serialize: _playbackHistorySerialize,
  deserialize: _playbackHistoryDeserialize,
  deserializeProp: _playbackHistoryDeserializeProp,
  idName: r'id',
  indexes: {
    r'episodeId': IndexSchema(
      id: -5445487708405506290,
      name: r'episodeId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'episodeId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _playbackHistoryGetId,
  getLinks: _playbackHistoryGetLinks,
  attach: _playbackHistoryAttach,
  version: '3.3.0',
);

int _playbackHistoryEstimateSize(
  PlaybackHistory object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _playbackHistorySerialize(
  PlaybackHistory object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.completedAt);
  writer.writeLong(offsets[1], object.durationMs);
  writer.writeLong(offsets[2], object.episodeId);
  writer.writeDateTime(offsets[3], object.firstPlayedAt);
  writer.writeDateTime(offsets[4], object.lastPlayedAt);
  writer.writeLong(offsets[5], object.playCount);
  writer.writeLong(offsets[6], object.positionMs);
}

PlaybackHistory _playbackHistoryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlaybackHistory();
  object.completedAt = reader.readDateTimeOrNull(offsets[0]);
  object.durationMs = reader.readLongOrNull(offsets[1]);
  object.episodeId = reader.readLong(offsets[2]);
  object.firstPlayedAt = reader.readDateTimeOrNull(offsets[3]);
  object.id = id;
  object.lastPlayedAt = reader.readDateTimeOrNull(offsets[4]);
  object.playCount = reader.readLong(offsets[5]);
  object.positionMs = reader.readLong(offsets[6]);
  return object;
}

P _playbackHistoryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _playbackHistoryGetId(PlaybackHistory object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _playbackHistoryGetLinks(PlaybackHistory object) {
  return [];
}

void _playbackHistoryAttach(
  IsarCollection<dynamic> col,
  Id id,
  PlaybackHistory object,
) {
  object.id = id;
}

extension PlaybackHistoryByIndex on IsarCollection<PlaybackHistory> {
  Future<PlaybackHistory?> getByEpisodeId(int episodeId) {
    return getByIndex(r'episodeId', [episodeId]);
  }

  PlaybackHistory? getByEpisodeIdSync(int episodeId) {
    return getByIndexSync(r'episodeId', [episodeId]);
  }

  Future<bool> deleteByEpisodeId(int episodeId) {
    return deleteByIndex(r'episodeId', [episodeId]);
  }

  bool deleteByEpisodeIdSync(int episodeId) {
    return deleteByIndexSync(r'episodeId', [episodeId]);
  }

  Future<List<PlaybackHistory?>> getAllByEpisodeId(List<int> episodeIdValues) {
    final values = episodeIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'episodeId', values);
  }

  List<PlaybackHistory?> getAllByEpisodeIdSync(List<int> episodeIdValues) {
    final values = episodeIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'episodeId', values);
  }

  Future<int> deleteAllByEpisodeId(List<int> episodeIdValues) {
    final values = episodeIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'episodeId', values);
  }

  int deleteAllByEpisodeIdSync(List<int> episodeIdValues) {
    final values = episodeIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'episodeId', values);
  }

  Future<Id> putByEpisodeId(PlaybackHistory object) {
    return putByIndex(r'episodeId', object);
  }

  Id putByEpisodeIdSync(PlaybackHistory object, {bool saveLinks = true}) {
    return putByIndexSync(r'episodeId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByEpisodeId(List<PlaybackHistory> objects) {
    return putAllByIndex(r'episodeId', objects);
  }

  List<Id> putAllByEpisodeIdSync(
    List<PlaybackHistory> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'episodeId', objects, saveLinks: saveLinks);
  }
}

extension PlaybackHistoryQueryWhereSort
    on QueryBuilder<PlaybackHistory, PlaybackHistory, QWhere> {
  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterWhere> anyEpisodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'episodeId'),
      );
    });
  }
}

extension PlaybackHistoryQueryWhere
    on QueryBuilder<PlaybackHistory, PlaybackHistory, QWhereClause> {
  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterWhereClause>
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

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterWhereClause> idBetween(
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

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterWhereClause>
  episodeIdEqualTo(int episodeId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'episodeId', value: [episodeId]),
      );
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterWhereClause>
  episodeIdNotEqualTo(int episodeId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'episodeId',
                lower: [],
                upper: [episodeId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'episodeId',
                lower: [episodeId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'episodeId',
                lower: [episodeId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'episodeId',
                lower: [],
                upper: [episodeId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterWhereClause>
  episodeIdGreaterThan(int episodeId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'episodeId',
          lower: [episodeId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterWhereClause>
  episodeIdLessThan(int episodeId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'episodeId',
          lower: [],
          upper: [episodeId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterWhereClause>
  episodeIdBetween(
    int lowerEpisodeId,
    int upperEpisodeId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'episodeId',
          lower: [lowerEpisodeId],
          includeLower: includeLower,
          upper: [upperEpisodeId],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension PlaybackHistoryQueryFilter
    on QueryBuilder<PlaybackHistory, PlaybackHistory, QFilterCondition> {
  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
  completedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'completedAt'),
      );
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
  completedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'completedAt'),
      );
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
  completedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'completedAt', value: value),
      );
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
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

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
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

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
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

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
  durationMsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'durationMs'),
      );
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
  durationMsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'durationMs'),
      );
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
  durationMsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'durationMs', value: value),
      );
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
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

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
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

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
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

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
  episodeIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'episodeId', value: value),
      );
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
  episodeIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'episodeId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
  episodeIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'episodeId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
  episodeIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'episodeId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
  firstPlayedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'firstPlayedAt'),
      );
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
  firstPlayedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'firstPlayedAt'),
      );
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
  firstPlayedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'firstPlayedAt', value: value),
      );
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
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

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
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

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
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

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
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

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
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

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
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

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
  lastPlayedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastPlayedAt'),
      );
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
  lastPlayedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastPlayedAt'),
      );
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
  lastPlayedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastPlayedAt', value: value),
      );
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
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

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
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

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
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

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
  playCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'playCount', value: value),
      );
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
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

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
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

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
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

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
  positionMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'positionMs', value: value),
      );
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
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

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
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

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterFilterCondition>
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
}

extension PlaybackHistoryQueryObject
    on QueryBuilder<PlaybackHistory, PlaybackHistory, QFilterCondition> {}

extension PlaybackHistoryQueryLinks
    on QueryBuilder<PlaybackHistory, PlaybackHistory, QFilterCondition> {}

extension PlaybackHistoryQuerySortBy
    on QueryBuilder<PlaybackHistory, PlaybackHistory, QSortBy> {
  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterSortBy>
  sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterSortBy>
  sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterSortBy>
  sortByDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMs', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterSortBy>
  sortByDurationMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMs', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterSortBy>
  sortByEpisodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeId', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterSortBy>
  sortByEpisodeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeId', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterSortBy>
  sortByFirstPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstPlayedAt', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterSortBy>
  sortByFirstPlayedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstPlayedAt', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterSortBy>
  sortByLastPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAt', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterSortBy>
  sortByLastPlayedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAt', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterSortBy>
  sortByPlayCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playCount', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterSortBy>
  sortByPlayCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playCount', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterSortBy>
  sortByPositionMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionMs', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterSortBy>
  sortByPositionMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionMs', Sort.desc);
    });
  }
}

extension PlaybackHistoryQuerySortThenBy
    on QueryBuilder<PlaybackHistory, PlaybackHistory, QSortThenBy> {
  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterSortBy>
  thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterSortBy>
  thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterSortBy>
  thenByDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMs', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterSortBy>
  thenByDurationMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMs', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterSortBy>
  thenByEpisodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeId', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterSortBy>
  thenByEpisodeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeId', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterSortBy>
  thenByFirstPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstPlayedAt', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterSortBy>
  thenByFirstPlayedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstPlayedAt', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterSortBy>
  thenByLastPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAt', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterSortBy>
  thenByLastPlayedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAt', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterSortBy>
  thenByPlayCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playCount', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterSortBy>
  thenByPlayCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playCount', Sort.desc);
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterSortBy>
  thenByPositionMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionMs', Sort.asc);
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QAfterSortBy>
  thenByPositionMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionMs', Sort.desc);
    });
  }
}

extension PlaybackHistoryQueryWhereDistinct
    on QueryBuilder<PlaybackHistory, PlaybackHistory, QDistinct> {
  QueryBuilder<PlaybackHistory, PlaybackHistory, QDistinct>
  distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAt');
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QDistinct>
  distinctByDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationMs');
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QDistinct>
  distinctByEpisodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'episodeId');
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QDistinct>
  distinctByFirstPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'firstPlayedAt');
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QDistinct>
  distinctByLastPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPlayedAt');
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QDistinct>
  distinctByPlayCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playCount');
    });
  }

  QueryBuilder<PlaybackHistory, PlaybackHistory, QDistinct>
  distinctByPositionMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'positionMs');
    });
  }
}

extension PlaybackHistoryQueryProperty
    on QueryBuilder<PlaybackHistory, PlaybackHistory, QQueryProperty> {
  QueryBuilder<PlaybackHistory, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PlaybackHistory, DateTime?, QQueryOperations>
  completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAt');
    });
  }

  QueryBuilder<PlaybackHistory, int?, QQueryOperations> durationMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationMs');
    });
  }

  QueryBuilder<PlaybackHistory, int, QQueryOperations> episodeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodeId');
    });
  }

  QueryBuilder<PlaybackHistory, DateTime?, QQueryOperations>
  firstPlayedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'firstPlayedAt');
    });
  }

  QueryBuilder<PlaybackHistory, DateTime?, QQueryOperations>
  lastPlayedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPlayedAt');
    });
  }

  QueryBuilder<PlaybackHistory, int, QQueryOperations> playCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playCount');
    });
  }

  QueryBuilder<PlaybackHistory, int, QQueryOperations> positionMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'positionMs');
    });
  }
}
