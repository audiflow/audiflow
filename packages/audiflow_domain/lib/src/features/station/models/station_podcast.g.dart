// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station_podcast.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStationPodcastCollection on Isar {
  IsarCollection<StationPodcast> get stationPodcasts => this.collection();
}

const StationPodcastSchema = CollectionSchema(
  name: r'StationPodcast',
  id: 6309185686506009399,
  properties: {
    r'addedAt': PropertySchema(
      id: 0,
      name: r'addedAt',
      type: IsarType.dateTime,
    ),
    r'podcastId': PropertySchema(
      id: 1,
      name: r'podcastId',
      type: IsarType.long,
    ),
    r'stationId': PropertySchema(
      id: 2,
      name: r'stationId',
      type: IsarType.long,
    ),
  },

  estimateSize: _stationPodcastEstimateSize,
  serialize: _stationPodcastSerialize,
  deserialize: _stationPodcastDeserialize,
  deserializeProp: _stationPodcastDeserializeProp,
  idName: r'id',
  indexes: {
    r'stationId_podcastId': IndexSchema(
      id: -2262103617537322876,
      name: r'stationId_podcastId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'stationId',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'podcastId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _stationPodcastGetId,
  getLinks: _stationPodcastGetLinks,
  attach: _stationPodcastAttach,
  version: '3.3.2',
);

int _stationPodcastEstimateSize(
  StationPodcast object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _stationPodcastSerialize(
  StationPodcast object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.addedAt);
  writer.writeLong(offsets[1], object.podcastId);
  writer.writeLong(offsets[2], object.stationId);
}

StationPodcast _stationPodcastDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StationPodcast();
  object.addedAt = reader.readDateTime(offsets[0]);
  object.id = id;
  object.podcastId = reader.readLong(offsets[1]);
  object.stationId = reader.readLong(offsets[2]);
  return object;
}

P _stationPodcastDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _stationPodcastGetId(StationPodcast object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _stationPodcastGetLinks(StationPodcast object) {
  return [];
}

void _stationPodcastAttach(
  IsarCollection<dynamic> col,
  Id id,
  StationPodcast object,
) {
  object.id = id;
}

extension StationPodcastByIndex on IsarCollection<StationPodcast> {
  Future<StationPodcast?> getByStationIdPodcastId(
    int stationId,
    int podcastId,
  ) {
    return getByIndex(r'stationId_podcastId', [stationId, podcastId]);
  }

  StationPodcast? getByStationIdPodcastIdSync(int stationId, int podcastId) {
    return getByIndexSync(r'stationId_podcastId', [stationId, podcastId]);
  }

  Future<bool> deleteByStationIdPodcastId(int stationId, int podcastId) {
    return deleteByIndex(r'stationId_podcastId', [stationId, podcastId]);
  }

  bool deleteByStationIdPodcastIdSync(int stationId, int podcastId) {
    return deleteByIndexSync(r'stationId_podcastId', [stationId, podcastId]);
  }

  Future<List<StationPodcast?>> getAllByStationIdPodcastId(
    List<int> stationIdValues,
    List<int> podcastIdValues,
  ) {
    final len = stationIdValues.length;
    assert(
      podcastIdValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([stationIdValues[i], podcastIdValues[i]]);
    }

    return getAllByIndex(r'stationId_podcastId', values);
  }

  List<StationPodcast?> getAllByStationIdPodcastIdSync(
    List<int> stationIdValues,
    List<int> podcastIdValues,
  ) {
    final len = stationIdValues.length;
    assert(
      podcastIdValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([stationIdValues[i], podcastIdValues[i]]);
    }

    return getAllByIndexSync(r'stationId_podcastId', values);
  }

  Future<int> deleteAllByStationIdPodcastId(
    List<int> stationIdValues,
    List<int> podcastIdValues,
  ) {
    final len = stationIdValues.length;
    assert(
      podcastIdValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([stationIdValues[i], podcastIdValues[i]]);
    }

    return deleteAllByIndex(r'stationId_podcastId', values);
  }

  int deleteAllByStationIdPodcastIdSync(
    List<int> stationIdValues,
    List<int> podcastIdValues,
  ) {
    final len = stationIdValues.length;
    assert(
      podcastIdValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([stationIdValues[i], podcastIdValues[i]]);
    }

    return deleteAllByIndexSync(r'stationId_podcastId', values);
  }

  Future<Id> putByStationIdPodcastId(StationPodcast object) {
    return putByIndex(r'stationId_podcastId', object);
  }

  Id putByStationIdPodcastIdSync(
    StationPodcast object, {
    bool saveLinks = true,
  }) {
    return putByIndexSync(r'stationId_podcastId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByStationIdPodcastId(List<StationPodcast> objects) {
    return putAllByIndex(r'stationId_podcastId', objects);
  }

  List<Id> putAllByStationIdPodcastIdSync(
    List<StationPodcast> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(
      r'stationId_podcastId',
      objects,
      saveLinks: saveLinks,
    );
  }
}

extension StationPodcastQueryWhereSort
    on QueryBuilder<StationPodcast, StationPodcast, QWhere> {
  QueryBuilder<StationPodcast, StationPodcast, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<StationPodcast, StationPodcast, QAfterWhere>
  anyStationIdPodcastId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'stationId_podcastId'),
      );
    });
  }
}

