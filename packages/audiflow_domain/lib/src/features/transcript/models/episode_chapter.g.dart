// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode_chapter.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetEpisodeChapterCollection on Isar {
  IsarCollection<EpisodeChapter> get episodeChapters => this.collection();
}

const EpisodeChapterSchema = CollectionSchema(
  name: r'EpisodeChapter',
  id: 3403980131243765886,
  properties: {
    r'endMs': PropertySchema(id: 0, name: r'endMs', type: IsarType.long),
    r'episodeId': PropertySchema(
      id: 1,
      name: r'episodeId',
      type: IsarType.long,
    ),
    r'imageUrl': PropertySchema(
      id: 2,
      name: r'imageUrl',
      type: IsarType.string,
    ),
    r'sortOrder': PropertySchema(
      id: 3,
      name: r'sortOrder',
      type: IsarType.long,
    ),
    r'startMs': PropertySchema(id: 4, name: r'startMs', type: IsarType.long),
    r'title': PropertySchema(id: 5, name: r'title', type: IsarType.string),
    r'url': PropertySchema(id: 6, name: r'url', type: IsarType.string),
  },

  estimateSize: _episodeChapterEstimateSize,
  serialize: _episodeChapterSerialize,
  deserialize: _episodeChapterDeserialize,
  deserializeProp: _episodeChapterDeserializeProp,
  idName: r'id',
  indexes: {
    r'episodeId_sortOrder': IndexSchema(
      id: -386908115888310825,
      name: r'episodeId_sortOrder',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'episodeId',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'sortOrder',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _episodeChapterGetId,
  getLinks: _episodeChapterGetLinks,
  attach: _episodeChapterAttach,
  version: '3.3.2',
);

int _episodeChapterEstimateSize(
  EpisodeChapter object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.imageUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  {
    final value = object.url;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _episodeChapterSerialize(
  EpisodeChapter object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.endMs);
  writer.writeLong(offsets[1], object.episodeId);
  writer.writeString(offsets[2], object.imageUrl);
  writer.writeLong(offsets[3], object.sortOrder);
  writer.writeLong(offsets[4], object.startMs);
  writer.writeString(offsets[5], object.title);
  writer.writeString(offsets[6], object.url);
}

EpisodeChapter _episodeChapterDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EpisodeChapter();
  object.endMs = reader.readLongOrNull(offsets[0]);
  object.episodeId = reader.readLong(offsets[1]);
  object.id = id;
  object.imageUrl = reader.readStringOrNull(offsets[2]);
  object.sortOrder = reader.readLong(offsets[3]);
  object.startMs = reader.readLong(offsets[4]);
  object.title = reader.readString(offsets[5]);
  object.url = reader.readStringOrNull(offsets[6]);
  return object;
}

P _episodeChapterDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _episodeChapterGetId(EpisodeChapter object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _episodeChapterGetLinks(EpisodeChapter object) {
  return [];
}

void _episodeChapterAttach(
  IsarCollection<dynamic> col,
  Id id,
  EpisodeChapter object,
) {
  object.id = id;
}

extension EpisodeChapterByIndex on IsarCollection<EpisodeChapter> {
  Future<EpisodeChapter?> getByEpisodeIdSortOrder(
    int episodeId,
    int sortOrder,
  ) {
    return getByIndex(r'episodeId_sortOrder', [episodeId, sortOrder]);
  }

  EpisodeChapter? getByEpisodeIdSortOrderSync(int episodeId, int sortOrder) {
    return getByIndexSync(r'episodeId_sortOrder', [episodeId, sortOrder]);
  }

  Future<bool> deleteByEpisodeIdSortOrder(int episodeId, int sortOrder) {
    return deleteByIndex(r'episodeId_sortOrder', [episodeId, sortOrder]);
  }

  bool deleteByEpisodeIdSortOrderSync(int episodeId, int sortOrder) {
    return deleteByIndexSync(r'episodeId_sortOrder', [episodeId, sortOrder]);
  }

  Future<List<EpisodeChapter?>> getAllByEpisodeIdSortOrder(
    List<int> episodeIdValues,
    List<int> sortOrderValues,
  ) {
    final len = episodeIdValues.length;
    assert(
      sortOrderValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([episodeIdValues[i], sortOrderValues[i]]);
    }

    return getAllByIndex(r'episodeId_sortOrder', values);
  }

  List<EpisodeChapter?> getAllByEpisodeIdSortOrderSync(
    List<int> episodeIdValues,
    List<int> sortOrderValues,
  ) {
    final len = episodeIdValues.length;
    assert(
      sortOrderValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([episodeIdValues[i], sortOrderValues[i]]);
    }

    return getAllByIndexSync(r'episodeId_sortOrder', values);
  }

  Future<int> deleteAllByEpisodeIdSortOrder(
    List<int> episodeIdValues,
    List<int> sortOrderValues,
  ) {
    final len = episodeIdValues.length;
    assert(
      sortOrderValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([episodeIdValues[i], sortOrderValues[i]]);
    }

    return deleteAllByIndex(r'episodeId_sortOrder', values);
  }

  int deleteAllByEpisodeIdSortOrderSync(
    List<int> episodeIdValues,
    List<int> sortOrderValues,
  ) {
    final len = episodeIdValues.length;
    assert(
      sortOrderValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([episodeIdValues[i], sortOrderValues[i]]);
    }

    return deleteAllByIndexSync(r'episodeId_sortOrder', values);
  }

  Future<Id> putByEpisodeIdSortOrder(EpisodeChapter object) {
    return putByIndex(r'episodeId_sortOrder', object);
  }

  Id putByEpisodeIdSortOrderSync(
    EpisodeChapter object, {
    bool saveLinks = true,
  }) {
    return putByIndexSync(r'episodeId_sortOrder', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByEpisodeIdSortOrder(List<EpisodeChapter> objects) {
    return putAllByIndex(r'episodeId_sortOrder', objects);
  }

  List<Id> putAllByEpisodeIdSortOrderSync(
    List<EpisodeChapter> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(
      r'episodeId_sortOrder',
      objects,
      saveLinks: saveLinks,
    );
  }
}

extension EpisodeChapterQueryWhereSort
    on QueryBuilder<EpisodeChapter, EpisodeChapter, QWhere> {
  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterWhere>
  anyEpisodeIdSortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'episodeId_sortOrder'),
      );
    });
  }
}

