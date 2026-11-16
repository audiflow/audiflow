// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outbox_op.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetOutboxOpCollection on Isar {
  IsarCollection<OutboxOp> get outboxOps => this.collection();
}

const OutboxOpSchema = CollectionSchema(
  name: r'OutboxOp',
  id: -5102192805966515534,
  properties: {
    r'entity': PropertySchema(id: 0, name: r'entity', type: IsarType.string),
    r'fieldId': PropertySchema(id: 1, name: r'fieldId', type: IsarType.long),
    r'hlc': PropertySchema(id: 2, name: r'hlc', type: IsarType.long),
    r'key': PropertySchema(id: 3, name: r'key', type: IsarType.string),
    r'opId': PropertySchema(id: 4, name: r'opId', type: IsarType.string),
    r'payload': PropertySchema(
      id: 5,
      name: r'payload',
      type: IsarType.byteList,
    ),
  },

  estimateSize: _outboxOpEstimateSize,
  serialize: _outboxOpSerialize,
  deserialize: _outboxOpDeserialize,
  deserializeProp: _outboxOpDeserializeProp,
  idName: r'id',
  indexes: {
    r'opId': IndexSchema(
      id: -7257366839637970090,
      name: r'opId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'opId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'entity_key_fieldId': IndexSchema(
      id: 3938043461352798127,
      name: r'entity_key_fieldId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'entity',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'key',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'fieldId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _outboxOpGetId,
  getLinks: _outboxOpGetLinks,
  attach: _outboxOpAttach,
  version: '3.3.2',
);

int _outboxOpEstimateSize(
  OutboxOp object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.entity.length * 3;
  bytesCount += 3 + object.key.length * 3;
  bytesCount += 3 + object.opId.length * 3;
  bytesCount += 3 + object.payload.length;
  return bytesCount;
}

void _outboxOpSerialize(
  OutboxOp object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.entity);
  writer.writeLong(offsets[1], object.fieldId);
  writer.writeLong(offsets[2], object.hlc);
  writer.writeString(offsets[3], object.key);
  writer.writeString(offsets[4], object.opId);
  writer.writeByteList(offsets[5], object.payload);
}

OutboxOp _outboxOpDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = OutboxOp();
  object.entity = reader.readString(offsets[0]);
  object.fieldId = reader.readLong(offsets[1]);
  object.hlc = reader.readLong(offsets[2]);
  object.id = id;
  object.key = reader.readString(offsets[3]);
  object.opId = reader.readString(offsets[4]);
  object.payload = reader.readByteList(offsets[5]) ?? [];
  return object;
}

P _outboxOpDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readByteList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _outboxOpGetId(OutboxOp object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _outboxOpGetLinks(OutboxOp object) {
  return [];
}

void _outboxOpAttach(IsarCollection<dynamic> col, Id id, OutboxOp object) {
  object.id = id;
}

extension OutboxOpByIndex on IsarCollection<OutboxOp> {
  Future<OutboxOp?> getByOpId(String opId) {
    return getByIndex(r'opId', [opId]);
  }

  OutboxOp? getByOpIdSync(String opId) {
    return getByIndexSync(r'opId', [opId]);
  }

  Future<bool> deleteByOpId(String opId) {
    return deleteByIndex(r'opId', [opId]);
  }

  bool deleteByOpIdSync(String opId) {
    return deleteByIndexSync(r'opId', [opId]);
  }

  Future<List<OutboxOp?>> getAllByOpId(List<String> opIdValues) {
    final values = opIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'opId', values);
  }

  List<OutboxOp?> getAllByOpIdSync(List<String> opIdValues) {
    final values = opIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'opId', values);
  }

  Future<int> deleteAllByOpId(List<String> opIdValues) {
    final values = opIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'opId', values);
  }

  int deleteAllByOpIdSync(List<String> opIdValues) {
    final values = opIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'opId', values);
  }

  Future<Id> putByOpId(OutboxOp object) {
    return putByIndex(r'opId', object);
  }

  Id putByOpIdSync(OutboxOp object, {bool saveLinks = true}) {
    return putByIndexSync(r'opId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByOpId(List<OutboxOp> objects) {
    return putAllByIndex(r'opId', objects);
  }

  List<Id> putAllByOpIdSync(List<OutboxOp> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'opId', objects, saveLinks: saveLinks);
  }

  Future<OutboxOp?> getByEntityKeyFieldId(
    String entity,
    String key,
    int fieldId,
  ) {
    return getByIndex(r'entity_key_fieldId', [entity, key, fieldId]);
  }

  OutboxOp? getByEntityKeyFieldIdSync(String entity, String key, int fieldId) {
    return getByIndexSync(r'entity_key_fieldId', [entity, key, fieldId]);
  }

  Future<bool> deleteByEntityKeyFieldId(
    String entity,
    String key,
    int fieldId,
  ) {
    return deleteByIndex(r'entity_key_fieldId', [entity, key, fieldId]);
  }

  bool deleteByEntityKeyFieldIdSync(String entity, String key, int fieldId) {
    return deleteByIndexSync(r'entity_key_fieldId', [entity, key, fieldId]);
  }

  Future<List<OutboxOp?>> getAllByEntityKeyFieldId(
    List<String> entityValues,
    List<String> keyValues,
    List<int> fieldIdValues,
  ) {
    final len = entityValues.length;
    assert(
      keyValues.length == len && fieldIdValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([entityValues[i], keyValues[i], fieldIdValues[i]]);
    }

    return getAllByIndex(r'entity_key_fieldId', values);
  }

  List<OutboxOp?> getAllByEntityKeyFieldIdSync(
    List<String> entityValues,
    List<String> keyValues,
    List<int> fieldIdValues,
  ) {
    final len = entityValues.length;
    assert(
      keyValues.length == len && fieldIdValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([entityValues[i], keyValues[i], fieldIdValues[i]]);
    }

    return getAllByIndexSync(r'entity_key_fieldId', values);
  }

  Future<int> deleteAllByEntityKeyFieldId(
    List<String> entityValues,
    List<String> keyValues,
    List<int> fieldIdValues,
  ) {
    final len = entityValues.length;
    assert(
      keyValues.length == len && fieldIdValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([entityValues[i], keyValues[i], fieldIdValues[i]]);
    }

    return deleteAllByIndex(r'entity_key_fieldId', values);
  }

  int deleteAllByEntityKeyFieldIdSync(
    List<String> entityValues,
    List<String> keyValues,
    List<int> fieldIdValues,
  ) {
    final len = entityValues.length;
    assert(
      keyValues.length == len && fieldIdValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([entityValues[i], keyValues[i], fieldIdValues[i]]);
    }

    return deleteAllByIndexSync(r'entity_key_fieldId', values);
  }

  Future<Id> putByEntityKeyFieldId(OutboxOp object) {
    return putByIndex(r'entity_key_fieldId', object);
  }

  Id putByEntityKeyFieldIdSync(OutboxOp object, {bool saveLinks = true}) {
    return putByIndexSync(r'entity_key_fieldId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByEntityKeyFieldId(List<OutboxOp> objects) {
    return putAllByIndex(r'entity_key_fieldId', objects);
  }

  List<Id> putAllByEntityKeyFieldIdSync(
    List<OutboxOp> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(
      r'entity_key_fieldId',
      objects,
      saveLinks: saveLinks,
    );
  }
}