extension StationPodcastQueryWhere
    on QueryBuilder<StationPodcast, StationPodcast, QWhereClause> {
  QueryBuilder<StationPodcast, StationPodcast, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<StationPodcast, StationPodcast, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<StationPodcast, StationPodcast, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<StationPodcast, StationPodcast, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<StationPodcast, StationPodcast, QAfterWhereClause> idBetween(
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

  QueryBuilder<StationPodcast, StationPodcast, QAfterWhereClause>
  stationIdEqualToAnyPodcastId(int stationId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'stationId_podcastId',
          value: [stationId],
        ),
      );
    });
  }

  QueryBuilder<StationPodcast, StationPodcast, QAfterWhereClause>
  stationIdNotEqualToAnyPodcastId(int stationId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stationId_podcastId',
                lower: [],
                upper: [stationId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stationId_podcastId',
                lower: [stationId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stationId_podcastId',
                lower: [stationId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stationId_podcastId',
                lower: [],
                upper: [stationId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<StationPodcast, StationPodcast, QAfterWhereClause>
  stationIdGreaterThanAnyPodcastId(int stationId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'stationId_podcastId',
          lower: [stationId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<StationPodcast, StationPodcast, QAfterWhereClause>
  stationIdLessThanAnyPodcastId(int stationId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'stationId_podcastId',
          lower: [],
          upper: [stationId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<StationPodcast, StationPodcast, QAfterWhereClause>
  stationIdBetweenAnyPodcastId(
    int lowerStationId,
    int upperStationId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'stationId_podcastId',
          lower: [lowerStationId],
          includeLower: includeLower,
          upper: [upperStationId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StationPodcast, StationPodcast, QAfterWhereClause>
  stationIdPodcastIdEqualTo(int stationId, int podcastId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'stationId_podcastId',
          value: [stationId, podcastId],
        ),
      );
    });
  }

  QueryBuilder<StationPodcast, StationPodcast, QAfterWhereClause>
  stationIdEqualToPodcastIdNotEqualTo(int stationId, int podcastId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stationId_podcastId',
                lower: [stationId],
                upper: [stationId, podcastId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stationId_podcastId',
                lower: [stationId, podcastId],
                includeLower: false,
                upper: [stationId],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stationId_podcastId',
                lower: [stationId, podcastId],
                includeLower: false,
                upper: [stationId],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stationId_podcastId',
                lower: [stationId],
                upper: [stationId, podcastId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<StationPodcast, StationPodcast, QAfterWhereClause>
  stationIdEqualToPodcastIdGreaterThan(
    int stationId,
    int podcastId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'stationId_podcastId',
          lower: [stationId, podcastId],
          includeLower: include,
          upper: [stationId],
        ),
      );
    });
  }

  QueryBuilder<StationPodcast, StationPodcast, QAfterWhereClause>
  stationIdEqualToPodcastIdLessThan(
    int stationId,
    int podcastId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'stationId_podcastId',
          lower: [stationId],
          upper: [stationId, podcastId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<StationPodcast, StationPodcast, QAfterWhereClause>
  stationIdEqualToPodcastIdBetween(
    int stationId,
    int lowerPodcastId,
    int upperPodcastId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'stationId_podcastId',
          lower: [stationId, lowerPodcastId],
          includeLower: includeLower,
          upper: [stationId, upperPodcastId],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension StationPodcastQueryFilter
    on QueryBuilder<StationPodcast, StationPodcast, QFilterCondition> {
  QueryBuilder<StationPodcast, StationPodcast, QAfterFilterCondition>
  addedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'addedAt', value: value),
      );
    });
  }

  QueryBuilder<StationPodcast, StationPodcast, QAfterFilterCondition>
  addedAtGreaterThan(DateTime value, {bool include = false}) {
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

  QueryBuilder<StationPodcast, StationPodcast, QAfterFilterCondition>
  addedAtLessThan(DateTime value, {bool include = false}) {
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

  QueryBuilder<StationPodcast, StationPodcast, QAfterFilterCondition>
  addedAtBetween(
    DateTime lower,
    DateTime upper, {
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

  QueryBuilder<StationPodcast, StationPodcast, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<StationPodcast, StationPodcast, QAfterFilterCondition>
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

  QueryBuilder<StationPodcast, StationPodcast, QAfterFilterCondition>
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

  QueryBuilder<StationPodcast, StationPodcast, QAfterFilterCondition> idBetween(
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

  QueryBuilder<StationPodcast, StationPodcast, QAfterFilterCondition>
  podcastIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'podcastId', value: value),
      );
    });
  }

  QueryBuilder<StationPodcast, StationPodcast, QAfterFilterCondition>
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

  QueryBuilder<StationPodcast, StationPodcast, QAfterFilterCondition>
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

  QueryBuilder<StationPodcast, StationPodcast, QAfterFilterCondition>
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

  QueryBuilder<StationPodcast, StationPodcast, QAfterFilterCondition>
  stationIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'stationId', value: value),
      );
    });
  }

  QueryBuilder<StationPodcast, StationPodcast, QAfterFilterCondition>
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

  QueryBuilder<StationPodcast, StationPodcast, QAfterFilterCondition>
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

  QueryBuilder<StationPodcast, StationPodcast, QAfterFilterCondition>
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

