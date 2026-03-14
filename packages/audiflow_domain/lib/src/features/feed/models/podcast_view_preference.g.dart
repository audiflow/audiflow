// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_view_preference.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPodcastViewPreferenceCollection on Isar {
  IsarCollection<PodcastViewPreference> get podcastViewPreferences =>
      this.collection();
}

const PodcastViewPreferenceSchema = CollectionSchema(
  name: r'PodcastViewPreference',
  id: -5835931761276870986,
  properties: {
    r'episodeFilter': PropertySchema(
      id: 0,
      name: r'episodeFilter',
      type: IsarType.string,
    ),
    r'episodeSortOrder': PropertySchema(
      id: 1,
      name: r'episodeSortOrder',
      type: IsarType.string,
    ),
    r'podcastId': PropertySchema(
      id: 2,
      name: r'podcastId',
      type: IsarType.long,
    ),
    r'seasonSortField': PropertySchema(
      id: 3,
      name: r'seasonSortField',
      type: IsarType.string,
    ),
    r'seasonSortOrder': PropertySchema(
      id: 4,
      name: r'seasonSortOrder',
      type: IsarType.string,
    ),
    r'selectedPlaylistId': PropertySchema(
      id: 5,
      name: r'selectedPlaylistId',
      type: IsarType.string,
    ),
    r'viewMode': PropertySchema(
      id: 6,
      name: r'viewMode',
      type: IsarType.string,
    ),
  },

  estimateSize: _podcastViewPreferenceEstimateSize,
  serialize: _podcastViewPreferenceSerialize,
  deserialize: _podcastViewPreferenceDeserialize,
  deserializeProp: _podcastViewPreferenceDeserializeProp,
  idName: r'id',
  indexes: {
    r'podcastId': IndexSchema(
      id: -1067219606322714012,
      name: r'podcastId',
      unique: true,
      replace: false,
      properties: [
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

  getId: _podcastViewPreferenceGetId,
  getLinks: _podcastViewPreferenceGetLinks,
  attach: _podcastViewPreferenceAttach,
  version: '3.3.0',
);

int _podcastViewPreferenceEstimateSize(
  PodcastViewPreference object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.episodeFilter.length * 3;
  bytesCount += 3 + object.episodeSortOrder.length * 3;
  bytesCount += 3 + object.seasonSortField.length * 3;
  bytesCount += 3 + object.seasonSortOrder.length * 3;
  {
    final value = object.selectedPlaylistId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.viewMode.length * 3;
  return bytesCount;
}

void _podcastViewPreferenceSerialize(
  PodcastViewPreference object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.episodeFilter);
  writer.writeString(offsets[1], object.episodeSortOrder);
  writer.writeLong(offsets[2], object.podcastId);
  writer.writeString(offsets[3], object.seasonSortField);
  writer.writeString(offsets[4], object.seasonSortOrder);
  writer.writeString(offsets[5], object.selectedPlaylistId);
  writer.writeString(offsets[6], object.viewMode);
}

PodcastViewPreference _podcastViewPreferenceDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PodcastViewPreference();
  object.episodeFilter = reader.readString(offsets[0]);
  object.episodeSortOrder = reader.readString(offsets[1]);
  object.id = id;
  object.podcastId = reader.readLong(offsets[2]);
  object.seasonSortField = reader.readString(offsets[3]);
  object.seasonSortOrder = reader.readString(offsets[4]);
  object.selectedPlaylistId = reader.readStringOrNull(offsets[5]);
  object.viewMode = reader.readString(offsets[6]);
  return object;
}

P _podcastViewPreferenceDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _podcastViewPreferenceGetId(PodcastViewPreference object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _podcastViewPreferenceGetLinks(
  PodcastViewPreference object,
) {
  return [];
}

void _podcastViewPreferenceAttach(
  IsarCollection<dynamic> col,
  Id id,
  PodcastViewPreference object,
) {
  object.id = id;
}

extension PodcastViewPreferenceByIndex
    on IsarCollection<PodcastViewPreference> {
  Future<PodcastViewPreference?> getByPodcastId(int podcastId) {
    return getByIndex(r'podcastId', [podcastId]);
  }

  PodcastViewPreference? getByPodcastIdSync(int podcastId) {
    return getByIndexSync(r'podcastId', [podcastId]);
  }

  Future<bool> deleteByPodcastId(int podcastId) {
    return deleteByIndex(r'podcastId', [podcastId]);
  }

  bool deleteByPodcastIdSync(int podcastId) {
    return deleteByIndexSync(r'podcastId', [podcastId]);
  }

  Future<List<PodcastViewPreference?>> getAllByPodcastId(
    List<int> podcastIdValues,
  ) {
    final values = podcastIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'podcastId', values);
  }

  List<PodcastViewPreference?> getAllByPodcastIdSync(
    List<int> podcastIdValues,
  ) {
    final values = podcastIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'podcastId', values);
  }

  Future<int> deleteAllByPodcastId(List<int> podcastIdValues) {
    final values = podcastIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'podcastId', values);
  }

  int deleteAllByPodcastIdSync(List<int> podcastIdValues) {
    final values = podcastIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'podcastId', values);
  }

  Future<Id> putByPodcastId(PodcastViewPreference object) {
    return putByIndex(r'podcastId', object);
  }

  Id putByPodcastIdSync(PodcastViewPreference object, {bool saveLinks = true}) {
    return putByIndexSync(r'podcastId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPodcastId(List<PodcastViewPreference> objects) {
    return putAllByIndex(r'podcastId', objects);
  }

  List<Id> putAllByPodcastIdSync(
    List<PodcastViewPreference> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'podcastId', objects, saveLinks: saveLinks);
  }
}