extension EpisodeChapterQueryWhere
    on QueryBuilder<EpisodeChapter, EpisodeChapter, QWhereClause> {
  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterWhereClause> idBetween(
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

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterWhereClause>
  episodeIdEqualToAnySortOrder(int episodeId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'episodeId_sortOrder',
          value: [episodeId],
        ),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterWhereClause>
  episodeIdNotEqualToAnySortOrder(int episodeId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'episodeId_sortOrder',
                lower: [],
                upper: [episodeId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'episodeId_sortOrder',
                lower: [episodeId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'episodeId_sortOrder',
                lower: [episodeId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'episodeId_sortOrder',
                lower: [],
                upper: [episodeId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterWhereClause>
  episodeIdGreaterThanAnySortOrder(int episodeId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'episodeId_sortOrder',
          lower: [episodeId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterWhereClause>
  episodeIdLessThanAnySortOrder(int episodeId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'episodeId_sortOrder',
          lower: [],
          upper: [episodeId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterWhereClause>
  episodeIdBetweenAnySortOrder(
    int lowerEpisodeId,
    int upperEpisodeId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'episodeId_sortOrder',
          lower: [lowerEpisodeId],
          includeLower: includeLower,
          upper: [upperEpisodeId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterWhereClause>
  episodeIdSortOrderEqualTo(int episodeId, int sortOrder) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'episodeId_sortOrder',
          value: [episodeId, sortOrder],
        ),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterWhereClause>
  episodeIdEqualToSortOrderNotEqualTo(int episodeId, int sortOrder) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'episodeId_sortOrder',
                lower: [episodeId],
                upper: [episodeId, sortOrder],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'episodeId_sortOrder',
                lower: [episodeId, sortOrder],
                includeLower: false,
                upper: [episodeId],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'episodeId_sortOrder',
                lower: [episodeId, sortOrder],
                includeLower: false,
                upper: [episodeId],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'episodeId_sortOrder',
                lower: [episodeId],
                upper: [episodeId, sortOrder],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterWhereClause>
  episodeIdEqualToSortOrderGreaterThan(
    int episodeId,
    int sortOrder, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'episodeId_sortOrder',
          lower: [episodeId, sortOrder],
          includeLower: include,
          upper: [episodeId],
        ),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterWhereClause>
  episodeIdEqualToSortOrderLessThan(
    int episodeId,
    int sortOrder, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'episodeId_sortOrder',
          lower: [episodeId],
          upper: [episodeId, sortOrder],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterWhereClause>
  episodeIdEqualToSortOrderBetween(
    int episodeId,
    int lowerSortOrder,
    int upperSortOrder, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'episodeId_sortOrder',
          lower: [episodeId, lowerSortOrder],
          includeLower: includeLower,
          upper: [episodeId, upperSortOrder],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension EpisodeChapterQueryFilter
    on QueryBuilder<EpisodeChapter, EpisodeChapter, QFilterCondition> {
  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  endMsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'endMs'),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  endMsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'endMs'),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  endMsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'endMs', value: value),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  endMsGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'endMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  endMsLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'endMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  endMsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'endMs',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  episodeIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'episodeId', value: value),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
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

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
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

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
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

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
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

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
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

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition> idBetween(
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

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  imageUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'imageUrl'),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  imageUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'imageUrl'),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  imageUrlEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'imageUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  imageUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'imageUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  imageUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'imageUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  imageUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'imageUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  imageUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'imageUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  imageUrlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'imageUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  imageUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'imageUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  imageUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'imageUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  imageUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'imageUrl', value: ''),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  imageUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'imageUrl', value: ''),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  sortOrderEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sortOrder', value: value),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
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

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
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

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
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

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  startMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startMs', value: value),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  startMsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'startMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  startMsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'startMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  startMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startMs',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  titleEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
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

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  titleLessThan(
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

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  titleBetween(
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

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
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

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  titleEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  titleContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  titleMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  urlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'url'),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  urlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'url'),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  urlEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  urlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  urlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  urlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'url',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  urlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  urlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  urlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  urlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'url',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  urlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'url', value: ''),
      );
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterFilterCondition>
  urlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'url', value: ''),
      );
    });
  }
}

