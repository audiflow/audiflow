// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station_state.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetStationStateCollection on Isar {
  IsarCollection<StationState> get stationStates => this.collection();
}

const StationStateSchema = CollectionSchema(
  name: r'StationState',
  id: -1089930897125381748,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'defaultEpisodeLimit': PropertySchema(
      id: 1,
      name: r'defaultEpisodeLimit',
      type: IsarType.long,
    ),
    r'defaultEpisodeLimitHlc': PropertySchema(
      id: 2,
      name: r'defaultEpisodeLimitHlc',
      type: IsarType.long,
    ),
    r'deleted': PropertySchema(id: 3, name: r'deleted', type: IsarType.bool),
    r'deletedHlc': PropertySchema(
      id: 4,
      name: r'deletedHlc',
      type: IsarType.long,
    ),
    r'durationFilterHlc': PropertySchema(
      id: 5,
      name: r'durationFilterHlc',
      type: IsarType.long,
    ),
    r'durationMinutes': PropertySchema(
      id: 6,
      name: r'durationMinutes',
      type: IsarType.long,
    ),
    r'durationOperator': PropertySchema(
      id: 7,
      name: r'durationOperator',
      type: IsarType.string,
    ),
    r'episodeSortType': PropertySchema(
      id: 8,
      name: r'episodeSortType',
      type: IsarType.string,
    ),
    r'episodeSortTypeHlc': PropertySchema(
      id: 9,
      name: r'episodeSortTypeHlc',
      type: IsarType.long,
    ),
    r'filterDownloaded': PropertySchema(
      id: 10,
      name: r'filterDownloaded',
      type: IsarType.bool,
    ),
    r'filterDownloadedHlc': PropertySchema(
      id: 11,
      name: r'filterDownloadedHlc',
      type: IsarType.long,
    ),
    r'filterFavorited': PropertySchema(
      id: 12,
      name: r'filterFavorited',
      type: IsarType.bool,
    ),
    r'filterFavoritedHlc': PropertySchema(
      id: 13,
      name: r'filterFavoritedHlc',
      type: IsarType.long,
    ),
    r'groupByPodcast': PropertySchema(
      id: 14,
      name: r'groupByPodcast',
      type: IsarType.bool,
    ),
    r'groupByPodcastHlc': PropertySchema(
      id: 15,
      name: r'groupByPodcastHlc',
      type: IsarType.long,
    ),
    r'hideCompleted': PropertySchema(
      id: 16,
      name: r'hideCompleted',
      type: IsarType.bool,
    ),
    r'hideCompletedHlc': PropertySchema(
      id: 17,
      name: r'hideCompletedHlc',
      type: IsarType.long,
    ),
    r'lastPlayedAt': PropertySchema(
      id: 18,
      name: r'lastPlayedAt',
      type: IsarType.dateTime,
    ),
    r'lastPlayedAtHlc': PropertySchema(
      id: 19,
      name: r'lastPlayedAtHlc',
      type: IsarType.long,
    ),
    r'name': PropertySchema(id: 20, name: r'name', type: IsarType.string),
    r'nameHlc': PropertySchema(id: 21, name: r'nameHlc', type: IsarType.long),
    r'podcastSortType': PropertySchema(
      id: 22,
      name: r'podcastSortType',
      type: IsarType.string,
    ),
    r'podcastSortTypeHlc': PropertySchema(
      id: 23,
      name: r'podcastSortTypeHlc',
      type: IsarType.long,
    ),
    r'publishedWithinDays': PropertySchema(
      id: 24,
      name: r'publishedWithinDays',
      type: IsarType.long,
    ),
    r'publishedWithinDaysHlc': PropertySchema(
      id: 25,
      name: r'publishedWithinDaysHlc',
      type: IsarType.long,
    ),
    r'sortOrder': PropertySchema(
      id: 26,
      name: r'sortOrder',
      type: IsarType.long,
    ),
    r'sortOrderHlc': PropertySchema(
      id: 27,
      name: r'sortOrderHlc',
      type: IsarType.long,
    ),
    r'stationId': PropertySchema(
      id: 28,
      name: r'stationId',
      type: IsarType.string,
    ),
  },

  estimateSize: _stationStateEstimateSize,
  serialize: _stationStateSerialize,
  deserialize: _stationStateDeserialize,
  deserializeProp: _stationStateDeserializeProp,
  idName: r'id',
  indexes: {
    r'stationId': IndexSchema(
      id: 4702835299779894007,
      name: r'stationId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'stationId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _stationStateGetId,
  getLinks: _stationStateGetLinks,
  attach: _stationStateAttach,
  version: '3.3.2',
);

int _stationStateEstimateSize(
  StationState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.durationOperator;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.episodeSortType.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.podcastSortType.length * 3;
  bytesCount += 3 + object.stationId.length * 3;
  return bytesCount;
}

void _stationStateSerialize(
  StationState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeLong(offsets[1], object.defaultEpisodeLimit);
  writer.writeLong(offsets[2], object.defaultEpisodeLimitHlc);
  writer.writeBool(offsets[3], object.deleted);
  writer.writeLong(offsets[4], object.deletedHlc);
  writer.writeLong(offsets[5], object.durationFilterHlc);
  writer.writeLong(offsets[6], object.durationMinutes);
  writer.writeString(offsets[7], object.durationOperator);
  writer.writeString(offsets[8], object.episodeSortType);
  writer.writeLong(offsets[9], object.episodeSortTypeHlc);
  writer.writeBool(offsets[10], object.filterDownloaded);
  writer.writeLong(offsets[11], object.filterDownloadedHlc);
  writer.writeBool(offsets[12], object.filterFavorited);
  writer.writeLong(offsets[13], object.filterFavoritedHlc);
  writer.writeBool(offsets[14], object.groupByPodcast);
  writer.writeLong(offsets[15], object.groupByPodcastHlc);
  writer.writeBool(offsets[16], object.hideCompleted);
  writer.writeLong(offsets[17], object.hideCompletedHlc);
  writer.writeDateTime(offsets[18], object.lastPlayedAt);
  writer.writeLong(offsets[19], object.lastPlayedAtHlc);
  writer.writeString(offsets[20], object.name);
  writer.writeLong(offsets[21], object.nameHlc);
  writer.writeString(offsets[22], object.podcastSortType);
  writer.writeLong(offsets[23], object.podcastSortTypeHlc);
  writer.writeLong(offsets[24], object.publishedWithinDays);
  writer.writeLong(offsets[25], object.publishedWithinDaysHlc);
  writer.writeLong(offsets[26], object.sortOrder);
  writer.writeLong(offsets[27], object.sortOrderHlc);
  writer.writeString(offsets[28], object.stationId);
}

StationState _stationStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StationState();
  object.createdAt = reader.readDateTimeOrNull(offsets[0]);
  object.defaultEpisodeLimit = reader.readLongOrNull(offsets[1]);
  object.defaultEpisodeLimitHlc = reader.readLong(offsets[2]);
  object.deleted = reader.readBool(offsets[3]);
  object.deletedHlc = reader.readLong(offsets[4]);
  object.durationFilterHlc = reader.readLong(offsets[5]);
  object.durationMinutes = reader.readLong(offsets[6]);
  object.durationOperator = reader.readStringOrNull(offsets[7]);
  object.episodeSortType = reader.readString(offsets[8]);
  object.episodeSortTypeHlc = reader.readLong(offsets[9]);
  object.filterDownloaded = reader.readBool(offsets[10]);
  object.filterDownloadedHlc = reader.readLong(offsets[11]);
  object.filterFavorited = reader.readBool(offsets[12]);
  object.filterFavoritedHlc = reader.readLong(offsets[13]);
  object.groupByPodcast = reader.readBool(offsets[14]);
  object.groupByPodcastHlc = reader.readLong(offsets[15]);
  object.hideCompleted = reader.readBool(offsets[16]);
  object.hideCompletedHlc = reader.readLong(offsets[17]);
  object.id = id;
  object.lastPlayedAt = reader.readDateTimeOrNull(offsets[18]);
  object.lastPlayedAtHlc = reader.readLong(offsets[19]);
  object.name = reader.readString(offsets[20]);
  object.nameHlc = reader.readLong(offsets[21]);
  object.podcastSortType = reader.readString(offsets[22]);
  object.podcastSortTypeHlc = reader.readLong(offsets[23]);
  object.publishedWithinDays = reader.readLongOrNull(offsets[24]);
  object.publishedWithinDaysHlc = reader.readLong(offsets[25]);
  object.sortOrder = reader.readLong(offsets[26]);
  object.sortOrderHlc = reader.readLong(offsets[27]);
  object.stationId = reader.readString(offsets[28]);
  return object;
}

