// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_meta.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetSyncMetaCollection on Isar {
  IsarCollection<SyncMeta> get syncMetas => this.collection();
}

const SyncMetaSchema = CollectionSchema(
  name: r'SyncMeta',
  id: 7779218425528899915,
  properties: {
    r'continuityRestorePending': PropertySchema(
      id: 0,
      name: r'continuityRestorePending',
      type: IsarType.bool,
    ),
    r'deviceId': PropertySchema(
      id: 1,
      name: r'deviceId',
      type: IsarType.string,
    ),
    r'fullStateRequested': PropertySchema(
      id: 2,
      name: r'fullStateRequested',
      type: IsarType.long,
    ),
    r'fullStateSent': PropertySchema(
      id: 3,
      name: r'fullStateSent',
      type: IsarType.long,
    ),
    r'historyId': PropertySchema(
      id: 4,
      name: r'historyId',
      type: IsarType.string,
    ),
    r'hlc': PropertySchema(id: 5, name: r'hlc', type: IsarType.long),
    r'lastSnapshotHlc': PropertySchema(
      id: 6,
      name: r'lastSnapshotHlc',
      type: IsarType.long,
    ),
    r'queueProjectionPending': PropertySchema(
      id: 7,
      name: r'queueProjectionPending',
      type: IsarType.bool,
    ),
    r'schemaVersion': PropertySchema(
      id: 8,
      name: r'schemaVersion',
      type: IsarType.long,
    ),
    r'serverCursor': PropertySchema(
      id: 9,
      name: r'serverCursor',
      type: IsarType.long,
    ),
    r'tombstoneHorizon': PropertySchema(
      id: 10,
      name: r'tombstoneHorizon',
      type: IsarType.long,
    ),
  },

  estimateSize: _syncMetaEstimateSize,
  serialize: _syncMetaSerialize,
  deserialize: _syncMetaDeserialize,
  deserializeProp: _syncMetaDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _syncMetaGetId,
  getLinks: _syncMetaGetLinks,
  attach: _syncMetaAttach,
  version: '3.3.2',
);

int _syncMetaEstimateSize(
  SyncMeta object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.deviceId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.historyId.length * 3;
  return bytesCount;
}

void _syncMetaSerialize(
  SyncMeta object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.continuityRestorePending);
  writer.writeString(offsets[1], object.deviceId);
  writer.writeLong(offsets[2], object.storedFullStateRequested);
  writer.writeLong(offsets[3], object.storedFullStateSent);
  writer.writeString(offsets[4], object.historyId);
  writer.writeLong(offsets[5], object.hlc);
  writer.writeLong(offsets[6], object.storedLastSnapshotHlc);
  writer.writeBool(offsets[7], object.queueProjectionPending);
  writer.writeLong(offsets[8], object.schemaVersion);
  writer.writeLong(offsets[9], object.storedServerCursor);
  writer.writeLong(offsets[10], object.tombstoneHorizon);
}

SyncMeta _syncMetaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SyncMeta();
  object.continuityRestorePending = reader.readBool(offsets[0]);
  object.deviceId = reader.readStringOrNull(offsets[1]);
  object.storedFullStateRequested = reader.readLongOrNull(offsets[2]);
  object.storedFullStateSent = reader.readLongOrNull(offsets[3]);
  object.historyId = reader.readString(offsets[4]);
  object.hlc = reader.readLong(offsets[5]);
  object.id = id;
  object.storedLastSnapshotHlc = reader.readLongOrNull(offsets[6]);
  object.queueProjectionPending = reader.readBool(offsets[7]);
  object.schemaVersion = reader.readLong(offsets[8]);
  object.storedServerCursor = reader.readLongOrNull(offsets[9]);
  object.tombstoneHorizon = reader.readLong(offsets[10]);
  return object;
}