extension PodcastViewPreferenceQueryWhereSort
    on QueryBuilder<PodcastViewPreference, PodcastViewPreference, QWhere> {
  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterWhere>
  anyPodcastId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'podcastId'),
      );
    });
  }
}

extension PodcastViewPreferenceQueryWhere
    on
        QueryBuilder<
          PodcastViewPreference,
          PodcastViewPreference,
          QWhereClause
        > {
  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterWhereClause>
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

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterWhereClause>
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

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterWhereClause>
  podcastIdEqualTo(int podcastId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'podcastId', value: [podcastId]),
      );
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterWhereClause>
  podcastIdNotEqualTo(int podcastId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId',
                lower: [],
                upper: [podcastId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId',
                lower: [podcastId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId',
                lower: [podcastId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'podcastId',
                lower: [],
                upper: [podcastId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterWhereClause>
  podcastIdGreaterThan(int podcastId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'podcastId',
          lower: [podcastId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterWhereClause>
  podcastIdLessThan(int podcastId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'podcastId',
          lower: [],
          upper: [podcastId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterWhereClause>
  podcastIdBetween(
    int lowerPodcastId,
    int upperPodcastId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'podcastId',
          lower: [lowerPodcastId],
          includeLower: includeLower,
          upper: [upperPodcastId],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension PodcastViewPreferenceQueryFilter
    on
        QueryBuilder<
          PodcastViewPreference,
          PodcastViewPreference,
          QFilterCondition
        > {
  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  episodeFilterEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'episodeFilter',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  episodeFilterGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'episodeFilter',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  episodeFilterLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'episodeFilter',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  episodeFilterBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'episodeFilter',
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
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  episodeFilterStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'episodeFilter',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  episodeFilterEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'episodeFilter',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  episodeFilterContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'episodeFilter',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  episodeFilterMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'episodeFilter',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  episodeFilterIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'episodeFilter', value: ''),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  episodeFilterIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'episodeFilter', value: ''),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  episodeSortOrderEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'episodeSortOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  episodeSortOrderGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'episodeSortOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  episodeSortOrderLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'episodeSortOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  episodeSortOrderBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'episodeSortOrder',
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
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  episodeSortOrderStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'episodeSortOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  episodeSortOrderEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'episodeSortOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  episodeSortOrderContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'episodeSortOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  episodeSortOrderMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'episodeSortOrder',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  episodeSortOrderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'episodeSortOrder', value: ''),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  episodeSortOrderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'episodeSortOrder', value: ''),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
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
    PodcastViewPreference,
    PodcastViewPreference,
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
    PodcastViewPreference,
    PodcastViewPreference,
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
    PodcastViewPreference,
    PodcastViewPreference,
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
    PodcastViewPreference,
    PodcastViewPreference,
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
    PodcastViewPreference,
    PodcastViewPreference,
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
    PodcastViewPreference,
    PodcastViewPreference,
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
    PodcastViewPreference,
    PodcastViewPreference,
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
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  seasonSortFieldEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'seasonSortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  seasonSortFieldGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'seasonSortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  seasonSortFieldLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'seasonSortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  seasonSortFieldBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'seasonSortField',
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
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  seasonSortFieldStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'seasonSortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  seasonSortFieldEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'seasonSortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  seasonSortFieldContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'seasonSortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  seasonSortFieldMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'seasonSortField',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  seasonSortFieldIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'seasonSortField', value: ''),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  seasonSortFieldIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'seasonSortField', value: ''),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  seasonSortOrderEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'seasonSortOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  seasonSortOrderGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'seasonSortOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  seasonSortOrderLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'seasonSortOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  seasonSortOrderBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'seasonSortOrder',
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
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  seasonSortOrderStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'seasonSortOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  seasonSortOrderEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'seasonSortOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  seasonSortOrderContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'seasonSortOrder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  seasonSortOrderMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'seasonSortOrder',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  seasonSortOrderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'seasonSortOrder', value: ''),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  seasonSortOrderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'seasonSortOrder', value: ''),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  selectedPlaylistIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'selectedPlaylistId'),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  selectedPlaylistIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'selectedPlaylistId'),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  selectedPlaylistIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'selectedPlaylistId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  selectedPlaylistIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'selectedPlaylistId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  selectedPlaylistIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'selectedPlaylistId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  selectedPlaylistIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'selectedPlaylistId',
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
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  selectedPlaylistIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'selectedPlaylistId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  selectedPlaylistIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'selectedPlaylistId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  selectedPlaylistIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'selectedPlaylistId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  selectedPlaylistIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'selectedPlaylistId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  selectedPlaylistIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'selectedPlaylistId', value: ''),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  selectedPlaylistIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'selectedPlaylistId', value: ''),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  viewModeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'viewMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  viewModeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'viewMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  viewModeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'viewMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  viewModeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'viewMode',
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
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  viewModeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'viewMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  viewModeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'viewMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  viewModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'viewMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  viewModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'viewMode',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  viewModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'viewMode', value: ''),
      );
    });
  }

  QueryBuilder<
    PodcastViewPreference,
    PodcastViewPreference,
    QAfterFilterCondition
  >
  viewModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'viewMode', value: ''),
      );
    });
  }
}