P _stationStateDeserializeProp<P>(
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
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readBool(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    case 16:
      return (reader.readBool(offset)) as P;
    case 17:
      return (reader.readLong(offset)) as P;
    case 18:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 19:
      return (reader.readLong(offset)) as P;
    case 20:
      return (reader.readString(offset)) as P;
    case 21:
      return (reader.readLong(offset)) as P;
    case 22:
      return (reader.readString(offset)) as P;
    case 23:
      return (reader.readLong(offset)) as P;
    case 24:
      return (reader.readLongOrNull(offset)) as P;
    case 25:
      return (reader.readLong(offset)) as P;
    case 26:
      return (reader.readLong(offset)) as P;
    case 27:
      return (reader.readLong(offset)) as P;
    case 28:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _stationStateGetId(StationState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _stationStateGetLinks(StationState object) {
  return [];
}

void _stationStateAttach(
  IsarCollection<dynamic> col,
  Id id,
  StationState object,
) {
  object.id = id;
}

extension StationStateByIndex on IsarCollection<StationState> {
  Future<StationState?> getByStationId(String stationId) {
    return getByIndex(r'stationId', [stationId]);
  }

  StationState? getByStationIdSync(String stationId) {
    return getByIndexSync(r'stationId', [stationId]);
  }

  Future<bool> deleteByStationId(String stationId) {
    return deleteByIndex(r'stationId', [stationId]);
  }

  bool deleteByStationIdSync(String stationId) {
    return deleteByIndexSync(r'stationId', [stationId]);
  }

  Future<List<StationState?>> getAllByStationId(List<String> stationIdValues) {
    final values = stationIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'stationId', values);
  }

  List<StationState?> getAllByStationIdSync(List<String> stationIdValues) {
    final values = stationIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'stationId', values);
  }

  Future<int> deleteAllByStationId(List<String> stationIdValues) {
    final values = stationIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'stationId', values);
  }

  int deleteAllByStationIdSync(List<String> stationIdValues) {
    final values = stationIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'stationId', values);
  }

  Future<Id> putByStationId(StationState object) {
    return putByIndex(r'stationId', object);
  }

  Id putByStationIdSync(StationState object, {bool saveLinks = true}) {
    return putByIndexSync(r'stationId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByStationId(List<StationState> objects) {
    return putAllByIndex(r'stationId', objects);
  }

  List<Id> putAllByStationIdSync(
    List<StationState> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'stationId', objects, saveLinks: saveLinks);
  }
}