P _syncMetaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _syncMetaGetId(SyncMeta object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _syncMetaGetLinks(SyncMeta object) {
  return [];
}

void _syncMetaAttach(IsarCollection<dynamic> col, Id id, SyncMeta object) {
  object.id = id;
}

extension SyncMetaQueryWhereSort on QueryBuilder<SyncMeta, SyncMeta, QWhere> {
  QueryBuilder<SyncMeta, SyncMeta, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SyncMetaQueryWhere on QueryBuilder<SyncMeta, SyncMeta, QWhereClause> {
  QueryBuilder<SyncMeta, SyncMeta, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<SyncMeta, SyncMeta, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterWhereClause> idBetween(
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
}

extension SyncMetaQueryFilter
    on QueryBuilder<SyncMeta, SyncMeta, QFilterCondition> {
  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  continuityRestorePendingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'continuityRestorePending',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> deviceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'deviceId'),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> deviceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'deviceId'),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> deviceIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> deviceIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> deviceIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> deviceIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'deviceId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> deviceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> deviceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> deviceIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> deviceIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'deviceId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deviceId', value: ''),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'deviceId', value: ''),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  storedFullStateRequestedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'fullStateRequested'),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  storedFullStateRequestedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'fullStateRequested'),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  storedFullStateRequestedEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fullStateRequested', value: value),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  storedFullStateRequestedGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fullStateRequested',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  storedFullStateRequestedLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fullStateRequested',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  storedFullStateRequestedBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fullStateRequested',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  storedFullStateSentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'fullStateSent'),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  storedFullStateSentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'fullStateSent'),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  storedFullStateSentEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fullStateSent', value: value),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  storedFullStateSentGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fullStateSent',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  storedFullStateSentLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fullStateSent',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  storedFullStateSentBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fullStateSent',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> historyIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'historyId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> historyIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'historyId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> historyIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'historyId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> historyIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'historyId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> historyIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'historyId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> historyIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'historyId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> historyIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'historyId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> historyIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'historyId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> historyIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'historyId', value: ''),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  historyIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'historyId', value: ''),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> hlcEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hlc', value: value),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> hlcGreaterThan(
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

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> hlcLessThan(
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

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> hlcBetween(
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

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  storedLastSnapshotHlcIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastSnapshotHlc'),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  storedLastSnapshotHlcIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastSnapshotHlc'),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  storedLastSnapshotHlcEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastSnapshotHlc', value: value),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  storedLastSnapshotHlcGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastSnapshotHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  storedLastSnapshotHlcLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastSnapshotHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  storedLastSnapshotHlcBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastSnapshotHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  queueProjectionPendingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'queueProjectionPending',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> schemaVersionEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'schemaVersion', value: value),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  schemaVersionGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'schemaVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> schemaVersionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'schemaVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition> schemaVersionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'schemaVersion',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  storedServerCursorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'serverCursor'),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  storedServerCursorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'serverCursor'),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  storedServerCursorEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'serverCursor', value: value),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  storedServerCursorGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'serverCursor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  storedServerCursorLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'serverCursor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  storedServerCursorBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'serverCursor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  tombstoneHorizonEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tombstoneHorizon', value: value),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  tombstoneHorizonGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tombstoneHorizon',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  tombstoneHorizonLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tombstoneHorizon',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterFilterCondition>
  tombstoneHorizonBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tombstoneHorizon',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension SyncMetaQueryObject
    on QueryBuilder<SyncMeta, SyncMeta, QFilterCondition> {}

extension SyncMetaQueryLinks
    on QueryBuilder<SyncMeta, SyncMeta, QFilterCondition> {}

extension SyncMetaQuerySortBy on QueryBuilder<SyncMeta, SyncMeta, QSortBy> {
  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy>
  sortByContinuityRestorePending() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'continuityRestorePending', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy>
  sortByContinuityRestorePendingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'continuityRestorePending', Sort.desc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy>
  sortByStoredFullStateRequested() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullStateRequested', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy>
  sortByStoredFullStateRequestedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullStateRequested', Sort.desc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> sortByStoredFullStateSent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullStateSent', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy>
  sortByStoredFullStateSentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullStateSent', Sort.desc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> sortByHistoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'historyId', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> sortByHistoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'historyId', Sort.desc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> sortByHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hlc', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> sortByHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hlc', Sort.desc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> sortByStoredLastSnapshotHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSnapshotHlc', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy>
  sortByStoredLastSnapshotHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSnapshotHlc', Sort.desc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy>
  sortByQueueProjectionPending() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'queueProjectionPending', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy>
  sortByQueueProjectionPendingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'queueProjectionPending', Sort.desc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> sortBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> sortBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> sortByStoredServerCursor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverCursor', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy>
  sortByStoredServerCursorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverCursor', Sort.desc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> sortByTombstoneHorizon() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tombstoneHorizon', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> sortByTombstoneHorizonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tombstoneHorizon', Sort.desc);
    });
  }
}

