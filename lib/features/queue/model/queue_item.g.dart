// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_item.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetManualQueueItemCollection on Isar {
  IsarCollection<ManualQueueItem> get manualQueueItems => this.collection();
}

const ManualQueueItemSchema = CollectionSchema(
  name: r'ManualQueueItem',
  id: 221098417398045245,
  properties: {
    r'eid': PropertySchema(
      id: 0,
      name: r'eid',
      type: IsarType.long,
    ),
    r'ordinal': PropertySchema(
      id: 1,
      name: r'ordinal',
      type: IsarType.long,
    ),
    r'pid': PropertySchema(
      id: 2,
      name: r'pid',
      type: IsarType.long,
    )
  },
  estimateSize: _manualQueueItemEstimateSize,
  serialize: _manualQueueItemSerialize,
  deserialize: _manualQueueItemDeserialize,
  deserializeProp: _manualQueueItemDeserializeProp,
  idName: r'id',
  indexes: {
    r'ordinal': IndexSchema(
      id: -8402712707119853872,
      name: r'ordinal',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'ordinal',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _manualQueueItemGetId,
  getLinks: _manualQueueItemGetLinks,
  attach: _manualQueueItemAttach,
  version: '3.1.7',
);

int _manualQueueItemEstimateSize(
  ManualQueueItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _manualQueueItemSerialize(
  ManualQueueItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.eid);
  writer.writeLong(offsets[1], object.ordinal);
  writer.writeLong(offsets[2], object.pid);
}

ManualQueueItem _manualQueueItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ManualQueueItem(
    eid: reader.readLong(offsets[0]),
    id: id,
    ordinal: reader.readLong(offsets[1]),
    pid: reader.readLong(offsets[2]),
  );
  return object;
}

P _manualQueueItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _manualQueueItemGetId(ManualQueueItem object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _manualQueueItemGetLinks(ManualQueueItem object) {
  return [];
}

void _manualQueueItemAttach(
    IsarCollection<dynamic> col, Id id, ManualQueueItem object) {
  object.id = id;
}

extension ManualQueueItemQueryWhereSort
    on QueryBuilder<ManualQueueItem, ManualQueueItem, QWhere> {
  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterWhere> anyOrdinal() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'ordinal'),
      );
    });
  }
}

extension ManualQueueItemQueryWhere
    on QueryBuilder<ManualQueueItem, ManualQueueItem, QWhereClause> {
  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterWhereClause>
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

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterWhereClause> idBetween(
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

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterWhereClause>
      ordinalEqualTo(int ordinal) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'ordinal',
        value: [ordinal],
      ));
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterWhereClause>
      ordinalNotEqualTo(int ordinal) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ordinal',
              lower: [],
              upper: [ordinal],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ordinal',
              lower: [ordinal],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ordinal',
              lower: [ordinal],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ordinal',
              lower: [],
              upper: [ordinal],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterWhereClause>
      ordinalGreaterThan(
    int ordinal, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'ordinal',
        lower: [ordinal],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterWhereClause>
      ordinalLessThan(
    int ordinal, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'ordinal',
        lower: [],
        upper: [ordinal],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterWhereClause>
      ordinalBetween(
    int lowerOrdinal,
    int upperOrdinal, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'ordinal',
        lower: [lowerOrdinal],
        includeLower: includeLower,
        upper: [upperOrdinal],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ManualQueueItemQueryFilter
    on QueryBuilder<ManualQueueItem, ManualQueueItem, QFilterCondition> {
  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterFilterCondition>
      eidEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eid',
        value: value,
      ));
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterFilterCondition>
      eidGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'eid',
        value: value,
      ));
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterFilterCondition>
      eidLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'eid',
        value: value,
      ));
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterFilterCondition>
      eidBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'eid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterFilterCondition>
      idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterFilterCondition>
      idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterFilterCondition>
      idEqualTo(Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterFilterCondition>
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

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterFilterCondition>
      ordinalEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ordinal',
        value: value,
      ));
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterFilterCondition>
      ordinalGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ordinal',
        value: value,
      ));
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterFilterCondition>
      ordinalLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ordinal',
        value: value,
      ));
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterFilterCondition>
      ordinalBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ordinal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterFilterCondition>
      pidEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pid',
        value: value,
      ));
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterFilterCondition>
      pidGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pid',
        value: value,
      ));
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterFilterCondition>
      pidLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pid',
        value: value,
      ));
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterFilterCondition>
      pidBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ManualQueueItemQueryObject
    on QueryBuilder<ManualQueueItem, ManualQueueItem, QFilterCondition> {}

extension ManualQueueItemQueryLinks
    on QueryBuilder<ManualQueueItem, ManualQueueItem, QFilterCondition> {}

extension ManualQueueItemQuerySortBy
    on QueryBuilder<ManualQueueItem, ManualQueueItem, QSortBy> {
  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterSortBy> sortByEid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eid', Sort.asc);
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterSortBy> sortByEidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eid', Sort.desc);
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterSortBy> sortByOrdinal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ordinal', Sort.asc);
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterSortBy>
      sortByOrdinalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ordinal', Sort.desc);
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterSortBy> sortByPid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pid', Sort.asc);
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterSortBy> sortByPidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pid', Sort.desc);
    });
  }
}

extension ManualQueueItemQuerySortThenBy
    on QueryBuilder<ManualQueueItem, ManualQueueItem, QSortThenBy> {
  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterSortBy> thenByEid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eid', Sort.asc);
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterSortBy> thenByEidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eid', Sort.desc);
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterSortBy> thenByOrdinal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ordinal', Sort.asc);
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterSortBy>
      thenByOrdinalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ordinal', Sort.desc);
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterSortBy> thenByPid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pid', Sort.asc);
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QAfterSortBy> thenByPidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pid', Sort.desc);
    });
  }
}

extension ManualQueueItemQueryWhereDistinct
    on QueryBuilder<ManualQueueItem, ManualQueueItem, QDistinct> {
  QueryBuilder<ManualQueueItem, ManualQueueItem, QDistinct> distinctByEid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'eid');
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QDistinct>
      distinctByOrdinal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ordinal');
    });
  }

  QueryBuilder<ManualQueueItem, ManualQueueItem, QDistinct> distinctByPid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pid');
    });
  }
}

extension ManualQueueItemQueryProperty
    on QueryBuilder<ManualQueueItem, ManualQueueItem, QQueryProperty> {
  QueryBuilder<ManualQueueItem, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ManualQueueItem, int, QQueryOperations> eidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'eid');
    });
  }

  QueryBuilder<ManualQueueItem, int, QQueryOperations> ordinalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ordinal');
    });
  }

  QueryBuilder<ManualQueueItem, int, QQueryOperations> pidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pid');
    });
  }
}