extension StationStateQueryWhereSort
    on QueryBuilder<StationState, StationState, QWhere> {
  QueryBuilder<StationState, StationState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension StationStateQueryWhere
    on QueryBuilder<StationState, StationState, QWhereClause> {
  QueryBuilder<StationState, StationState, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<StationState, StationState, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<StationState, StationState, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterWhereClause> idBetween(
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

  QueryBuilder<StationState, StationState, QAfterWhereClause> stationIdEqualTo(
    String stationId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'stationId', value: [stationId]),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterWhereClause>
  stationIdNotEqualTo(String stationId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stationId',
                lower: [],
                upper: [stationId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stationId',
                lower: [stationId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stationId',
                lower: [stationId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stationId',
                lower: [],
                upper: [stationId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension StationStateQueryFilter
    on QueryBuilder<StationState, StationState, QFilterCondition> {
  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'createdAt'),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'createdAt'),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  createdAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  createdAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  createdAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  defaultEpisodeLimitIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'defaultEpisodeLimit'),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  defaultEpisodeLimitIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'defaultEpisodeLimit'),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  defaultEpisodeLimitEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'defaultEpisodeLimit', value: value),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  defaultEpisodeLimitGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'defaultEpisodeLimit',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  defaultEpisodeLimitLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'defaultEpisodeLimit',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  defaultEpisodeLimitBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'defaultEpisodeLimit',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  defaultEpisodeLimitHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'defaultEpisodeLimitHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  defaultEpisodeLimitHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'defaultEpisodeLimitHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  defaultEpisodeLimitHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'defaultEpisodeLimitHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  defaultEpisodeLimitHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'defaultEpisodeLimitHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  deletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deleted', value: value),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  deletedHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deletedHlc', value: value),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  deletedHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'deletedHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  deletedHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'deletedHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  deletedHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'deletedHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  durationFilterHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'durationFilterHlc', value: value),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  durationFilterHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'durationFilterHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  durationFilterHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'durationFilterHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  durationFilterHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'durationFilterHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  durationMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'durationMinutes', value: value),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  durationMinutesGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'durationMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  durationMinutesLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'durationMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  durationMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'durationMinutes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  durationOperatorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'durationOperator'),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  durationOperatorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'durationOperator'),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  durationOperatorEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'durationOperator',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  durationOperatorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'durationOperator',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  durationOperatorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'durationOperator',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  durationOperatorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'durationOperator',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  durationOperatorStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'durationOperator',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  durationOperatorEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'durationOperator',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  durationOperatorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'durationOperator',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  durationOperatorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'durationOperator',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  durationOperatorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'durationOperator', value: ''),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  durationOperatorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'durationOperator', value: ''),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  episodeSortTypeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'episodeSortType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  episodeSortTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'episodeSortType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  episodeSortTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'episodeSortType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  episodeSortTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'episodeSortType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  episodeSortTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'episodeSortType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  episodeSortTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'episodeSortType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  episodeSortTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'episodeSortType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  episodeSortTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'episodeSortType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  episodeSortTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'episodeSortType', value: ''),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  episodeSortTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'episodeSortType', value: ''),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  episodeSortTypeHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'episodeSortTypeHlc', value: value),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  episodeSortTypeHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'episodeSortTypeHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  episodeSortTypeHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'episodeSortTypeHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  episodeSortTypeHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'episodeSortTypeHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  filterDownloadedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'filterDownloaded', value: value),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  filterDownloadedHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'filterDownloadedHlc', value: value),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  filterDownloadedHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'filterDownloadedHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  filterDownloadedHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'filterDownloadedHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  filterDownloadedHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'filterDownloadedHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  filterFavoritedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'filterFavorited', value: value),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  filterFavoritedHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'filterFavoritedHlc', value: value),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  filterFavoritedHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'filterFavoritedHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  filterFavoritedHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'filterFavoritedHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  filterFavoritedHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'filterFavoritedHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  groupByPodcastEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'groupByPodcast', value: value),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  groupByPodcastHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'groupByPodcastHlc', value: value),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  groupByPodcastHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'groupByPodcastHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  groupByPodcastHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'groupByPodcastHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  groupByPodcastHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'groupByPodcastHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  hideCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hideCompleted', value: value),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  hideCompletedHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hideCompletedHlc', value: value),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  hideCompletedHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'hideCompletedHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  hideCompletedHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'hideCompletedHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  hideCompletedHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'hideCompletedHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<StationState, StationState, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<StationState, StationState, QAfterFilterCondition> idBetween(
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

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  lastPlayedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastPlayedAt'),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  lastPlayedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastPlayedAt'),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  lastPlayedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastPlayedAt', value: value),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
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

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
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

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
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

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  lastPlayedAtHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastPlayedAtHlc', value: value),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
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

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
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

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
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

  QueryBuilder<StationState, StationState, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  nameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition> nameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition> nameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  nameHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nameHlc', value: value),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  nameHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nameHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  nameHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nameHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  nameHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nameHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  podcastSortTypeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'podcastSortType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  podcastSortTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'podcastSortType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  podcastSortTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'podcastSortType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  podcastSortTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'podcastSortType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  podcastSortTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'podcastSortType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  podcastSortTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'podcastSortType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  podcastSortTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'podcastSortType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  podcastSortTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'podcastSortType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  podcastSortTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'podcastSortType', value: ''),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  podcastSortTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'podcastSortType', value: ''),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  podcastSortTypeHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'podcastSortTypeHlc', value: value),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  podcastSortTypeHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'podcastSortTypeHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  podcastSortTypeHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'podcastSortTypeHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  podcastSortTypeHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'podcastSortTypeHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  publishedWithinDaysIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'publishedWithinDays'),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  publishedWithinDaysIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'publishedWithinDays'),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  publishedWithinDaysEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'publishedWithinDays', value: value),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  publishedWithinDaysGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'publishedWithinDays',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  publishedWithinDaysLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'publishedWithinDays',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  publishedWithinDaysBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'publishedWithinDays',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  publishedWithinDaysHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'publishedWithinDaysHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  publishedWithinDaysHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'publishedWithinDaysHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  publishedWithinDaysHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'publishedWithinDaysHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  publishedWithinDaysHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'publishedWithinDaysHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  sortOrderEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sortOrder', value: value),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  sortOrderGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sortOrder',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  sortOrderLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sortOrder',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  sortOrderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sortOrder',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  sortOrderHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sortOrderHlc', value: value),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  sortOrderHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sortOrderHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  sortOrderHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sortOrderHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  sortOrderHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sortOrderHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  stationIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'stationId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  stationIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'stationId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  stationIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'stationId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  stationIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'stationId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  stationIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'stationId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  stationIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'stationId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  stationIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'stationId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  stationIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'stationId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  stationIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'stationId', value: ''),
      );
    });
  }

  QueryBuilder<StationState, StationState, QAfterFilterCondition>
  stationIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'stationId', value: ''),
      );
    });
  }
}