extension SyncMetaQuerySortThenBy
    on QueryBuilder<SyncMeta, SyncMeta, QSortThenBy> {
  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy>
  thenByContinuityRestorePending() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'continuityRestorePending', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy>
  thenByContinuityRestorePendingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'continuityRestorePending', Sort.desc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy>
  thenByStoredFullStateRequested() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullStateRequested', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy>
  thenByStoredFullStateRequestedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullStateRequested', Sort.desc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> thenByStoredFullStateSent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullStateSent', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy>
  thenByStoredFullStateSentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullStateSent', Sort.desc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> thenByHistoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'historyId', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> thenByHistoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'historyId', Sort.desc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> thenByHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hlc', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> thenByHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hlc', Sort.desc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> thenByStoredLastSnapshotHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSnapshotHlc', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy>
  thenByStoredLastSnapshotHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSnapshotHlc', Sort.desc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy>
  thenByQueueProjectionPending() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'queueProjectionPending', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy>
  thenByQueueProjectionPendingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'queueProjectionPending', Sort.desc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> thenBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> thenBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> thenByStoredServerCursor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverCursor', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy>
  thenByStoredServerCursorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverCursor', Sort.desc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> thenByTombstoneHorizon() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tombstoneHorizon', Sort.asc);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QAfterSortBy> thenByTombstoneHorizonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tombstoneHorizon', Sort.desc);
    });
  }
}

extension SyncMetaQueryWhereDistinct
    on QueryBuilder<SyncMeta, SyncMeta, QDistinct> {
  QueryBuilder<SyncMeta, SyncMeta, QDistinct>
  distinctByContinuityRestorePending() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'continuityRestorePending');
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QDistinct> distinctByDeviceId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QDistinct>
  distinctByStoredFullStateRequested() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fullStateRequested');
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QDistinct> distinctByStoredFullStateSent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fullStateSent');
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QDistinct> distinctByHistoryId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'historyId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QDistinct> distinctByHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hlc');
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QDistinct>
  distinctByStoredLastSnapshotHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSnapshotHlc');
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QDistinct>
  distinctByQueueProjectionPending() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'queueProjectionPending');
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QDistinct> distinctBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schemaVersion');
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QDistinct> distinctByStoredServerCursor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverCursor');
    });
  }

  QueryBuilder<SyncMeta, SyncMeta, QDistinct> distinctByTombstoneHorizon() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tombstoneHorizon');
    });
  }
}

extension SyncMetaQueryProperty
    on QueryBuilder<SyncMeta, SyncMeta, QQueryProperty> {
  QueryBuilder<SyncMeta, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SyncMeta, bool, QQueryOperations>
  continuityRestorePendingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'continuityRestorePending');
    });
  }

  QueryBuilder<SyncMeta, String?, QQueryOperations> deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<SyncMeta, int?, QQueryOperations>
  storedFullStateRequestedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fullStateRequested');
    });
  }

  QueryBuilder<SyncMeta, int?, QQueryOperations> storedFullStateSentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fullStateSent');
    });
  }

  QueryBuilder<SyncMeta, String, QQueryOperations> historyIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'historyId');
    });
  }

  QueryBuilder<SyncMeta, int, QQueryOperations> hlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hlc');
    });
  }

  QueryBuilder<SyncMeta, int?, QQueryOperations>
  storedLastSnapshotHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSnapshotHlc');
    });
  }

  QueryBuilder<SyncMeta, bool, QQueryOperations>
  queueProjectionPendingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'queueProjectionPending');
    });
  }

  QueryBuilder<SyncMeta, int, QQueryOperations> schemaVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schemaVersion');
    });
  }

  QueryBuilder<SyncMeta, int?, QQueryOperations> storedServerCursorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverCursor');
    });
  }

  QueryBuilder<SyncMeta, int, QQueryOperations> tombstoneHorizonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tombstoneHorizon');
    });
  }
}