extension OutboxOpQueryWhereSort on QueryBuilder<OutboxOp, OutboxOp, QWhere> {
  QueryBuilder<OutboxOp, OutboxOp, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension OutboxOpQueryWhere on QueryBuilder<OutboxOp, OutboxOp, QWhereClause> {
  QueryBuilder<OutboxOp, OutboxOp, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<OutboxOp, OutboxOp, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterWhereClause> idBetween(
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

  QueryBuilder<OutboxOp, OutboxOp, QAfterWhereClause> opIdEqualTo(String opId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'opId', value: [opId]),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterWhereClause> opIdNotEqualTo(
    String opId,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'opId',
                lower: [],
                upper: [opId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'opId',
                lower: [opId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'opId',
                lower: [opId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'opId',
                lower: [],
                upper: [opId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterWhereClause>
  entityEqualToAnyKeyFieldId(String entity) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'entity_key_fieldId',
          value: [entity],
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterWhereClause>
  entityNotEqualToAnyKeyFieldId(String entity) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entity_key_fieldId',
                lower: [],
                upper: [entity],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entity_key_fieldId',
                lower: [entity],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entity_key_fieldId',
                lower: [entity],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entity_key_fieldId',
                lower: [],
                upper: [entity],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterWhereClause>
  entityKeyEqualToAnyFieldId(String entity, String key) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'entity_key_fieldId',
          value: [entity, key],
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterWhereClause>
  entityEqualToKeyNotEqualToAnyFieldId(String entity, String key) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entity_key_fieldId',
                lower: [entity],
                upper: [entity, key],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entity_key_fieldId',
                lower: [entity, key],
                includeLower: false,
                upper: [entity],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entity_key_fieldId',
                lower: [entity, key],
                includeLower: false,
                upper: [entity],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entity_key_fieldId',
                lower: [entity],
                upper: [entity, key],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterWhereClause> entityKeyFieldIdEqualTo(
    String entity,
    String key,
    int fieldId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'entity_key_fieldId',
          value: [entity, key, fieldId],
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterWhereClause>
  entityKeyEqualToFieldIdNotEqualTo(String entity, String key, int fieldId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entity_key_fieldId',
                lower: [entity, key],
                upper: [entity, key, fieldId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entity_key_fieldId',
                lower: [entity, key, fieldId],
                includeLower: false,
                upper: [entity, key],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entity_key_fieldId',
                lower: [entity, key, fieldId],
                includeLower: false,
                upper: [entity, key],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entity_key_fieldId',
                lower: [entity, key],
                upper: [entity, key, fieldId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterWhereClause>
  entityKeyEqualToFieldIdGreaterThan(
    String entity,
    String key,
    int fieldId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'entity_key_fieldId',
          lower: [entity, key, fieldId],
          includeLower: include,
          upper: [entity, key],
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterWhereClause>
  entityKeyEqualToFieldIdLessThan(
    String entity,
    String key,
    int fieldId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'entity_key_fieldId',
          lower: [entity, key],
          upper: [entity, key, fieldId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterWhereClause>
  entityKeyEqualToFieldIdBetween(
    String entity,
    String key,
    int lowerFieldId,
    int upperFieldId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'entity_key_fieldId',
          lower: [entity, key, lowerFieldId],
          includeLower: includeLower,
          upper: [entity, key, upperFieldId],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension OutboxOpQueryFilter
    on QueryBuilder<OutboxOp, OutboxOp, QFilterCondition> {
  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> entityEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'entity',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> entityGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'entity',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> entityLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'entity',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> entityBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'entity',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> entityStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'entity',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> entityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'entity',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> entityContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'entity',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> entityMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'entity',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> entityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'entity', value: ''),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> entityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'entity', value: ''),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> fieldIdEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fieldId', value: value),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> fieldIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fieldId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> fieldIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fieldId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> fieldIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fieldId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> hlcEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hlc', value: value),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> hlcGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'hlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> hlcLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'hlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> hlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'hlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> idBetween(
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

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> keyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> keyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> keyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> keyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'key',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> keyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> keyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> keyContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> keyMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'key',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'key', value: ''),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'key', value: ''),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> opIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'opId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> opIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'opId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> opIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'opId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> opIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'opId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> opIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'opId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> opIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'opId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> opIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'opId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> opIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'opId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> opIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'opId', value: ''),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> opIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'opId', value: ''),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> payloadElementEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'payload', value: value),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition>
  payloadElementGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'payload',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition>
  payloadElementLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'payload',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> payloadElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'payload',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> payloadLengthEqualTo(
    int length,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', length, true, length, true);
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> payloadIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', 0, true, 0, true);
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> payloadIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', 0, false, 999999, true);
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> payloadLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', 0, true, length, include);
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition>
  payloadLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', length, include, 999999, true);
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterFilterCondition> payloadLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'payload',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension OutboxOpQueryObject
    on QueryBuilder<OutboxOp, OutboxOp, QFilterCondition> {}

extension OutboxOpQueryLinks
    on QueryBuilder<OutboxOp, OutboxOp, QFilterCondition> {}

extension OutboxOpQuerySortBy on QueryBuilder<OutboxOp, OutboxOp, QSortBy> {
  QueryBuilder<OutboxOp, OutboxOp, QAfterSortBy> sortByEntity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entity', Sort.asc);
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterSortBy> sortByEntityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entity', Sort.desc);
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterSortBy> sortByFieldId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fieldId', Sort.asc);
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterSortBy> sortByFieldIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fieldId', Sort.desc);
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterSortBy> sortByHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hlc', Sort.asc);
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterSortBy> sortByHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hlc', Sort.desc);
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterSortBy> sortByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterSortBy> sortByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterSortBy> sortByOpId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'opId', Sort.asc);
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterSortBy> sortByOpIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'opId', Sort.desc);
    });
  }
}

extension OutboxOpQuerySortThenBy
    on QueryBuilder<OutboxOp, OutboxOp, QSortThenBy> {
  QueryBuilder<OutboxOp, OutboxOp, QAfterSortBy> thenByEntity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entity', Sort.asc);
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterSortBy> thenByEntityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entity', Sort.desc);
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterSortBy> thenByFieldId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fieldId', Sort.asc);
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterSortBy> thenByFieldIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fieldId', Sort.desc);
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterSortBy> thenByHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hlc', Sort.asc);
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterSortBy> thenByHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hlc', Sort.desc);
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterSortBy> thenByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterSortBy> thenByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterSortBy> thenByOpId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'opId', Sort.asc);
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QAfterSortBy> thenByOpIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'opId', Sort.desc);
    });
  }
}