extension StationStateQueryObject
    on QueryBuilder<StationState, StationState, QFilterCondition> {}

extension StationStateQueryLinks
    on QueryBuilder<StationState, StationState, QFilterCondition> {}

extension StationStateQuerySortBy
    on QueryBuilder<StationState, StationState, QSortBy> {
  QueryBuilder<StationState, StationState, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByDefaultEpisodeLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultEpisodeLimit', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByDefaultEpisodeLimitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultEpisodeLimit', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByDefaultEpisodeLimitHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultEpisodeLimitHlc', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByDefaultEpisodeLimitHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultEpisodeLimitHlc', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy> sortByDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy> sortByDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy> sortByDeletedHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedHlc', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByDeletedHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedHlc', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByDurationFilterHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationFilterHlc', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByDurationFilterHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationFilterHlc', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMinutes', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMinutes', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByDurationOperator() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationOperator', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByDurationOperatorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationOperator', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByEpisodeSortType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeSortType', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByEpisodeSortTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeSortType', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByEpisodeSortTypeHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeSortTypeHlc', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByEpisodeSortTypeHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeSortTypeHlc', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByFilterDownloaded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterDownloaded', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByFilterDownloadedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterDownloaded', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByFilterDownloadedHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterDownloadedHlc', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByFilterDownloadedHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterDownloadedHlc', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByFilterFavorited() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterFavorited', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByFilterFavoritedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterFavorited', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByFilterFavoritedHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterFavoritedHlc', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByFilterFavoritedHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterFavoritedHlc', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByGroupByPodcast() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupByPodcast', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByGroupByPodcastDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupByPodcast', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByGroupByPodcastHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupByPodcastHlc', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByGroupByPodcastHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupByPodcastHlc', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy> sortByHideCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hideCompleted', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByHideCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hideCompleted', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByHideCompletedHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hideCompletedHlc', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByHideCompletedHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hideCompletedHlc', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy> sortByLastPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAt', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByLastPlayedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAt', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByLastPlayedAtHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAtHlc', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByLastPlayedAtHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAtHlc', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy> sortByNameHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameHlc', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy> sortByNameHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameHlc', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByPodcastSortType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastSortType', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByPodcastSortTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastSortType', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByPodcastSortTypeHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastSortTypeHlc', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByPodcastSortTypeHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastSortTypeHlc', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByPublishedWithinDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publishedWithinDays', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByPublishedWithinDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publishedWithinDays', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByPublishedWithinDaysHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publishedWithinDaysHlc', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortByPublishedWithinDaysHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publishedWithinDaysHlc', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy> sortBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy> sortBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy> sortBySortOrderHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrderHlc', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  sortBySortOrderHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrderHlc', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy> sortByStationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stationId', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy> sortByStationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stationId', Sort.desc);
    });
  }
}

extension StationStateQuerySortThenBy
    on QueryBuilder<StationState, StationState, QSortThenBy> {
  QueryBuilder<StationState, StationState, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByDefaultEpisodeLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultEpisodeLimit', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByDefaultEpisodeLimitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultEpisodeLimit', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByDefaultEpisodeLimitHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultEpisodeLimitHlc', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByDefaultEpisodeLimitHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultEpisodeLimitHlc', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy> thenByDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy> thenByDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy> thenByDeletedHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedHlc', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByDeletedHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedHlc', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByDurationFilterHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationFilterHlc', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByDurationFilterHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationFilterHlc', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMinutes', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMinutes', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByDurationOperator() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationOperator', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByDurationOperatorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationOperator', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByEpisodeSortType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeSortType', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByEpisodeSortTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeSortType', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByEpisodeSortTypeHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeSortTypeHlc', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByEpisodeSortTypeHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeSortTypeHlc', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByFilterDownloaded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterDownloaded', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByFilterDownloadedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterDownloaded', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByFilterDownloadedHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterDownloadedHlc', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByFilterDownloadedHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterDownloadedHlc', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByFilterFavorited() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterFavorited', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByFilterFavoritedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterFavorited', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByFilterFavoritedHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterFavoritedHlc', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByFilterFavoritedHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterFavoritedHlc', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByGroupByPodcast() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupByPodcast', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByGroupByPodcastDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupByPodcast', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByGroupByPodcastHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupByPodcastHlc', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByGroupByPodcastHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupByPodcastHlc', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy> thenByHideCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hideCompleted', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByHideCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hideCompleted', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByHideCompletedHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hideCompletedHlc', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByHideCompletedHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hideCompletedHlc', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy> thenByLastPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAt', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByLastPlayedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAt', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByLastPlayedAtHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAtHlc', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByLastPlayedAtHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayedAtHlc', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy> thenByNameHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameHlc', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy> thenByNameHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameHlc', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByPodcastSortType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastSortType', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByPodcastSortTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastSortType', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByPodcastSortTypeHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastSortTypeHlc', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByPodcastSortTypeHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastSortTypeHlc', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByPublishedWithinDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publishedWithinDays', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByPublishedWithinDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publishedWithinDays', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByPublishedWithinDaysHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publishedWithinDaysHlc', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenByPublishedWithinDaysHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publishedWithinDaysHlc', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy> thenBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy> thenBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy> thenBySortOrderHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrderHlc', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy>
  thenBySortOrderHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrderHlc', Sort.desc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy> thenByStationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stationId', Sort.asc);
    });
  }

  QueryBuilder<StationState, StationState, QAfterSortBy> thenByStationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stationId', Sort.desc);
    });
  }
}