extension EpisodeChapterQueryObject
    on QueryBuilder<EpisodeChapter, EpisodeChapter, QFilterCondition> {}

extension EpisodeChapterQueryLinks
    on QueryBuilder<EpisodeChapter, EpisodeChapter, QFilterCondition> {}

extension EpisodeChapterQuerySortBy
    on QueryBuilder<EpisodeChapter, EpisodeChapter, QSortBy> {
  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterSortBy> sortByEndMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMs', Sort.asc);
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterSortBy> sortByEndMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMs', Sort.desc);
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterSortBy> sortByEpisodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeId', Sort.asc);
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterSortBy>
  sortByEpisodeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeId', Sort.desc);
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterSortBy> sortByImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.asc);
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterSortBy>
  sortByImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.desc);
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterSortBy> sortBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterSortBy>
  sortBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterSortBy> sortByStartMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMs', Sort.asc);
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterSortBy>
  sortByStartMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMs', Sort.desc);
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterSortBy> sortByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterSortBy> sortByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension EpisodeChapterQuerySortThenBy
    on QueryBuilder<EpisodeChapter, EpisodeChapter, QSortThenBy> {
  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterSortBy> thenByEndMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMs', Sort.asc);
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterSortBy> thenByEndMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMs', Sort.desc);
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterSortBy> thenByEpisodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeId', Sort.asc);
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterSortBy>
  thenByEpisodeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeId', Sort.desc);
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterSortBy> thenByImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.asc);
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterSortBy>
  thenByImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.desc);
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterSortBy> thenBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterSortBy>
  thenBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterSortBy> thenByStartMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMs', Sort.asc);
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterSortBy>
  thenByStartMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMs', Sort.desc);
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterSortBy> thenByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QAfterSortBy> thenByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension EpisodeChapterQueryWhereDistinct
    on QueryBuilder<EpisodeChapter, EpisodeChapter, QDistinct> {
  QueryBuilder<EpisodeChapter, EpisodeChapter, QDistinct> distinctByEndMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endMs');
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QDistinct>
  distinctByEpisodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'episodeId');
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QDistinct> distinctByImageUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imageUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QDistinct>
  distinctBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortOrder');
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QDistinct> distinctByStartMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startMs');
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EpisodeChapter, EpisodeChapter, QDistinct> distinctByUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'url', caseSensitive: caseSensitive);
    });
  }
}

extension EpisodeChapterQueryProperty
    on QueryBuilder<EpisodeChapter, EpisodeChapter, QQueryProperty> {
  QueryBuilder<EpisodeChapter, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<EpisodeChapter, int?, QQueryOperations> endMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endMs');
    });
  }

  QueryBuilder<EpisodeChapter, int, QQueryOperations> episodeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodeId');
    });
  }

  QueryBuilder<EpisodeChapter, String?, QQueryOperations> imageUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imageUrl');
    });
  }

  QueryBuilder<EpisodeChapter, int, QQueryOperations> sortOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortOrder');
    });
  }

  QueryBuilder<EpisodeChapter, int, QQueryOperations> startMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startMs');
    });
  }

  QueryBuilder<EpisodeChapter, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<EpisodeChapter, String?, QQueryOperations> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'url');
    });
  }
}