extension PodcastViewPreferenceQueryObject
    on
        QueryBuilder<
          PodcastViewPreference,
          PodcastViewPreference,
          QFilterCondition
        > {}

extension PodcastViewPreferenceQueryLinks
    on
        QueryBuilder<
          PodcastViewPreference,
          PodcastViewPreference,
          QFilterCondition
        > {}

extension PodcastViewPreferenceQuerySortBy
    on QueryBuilder<PodcastViewPreference, PodcastViewPreference, QSortBy> {
  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterSortBy>
  sortByEpisodeFilter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeFilter', Sort.asc);
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterSortBy>
  sortByEpisodeFilterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeFilter', Sort.desc);
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterSortBy>
  sortByEpisodeSortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeSortOrder', Sort.asc);
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterSortBy>
  sortByEpisodeSortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeSortOrder', Sort.desc);
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterSortBy>
  sortByPodcastId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastId', Sort.asc);
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterSortBy>
  sortByPodcastIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastId', Sort.desc);
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterSortBy>
  sortBySeasonSortField() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonSortField', Sort.asc);
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterSortBy>
  sortBySeasonSortFieldDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonSortField', Sort.desc);
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterSortBy>
  sortBySeasonSortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonSortOrder', Sort.asc);
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterSortBy>
  sortBySeasonSortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonSortOrder', Sort.desc);
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterSortBy>
  sortBySelectedPlaylistId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedPlaylistId', Sort.asc);
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterSortBy>
  sortBySelectedPlaylistIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedPlaylistId', Sort.desc);
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterSortBy>
  sortByViewMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.asc);
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterSortBy>
  sortByViewModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.desc);
    });
  }
}