extension StationStateQueryWhereDistinct
    on QueryBuilder<StationState, StationState, QDistinct> {
  QueryBuilder<StationState, StationState, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<StationState, StationState, QDistinct>
  distinctByDefaultEpisodeLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'defaultEpisodeLimit');
    });
  }

  QueryBuilder<StationState, StationState, QDistinct>
  distinctByDefaultEpisodeLimitHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'defaultEpisodeLimitHlc');
    });
  }

  QueryBuilder<StationState, StationState, QDistinct> distinctByDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deleted');
    });
  }

  QueryBuilder<StationState, StationState, QDistinct> distinctByDeletedHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedHlc');
    });
  }

  QueryBuilder<StationState, StationState, QDistinct>
  distinctByDurationFilterHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationFilterHlc');
    });
  }

  QueryBuilder<StationState, StationState, QDistinct>
  distinctByDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationMinutes');
    });
  }

  QueryBuilder<StationState, StationState, QDistinct>
  distinctByDurationOperator({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'durationOperator',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<StationState, StationState, QDistinct>
  distinctByEpisodeSortType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'episodeSortType',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<StationState, StationState, QDistinct>
  distinctByEpisodeSortTypeHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'episodeSortTypeHlc');
    });
  }

  QueryBuilder<StationState, StationState, QDistinct>
  distinctByFilterDownloaded() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'filterDownloaded');
    });
  }

  QueryBuilder<StationState, StationState, QDistinct>
  distinctByFilterDownloadedHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'filterDownloadedHlc');
    });
  }

  QueryBuilder<StationState, StationState, QDistinct>
  distinctByFilterFavorited() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'filterFavorited');
    });
  }

  QueryBuilder<StationState, StationState, QDistinct>
  distinctByFilterFavoritedHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'filterFavoritedHlc');
    });
  }

  QueryBuilder<StationState, StationState, QDistinct>
  distinctByGroupByPodcast() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'groupByPodcast');
    });
  }

  QueryBuilder<StationState, StationState, QDistinct>
  distinctByGroupByPodcastHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'groupByPodcastHlc');
    });
  }

  QueryBuilder<StationState, StationState, QDistinct>
  distinctByHideCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hideCompleted');
    });
  }

  QueryBuilder<StationState, StationState, QDistinct>
  distinctByHideCompletedHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hideCompletedHlc');
    });
  }

  QueryBuilder<StationState, StationState, QDistinct> distinctByLastPlayedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPlayedAt');
    });
  }

  QueryBuilder<StationState, StationState, QDistinct>
  distinctByLastPlayedAtHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPlayedAtHlc');
    });
  }

  QueryBuilder<StationState, StationState, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StationState, StationState, QDistinct> distinctByNameHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nameHlc');
    });
  }

  QueryBuilder<StationState, StationState, QDistinct>
  distinctByPodcastSortType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'podcastSortType',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<StationState, StationState, QDistinct>
  distinctByPodcastSortTypeHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'podcastSortTypeHlc');
    });
  }

  QueryBuilder<StationState, StationState, QDistinct>
  distinctByPublishedWithinDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'publishedWithinDays');
    });
  }

  QueryBuilder<StationState, StationState, QDistinct>
  distinctByPublishedWithinDaysHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'publishedWithinDaysHlc');
    });
  }

  QueryBuilder<StationState, StationState, QDistinct> distinctBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortOrder');
    });
  }

  QueryBuilder<StationState, StationState, QDistinct> distinctBySortOrderHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortOrderHlc');
    });
  }

  QueryBuilder<StationState, StationState, QDistinct> distinctByStationId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stationId', caseSensitive: caseSensitive);
    });
  }
}