extension OutboxOpQueryWhereDistinct
    on QueryBuilder<OutboxOp, OutboxOp, QDistinct> {
  QueryBuilder<OutboxOp, OutboxOp, QDistinct> distinctByEntity({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entity', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QDistinct> distinctByFieldId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fieldId');
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QDistinct> distinctByHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hlc');
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QDistinct> distinctByKey({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'key', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QDistinct> distinctByOpId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'opId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OutboxOp, OutboxOp, QDistinct> distinctByPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'payload');
    });
  }
}

extension OutboxOpQueryProperty
    on QueryBuilder<OutboxOp, OutboxOp, QQueryProperty> {
  QueryBuilder<OutboxOp, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<OutboxOp, String, QQueryOperations> entityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entity');
    });
  }

  QueryBuilder<OutboxOp, int, QQueryOperations> fieldIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fieldId');
    });
  }

  QueryBuilder<OutboxOp, int, QQueryOperations> hlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hlc');
    });
  }

  QueryBuilder<OutboxOp, String, QQueryOperations> keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'key');
    });
  }

  QueryBuilder<OutboxOp, String, QQueryOperations> opIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'opId');
    });
  }

  QueryBuilder<OutboxOp, List<int>, QQueryOperations> payloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'payload');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetOpaqueFieldCollection on Isar {
  IsarCollection<OpaqueField> get opaqueFields => this.collection();
}

