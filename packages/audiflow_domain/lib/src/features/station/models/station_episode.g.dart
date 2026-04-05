// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station_episode.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStationEpisodeCollection on Isar {
  IsarCollection<StationEpisode> get stationEpisodes => this.collection();
}

const StationEpisodeSchema = CollectionSchema(
  name: r'StationEpisode',
  id: -3606906885775562987,
  properties: {
    r'episodeId': PropertySchema(
      id: 0,
      name: r'episodeId',
      type: IsarType.long,
    ),
    r'sortKey': PropertySchema(
      id: 1,
      name: r'sortKey',
      type: IsarType.dateTime,
    ),
    r'stationId': PropertySchema(
      id: 2,
      name: r'stationId',
      type: IsarType.long,
    ),
  },

  estimateSize: _stationEpisodeEstimateSize,
  serialize: _stationEpisodeSerialize,
  deserialize: _stationEpisodeDeserialize,
  deserializeProp: _stationEpisodeDeserializeProp,
  idName: r'id',
  indexes: {
    r'stationId_episodeId': IndexSchema(
      id: 6469780734470989604,
      name: r'stationId_episodeId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'stationId',
          type: IndexType.value,
          caseSensitive: false,
        ),
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

  getId: _stationEpisodeGetId,
  getLinks: _stationEpisodeGetLinks,
  attach: _stationEpisodeAttach,
  version: '3.3.2',
);

int _stationEpisodeEstimateSize(
  StationEpisode object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _stationEpisodeSerialize(
  StationEpisode object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.episodeId);
  writer.writeDateTime(offsets[1], object.sortKey);
  writer.writeLong(offsets[2], object.stationId);
}

StationEpisode _stationEpisodeDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StationEpisode();
  object.episodeId = reader.readLong(offsets[0]);
  object.id = id;
  object.sortKey = reader.readDateTimeOrNull(offsets[1]);
  object.stationId = reader.readLong(offsets[2]);
  return object;
}

P _stationEpisodeDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _stationEpisodeGetId(StationEpisode object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _stationEpisodeGetLinks(StationEpisode object) {
  return [];
}

void _stationEpisodeAttach(
  IsarCollection<dynamic> col,
  Id id,
  StationEpisode object,
) {
  object.id = id;
}

extension StationEpisodeByIndex on IsarCollection<StationEpisode> {
  Future<StationEpisode?> getByStationIdEpisodeId(
    int stationId,
    int episodeId,
  ) {
    return getByIndex(r'stationId_episodeId', [stationId, episodeId]);
  }

  StationEpisode? getByStationIdEpisodeIdSync(int stationId, int episodeId) {
    return getByIndexSync(r'stationId_episodeId', [stationId, episodeId]);
  }

  Future<bool> deleteByStationIdEpisodeId(int stationId, int episodeId) {
    return deleteByIndex(r'stationId_episodeId', [stationId, episodeId]);
  }

  bool deleteByStationIdEpisodeIdSync(int stationId, int episodeId) {
    return deleteByIndexSync(r'stationId_episodeId', [stationId, episodeId]);
  }

  Future<List<StationEpisode?>> getAllByStationIdEpisodeId(
    List<int> stationIdValues,
    List<int> episodeIdValues,
  ) {
    final len = stationIdValues.length;
    assert(
      episodeIdValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([stationIdValues[i], episodeIdValues[i]]);
    }

    return getAllByIndex(r'stationId_episodeId', values);
  }

  List<StationEpisode?> getAllByStationIdEpisodeIdSync(
    List<int> stationIdValues,
    List<int> episodeIdValues,
  ) {
    final len = stationIdValues.length;
    assert(
      episodeIdValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([stationIdValues[i], episodeIdValues[i]]);
    }

    return getAllByIndexSync(r'stationId_episodeId', values);
  }

  Future<int> deleteAllByStationIdEpisodeId(
    List<int> stationIdValues,
    List<int> episodeIdValues,
  ) {
    final len = stationIdValues.length;
    assert(
      episodeIdValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([stationIdValues[i], episodeIdValues[i]]);
    }

    return deleteAllByIndex(r'stationId_episodeId', values);
  }

  int deleteAllByStationIdEpisodeIdSync(
    List<int> stationIdValues,
    List<int> episodeIdValues,
  ) {
    final len = stationIdValues.length;
    assert(
      episodeIdValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([stationIdValues[i], episodeIdValues[i]]);
    }

    return deleteAllByIndexSync(r'stationId_episodeId', values);
  }

  Future<Id> putByStationIdEpisodeId(StationEpisode object) {
    return putByIndex(r'stationId_episodeId', object);
  }

  Id putByStationIdEpisodeIdSync(
    StationEpisode object, {
    bool saveLinks = true,
  }) {
    return putByIndexSync(r'stationId_episodeId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByStationIdEpisodeId(List<StationEpisode> objects) {
    return putAllByIndex(r'stationId_episodeId', objects);
  }

  List<Id> putAllByStationIdEpisodeIdSync(
    List<StationEpisode> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(
      r'stationId_episodeId',
      objects,
      saveLinks: saveLinks,
    );
  }
}

extension StationEpisodeQueryWhereSort
    on QueryBuilder<StationEpisode, StationEpisode, QWhere> {
  QueryBuilder<StationEpisode, StationEpisode, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterWhere>
  anyStationIdEpisodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'stationId_episodeId'),
      );
    });
  }
}