extension StationStateQueryProperty
    on QueryBuilder<StationState, StationState, QQueryProperty> {
  QueryBuilder<StationState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StationState, DateTime?, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<StationState, int?, QQueryOperations>
  defaultEpisodeLimitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'defaultEpisodeLimit');
    });
  }

  QueryBuilder<StationState, int, QQueryOperations>
  defaultEpisodeLimitHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'defaultEpisodeLimitHlc');
    });
  }

  QueryBuilder<StationState, bool, QQueryOperations> deletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deleted');
    });
  }

  QueryBuilder<StationState, int, QQueryOperations> deletedHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedHlc');
    });
  }

  QueryBuilder<StationState, int, QQueryOperations>
  durationFilterHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationFilterHlc');
    });
  }

  QueryBuilder<StationState, int, QQueryOperations> durationMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationMinutes');
    });
  }

  QueryBuilder<StationState, String?, QQueryOperations>
  durationOperatorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationOperator');
    });
  }

  QueryBuilder<StationState, String, QQueryOperations>
  episodeSortTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodeSortType');
    });
  }

  QueryBuilder<StationState, int, QQueryOperations>
  episodeSortTypeHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodeSortTypeHlc');
    });
  }

  QueryBuilder<StationState, bool, QQueryOperations>
  filterDownloadedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filterDownloaded');
    });
  }

  QueryBuilder<StationState, int, QQueryOperations>
  filterDownloadedHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filterDownloadedHlc');
    });
  }

  QueryBuilder<StationState, bool, QQueryOperations> filterFavoritedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filterFavorited');
    });
  }

  QueryBuilder<StationState, int, QQueryOperations>
  filterFavoritedHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filterFavoritedHlc');
    });
  }

  QueryBuilder<StationState, bool, QQueryOperations> groupByPodcastProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'groupByPodcast');
    });
  }

  QueryBuilder<StationState, int, QQueryOperations>
  groupByPodcastHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'groupByPodcastHlc');
    });
  }

  QueryBuilder<StationState, bool, QQueryOperations> hideCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hideCompleted');
    });
  }

  QueryBuilder<StationState, int, QQueryOperations> hideCompletedHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hideCompletedHlc');
    });
  }

  QueryBuilder<StationState, DateTime?, QQueryOperations>
  lastPlayedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPlayedAt');
    });
  }

  QueryBuilder<StationState, int, QQueryOperations> lastPlayedAtHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPlayedAtHlc');
    });
  }

  QueryBuilder<StationState, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<StationState, int, QQueryOperations> nameHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nameHlc');
    });
  }

  QueryBuilder<StationState, String, QQueryOperations>
  podcastSortTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'podcastSortType');
    });
  }

  QueryBuilder<StationState, int, QQueryOperations>
  podcastSortTypeHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'podcastSortTypeHlc');
    });
  }

  QueryBuilder<StationState, int?, QQueryOperations>
  publishedWithinDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'publishedWithinDays');
    });
  }

  QueryBuilder<StationState, int, QQueryOperations>
  publishedWithinDaysHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'publishedWithinDaysHlc');
    });
  }

  QueryBuilder<StationState, int, QQueryOperations> sortOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortOrder');
    });
  }

  QueryBuilder<StationState, int, QQueryOperations> sortOrderHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortOrderHlc');
    });
  }

  QueryBuilder<StationState, String, QQueryOperations> stationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stationId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetStationMemberCollection on Isar {
  IsarCollection<StationMember> get stationMembers => this.collection();
}

const StationMemberSchema = CollectionSchema(
  name: r'StationMember',
  id: 4289975549524396372,
  properties: {
    r'addedAt': PropertySchema(
      id: 0,
      name: r'addedAt',
      type: IsarType.dateTime,
    ),
    r'deleted': PropertySchema(id: 1, name: r'deleted', type: IsarType.bool),
    r'deletedHlc': PropertySchema(
      id: 2,
      name: r'deletedHlc',
      type: IsarType.long,
    ),
    r'episodeLimit': PropertySchema(
      id: 3,
      name: r'episodeLimit',
      type: IsarType.long,
    ),
    r'episodeLimitHlc': PropertySchema(
      id: 4,
      name: r'episodeLimitHlc',
      type: IsarType.long,
    ),
    r'podcastKey': PropertySchema(
      id: 5,
      name: r'podcastKey',
      type: IsarType.string,
    ),
    r'sortOrder': PropertySchema(
      id: 6,
      name: r'sortOrder',
      type: IsarType.long,
    ),
    r'sortOrderHlc': PropertySchema(
      id: 7,
      name: r'sortOrderHlc',
      type: IsarType.long,
    ),
    r'stationId': PropertySchema(
      id: 8,
      name: r'stationId',
      type: IsarType.string,
    ),
  },

  estimateSize: _stationMemberEstimateSize,
  serialize: _stationMemberSerialize,
  deserialize: _stationMemberDeserialize,
  deserializeProp: _stationMemberDeserializeProp,
  idName: r'id',
  indexes: {
    r'stationId_podcastKey': IndexSchema(
      id: 910772406871264581,
      name: r'stationId_podcastKey',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'stationId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'podcastKey',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _stationMemberGetId,
  getLinks: _stationMemberGetLinks,
  attach: _stationMemberAttach,
  version: '3.3.2',
);

int _stationMemberEstimateSize(
  StationMember object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.podcastKey.length * 3;
  bytesCount += 3 + object.stationId.length * 3;
  return bytesCount;
}

void _stationMemberSerialize(
  StationMember object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.addedAt);
  writer.writeBool(offsets[1], object.deleted);
  writer.writeLong(offsets[2], object.deletedHlc);
  writer.writeLong(offsets[3], object.episodeLimit);
  writer.writeLong(offsets[4], object.episodeLimitHlc);
  writer.writeString(offsets[5], object.podcastKey);
  writer.writeLong(offsets[6], object.sortOrder);
  writer.writeLong(offsets[7], object.sortOrderHlc);
  writer.writeString(offsets[8], object.stationId);
}

StationMember _stationMemberDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StationMember();
  object.addedAt = reader.readDateTimeOrNull(offsets[0]);
  object.deleted = reader.readBool(offsets[1]);
  object.deletedHlc = reader.readLong(offsets[2]);
  object.episodeLimit = reader.readLongOrNull(offsets[3]);
  object.episodeLimitHlc = reader.readLong(offsets[4]);
  object.id = id;
  object.podcastKey = reader.readString(offsets[5]);
  object.sortOrder = reader.readLong(offsets[6]);
  object.sortOrderHlc = reader.readLong(offsets[7]);
  object.stationId = reader.readString(offsets[8]);
  return object;
}

