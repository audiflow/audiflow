// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_parental_flags.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPodcastParentalFlagsCollection on Isar {
  IsarCollection<PodcastParentalFlags> get podcastParentalFlags =>
      this.collection();
}

const PodcastParentalFlagsSchema = CollectionSchema(
  name: r'PodcastParentalFlags',
  id: -7675570354198711160,
  properties: {
    r'hideExplicitEpisodes': PropertySchema(
      id: 0,
      name: r'hideExplicitEpisodes',
      type: IsarType.bool,
    ),
    r'itunesId': PropertySchema(id: 1, name: r'itunesId', type: IsarType.long),
  },

  estimateSize: _podcastParentalFlagsEstimateSize,
  serialize: _podcastParentalFlagsSerialize,
  deserialize: _podcastParentalFlagsDeserialize,
  deserializeProp: _podcastParentalFlagsDeserializeProp,
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
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _podcastParentalFlagsGetId,
  getLinks: _podcastParentalFlagsGetLinks,
  attach: _podcastParentalFlagsAttach,
  version: '3.3.2',
);

int _podcastParentalFlagsEstimateSize(
  PodcastParentalFlags object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _podcastParentalFlagsSerialize(
  PodcastParentalFlags object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.hideExplicitEpisodes);
  writer.writeLong(offsets[1], object.itunesId);
}

PodcastParentalFlags _podcastParentalFlagsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PodcastParentalFlags();
  object.hideExplicitEpisodes = reader.readBool(offsets[0]);
  object.id = id;
  object.itunesId = reader.readLong(offsets[1]);
  return object;
}

P _podcastParentalFlagsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _podcastParentalFlagsGetId(PodcastParentalFlags object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _podcastParentalFlagsGetLinks(
  PodcastParentalFlags object,
) {
  return [];
}

void _podcastParentalFlagsAttach(
  IsarCollection<dynamic> col,
  Id id,
  PodcastParentalFlags object,
) {
  object.id = id;
}

extension PodcastParentalFlagsByIndex on IsarCollection<PodcastParentalFlags> {
  Future<PodcastParentalFlags?> getByItunesId(int itunesId) {
    return getByIndex(r'itunesId', [itunesId]);
  }

  PodcastParentalFlags? getByItunesIdSync(int itunesId) {
    return getByIndexSync(r'itunesId', [itunesId]);
  }

  Future<bool> deleteByItunesId(int itunesId) {
    return deleteByIndex(r'itunesId', [itunesId]);
  }

  bool deleteByItunesIdSync(int itunesId) {
    return deleteByIndexSync(r'itunesId', [itunesId]);
  }

  Future<List<PodcastParentalFlags?>> getAllByItunesId(
    List<int> itunesIdValues,
  ) {
    final values = itunesIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'itunesId', values);
  }

  List<PodcastParentalFlags?> getAllByItunesIdSync(List<int> itunesIdValues) {
    final values = itunesIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'itunesId', values);
  }

  Future<int> deleteAllByItunesId(List<int> itunesIdValues) {
    final values = itunesIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'itunesId', values);
  }

  int deleteAllByItunesIdSync(List<int> itunesIdValues) {
    final values = itunesIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'itunesId', values);
  }

  Future<Id> putByItunesId(PodcastParentalFlags object) {
    return putByIndex(r'itunesId', object);
  }

  Id putByItunesIdSync(PodcastParentalFlags object, {bool saveLinks = true}) {
    return putByIndexSync(r'itunesId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByItunesId(List<PodcastParentalFlags> objects) {
    return putAllByIndex(r'itunesId', objects);
  }

  List<Id> putAllByItunesIdSync(
    List<PodcastParentalFlags> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'itunesId', objects, saveLinks: saveLinks);
  }
}

extension PodcastParentalFlagsQueryWhereSort
    on QueryBuilder<PodcastParentalFlags, PodcastParentalFlags, QWhere> {
  QueryBuilder<PodcastParentalFlags, PodcastParentalFlags, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PodcastParentalFlags, PodcastParentalFlags, QAfterWhere>
  anyItunesId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'itunesId'),
      );
    });
  }
}

