// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcript.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTranscriptUrlCollection on Isar {
  IsarCollection<TranscriptUrl> get transcriptUrls => this.collection();
}

const TranscriptUrlSchema = CollectionSchema(
  name: r'TranscriptUrl',
  id: -5059617377644697676,
  properties: {
    r'language': PropertySchema(
      id: 0,
      name: r'language',
      type: IsarType.string,
    ),
    r'rel': PropertySchema(
      id: 1,
      name: r'rel',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 2,
      name: r'type',
      type: IsarType.byte,
      enumMap: _TranscriptUrltypeEnumValueMap,
    ),
    r'url': PropertySchema(
      id: 3,
      name: r'url',
      type: IsarType.string,
    )
  },
  estimateSize: _transcriptUrlEstimateSize,
  serialize: _transcriptUrlSerialize,
  deserialize: _transcriptUrlDeserialize,
  deserializeProp: _transcriptUrlDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _transcriptUrlGetId,
  getLinks: _transcriptUrlGetLinks,
  attach: _transcriptUrlAttach,
  version: '3.1.0+1',
);

int _transcriptUrlEstimateSize(
  TranscriptUrl object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.language.length * 3;
  bytesCount += 3 + object.rel.length * 3;
  bytesCount += 3 + object.url.length * 3;
  return bytesCount;
}

void _transcriptUrlSerialize(
  TranscriptUrl object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.language);
  writer.writeString(offsets[1], object.rel);
  writer.writeByte(offsets[2], object.type.index);
  writer.writeString(offsets[3], object.url);
}

TranscriptUrl _transcriptUrlDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TranscriptUrl(
    language: reader.readStringOrNull(offsets[0]) ?? '',
    rel: reader.readStringOrNull(offsets[1]) ?? '',
    type: _TranscriptUrltypeValueEnumMap[reader.readByteOrNull(offsets[2])] ??
        TranscriptFormat.unsupported,
    url: reader.readStringOrNull(offsets[3]) ?? '',
  );
  object.id = id;
  return object;
}

P _transcriptUrlDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 1:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 2:
      return (_TranscriptUrltypeValueEnumMap[reader.readByteOrNull(offset)] ??
          TranscriptFormat.unsupported) as P;
    case 3:
      return (reader.readStringOrNull(offset) ?? '') as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _TranscriptUrltypeEnumValueMap = {
  'json': 0,
  'subrip': 1,
  'unsupported': 2,
};
const _TranscriptUrltypeValueEnumMap = {
  0: TranscriptFormat.json,
  1: TranscriptFormat.subrip,
  2: TranscriptFormat.unsupported,
};