extension StationEpisodeQueryWhere
    on QueryBuilder<StationEpisode, StationEpisode, QWhereClause> {
  QueryBuilder<StationEpisode, StationEpisode, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<StationEpisode, StationEpisode, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterWhereClause> idBetween(
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

  QueryBuilder<StationEpisode, StationEpisode, QAfterWhereClause>
  stationIdEqualToAnyEpisodeId(int stationId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'stationId_episodeId',
          value: [stationId],
        ),
      );
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterWhereClause>
  stationIdNotEqualToAnyEpisodeId(int stationId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stationId_episodeId',
                lower: [],
                upper: [stationId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stationId_episodeId',
                lower: [stationId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stationId_episodeId',
                lower: [stationId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stationId_episodeId',
                lower: [],
                upper: [stationId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterWhereClause>
  stationIdGreaterThanAnyEpisodeId(int stationId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'stationId_episodeId',
          lower: [stationId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterWhereClause>
  stationIdLessThanAnyEpisodeId(int stationId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'stationId_episodeId',
          lower: [],
          upper: [stationId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterWhereClause>
  stationIdBetweenAnyEpisodeId(
    int lowerStationId,
    int upperStationId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'stationId_episodeId',
          lower: [lowerStationId],
          includeLower: includeLower,
          upper: [upperStationId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterWhereClause>
  stationIdEpisodeIdEqualTo(int stationId, int episodeId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'stationId_episodeId',
          value: [stationId, episodeId],
        ),
      );
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterWhereClause>
  stationIdEqualToEpisodeIdNotEqualTo(int stationId, int episodeId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stationId_episodeId',
                lower: [stationId],
                upper: [stationId, episodeId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stationId_episodeId',
                lower: [stationId, episodeId],
                includeLower: false,
                upper: [stationId],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stationId_episodeId',
                lower: [stationId, episodeId],
                includeLower: false,
                upper: [stationId],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stationId_episodeId',
                lower: [stationId],
                upper: [stationId, episodeId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterWhereClause>
  stationIdEqualToEpisodeIdGreaterThan(
    int stationId,
    int episodeId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'stationId_episodeId',
          lower: [stationId, episodeId],
          includeLower: include,
          upper: [stationId],
        ),
      );
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterWhereClause>
  stationIdEqualToEpisodeIdLessThan(
    int stationId,
    int episodeId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'stationId_episodeId',
          lower: [stationId],
          upper: [stationId, episodeId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterWhereClause>
  stationIdEqualToEpisodeIdBetween(
    int stationId,
    int lowerEpisodeId,
    int upperEpisodeId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'stationId_episodeId',
          lower: [stationId, lowerEpisodeId],
          includeLower: includeLower,
          upper: [stationId, upperEpisodeId],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension StationEpisodeQueryFilter
    on QueryBuilder<StationEpisode, StationEpisode, QFilterCondition> {
  QueryBuilder<StationEpisode, StationEpisode, QAfterFilterCondition>
  episodeIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'episodeId', value: value),
      );
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterFilterCondition>
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

  QueryBuilder<StationEpisode, StationEpisode, QAfterFilterCondition>
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

  QueryBuilder<StationEpisode, StationEpisode, QAfterFilterCondition>
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

  QueryBuilder<StationEpisode, StationEpisode, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterFilterCondition>
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

  QueryBuilder<StationEpisode, StationEpisode, QAfterFilterCondition>
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

  QueryBuilder<StationEpisode, StationEpisode, QAfterFilterCondition> idBetween(
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

  QueryBuilder<StationEpisode, StationEpisode, QAfterFilterCondition>
  sortKeyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'sortKey'),
      );
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterFilterCondition>
  sortKeyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'sortKey'),
      );
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterFilterCondition>
  sortKeyEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sortKey', value: value),
      );
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterFilterCondition>
  sortKeyGreaterThan(DateTime? value, {bool include = false}) {
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

  QueryBuilder<StationEpisode, StationEpisode, QAfterFilterCondition>
  sortKeyLessThan(DateTime? value, {bool include = false}) {
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

  QueryBuilder<StationEpisode, StationEpisode, QAfterFilterCondition>
  sortKeyBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<StationEpisode, StationEpisode, QAfterFilterCondition>
  stationIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'stationId', value: value),
      );
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterFilterCondition>
  stationIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'stationId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterFilterCondition>
  stationIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'stationId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterFilterCondition>
  stationIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'stationId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension StationEpisodeQueryObject
    on QueryBuilder<StationEpisode, StationEpisode, QFilterCondition> {}

extension StationEpisodeQueryLinks
    on QueryBuilder<StationEpisode, StationEpisode, QFilterCondition> {}

extension StationEpisodeQuerySortBy
    on QueryBuilder<StationEpisode, StationEpisode, QSortBy> {
  QueryBuilder<StationEpisode, StationEpisode, QAfterSortBy> sortByEpisodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeId', Sort.asc);
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterSortBy>
  sortByEpisodeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeId', Sort.desc);
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterSortBy> sortBySortKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortKey', Sort.asc);
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterSortBy>
  sortBySortKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortKey', Sort.desc);
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterSortBy> sortByStationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stationId', Sort.asc);
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterSortBy>
  sortByStationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stationId', Sort.desc);
    });
  }
}

extension StationEpisodeQuerySortThenBy
    on QueryBuilder<StationEpisode, StationEpisode, QSortThenBy> {
  QueryBuilder<StationEpisode, StationEpisode, QAfterSortBy> thenByEpisodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeId', Sort.asc);
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterSortBy>
  thenByEpisodeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeId', Sort.desc);
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterSortBy> thenBySortKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortKey', Sort.asc);
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterSortBy>
  thenBySortKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortKey', Sort.desc);
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterSortBy> thenByStationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stationId', Sort.asc);
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QAfterSortBy>
  thenByStationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stationId', Sort.desc);
    });
  }
}

extension StationEpisodeQueryWhereDistinct
    on QueryBuilder<StationEpisode, StationEpisode, QDistinct> {
  QueryBuilder<StationEpisode, StationEpisode, QDistinct>
  distinctByEpisodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'episodeId');
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QDistinct> distinctBySortKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortKey');
    });
  }

  QueryBuilder<StationEpisode, StationEpisode, QDistinct>
  distinctByStationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stationId');
    });
  }
}

extension StationEpisodeQueryProperty
    on QueryBuilder<StationEpisode, StationEpisode, QQueryProperty> {
  QueryBuilder<StationEpisode, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StationEpisode, int, QQueryOperations> episodeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodeId');
    });
  }

  QueryBuilder<StationEpisode, DateTime?, QQueryOperations> sortKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortKey');
    });
  }

  QueryBuilder<StationEpisode, int, QQueryOperations> stationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stationId');
    });
  }
}