extension StationPodcastQueryObject
    on QueryBuilder<StationPodcast, StationPodcast, QFilterCondition> {}

extension StationPodcastQueryLinks
    on QueryBuilder<StationPodcast, StationPodcast, QFilterCondition> {}

extension StationPodcastQuerySortBy
    on QueryBuilder<StationPodcast, StationPodcast, QSortBy> {
  QueryBuilder<StationPodcast, StationPodcast, QAfterSortBy> sortByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.asc);
    });
  }

  QueryBuilder<StationPodcast, StationPodcast, QAfterSortBy>
  sortByAddedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.desc);
    });
  }

  QueryBuilder<StationPodcast, StationPodcast, QAfterSortBy> sortByPodcastId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastId', Sort.asc);
    });
  }

  QueryBuilder<StationPodcast, StationPodcast, QAfterSortBy>
  sortByPodcastIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastId', Sort.desc);
    });
  }

  QueryBuilder<StationPodcast, StationPodcast, QAfterSortBy> sortByStationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stationId', Sort.asc);
    });
  }

  QueryBuilder<StationPodcast, StationPodcast, QAfterSortBy>
  sortByStationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stationId', Sort.desc);
    });
  }
}

extension StationPodcastQuerySortThenBy
    on QueryBuilder<StationPodcast, StationPodcast, QSortThenBy> {
  QueryBuilder<StationPodcast, StationPodcast, QAfterSortBy> thenByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.asc);
    });
  }

  QueryBuilder<StationPodcast, StationPodcast, QAfterSortBy>
  thenByAddedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.desc);
    });
  }

  QueryBuilder<StationPodcast, StationPodcast, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<StationPodcast, StationPodcast, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<StationPodcast, StationPodcast, QAfterSortBy> thenByPodcastId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastId', Sort.asc);
    });
  }

  QueryBuilder<StationPodcast, StationPodcast, QAfterSortBy>
  thenByPodcastIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastId', Sort.desc);
    });
  }

  QueryBuilder<StationPodcast, StationPodcast, QAfterSortBy> thenByStationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stationId', Sort.asc);
    });
  }

  QueryBuilder<StationPodcast, StationPodcast, QAfterSortBy>
  thenByStationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stationId', Sort.desc);
    });
  }
}

extension StationPodcastQueryWhereDistinct
    on QueryBuilder<StationPodcast, StationPodcast, QDistinct> {
  QueryBuilder<StationPodcast, StationPodcast, QDistinct> distinctByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'addedAt');
    });
  }

  QueryBuilder<StationPodcast, StationPodcast, QDistinct>
  distinctByPodcastId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'podcastId');
    });
  }

  QueryBuilder<StationPodcast, StationPodcast, QDistinct>
  distinctByStationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stationId');
    });
  }
}

extension StationPodcastQueryProperty
    on QueryBuilder<StationPodcast, StationPodcast, QQueryProperty> {
  QueryBuilder<StationPodcast, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StationPodcast, DateTime, QQueryOperations> addedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'addedAt');
    });
  }

  QueryBuilder<StationPodcast, int, QQueryOperations> podcastIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'podcastId');
    });
  }

  QueryBuilder<StationPodcast, int, QQueryOperations> stationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stationId');
    });
  }
}
