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

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TranscriptImpl _$$TranscriptImplFromJson(Map<String, dynamic> json) =>
    _$TranscriptImpl(
      id: json['id'] as int?,
      pguid: json['pguid'] as String,
      guid: json['guid'] as String,
      subtitles: (json['subtitles'] as List<dynamic>?)
              ?.map((e) => Subtitle.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Subtitle>[],
      filtered: json['filtered'] as bool? ?? false,
    );

Map<String, dynamic> _$$TranscriptImplToJson(_$TranscriptImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pguid': instance.pguid,
      'guid': instance.guid,
      'subtitles': instance.subtitles.map((e) => e.toJson()).toList(),
      'filtered': instance.filtered,
    };

_$SubtitleImpl _$$SubtitleImplFromJson(Map<String, dynamic> json) =>
    _$SubtitleImpl(
      index: json['index'] as int,
      start: Duration(microseconds: json['start'] as int),
      end: json['end'] == null
          ? null
          : Duration(microseconds: json['end'] as int),
      data: json['data'] as String?,
      speaker: json['speaker'] as String? ?? '',
    );

Map<String, dynamic> _$$SubtitleImplToJson(_$SubtitleImpl instance) =>
    <String, dynamic>{
      'index': instance.index,
      'start': instance.start.inMicroseconds,
      'end': instance.end?.inMicroseconds,
      'data': instance.data,
      'speaker': instance.speaker,
    };
