// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_file_removal.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetDownloadFileRemovalCollection on Isar {
  IsarCollection<DownloadFileRemoval> get downloadFileRemovals =>
      this.collection();
}

const DownloadFileRemovalSchema = CollectionSchema(
  name: r'DownloadFileRemoval',
  id: 431730033541783406,
  properties: {
    r'episodeId': PropertySchema(
      id: 0,
      name: r'episodeId',
      type: IsarType.long,
    ),
    r'storedPath': PropertySchema(
      id: 1,
      name: r'storedPath',
      type: IsarType.string,
    ),
  },

  estimateSize: _downloadFileRemovalEstimateSize,
  serialize: _downloadFileRemovalSerialize,
  deserialize: _downloadFileRemovalDeserialize,
  deserializeProp: _downloadFileRemovalDeserializeProp,
  idName: r'id',
  indexes: {
    r'episodeId': IndexSchema(
      id: -5445487708405506290,
      name: r'episodeId',
      unique: true,
      replace: true,
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

  getId: _downloadFileRemovalGetId,
  getLinks: _downloadFileRemovalGetLinks,
  attach: _downloadFileRemovalAttach,
  version: '3.3.2',
);

int _downloadFileRemovalEstimateSize(
  DownloadFileRemoval object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.storedPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _downloadFileRemovalSerialize(
  DownloadFileRemoval object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.episodeId);
  writer.writeString(offsets[1], object.storedPath);
}

DownloadFileRemoval _downloadFileRemovalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DownloadFileRemoval();
  object.episodeId = reader.readLong(offsets[0]);
  object.id = id;
  object.storedPath = reader.readStringOrNull(offsets[1]);
  return object;
}

P _downloadFileRemovalDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _downloadFileRemovalGetId(DownloadFileRemoval object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _downloadFileRemovalGetLinks(
  DownloadFileRemoval object,
) {
  return [];
}

void _downloadFileRemovalAttach(
  IsarCollection<dynamic> col,
  Id id,
  DownloadFileRemoval object,
) {
  object.id = id;
}

extension DownloadFileRemovalByIndex on IsarCollection<DownloadFileRemoval> {
  Future<DownloadFileRemoval?> getByEpisodeId(int episodeId) {
    return getByIndex(r'episodeId', [episodeId]);
  }

  DownloadFileRemoval? getByEpisodeIdSync(int episodeId) {
    return getByIndexSync(r'episodeId', [episodeId]);
  }

  Future<bool> deleteByEpisodeId(int episodeId) {
    return deleteByIndex(r'episodeId', [episodeId]);
  }

  bool deleteByEpisodeIdSync(int episodeId) {
    return deleteByIndexSync(r'episodeId', [episodeId]);
  }

  Future<List<DownloadFileRemoval?>> getAllByEpisodeId(
    List<int> episodeIdValues,
  ) {
    final values = episodeIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'episodeId', values);
  }

  List<DownloadFileRemoval?> getAllByEpisodeIdSync(List<int> episodeIdValues) {
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

  Future<Id> putByEpisodeId(DownloadFileRemoval object) {
    return putByIndex(r'episodeId', object);
  }

  Id putByEpisodeIdSync(DownloadFileRemoval object, {bool saveLinks = true}) {
    return putByIndexSync(r'episodeId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByEpisodeId(List<DownloadFileRemoval> objects) {
    return putAllByIndex(r'episodeId', objects);
  }

  List<Id> putAllByEpisodeIdSync(
    List<DownloadFileRemoval> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'episodeId', objects, saveLinks: saveLinks);
  }
}

extension DownloadFileRemovalQueryWhereSort
    on QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QWhere> {
  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterWhere>
  anyEpisodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'episodeId'),
      );
    });
  }
}

extension DownloadFileRemovalQueryWhere
    on QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QWhereClause> {
  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterWhereClause>
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

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterWhereClause>
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

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterWhereClause>
  episodeIdEqualTo(int episodeId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'episodeId', value: [episodeId]),
      );
    });
  }

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterWhereClause>
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

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterWhereClause>
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

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterWhereClause>
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

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterWhereClause>
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

extension DownloadFileRemovalQueryFilter
    on
        QueryBuilder<
          DownloadFileRemoval,
          DownloadFileRemoval,
          QFilterCondition
        > {
  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterFilterCondition>
  episodeIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'episodeId', value: value),
      );
    });
  }

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterFilterCondition>
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

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterFilterCondition>
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

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterFilterCondition>
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

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterFilterCondition>
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

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterFilterCondition>
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

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterFilterCondition>
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

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterFilterCondition>
  storedPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'storedPath'),
      );
    });
  }

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterFilterCondition>
  storedPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'storedPath'),
      );
    });
  }

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterFilterCondition>
  storedPathEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'storedPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterFilterCondition>
  storedPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'storedPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterFilterCondition>
  storedPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'storedPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterFilterCondition>
  storedPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'storedPath',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterFilterCondition>
  storedPathStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'storedPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterFilterCondition>
  storedPathEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'storedPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterFilterCondition>
  storedPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'storedPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterFilterCondition>
  storedPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'storedPath',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterFilterCondition>
  storedPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'storedPath', value: ''),
      );
    });
  }

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterFilterCondition>
  storedPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'storedPath', value: ''),
      );
    });
  }
}

extension DownloadFileRemovalQueryObject
    on
        QueryBuilder<
          DownloadFileRemoval,
          DownloadFileRemoval,
          QFilterCondition
        > {}

extension DownloadFileRemovalQueryLinks
    on
        QueryBuilder<
          DownloadFileRemoval,
          DownloadFileRemoval,
          QFilterCondition
        > {}

extension DownloadFileRemovalQuerySortBy
    on QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QSortBy> {
  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterSortBy>
  sortByEpisodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeId', Sort.asc);
    });
  }

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterSortBy>
  sortByEpisodeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeId', Sort.desc);
    });
  }

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterSortBy>
  sortByStoredPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storedPath', Sort.asc);
    });
  }

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterSortBy>
  sortByStoredPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storedPath', Sort.desc);
    });
  }
}

extension DownloadFileRemovalQuerySortThenBy
    on QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QSortThenBy> {
  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterSortBy>
  thenByEpisodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeId', Sort.asc);
    });
  }

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterSortBy>
  thenByEpisodeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeId', Sort.desc);
    });
  }

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterSortBy>
  thenByStoredPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storedPath', Sort.asc);
    });
  }

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QAfterSortBy>
  thenByStoredPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storedPath', Sort.desc);
    });
  }
}

extension DownloadFileRemovalQueryWhereDistinct
    on QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QDistinct> {
  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QDistinct>
  distinctByEpisodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'episodeId');
    });
  }

  QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QDistinct>
  distinctByStoredPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'storedPath', caseSensitive: caseSensitive);
    });
  }
}

extension DownloadFileRemovalQueryProperty
    on QueryBuilder<DownloadFileRemoval, DownloadFileRemoval, QQueryProperty> {
  QueryBuilder<DownloadFileRemoval, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DownloadFileRemoval, int, QQueryOperations> episodeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodeId');
    });
  }

  QueryBuilder<DownloadFileRemoval, String?, QQueryOperations>
  storedPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'storedPath');
    });
  }
}