extension PodcastViewPreferenceQuerySortThenBy
    on QueryBuilder<PodcastViewPreference, PodcastViewPreference, QSortThenBy> {
  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterSortBy>
  thenByEpisodeFilter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeFilter', Sort.asc);
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterSortBy>
  thenByEpisodeFilterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeFilter', Sort.desc);
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterSortBy>
  thenByEpisodeSortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeSortOrder', Sort.asc);
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterSortBy>
  thenByEpisodeSortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeSortOrder', Sort.desc);
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterSortBy>
  thenByPodcastId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastId', Sort.asc);
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterSortBy>
  thenByPodcastIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'podcastId', Sort.desc);
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterSortBy>
  thenBySeasonSortField() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonSortField', Sort.asc);
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterSortBy>
  thenBySeasonSortFieldDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonSortField', Sort.desc);
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterSortBy>
  thenBySeasonSortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonSortOrder', Sort.asc);
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterSortBy>
  thenBySeasonSortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonSortOrder', Sort.desc);
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterSortBy>
  thenBySelectedPlaylistId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedPlaylistId', Sort.asc);
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterSortBy>
  thenBySelectedPlaylistIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedPlaylistId', Sort.desc);
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterSortBy>
  thenByViewMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.asc);
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QAfterSortBy>
  thenByViewModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.desc);
    });
  }
}

extension PodcastViewPreferenceQueryWhereDistinct
    on QueryBuilder<PodcastViewPreference, PodcastViewPreference, QDistinct> {
  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QDistinct>
  distinctByEpisodeFilter({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'episodeFilter',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QDistinct>
  distinctByEpisodeSortOrder({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'episodeSortOrder',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QDistinct>
  distinctByPodcastId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'podcastId');
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QDistinct>
  distinctBySeasonSortField({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'seasonSortField',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QDistinct>
  distinctBySeasonSortOrder({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'seasonSortOrder',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QDistinct>
  distinctBySelectedPlaylistId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'selectedPlaylistId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PodcastViewPreference, PodcastViewPreference, QDistinct>
  distinctByViewMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'viewMode', caseSensitive: caseSensitive);
    });
  }
}

extension PodcastViewPreferenceQueryProperty
    on
        QueryBuilder<
          PodcastViewPreference,
          PodcastViewPreference,
          QQueryProperty
        > {
  QueryBuilder<PodcastViewPreference, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PodcastViewPreference, String, QQueryOperations>
  episodeFilterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodeFilter');
    });
  }

  QueryBuilder<PodcastViewPreference, String, QQueryOperations>
  episodeSortOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodeSortOrder');
    });
  }

  QueryBuilder<PodcastViewPreference, int, QQueryOperations>
  podcastIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'podcastId');
    });
  }

  QueryBuilder<PodcastViewPreference, String, QQueryOperations>
  seasonSortFieldProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'seasonSortField');
    });
  }

  QueryBuilder<PodcastViewPreference, String, QQueryOperations>
  seasonSortOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'seasonSortOrder');
    });
  }

  QueryBuilder<PodcastViewPreference, String?, QQueryOperations>
  selectedPlaylistIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'selectedPlaylistId');
    });
  }

  QueryBuilder<PodcastViewPreference, String, QQueryOperations>
  viewModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'viewMode');
    });
  }
}