P _stationMemberDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _stationMemberGetId(StationMember object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _stationMemberGetLinks(StationMember object) {
  return [];
}

void _stationMemberAttach(
  IsarCollection<dynamic> col,
  Id id,
  StationMember object,
) {
  object.id = id;
}

extension StationMemberByIndex on IsarCollection<StationMember> {
  Future<StationMember?> getByStationIdPodcastKey(
    String stationId,
    String podcastKey,
  ) {
    return getByIndex(r'stationId_podcastKey', [stationId, podcastKey]);
  }

  StationMember? getByStationIdPodcastKeySync(
    String stationId,
    String podcastKey,
  ) {
    return getByIndexSync(r'stationId_podcastKey', [stationId, podcastKey]);
  }

  Future<bool> deleteByStationIdPodcastKey(
    String stationId,
    String podcastKey,
  ) {
    return deleteByIndex(r'stationId_podcastKey', [stationId, podcastKey]);
  }

  bool deleteByStationIdPodcastKeySync(String stationId, String podcastKey) {
    return deleteByIndexSync(r'stationId_podcastKey', [stationId, podcastKey]);
  }

  Future<List<StationMember?>> getAllByStationIdPodcastKey(
    List<String> stationIdValues,
    List<String> podcastKeyValues,
  ) {
    final len = stationIdValues.length;
    assert(
      podcastKeyValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([stationIdValues[i], podcastKeyValues[i]]);
    }

    return getAllByIndex(r'stationId_podcastKey', values);
  }

  List<StationMember?> getAllByStationIdPodcastKeySync(
    List<String> stationIdValues,
    List<String> podcastKeyValues,
  ) {
    final len = stationIdValues.length;
    assert(
      podcastKeyValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([stationIdValues[i], podcastKeyValues[i]]);
    }

    return getAllByIndexSync(r'stationId_podcastKey', values);
  }

  Future<int> deleteAllByStationIdPodcastKey(
    List<String> stationIdValues,
    List<String> podcastKeyValues,
  ) {
    final len = stationIdValues.length;
    assert(
      podcastKeyValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([stationIdValues[i], podcastKeyValues[i]]);
    }

    return deleteAllByIndex(r'stationId_podcastKey', values);
  }

  int deleteAllByStationIdPodcastKeySync(
    List<String> stationIdValues,
    List<String> podcastKeyValues,
  ) {
    final len = stationIdValues.length;
    assert(
      podcastKeyValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([stationIdValues[i], podcastKeyValues[i]]);
    }

    return deleteAllByIndexSync(r'stationId_podcastKey', values);
  }

  Future<Id> putByStationIdPodcastKey(StationMember object) {
    return putByIndex(r'stationId_podcastKey', object);
  }

  Id putByStationIdPodcastKeySync(
    StationMember object, {
    bool saveLinks = true,
  }) {
    return putByIndexSync(
      r'stationId_podcastKey',
      object,
      saveLinks: saveLinks,
    );
  }

  Future<List<Id>> putAllByStationIdPodcastKey(List<StationMember> objects) {
    return putAllByIndex(r'stationId_podcastKey', objects);
  }

  List<Id> putAllByStationIdPodcastKeySync(
    List<StationMember> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(
      r'stationId_podcastKey',
      objects,
      saveLinks: saveLinks,
    );
  }
}

extension StationMemberQueryWhereSort
    on QueryBuilder<StationMember, StationMember, QWhere> {
  QueryBuilder<StationMember, StationMember, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension StationMemberQueryWhere
    on QueryBuilder<StationMember, StationMember, QWhereClause> {
  QueryBuilder<StationMember, StationMember, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<StationMember, StationMember, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterWhereClause> idBetween(
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

  QueryBuilder<StationMember, StationMember, QAfterWhereClause>
  stationIdEqualToAnyPodcastKey(String stationId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'stationId_podcastKey',
          value: [stationId],
        ),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterWhereClause>
  stationIdNotEqualToAnyPodcastKey(String stationId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stationId_podcastKey',
                lower: [],
                upper: [stationId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stationId_podcastKey',
                lower: [stationId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stationId_podcastKey',
                lower: [stationId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stationId_podcastKey',
                lower: [],
                upper: [stationId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterWhereClause>
  stationIdPodcastKeyEqualTo(String stationId, String podcastKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'stationId_podcastKey',
          value: [stationId, podcastKey],
        ),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterWhereClause>
  stationIdEqualToPodcastKeyNotEqualTo(String stationId, String podcastKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stationId_podcastKey',
                lower: [stationId],
                upper: [stationId, podcastKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stationId_podcastKey',
                lower: [stationId, podcastKey],
                includeLower: false,
                upper: [stationId],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stationId_podcastKey',
                lower: [stationId, podcastKey],
                includeLower: false,
                upper: [stationId],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stationId_podcastKey',
                lower: [stationId],
                upper: [stationId, podcastKey],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension StationMemberQueryFilter
    on QueryBuilder<StationMember, StationMember, QFilterCondition> {
  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  addedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'addedAt'),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  addedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'addedAt'),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  addedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'addedAt', value: value),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  addedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'addedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  addedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'addedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  addedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'addedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  deletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deleted', value: value),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  deletedHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deletedHlc', value: value),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  deletedHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'deletedHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  deletedHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'deletedHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  deletedHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'deletedHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  episodeLimitIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'episodeLimit'),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  episodeLimitIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'episodeLimit'),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  episodeLimitEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'episodeLimit', value: value),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  episodeLimitGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'episodeLimit',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  episodeLimitLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'episodeLimit',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  episodeLimitBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'episodeLimit',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  episodeLimitHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'episodeLimitHlc', value: value),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  episodeLimitHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'episodeLimitHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  episodeLimitHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'episodeLimitHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  episodeLimitHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'episodeLimitHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
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

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition> idBetween(
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

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
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

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
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

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
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

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
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

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
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

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
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

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
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

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
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

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  podcastKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'podcastKey', value: ''),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  podcastKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'podcastKey', value: ''),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  sortOrderEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sortOrder', value: value),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  sortOrderGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sortOrder',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  sortOrderLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sortOrder',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  sortOrderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sortOrder',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  sortOrderHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sortOrderHlc', value: value),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  sortOrderHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sortOrderHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  sortOrderHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sortOrderHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  sortOrderHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sortOrderHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  stationIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'stationId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  stationIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'stationId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  stationIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'stationId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  stationIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'stationId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  stationIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'stationId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  stationIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'stationId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  stationIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'stationId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  stationIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'stationId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  stationIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'stationId', value: ''),
      );
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterFilterCondition>
  stationIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'stationId', value: ''),
      );
    });
  }
}

