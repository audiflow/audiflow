// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, duplicate_ignore

part of 'queue.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetQueueCollection on Isar {
  IsarCollection<Queue> get queues => this.collection();
}

const QueueSchema = CollectionSchema(
  name: r'Queue',
  id: 747233922160618226,
  properties: {
    r'encoded': PropertySchema(
      id: 0,
      name: r'encoded',
      type: IsarType.string,
    )
  },
  estimateSize: _queueEstimateSize,
  serialize: _queueSerialize,
  deserialize: _queueDeserialize,
  deserializeProp: _queueDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _queueGetId,
  getLinks: _queueGetLinks,
  attach: _queueAttach,
  version: '3.1.0+1',
);

int _queueEstimateSize(
  Queue object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.encoded.length * 3;
  return bytesCount;
}

void _queueSerialize(
  Queue object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.encoded);
}

Queue _queueDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Queue(
    encoded: reader.readString(offsets[0]),
  );
  return object;
}

P _queueDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _queueGetId(Queue object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _queueGetLinks(Queue object) {
  return [];
}

void _queueAttach(IsarCollection<dynamic> col, Id id, Queue object) {}

extension QueueQueryWhereSort on QueryBuilder<Queue, Queue, QWhere> {
  QueryBuilder<Queue, Queue, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension QueueQueryWhere on QueryBuilder<Queue, Queue, QWhereClause> {
  QueryBuilder<Queue, Queue, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Queue, Queue, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Queue, Queue, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Queue, Queue, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Queue, Queue, QAfterWhereClause> idBetween(
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

extension QueueQueryFilter on QueryBuilder<Queue, Queue, QFilterCondition> {
  QueryBuilder<Queue, Queue, QAfterFilterCondition> encodedEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'encoded',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Queue, Queue, QAfterFilterCondition> encodedGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'encoded',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Queue, Queue, QAfterFilterCondition> encodedLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'encoded',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Queue, Queue, QAfterFilterCondition> encodedBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'encoded',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Queue, Queue, QAfterFilterCondition> encodedStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'encoded',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Queue, Queue, QAfterFilterCondition> encodedEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'encoded',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Queue, Queue, QAfterFilterCondition> encodedContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'encoded',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Queue, Queue, QAfterFilterCondition> encodedMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'encoded',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Queue, Queue, QAfterFilterCondition> encodedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'encoded',
        value: '',
      ));
    });
  }

  QueryBuilder<Queue, Queue, QAfterFilterCondition> encodedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'encoded',
        value: '',
      ));
    });
  }

  QueryBuilder<Queue, Queue, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Queue, Queue, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Queue, Queue, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Queue, Queue, QAfterFilterCondition> idBetween(
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
}

extension QueueQueryObject on QueryBuilder<Queue, Queue, QFilterCondition> {}

extension QueueQueryLinks on QueryBuilder<Queue, Queue, QFilterCondition> {}

extension QueueQuerySortBy on QueryBuilder<Queue, Queue, QSortBy> {
  QueryBuilder<Queue, Queue, QAfterSortBy> sortByEncoded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encoded', Sort.asc);
    });
  }

  QueryBuilder<Queue, Queue, QAfterSortBy> sortByEncodedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encoded', Sort.desc);
    });
  }
}

extension QueueQuerySortThenBy on QueryBuilder<Queue, Queue, QSortThenBy> {
  QueryBuilder<Queue, Queue, QAfterSortBy> thenByEncoded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encoded', Sort.asc);
    });
  }

  QueryBuilder<Queue, Queue, QAfterSortBy> thenByEncodedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encoded', Sort.desc);
    });
  }

  QueryBuilder<Queue, Queue, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Queue, Queue, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension QueueQueryWhereDistinct on QueryBuilder<Queue, Queue, QDistinct> {
  QueryBuilder<Queue, Queue, QDistinct> distinctByEncoded(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'encoded', caseSensitive: caseSensitive);
    });
  }
}

extension QueueQueryProperty on QueryBuilder<Queue, Queue, QQueryProperty> {
  QueryBuilder<Queue, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Queue, String, QQueryOperations> encodedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'encoded');
    });
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QueueItemImpl _$$QueueItemImplFromJson(Map<String, dynamic> json) =>
    _$QueueItemImpl(
      id: json['id'] as String,
      pid: json['pid'] as int,
      eid: json['eid'] as int,
      type: $enumDecode(_$QueueTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$$QueueItemImplToJson(_$QueueItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pid': instance.pid,
      'eid': instance.eid,
      'type': _$QueueTypeEnumMap[instance.type]!,
    };

const _$QueueTypeEnumMap = {
  QueueType.primary: 'primary',
  QueueType.adhoc: 'adhoc',
};