Id _transcriptUrlGetId(TranscriptUrl object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _transcriptUrlGetLinks(TranscriptUrl object) {
  return [];
}

void _transcriptUrlAttach(
    IsarCollection<dynamic> col, Id id, TranscriptUrl object) {
  object.id = id;
}

extension TranscriptUrlQueryWhereSort
    on QueryBuilder<TranscriptUrl, TranscriptUrl, QWhere> {
  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TranscriptUrlQueryWhere
    on QueryBuilder<TranscriptUrl, TranscriptUrl, QWhereClause> {
  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TranscriptUrlQueryFilter
    on QueryBuilder<TranscriptUrl, TranscriptUrl, QFilterCondition> {
  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition> idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition>
      idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition> idEqualTo(
      Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition>
      idGreaterThan(
    Id? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition> idLessThan(
    Id? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition> idBetween(
    Id? lower,
    Id? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition>
      languageEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition>
      languageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition>
      languageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition>
      languageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'language',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition>
      languageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition>
      languageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition>
      languageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition>
      languageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'language',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition>
      languageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'language',
        value: '',
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition>
      languageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'language',
        value: '',
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition> relEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition>
      relGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition> relLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition> relBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition>
      relStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition> relEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition> relContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition> relMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition>
      relIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rel',
        value: '',
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition>
      relIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rel',
        value: '',
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition> typeEqualTo(
      TranscriptFormat value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition>
      typeGreaterThan(
    TranscriptFormat value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition>
      typeLessThan(
    TranscriptFormat value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition> typeBetween(
    TranscriptFormat lower,
    TranscriptFormat upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition> urlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition>
      urlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition> urlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition> urlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'url',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition>
      urlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition> urlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition> urlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition> urlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'url',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition>
      urlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'url',
        value: '',
      ));
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterFilterCondition>
      urlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'url',
        value: '',
      ));
    });
  }
}

extension TranscriptUrlQueryObject
    on QueryBuilder<TranscriptUrl, TranscriptUrl, QFilterCondition> {}

extension TranscriptUrlQueryLinks
    on QueryBuilder<TranscriptUrl, TranscriptUrl, QFilterCondition> {}

extension TranscriptUrlQuerySortBy
    on QueryBuilder<TranscriptUrl, TranscriptUrl, QSortBy> {
  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterSortBy> sortByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterSortBy>
      sortByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterSortBy> sortByRel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rel', Sort.asc);
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterSortBy> sortByRelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rel', Sort.desc);
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterSortBy> sortByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterSortBy> sortByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension TranscriptUrlQuerySortThenBy
    on QueryBuilder<TranscriptUrl, TranscriptUrl, QSortThenBy> {
  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterSortBy> thenByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterSortBy>
      thenByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterSortBy> thenByRel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rel', Sort.asc);
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterSortBy> thenByRelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rel', Sort.desc);
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterSortBy> thenByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QAfterSortBy> thenByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension TranscriptUrlQueryWhereDistinct
    on QueryBuilder<TranscriptUrl, TranscriptUrl, QDistinct> {
  QueryBuilder<TranscriptUrl, TranscriptUrl, QDistinct> distinctByLanguage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'language', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QDistinct> distinctByRel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rel', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptUrl, QDistinct> distinctByUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'url', caseSensitive: caseSensitive);
    });
  }
}

extension TranscriptUrlQueryProperty
    on QueryBuilder<TranscriptUrl, TranscriptUrl, QQueryProperty> {
  QueryBuilder<TranscriptUrl, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TranscriptUrl, String, QQueryOperations> languageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'language');
    });
  }

  QueryBuilder<TranscriptUrl, String, QQueryOperations> relProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rel');
    });
  }

  QueryBuilder<TranscriptUrl, TranscriptFormat, QQueryOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<TranscriptUrl, String, QQueryOperations> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'url');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTranscriptCollection on Isar {
  IsarCollection<Transcript> get transcripts => this.collection();
}

const TranscriptSchema = CollectionSchema(
  name: r'Transcript',
  id: -8505618206250344956,
  properties: {
    r'filtered': PropertySchema(
      id: 0,
      name: r'filtered',
      type: IsarType.bool,
    ),
    r'guid': PropertySchema(
      id: 1,
      name: r'guid',
      type: IsarType.string,
    ),
    r'pguid': PropertySchema(
      id: 2,
      name: r'pguid',
      type: IsarType.string,
    ),
    r'transcriptId': PropertySchema(
      id: 3,
      name: r'transcriptId',
      type: IsarType.long,
    )
  },
  estimateSize: _transcriptEstimateSize,
  serialize: _transcriptSerialize,
  deserialize: _transcriptDeserialize,
  deserializeProp: _transcriptDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'subtitles': LinkSchema(
      id: -5558116200046957046,
      name: r'subtitles',
      target: r'Subtitle',
      single: false,
    )
  },
  embeddedSchemas: {},
  getId: _transcriptGetId,
  getLinks: _transcriptGetLinks,
  attach: _transcriptAttach,
  version: '3.1.0+1',
);

int _transcriptEstimateSize(
  Transcript object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.guid.length * 3;
  bytesCount += 3 + object.pguid.length * 3;
  return bytesCount;
}

void _transcriptSerialize(
  Transcript object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.filtered);
  writer.writeString(offsets[1], object.guid);
  writer.writeString(offsets[2], object.pguid);
  writer.writeLong(offsets[3], object.transcriptId);
}