extension StationMemberQueryObject
    on QueryBuilder<StationMember, StationMember, QFilterCondition> {}

extension StationMemberQueryLinks
    on QueryBuilder<StationMember, StationMember, QFilterCondition> {}

extension StationMemberQuerySortBy
    on QueryBuilder<StationMember, StationMember, QSortBy> {
  QueryBuilder<StationMember, StationMember, QAfterSortBy> sortByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.asc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy> sortByAddedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.desc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy> sortByDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.asc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy> sortByDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.desc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy> sortByDeletedHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedHlc', Sort.asc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy>
  sortByDeletedHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedHlc', Sort.desc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy>
  sortByEpisodeLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeLimit', Sort.asc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy>
  sortByEpisodeLimitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeLimit', Sort.desc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy>
  sortByEpisodeLimitHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeLimitHlc', Sort.asc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy>
  sortByEpisodeLimitHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeLimitHlc', Sort.desc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy> sortByPodcastKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastKey', Sort.asc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy>
  sortByPodcastKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastKey', Sort.desc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy> sortBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy>
  sortBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy>
  sortBySortOrderHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrderHlc', Sort.asc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy>
  sortBySortOrderHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrderHlc', Sort.desc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy> sortByStationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stationId', Sort.asc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy>
  sortByStationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stationId', Sort.desc);
    });
  }
}

extension StationMemberQuerySortThenBy
    on QueryBuilder<StationMember, StationMember, QSortThenBy> {
  QueryBuilder<StationMember, StationMember, QAfterSortBy> thenByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.asc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy> thenByAddedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.desc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy> thenByDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.asc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy> thenByDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.desc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy> thenByDeletedHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedHlc', Sort.asc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy>
  thenByDeletedHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedHlc', Sort.desc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy>
  thenByEpisodeLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeLimit', Sort.asc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy>
  thenByEpisodeLimitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeLimit', Sort.desc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy>
  thenByEpisodeLimitHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeLimitHlc', Sort.asc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy>
  thenByEpisodeLimitHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeLimitHlc', Sort.desc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy> thenByPodcastKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastKey', Sort.asc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy>
  thenByPodcastKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastKey', Sort.desc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy> thenBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy>
  thenBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy>
  thenBySortOrderHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrderHlc', Sort.asc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy>
  thenBySortOrderHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrderHlc', Sort.desc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy> thenByStationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stationId', Sort.asc);
    });
  }

  QueryBuilder<StationMember, StationMember, QAfterSortBy>
  thenByStationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stationId', Sort.desc);
    });
  }
}

extension StationMemberQueryWhereDistinct
    on QueryBuilder<StationMember, StationMember, QDistinct> {
  QueryBuilder<StationMember, StationMember, QDistinct> distinctByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'addedAt');
    });
  }

  QueryBuilder<StationMember, StationMember, QDistinct> distinctByDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deleted');
    });
  }

  QueryBuilder<StationMember, StationMember, QDistinct> distinctByDeletedHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedHlc');
    });
  }

  QueryBuilder<StationMember, StationMember, QDistinct>
  distinctByEpisodeLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'episodeLimit');
    });
  }

  QueryBuilder<StationMember, StationMember, QDistinct>
  distinctByEpisodeLimitHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'episodeLimitHlc');
    });
  }

  QueryBuilder<StationMember, StationMember, QDistinct> distinctByPodcastKey({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'podcastKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StationMember, StationMember, QDistinct> distinctBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortOrder');
    });
  }

  QueryBuilder<StationMember, StationMember, QDistinct>
  distinctBySortOrderHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortOrderHlc');
    });
  }

  QueryBuilder<StationMember, StationMember, QDistinct> distinctByStationId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stationId', caseSensitive: caseSensitive);
    });
  }
}

extension StationMemberQueryProperty
    on QueryBuilder<StationMember, StationMember, QQueryProperty> {
  QueryBuilder<StationMember, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StationMember, DateTime?, QQueryOperations> addedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'addedAt');
    });
  }

  QueryBuilder<StationMember, bool, QQueryOperations> deletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deleted');
    });
  }

  QueryBuilder<StationMember, int, QQueryOperations> deletedHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedHlc');
    });
  }

  QueryBuilder<StationMember, int?, QQueryOperations> episodeLimitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodeLimit');
    });
  }

  QueryBuilder<StationMember, int, QQueryOperations> episodeLimitHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodeLimitHlc');
    });
  }

  QueryBuilder<StationMember, String, QQueryOperations> podcastKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'podcastKey');
    });
  }

  QueryBuilder<StationMember, int, QQueryOperations> sortOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortOrder');
    });
  }

  QueryBuilder<StationMember, int, QQueryOperations> sortOrderHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortOrderHlc');
    });
  }

  QueryBuilder<StationMember, String, QQueryOperations> stationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stationId');
    });
  }
}