const OpaqueFieldSchema = CollectionSchema(
  name: r'OpaqueField',
  id: 6837422800477542533,
  properties: {
    r'entity': PropertySchema(id: 0, name: r'entity', type: IsarType.string),
    r'fieldId': PropertySchema(id: 1, name: r'fieldId', type: IsarType.long),
    r'hlc': PropertySchema(id: 2, name: r'hlc', type: IsarType.long),
    r'key': PropertySchema(id: 3, name: r'key', type: IsarType.string),
    r'payload': PropertySchema(
      id: 4,
      name: r'payload',
      type: IsarType.byteList,
    ),
  },

  estimateSize: _opaqueFieldEstimateSize,
  serialize: _opaqueFieldSerialize,
  deserialize: _opaqueFieldDeserialize,
  deserializeProp: _opaqueFieldDeserializeProp,
  idName: r'id',
  indexes: {
    r'entity_key_fieldId': IndexSchema(
      id: 3938043461352798127,
      name: r'entity_key_fieldId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'entity',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'key',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'fieldId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _opaqueFieldGetId,
  getLinks: _opaqueFieldGetLinks,
  attach: _opaqueFieldAttach,
  version: '3.3.2',
);

int _opaqueFieldEstimateSize(
  OpaqueField object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.entity.length * 3;
  bytesCount += 3 + object.key.length * 3;
  bytesCount += 3 + object.payload.length;
  return bytesCount;
}

void _opaqueFieldSerialize(
  OpaqueField object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.entity);
  writer.writeLong(offsets[1], object.fieldId);
  writer.writeLong(offsets[2], object.hlc);
  writer.writeString(offsets[3], object.key);
  writer.writeByteList(offsets[4], object.payload);
}

OpaqueField _opaqueFieldDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = OpaqueField();
  object.entity = reader.readString(offsets[0]);
  object.fieldId = reader.readLong(offsets[1]);
  object.hlc = reader.readLong(offsets[2]);
  object.id = id;
  object.key = reader.readString(offsets[3]);
  object.payload = reader.readByteList(offsets[4]) ?? [];
  return object;
}