Transcript _transcriptDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Transcript(
    filtered: reader.readBoolOrNull(offsets[0]) ?? false,
    guid: reader.readString(offsets[1]),
    pguid: reader.readString(offsets[2]),
    transcriptId: reader.readLongOrNull(offsets[3]),
  );
  return object;
}

P _transcriptDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _transcriptGetId(Transcript object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _transcriptGetLinks(Transcript object) {
  return [object.subtitles];
}

void _transcriptAttach(IsarCollection<dynamic> col, Id id, Transcript object) {
  object.subtitles
      .attach(col, col.isar.collection<Subtitle>(), r'subtitles', id);
}

extension TranscriptQueryWhereSort
    on QueryBuilder<Transcript, Transcript, QWhere> {
  QueryBuilder<Transcript, Transcript, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TranscriptQueryWhere
    on QueryBuilder<Transcript, Transcript, QWhereClause> {
  QueryBuilder<Transcript, Transcript, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Transcript, Transcript, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TranscriptQueryFilter
    on QueryBuilder<Transcript, Transcript, QFilterCondition> {
  QueryBuilder<Transcript, Transcript, QAfterFilterCondition> filteredEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'filtered',
        value: value,
      ));
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition> guidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'guid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition> guidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'guid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition> guidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'guid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition> guidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'guid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition> guidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'guid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition> guidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'guid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition> guidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'guid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition> guidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'guid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition> guidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'guid',
        value: '',
      ));
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition> guidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'guid',
        value: '',
      ));
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition> pguidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pguid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition> pguidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pguid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition> pguidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pguid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition> pguidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pguid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition> pguidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pguid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition> pguidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pguid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition> pguidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pguid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition> pguidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pguid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition> pguidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pguid',
        value: '',
      ));
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition>
      pguidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pguid',
        value: '',
      ));
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition>
      transcriptIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'transcriptId',
      ));
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition>
      transcriptIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'transcriptId',
      ));
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition>
      transcriptIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'transcriptId',
        value: value,
      ));
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition>
      transcriptIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'transcriptId',
        value: value,
      ));
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition>
      transcriptIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'transcriptId',
        value: value,
      ));
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition>
      transcriptIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'transcriptId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TranscriptQueryObject
    on QueryBuilder<Transcript, Transcript, QFilterCondition> {}

extension TranscriptQueryLinks
    on QueryBuilder<Transcript, Transcript, QFilterCondition> {
  QueryBuilder<Transcript, Transcript, QAfterFilterCondition> subtitles(
      FilterQuery<Subtitle> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'subtitles');
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition>
      subtitlesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'subtitles', length, true, length, true);
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition>
      subtitlesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'subtitles', 0, true, 0, true);
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition>
      subtitlesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'subtitles', 0, false, 999999, true);
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition>
      subtitlesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'subtitles', 0, true, length, include);
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition>
      subtitlesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'subtitles', length, include, 999999, true);
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterFilterCondition>
      subtitlesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'subtitles', lower, includeLower, upper, includeUpper);
    });
  }
}

extension TranscriptQuerySortBy
    on QueryBuilder<Transcript, Transcript, QSortBy> {
  QueryBuilder<Transcript, Transcript, QAfterSortBy> sortByFiltered() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filtered', Sort.asc);
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterSortBy> sortByFilteredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filtered', Sort.desc);
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterSortBy> sortByGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.asc);
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterSortBy> sortByGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.desc);
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterSortBy> sortByPguid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pguid', Sort.asc);
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterSortBy> sortByPguidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pguid', Sort.desc);
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterSortBy> sortByTranscriptId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transcriptId', Sort.asc);
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterSortBy> sortByTranscriptIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transcriptId', Sort.desc);
    });
  }
}

extension TranscriptQuerySortThenBy
    on QueryBuilder<Transcript, Transcript, QSortThenBy> {
  QueryBuilder<Transcript, Transcript, QAfterSortBy> thenByFiltered() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filtered', Sort.asc);
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterSortBy> thenByFilteredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filtered', Sort.desc);
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterSortBy> thenByGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.asc);
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterSortBy> thenByGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.desc);
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterSortBy> thenByPguid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pguid', Sort.asc);
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterSortBy> thenByPguidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pguid', Sort.desc);
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterSortBy> thenByTranscriptId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transcriptId', Sort.asc);
    });
  }

  QueryBuilder<Transcript, Transcript, QAfterSortBy> thenByTranscriptIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transcriptId', Sort.desc);
    });
  }
}

