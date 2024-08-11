// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_queue_builder_info.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAutoQueueBuilderInfoCollection on Isar {
  IsarCollection<AutoQueueBuilderInfo> get autoQueueBuilderInfos =>
      this.collection();
}

const AutoQueueBuilderInfoSchema = CollectionSchema(
  name: r'AutoQueueBuilderInfo',
  id: 8832518747618792917,
  properties: {
    r'json': PropertySchema(
      id: 0,
      name: r'json',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 1,
      name: r'type',
      type: IsarType.byte,
      enumMap: _AutoQueueBuilderInfotypeEnumValueMap,
    )
  },
  estimateSize: _autoQueueBuilderInfoEstimateSize,
  serialize: _autoQueueBuilderInfoSerialize,
  deserialize: _autoQueueBuilderInfoDeserialize,
  deserializeProp: _autoQueueBuilderInfoDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _autoQueueBuilderInfoGetId,
  getLinks: _autoQueueBuilderInfoGetLinks,
  attach: _autoQueueBuilderInfoAttach,
  version: '3.1.7',
);

int _autoQueueBuilderInfoEstimateSize(
  AutoQueueBuilderInfo object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.json.length * 3;
  return bytesCount;
}

void _autoQueueBuilderInfoSerialize(
  AutoQueueBuilderInfo object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.json);
  writer.writeByte(offsets[1], object.type.index);
}

AutoQueueBuilderInfo _autoQueueBuilderInfoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AutoQueueBuilderInfo(
    json: reader.readString(offsets[0]),
    type: _AutoQueueBuilderInfotypeValueEnumMap[
            reader.readByteOrNull(offsets[1])] ??
        AutoQueueBuilderType.detailsPage,
  );
  return object;
}

P _autoQueueBuilderInfoDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (_AutoQueueBuilderInfotypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          AutoQueueBuilderType.detailsPage) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _AutoQueueBuilderInfotypeEnumValueMap = {
  'detailsPage': 0,
};
const _AutoQueueBuilderInfotypeValueEnumMap = {
  0: AutoQueueBuilderType.detailsPage,
};

Id _autoQueueBuilderInfoGetId(AutoQueueBuilderInfo object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _autoQueueBuilderInfoGetLinks(
    AutoQueueBuilderInfo object) {
  return [];
}

void _autoQueueBuilderInfoAttach(
    IsarCollection<dynamic> col, Id id, AutoQueueBuilderInfo object) {}

extension AutoQueueBuilderInfoQueryWhereSort
    on QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo, QWhere> {
  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AutoQueueBuilderInfoQueryWhere
    on QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo, QWhereClause> {
  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo, QAfterWhereClause>
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

  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo, QAfterWhereClause>
      idBetween(
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

extension AutoQueueBuilderInfoQueryFilter on QueryBuilder<AutoQueueBuilderInfo,
    AutoQueueBuilderInfo, QFilterCondition> {
  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo,
      QAfterFilterCondition> jsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'json',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo,
      QAfterFilterCondition> jsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'json',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo,
      QAfterFilterCondition> jsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'json',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo,
      QAfterFilterCondition> jsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'json',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo,
      QAfterFilterCondition> jsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'json',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo,
      QAfterFilterCondition> jsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'json',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo,
          QAfterFilterCondition>
      jsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'json',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo,
          QAfterFilterCondition>
      jsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'json',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo,
      QAfterFilterCondition> jsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'json',
        value: '',
      ));
    });
  }

  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo,
      QAfterFilterCondition> jsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'json',
        value: '',
      ));
    });
  }

  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo,
      QAfterFilterCondition> typeEqualTo(AutoQueueBuilderType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo,
      QAfterFilterCondition> typeGreaterThan(
    AutoQueueBuilderType value, {
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

  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo,
      QAfterFilterCondition> typeLessThan(
    AutoQueueBuilderType value, {
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

  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo,
      QAfterFilterCondition> typeBetween(
    AutoQueueBuilderType lower,
    AutoQueueBuilderType upper, {
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
}

extension AutoQueueBuilderInfoQueryObject on QueryBuilder<AutoQueueBuilderInfo,
    AutoQueueBuilderInfo, QFilterCondition> {}

extension AutoQueueBuilderInfoQueryLinks on QueryBuilder<AutoQueueBuilderInfo,
    AutoQueueBuilderInfo, QFilterCondition> {}

extension AutoQueueBuilderInfoQuerySortBy
    on QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo, QSortBy> {
  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo, QAfterSortBy>
      sortByJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'json', Sort.asc);
    });
  }

  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo, QAfterSortBy>
      sortByJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'json', Sort.desc);
    });
  }

  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo, QAfterSortBy>
      sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension AutoQueueBuilderInfoQuerySortThenBy
    on QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo, QSortThenBy> {
  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo, QAfterSortBy>
      thenByJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'json', Sort.asc);
    });
  }

  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo, QAfterSortBy>
      thenByJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'json', Sort.desc);
    });
  }

  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo, QAfterSortBy>
      thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension AutoQueueBuilderInfoQueryWhereDistinct
    on QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo, QDistinct> {
  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo, QDistinct>
      distinctByJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'json', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderInfo, QDistinct>
      distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }
}

extension AutoQueueBuilderInfoQueryProperty on QueryBuilder<
    AutoQueueBuilderInfo, AutoQueueBuilderInfo, QQueryProperty> {
  QueryBuilder<AutoQueueBuilderInfo, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AutoQueueBuilderInfo, String, QQueryOperations> jsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'json');
    });
  }

  QueryBuilder<AutoQueueBuilderInfo, AutoQueueBuilderType, QQueryOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
