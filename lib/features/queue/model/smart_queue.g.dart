// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smart_queue.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSmartQueueInfoCollection on Isar {
  IsarCollection<SmartQueueInfo> get smartQueueInfos => this.collection();
}

const SmartQueueInfoSchema = CollectionSchema(
  name: r'SmartQueueInfo',
  id: 3338004753092901979,
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
      enumMap: _SmartQueueInfotypeEnumValueMap,
    )
  },
  estimateSize: _smartQueueInfoEstimateSize,
  serialize: _smartQueueInfoSerialize,
  deserialize: _smartQueueInfoDeserialize,
  deserializeProp: _smartQueueInfoDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _smartQueueInfoGetId,
  getLinks: _smartQueueInfoGetLinks,
  attach: _smartQueueInfoAttach,
  version: '3.1.7',
);

int _smartQueueInfoEstimateSize(
  SmartQueueInfo object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.json.length * 3;
  return bytesCount;
}

void _smartQueueInfoSerialize(
  SmartQueueInfo object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.json);
  writer.writeByte(offsets[1], object.type.index);
}

SmartQueueInfo _smartQueueInfoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SmartQueueInfo(
    json: reader.readString(offsets[0]),
    type: _SmartQueueInfotypeValueEnumMap[reader.readByteOrNull(offsets[1])] ??
        SmartQueueType.detailsPage,
  );
  return object;
}

P _smartQueueInfoDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (_SmartQueueInfotypeValueEnumMap[reader.readByteOrNull(offset)] ??
          SmartQueueType.detailsPage) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SmartQueueInfotypeEnumValueMap = {
  'detailsPage': 0,
};
const _SmartQueueInfotypeValueEnumMap = {
  0: SmartQueueType.detailsPage,
};

Id _smartQueueInfoGetId(SmartQueueInfo object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _smartQueueInfoGetLinks(SmartQueueInfo object) {
  return [];
}

void _smartQueueInfoAttach(
    IsarCollection<dynamic> col, Id id, SmartQueueInfo object) {}

extension SmartQueueInfoQueryWhereSort
    on QueryBuilder<SmartQueueInfo, SmartQueueInfo, QWhere> {
  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SmartQueueInfoQueryWhere
    on QueryBuilder<SmartQueueInfo, SmartQueueInfo, QWhereClause> {
  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterWhereClause> idBetween(
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

extension SmartQueueInfoQueryFilter
    on QueryBuilder<SmartQueueInfo, SmartQueueInfo, QFilterCondition> {
  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterFilterCondition>
      jsonEqualTo(
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

  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterFilterCondition>
      jsonGreaterThan(
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

  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterFilterCondition>
      jsonLessThan(
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

  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterFilterCondition>
      jsonBetween(
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

  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterFilterCondition>
      jsonStartsWith(
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

  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterFilterCondition>
      jsonEndsWith(
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

  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterFilterCondition>
      jsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'json',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterFilterCondition>
      jsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'json',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterFilterCondition>
      jsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'json',
        value: '',
      ));
    });
  }

  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterFilterCondition>
      jsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'json',
        value: '',
      ));
    });
  }

  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterFilterCondition>
      typeEqualTo(SmartQueueType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterFilterCondition>
      typeGreaterThan(
    SmartQueueType value, {
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

  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterFilterCondition>
      typeLessThan(
    SmartQueueType value, {
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

  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterFilterCondition>
      typeBetween(
    SmartQueueType lower,
    SmartQueueType upper, {
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

extension SmartQueueInfoQueryObject
    on QueryBuilder<SmartQueueInfo, SmartQueueInfo, QFilterCondition> {}

extension SmartQueueInfoQueryLinks
    on QueryBuilder<SmartQueueInfo, SmartQueueInfo, QFilterCondition> {}

extension SmartQueueInfoQuerySortBy
    on QueryBuilder<SmartQueueInfo, SmartQueueInfo, QSortBy> {
  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterSortBy> sortByJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'json', Sort.asc);
    });
  }

  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterSortBy> sortByJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'json', Sort.desc);
    });
  }

  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension SmartQueueInfoQuerySortThenBy
    on QueryBuilder<SmartQueueInfo, SmartQueueInfo, QSortThenBy> {
  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterSortBy> thenByJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'json', Sort.asc);
    });
  }

  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterSortBy> thenByJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'json', Sort.desc);
    });
  }

  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension SmartQueueInfoQueryWhereDistinct
    on QueryBuilder<SmartQueueInfo, SmartQueueInfo, QDistinct> {
  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QDistinct> distinctByJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'json', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmartQueueInfo, SmartQueueInfo, QDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }
}

extension SmartQueueInfoQueryProperty
    on QueryBuilder<SmartQueueInfo, SmartQueueInfo, QQueryProperty> {
  QueryBuilder<SmartQueueInfo, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SmartQueueInfo, String, QQueryOperations> jsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'json');
    });
  }

  QueryBuilder<SmartQueueInfo, SmartQueueType, QQueryOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