extension TranscriptQueryWhereDistinct
    on QueryBuilder<Transcript, Transcript, QDistinct> {
  QueryBuilder<Transcript, Transcript, QDistinct> distinctByFiltered() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'filtered');
    });
  }

  QueryBuilder<Transcript, Transcript, QDistinct> distinctByGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'guid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Transcript, Transcript, QDistinct> distinctByPguid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pguid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Transcript, Transcript, QDistinct> distinctByTranscriptId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'transcriptId');
    });
  }
}

extension TranscriptQueryProperty
    on QueryBuilder<Transcript, Transcript, QQueryProperty> {
  QueryBuilder<Transcript, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Transcript, bool, QQueryOperations> filteredProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filtered');
    });
  }

  QueryBuilder<Transcript, String, QQueryOperations> guidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'guid');
    });
  }

  QueryBuilder<Transcript, String, QQueryOperations> pguidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pguid');
    });
  }

  QueryBuilder<Transcript, int?, QQueryOperations> transcriptIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'transcriptId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSubtitleCollection on Isar {
  IsarCollection<Subtitle> get subtitles => this.collection();
}

const SubtitleSchema = CollectionSchema(
  name: r'Subtitle',
  id: -3865040321401720205,
  properties: {
    r'data': PropertySchema(
      id: 0,
      name: r'data',
      type: IsarType.string,
    ),
    r'endMS': PropertySchema(
      id: 1,
      name: r'endMS',
      type: IsarType.long,
    ),
    r'index': PropertySchema(
      id: 2,
      name: r'index',
      type: IsarType.long,
    ),
    r'speaker': PropertySchema(
      id: 3,
      name: r'speaker',
      type: IsarType.string,
    ),
    r'startMS': PropertySchema(
      id: 4,
      name: r'startMS',
      type: IsarType.long,
    )
  },
  estimateSize: _subtitleEstimateSize,
  serialize: _subtitleSerialize,
  deserialize: _subtitleDeserialize,
  deserializeProp: _subtitleDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _subtitleGetId,
  getLinks: _subtitleGetLinks,
  attach: _subtitleAttach,
  version: '3.1.0+1',
);

int _subtitleEstimateSize(
  Subtitle object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.data;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.speaker.length * 3;
  return bytesCount;
}

void _subtitleSerialize(
  Subtitle object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.data);
  writer.writeLong(offsets[1], object.endMS);
  writer.writeLong(offsets[2], object.index);
  writer.writeString(offsets[3], object.speaker);
  writer.writeLong(offsets[4], object.startMS);
}

Subtitle _subtitleDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Subtitle(
    data: reader.readStringOrNull(offsets[0]),
    endMS: reader.readLongOrNull(offsets[1]),
    id: id,
    index: reader.readLong(offsets[2]),
    speaker: reader.readStringOrNull(offsets[3]) ?? '',
    startMS: reader.readLong(offsets[4]),
  );
  return object;
}