P _opaqueFieldDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readByteList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _opaqueFieldGetId(OpaqueField object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _opaqueFieldGetLinks(OpaqueField object) {
  return [];
}

void _opaqueFieldAttach(
  IsarCollection<dynamic> col,
  Id id,
  OpaqueField object,
) {
  object.id = id;
}

extension OpaqueFieldByIndex on IsarCollection<OpaqueField> {
  Future<OpaqueField?> getByEntityKeyFieldId(
    String entity,
    String key,
    int fieldId,
  ) {
    return getByIndex(r'entity_key_fieldId', [entity, key, fieldId]);
  }

  OpaqueField? getByEntityKeyFieldIdSync(
    String entity,
    String key,
    int fieldId,
  ) {
    return getByIndexSync(r'entity_key_fieldId', [entity, key, fieldId]);
  }

  Future<bool> deleteByEntityKeyFieldId(
    String entity,
    String key,
    int fieldId,
  ) {
    return deleteByIndex(r'entity_key_fieldId', [entity, key, fieldId]);
  }

  bool deleteByEntityKeyFieldIdSync(String entity, String key, int fieldId) {
    return deleteByIndexSync(r'entity_key_fieldId', [entity, key, fieldId]);
  }

  Future<List<OpaqueField?>> getAllByEntityKeyFieldId(
    List<String> entityValues,
    List<String> keyValues,
    List<int> fieldIdValues,
  ) {
    final len = entityValues.length;
    assert(
      keyValues.length == len && fieldIdValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([entityValues[i], keyValues[i], fieldIdValues[i]]);
    }

    return getAllByIndex(r'entity_key_fieldId', values);
  }

  List<OpaqueField?> getAllByEntityKeyFieldIdSync(
    List<String> entityValues,
    List<String> keyValues,
    List<int> fieldIdValues,
  ) {
    final len = entityValues.length;
    assert(
      keyValues.length == len && fieldIdValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([entityValues[i], keyValues[i], fieldIdValues[i]]);
    }

    return getAllByIndexSync(r'entity_key_fieldId', values);
  }

  Future<int> deleteAllByEntityKeyFieldId(
    List<String> entityValues,
    List<String> keyValues,
    List<int> fieldIdValues,
  ) {
    final len = entityValues.length;
    assert(
      keyValues.length == len && fieldIdValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([entityValues[i], keyValues[i], fieldIdValues[i]]);
    }

    return deleteAllByIndex(r'entity_key_fieldId', values);
  }

  int deleteAllByEntityKeyFieldIdSync(
    List<String> entityValues,
    List<String> keyValues,
    List<int> fieldIdValues,
  ) {
    final len = entityValues.length;
    assert(
      keyValues.length == len && fieldIdValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([entityValues[i], keyValues[i], fieldIdValues[i]]);
    }

    return deleteAllByIndexSync(r'entity_key_fieldId', values);
  }

  Future<Id> putByEntityKeyFieldId(OpaqueField object) {
    return putByIndex(r'entity_key_fieldId', object);
  }

  Id putByEntityKeyFieldIdSync(OpaqueField object, {bool saveLinks = true}) {
    return putByIndexSync(r'entity_key_fieldId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByEntityKeyFieldId(List<OpaqueField> objects) {
    return putAllByIndex(r'entity_key_fieldId', objects);
  }

  List<Id> putAllByEntityKeyFieldIdSync(
    List<OpaqueField> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(
      r'entity_key_fieldId',
      objects,
      saveLinks: saveLinks,
    );
  }
}

extension OpaqueFieldQueryWhereSort
    on QueryBuilder<OpaqueField, OpaqueField, QWhere> {
  QueryBuilder<OpaqueField, OpaqueField, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension OpaqueFieldQueryWhere
    on QueryBuilder<OpaqueField, OpaqueField, QWhereClause> {
  QueryBuilder<OpaqueField, OpaqueField, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<OpaqueField, OpaqueField, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterWhereClause> idBetween(
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

  QueryBuilder<OpaqueField, OpaqueField, QAfterWhereClause>
  entityEqualToAnyKeyFieldId(String entity) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'entity_key_fieldId',
          value: [entity],
        ),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterWhereClause>
  entityNotEqualToAnyKeyFieldId(String entity) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entity_key_fieldId',
                lower: [],
                upper: [entity],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entity_key_fieldId',
                lower: [entity],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entity_key_fieldId',
                lower: [entity],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entity_key_fieldId',
                lower: [],
                upper: [entity],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterWhereClause>
  entityKeyEqualToAnyFieldId(String entity, String key) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'entity_key_fieldId',
          value: [entity, key],
        ),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterWhereClause>
  entityEqualToKeyNotEqualToAnyFieldId(String entity, String key) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entity_key_fieldId',
                lower: [entity],
                upper: [entity, key],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entity_key_fieldId',
                lower: [entity, key],
                includeLower: false,
                upper: [entity],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entity_key_fieldId',
                lower: [entity, key],
                includeLower: false,
                upper: [entity],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entity_key_fieldId',
                lower: [entity],
                upper: [entity, key],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterWhereClause>
  entityKeyFieldIdEqualTo(String entity, String key, int fieldId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'entity_key_fieldId',
          value: [entity, key, fieldId],
        ),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterWhereClause>
  entityKeyEqualToFieldIdNotEqualTo(String entity, String key, int fieldId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entity_key_fieldId',
                lower: [entity, key],
                upper: [entity, key, fieldId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entity_key_fieldId',
                lower: [entity, key, fieldId],
                includeLower: false,
                upper: [entity, key],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entity_key_fieldId',
                lower: [entity, key, fieldId],
                includeLower: false,
                upper: [entity, key],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entity_key_fieldId',
                lower: [entity, key],
                upper: [entity, key, fieldId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterWhereClause>
  entityKeyEqualToFieldIdGreaterThan(
    String entity,
    String key,
    int fieldId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'entity_key_fieldId',
          lower: [entity, key, fieldId],
          includeLower: include,
          upper: [entity, key],
        ),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterWhereClause>
  entityKeyEqualToFieldIdLessThan(
    String entity,
    String key,
    int fieldId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'entity_key_fieldId',
          lower: [entity, key],
          upper: [entity, key, fieldId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterWhereClause>
  entityKeyEqualToFieldIdBetween(
    String entity,
    String key,
    int lowerFieldId,
    int upperFieldId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'entity_key_fieldId',
          lower: [entity, key, lowerFieldId],
          includeLower: includeLower,
          upper: [entity, key, upperFieldId],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension OpaqueFieldQueryFilter
    on QueryBuilder<OpaqueField, OpaqueField, QFilterCondition> {
  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition> entityEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'entity',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition>
  entityGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'entity',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition> entityLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'entity',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition> entityBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'entity',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition>
  entityStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'entity',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition> entityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'entity',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition> entityContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'entity',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition> entityMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'entity',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition>
  entityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'entity', value: ''),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition>
  entityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'entity', value: ''),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition> fieldIdEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fieldId', value: value),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition>
  fieldIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fieldId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition> fieldIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fieldId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition> fieldIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fieldId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition> hlcEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hlc', value: value),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition> hlcGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'hlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition> hlcLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'hlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition> hlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'hlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition> idBetween(
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

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition> keyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition> keyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition> keyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition> keyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'key',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition> keyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition> keyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition> keyContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition> keyMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'key',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition> keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'key', value: ''),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition>
  keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'key', value: ''),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition>
  payloadElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'payload', value: value),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition>
  payloadElementGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'payload',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition>
  payloadElementLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'payload',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition>
  payloadElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'payload',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition>
  payloadLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', length, true, length, true);
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition>
  payloadIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', 0, true, 0, true);
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition>
  payloadIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', 0, false, 999999, true);
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition>
  payloadLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', 0, true, length, include);
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition>
  payloadLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'payload', length, include, 999999, true);
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterFilterCondition>
  payloadLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'payload',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension OpaqueFieldQueryObject
    on QueryBuilder<OpaqueField, OpaqueField, QFilterCondition> {}

extension OpaqueFieldQueryLinks
    on QueryBuilder<OpaqueField, OpaqueField, QFilterCondition> {}

extension OpaqueFieldQuerySortBy
    on QueryBuilder<OpaqueField, OpaqueField, QSortBy> {
  QueryBuilder<OpaqueField, OpaqueField, QAfterSortBy> sortByEntity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entity', Sort.asc);
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterSortBy> sortByEntityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entity', Sort.desc);
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterSortBy> sortByFieldId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fieldId', Sort.asc);
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterSortBy> sortByFieldIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fieldId', Sort.desc);
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterSortBy> sortByHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hlc', Sort.asc);
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterSortBy> sortByHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hlc', Sort.desc);
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterSortBy> sortByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterSortBy> sortByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }
}

extension OpaqueFieldQuerySortThenBy
    on QueryBuilder<OpaqueField, OpaqueField, QSortThenBy> {
  QueryBuilder<OpaqueField, OpaqueField, QAfterSortBy> thenByEntity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entity', Sort.asc);
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterSortBy> thenByEntityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entity', Sort.desc);
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterSortBy> thenByFieldId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fieldId', Sort.asc);
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterSortBy> thenByFieldIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fieldId', Sort.desc);
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterSortBy> thenByHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hlc', Sort.asc);
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterSortBy> thenByHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hlc', Sort.desc);
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterSortBy> thenByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QAfterSortBy> thenByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }
}

extension OpaqueFieldQueryWhereDistinct
    on QueryBuilder<OpaqueField, OpaqueField, QDistinct> {
  QueryBuilder<OpaqueField, OpaqueField, QDistinct> distinctByEntity({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entity', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QDistinct> distinctByFieldId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fieldId');
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QDistinct> distinctByHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hlc');
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QDistinct> distinctByKey({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'key', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OpaqueField, OpaqueField, QDistinct> distinctByPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'payload');
    });
  }
}

extension OpaqueFieldQueryProperty
    on QueryBuilder<OpaqueField, OpaqueField, QQueryProperty> {
  QueryBuilder<OpaqueField, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<OpaqueField, String, QQueryOperations> entityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entity');
    });
  }

  QueryBuilder<OpaqueField, int, QQueryOperations> fieldIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fieldId');
    });
  }

  QueryBuilder<OpaqueField, int, QQueryOperations> hlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hlc');
    });
  }

  QueryBuilder<OpaqueField, String, QQueryOperations> keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'key');
    });
  }

  QueryBuilder<OpaqueField, List<int>, QQueryOperations> payloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'payload');
    });
  }
}