extension PodcastParentalFlagsQueryWhere
    on QueryBuilder<PodcastParentalFlags, PodcastParentalFlags, QWhereClause> {
  QueryBuilder<PodcastParentalFlags, PodcastParentalFlags, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<PodcastParentalFlags, PodcastParentalFlags, QAfterWhereClause>
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

  QueryBuilder<PodcastParentalFlags, PodcastParentalFlags, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PodcastParentalFlags, PodcastParentalFlags, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PodcastParentalFlags, PodcastParentalFlags, QAfterWhereClause>
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

  QueryBuilder<PodcastParentalFlags, PodcastParentalFlags, QAfterWhereClause>
  itunesIdEqualTo(int itunesId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'itunesId', value: [itunesId]),
      );
    });
  }

  QueryBuilder<PodcastParentalFlags, PodcastParentalFlags, QAfterWhereClause>
  itunesIdNotEqualTo(int itunesId) {
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

  QueryBuilder<PodcastParentalFlags, PodcastParentalFlags, QAfterWhereClause>
  itunesIdGreaterThan(int itunesId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'itunesId',
          lower: [itunesId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<PodcastParentalFlags, PodcastParentalFlags, QAfterWhereClause>
  itunesIdLessThan(int itunesId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'itunesId',
          lower: [],
          upper: [itunesId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<PodcastParentalFlags, PodcastParentalFlags, QAfterWhereClause>
  itunesIdBetween(
    int lowerItunesId,
    int upperItunesId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'itunesId',
          lower: [lowerItunesId],
          includeLower: includeLower,
          upper: [upperItunesId],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension PodcastParentalFlagsQueryFilter
    on
        QueryBuilder<
          PodcastParentalFlags,
          PodcastParentalFlags,
          QFilterCondition
        > {
  QueryBuilder<
    PodcastParentalFlags,
    PodcastParentalFlags,
    QAfterFilterCondition
  >
  hideExplicitEpisodesEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'hideExplicitEpisodes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastParentalFlags,
    PodcastParentalFlags,
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
    PodcastParentalFlags,
    PodcastParentalFlags,
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
    PodcastParentalFlags,
    PodcastParentalFlags,
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
    PodcastParentalFlags,
    PodcastParentalFlags,
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
    PodcastParentalFlags,
    PodcastParentalFlags,
    QAfterFilterCondition
  >
  itunesIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'itunesId', value: value),
      );
    });
  }

  QueryBuilder<
    PodcastParentalFlags,
    PodcastParentalFlags,
    QAfterFilterCondition
  >
  itunesIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'itunesId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastParentalFlags,
    PodcastParentalFlags,
    QAfterFilterCondition
  >
  itunesIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'itunesId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PodcastParentalFlags,
    PodcastParentalFlags,
    QAfterFilterCondition
  >
  itunesIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'itunesId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension PodcastParentalFlagsQueryObject
    on
        QueryBuilder<
          PodcastParentalFlags,
          PodcastParentalFlags,
          QFilterCondition
        > {}

extension PodcastParentalFlagsQueryLinks
    on
        QueryBuilder<
          PodcastParentalFlags,
          PodcastParentalFlags,
          QFilterCondition
        > {}

extension PodcastParentalFlagsQuerySortBy
    on QueryBuilder<PodcastParentalFlags, PodcastParentalFlags, QSortBy> {
  QueryBuilder<PodcastParentalFlags, PodcastParentalFlags, QAfterSortBy>
  sortByHideExplicitEpisodes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hideExplicitEpisodes', Sort.asc);
    });
  }

  QueryBuilder<PodcastParentalFlags, PodcastParentalFlags, QAfterSortBy>
  sortByHideExplicitEpisodesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hideExplicitEpisodes', Sort.desc);
    });
  }

  QueryBuilder<PodcastParentalFlags, PodcastParentalFlags, QAfterSortBy>
  sortByItunesId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesId', Sort.asc);
    });
  }

  QueryBuilder<PodcastParentalFlags, PodcastParentalFlags, QAfterSortBy>
  sortByItunesIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesId', Sort.desc);
    });
  }
}

extension PodcastParentalFlagsQuerySortThenBy
    on QueryBuilder<PodcastParentalFlags, PodcastParentalFlags, QSortThenBy> {
  QueryBuilder<PodcastParentalFlags, PodcastParentalFlags, QAfterSortBy>
  thenByHideExplicitEpisodes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hideExplicitEpisodes', Sort.asc);
    });
  }

  QueryBuilder<PodcastParentalFlags, PodcastParentalFlags, QAfterSortBy>
  thenByHideExplicitEpisodesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hideExplicitEpisodes', Sort.desc);
    });
  }

  QueryBuilder<PodcastParentalFlags, PodcastParentalFlags, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PodcastParentalFlags, PodcastParentalFlags, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PodcastParentalFlags, PodcastParentalFlags, QAfterSortBy>
  thenByItunesId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesId', Sort.asc);
    });
  }

  QueryBuilder<PodcastParentalFlags, PodcastParentalFlags, QAfterSortBy>
  thenByItunesIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itunesId', Sort.desc);
    });
  }
}

extension PodcastParentalFlagsQueryWhereDistinct
    on QueryBuilder<PodcastParentalFlags, PodcastParentalFlags, QDistinct> {
  QueryBuilder<PodcastParentalFlags, PodcastParentalFlags, QDistinct>
  distinctByHideExplicitEpisodes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hideExplicitEpisodes');
    });
  }

  QueryBuilder<PodcastParentalFlags, PodcastParentalFlags, QDistinct>
  distinctByItunesId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itunesId');
    });
  }
}

extension PodcastParentalFlagsQueryProperty
    on
        QueryBuilder<
          PodcastParentalFlags,
          PodcastParentalFlags,
          QQueryProperty
        > {
  QueryBuilder<PodcastParentalFlags, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PodcastParentalFlags, bool, QQueryOperations>
  hideExplicitEpisodesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hideExplicitEpisodes');
    });
  }

  QueryBuilder<PodcastParentalFlags, int, QQueryOperations> itunesIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itunesId');
    });
  }
}