P _subtitleDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 4:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _subtitleGetId(Subtitle object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _subtitleGetLinks(Subtitle object) {
  return [];
}

void _subtitleAttach(IsarCollection<dynamic> col, Id id, Subtitle object) {}

extension SubtitleQueryWhereSort on QueryBuilder<Subtitle, Subtitle, QWhere> {
  QueryBuilder<Subtitle, Subtitle, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SubtitleQueryWhere on QueryBuilder<Subtitle, Subtitle, QWhereClause> {
  QueryBuilder<Subtitle, Subtitle, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Subtitle, Subtitle, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SubtitleQueryFilter
    on QueryBuilder<Subtitle, Subtitle, QFilterCondition> {
  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> dataIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'data',
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> dataIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'data',
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> dataEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> dataGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'data',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> dataLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'data',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> dataBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'data',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> dataStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'data',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> dataEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'data',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> dataContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'data',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> dataMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'data',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> dataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data',
        value: '',
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> dataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'data',
        value: '',
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> endMSIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endMS',
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> endMSIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endMS',
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> endMSEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endMS',
        value: value,
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> endMSGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endMS',
        value: value,
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> endMSLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endMS',
        value: value,
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> endMSBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endMS',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> indexEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'index',
        value: value,
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> indexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'index',
        value: value,
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> indexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'index',
        value: value,
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> indexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'index',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> speakerEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'speaker',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> speakerGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'speaker',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> speakerLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'speaker',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> speakerBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'speaker',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> speakerStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'speaker',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> speakerEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'speaker',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> speakerContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'speaker',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> speakerMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'speaker',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> speakerIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'speaker',
        value: '',
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> speakerIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'speaker',
        value: '',
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> startMSEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startMS',
        value: value,
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> startMSGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startMS',
        value: value,
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> startMSLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startMS',
        value: value,
      ));
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterFilterCondition> startMSBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startMS',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SubtitleQueryObject
    on QueryBuilder<Subtitle, Subtitle, QFilterCondition> {}

extension SubtitleQueryLinks
    on QueryBuilder<Subtitle, Subtitle, QFilterCondition> {}

extension SubtitleQuerySortBy on QueryBuilder<Subtitle, Subtitle, QSortBy> {
  QueryBuilder<Subtitle, Subtitle, QAfterSortBy> sortByData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.asc);
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterSortBy> sortByDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.desc);
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterSortBy> sortByEndMS() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMS', Sort.asc);
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterSortBy> sortByEndMSDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMS', Sort.desc);
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterSortBy> sortByIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'index', Sort.asc);
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterSortBy> sortByIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'index', Sort.desc);
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterSortBy> sortBySpeaker() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speaker', Sort.asc);
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterSortBy> sortBySpeakerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speaker', Sort.desc);
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterSortBy> sortByStartMS() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMS', Sort.asc);
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterSortBy> sortByStartMSDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMS', Sort.desc);
    });
  }
}

extension SubtitleQuerySortThenBy
    on QueryBuilder<Subtitle, Subtitle, QSortThenBy> {
  QueryBuilder<Subtitle, Subtitle, QAfterSortBy> thenByData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.asc);
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterSortBy> thenByDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.desc);
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterSortBy> thenByEndMS() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMS', Sort.asc);
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterSortBy> thenByEndMSDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMS', Sort.desc);
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterSortBy> thenByIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'index', Sort.asc);
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterSortBy> thenByIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'index', Sort.desc);
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterSortBy> thenBySpeaker() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speaker', Sort.asc);
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterSortBy> thenBySpeakerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speaker', Sort.desc);
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterSortBy> thenByStartMS() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMS', Sort.asc);
    });
  }

  QueryBuilder<Subtitle, Subtitle, QAfterSortBy> thenByStartMSDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMS', Sort.desc);
    });
  }
}

extension SubtitleQueryWhereDistinct
    on QueryBuilder<Subtitle, Subtitle, QDistinct> {
  QueryBuilder<Subtitle, Subtitle, QDistinct> distinctByData(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'data', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Subtitle, Subtitle, QDistinct> distinctByEndMS() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endMS');
    });
  }

  QueryBuilder<Subtitle, Subtitle, QDistinct> distinctByIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'index');
    });
  }

  QueryBuilder<Subtitle, Subtitle, QDistinct> distinctBySpeaker(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'speaker', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Subtitle, Subtitle, QDistinct> distinctByStartMS() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startMS');
    });
  }
}

extension SubtitleQueryProperty
    on QueryBuilder<Subtitle, Subtitle, QQueryProperty> {
  QueryBuilder<Subtitle, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Subtitle, String?, QQueryOperations> dataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data');
    });
  }

  QueryBuilder<Subtitle, int?, QQueryOperations> endMSProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endMS');
    });
  }

  QueryBuilder<Subtitle, int, QQueryOperations> indexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'index');
    });
  }

  QueryBuilder<Subtitle, String, QQueryOperations> speakerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'speaker');
    });
  }

  QueryBuilder<Subtitle, int, QQueryOperations> startMSProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startMS');
    });
  }
}
