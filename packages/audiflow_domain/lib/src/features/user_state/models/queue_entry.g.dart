// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetQueueEntryCollection on Isar {
  IsarCollection<QueueEntry> get queueEntrys => this.collection();
}

const QueueEntrySchema = CollectionSchema(
  name: r'QueueEntry',
  id: -489801110525925890,
  properties: {
    r'addedAt': PropertySchema(
      id: 0,
      name: r'addedAt',
      type: IsarType.dateTime,
    ),
    r'deleted': PropertySchema(id: 1, name: r'deleted', type: IsarType.bool),
    r'deletedHlc': PropertySchema(
      id: 2,
      name: r'deletedHlc',
      type: IsarType.long,
    ),
    r'entryId': PropertySchema(id: 3, name: r'entryId', type: IsarType.string),
    r'episodeKey': PropertySchema(
      id: 4,
      name: r'episodeKey',
      type: IsarType.string,
    ),
    r'isAdhoc': PropertySchema(id: 5, name: r'isAdhoc', type: IsarType.bool),
    r'isAdhocHlc': PropertySchema(
      id: 6,
      name: r'isAdhocHlc',
      type: IsarType.long,
    ),
    r'rank': PropertySchema(id: 7, name: r'rank', type: IsarType.string),
    r'rankHlc': PropertySchema(id: 8, name: r'rankHlc', type: IsarType.long),
    r'sourceContext': PropertySchema(
      id: 9,
      name: r'sourceContext',
      type: IsarType.string,
    ),
    r'sourceContextHlc': PropertySchema(
      id: 10,
      name: r'sourceContextHlc',
      type: IsarType.long,
    ),
  },

  estimateSize: _queueEntryEstimateSize,
  serialize: _queueEntrySerialize,
  deserialize: _queueEntryDeserialize,
  deserializeProp: _queueEntryDeserializeProp,
  idName: r'id',
  indexes: {
    r'entryId': IndexSchema(
      id: 3733379884318738402,
      name: r'entryId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'entryId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'episodeKey': IndexSchema(
      id: 7918532910150633644,
      name: r'episodeKey',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'episodeKey',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _queueEntryGetId,
  getLinks: _queueEntryGetLinks,
  attach: _queueEntryAttach,
  version: '3.3.2',
);

int _queueEntryEstimateSize(
  QueueEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.entryId.length * 3;
  bytesCount += 3 + object.episodeKey.length * 3;
  bytesCount += 3 + object.rank.length * 3;
  {
    final value = object.sourceContext;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _queueEntrySerialize(
  QueueEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.addedAt);
  writer.writeBool(offsets[1], object.deleted);
  writer.writeLong(offsets[2], object.deletedHlc);
  writer.writeString(offsets[3], object.entryId);
  writer.writeString(offsets[4], object.episodeKey);
  writer.writeBool(offsets[5], object.isAdhoc);
  writer.writeLong(offsets[6], object.isAdhocHlc);
  writer.writeString(offsets[7], object.rank);
  writer.writeLong(offsets[8], object.rankHlc);
  writer.writeString(offsets[9], object.sourceContext);
  writer.writeLong(offsets[10], object.sourceContextHlc);
}

QueueEntry _queueEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = QueueEntry();
  object.addedAt = reader.readDateTimeOrNull(offsets[0]);
  object.deleted = reader.readBool(offsets[1]);
  object.deletedHlc = reader.readLong(offsets[2]);
  object.entryId = reader.readString(offsets[3]);
  object.episodeKey = reader.readString(offsets[4]);
  object.id = id;
  object.isAdhoc = reader.readBool(offsets[5]);
  object.isAdhocHlc = reader.readLong(offsets[6]);
  object.rank = reader.readString(offsets[7]);
  object.rankHlc = reader.readLong(offsets[8]);
  object.sourceContext = reader.readStringOrNull(offsets[9]);
  object.sourceContextHlc = reader.readLong(offsets[10]);
  return object;
}

P _queueEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _queueEntryGetId(QueueEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _queueEntryGetLinks(QueueEntry object) {
  return [];
}

void _queueEntryAttach(IsarCollection<dynamic> col, Id id, QueueEntry object) {
  object.id = id;
}

extension QueueEntryByIndex on IsarCollection<QueueEntry> {
  Future<QueueEntry?> getByEntryId(String entryId) {
    return getByIndex(r'entryId', [entryId]);
  }

  QueueEntry? getByEntryIdSync(String entryId) {
    return getByIndexSync(r'entryId', [entryId]);
  }

  Future<bool> deleteByEntryId(String entryId) {
    return deleteByIndex(r'entryId', [entryId]);
  }

  bool deleteByEntryIdSync(String entryId) {
    return deleteByIndexSync(r'entryId', [entryId]);
  }

  Future<List<QueueEntry?>> getAllByEntryId(List<String> entryIdValues) {
    final values = entryIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'entryId', values);
  }

  List<QueueEntry?> getAllByEntryIdSync(List<String> entryIdValues) {
    final values = entryIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'entryId', values);
  }

  Future<int> deleteAllByEntryId(List<String> entryIdValues) {
    final values = entryIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'entryId', values);
  }

  int deleteAllByEntryIdSync(List<String> entryIdValues) {
    final values = entryIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'entryId', values);
  }

  Future<Id> putByEntryId(QueueEntry object) {
    return putByIndex(r'entryId', object);
  }

  Id putByEntryIdSync(QueueEntry object, {bool saveLinks = true}) {
    return putByIndexSync(r'entryId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByEntryId(List<QueueEntry> objects) {
    return putAllByIndex(r'entryId', objects);
  }

  List<Id> putAllByEntryIdSync(
    List<QueueEntry> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'entryId', objects, saveLinks: saveLinks);
  }
}

extension QueueEntryQueryWhereSort
    on QueryBuilder<QueueEntry, QueueEntry, QWhere> {
  QueryBuilder<QueueEntry, QueueEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension QueueEntryQueryWhere
    on QueryBuilder<QueueEntry, QueueEntry, QWhereClause> {
  QueryBuilder<QueueEntry, QueueEntry, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<QueueEntry, QueueEntry, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterWhereClause> idBetween(
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

  QueryBuilder<QueueEntry, QueueEntry, QAfterWhereClause> entryIdEqualTo(
    String entryId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'entryId', value: [entryId]),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterWhereClause> entryIdNotEqualTo(
    String entryId,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entryId',
                lower: [],
                upper: [entryId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entryId',
                lower: [entryId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entryId',
                lower: [entryId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entryId',
                lower: [],
                upper: [entryId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterWhereClause> episodeKeyEqualTo(
    String episodeKey,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'episodeKey', value: [episodeKey]),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterWhereClause> episodeKeyNotEqualTo(
    String episodeKey,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'episodeKey',
                lower: [],
                upper: [episodeKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'episodeKey',
                lower: [episodeKey],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'episodeKey',
                lower: [episodeKey],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'episodeKey',
                lower: [],
                upper: [episodeKey],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension QueueEntryQueryFilter
    on QueryBuilder<QueueEntry, QueueEntry, QFilterCondition> {
  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> addedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'addedAt'),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition>
  addedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'addedAt'),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> addedAtEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'addedAt', value: value),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition>
  addedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'addedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> addedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'addedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> addedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'addedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> deletedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deleted', value: value),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> deletedHlcEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deletedHlc', value: value),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition>
  deletedHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'deletedHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition>
  deletedHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'deletedHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> deletedHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'deletedHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> entryIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'entryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition>
  entryIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'entryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> entryIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'entryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> entryIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'entryId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> entryIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'entryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> entryIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'entryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> entryIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'entryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> entryIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'entryId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> entryIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'entryId', value: ''),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition>
  entryIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'entryId', value: ''),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> episodeKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'episodeKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition>
  episodeKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'episodeKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition>
  episodeKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'episodeKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> episodeKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'episodeKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition>
  episodeKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'episodeKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition>
  episodeKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'episodeKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition>
  episodeKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'episodeKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> episodeKeyMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'episodeKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition>
  episodeKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'episodeKey', value: ''),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition>
  episodeKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'episodeKey', value: ''),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> idBetween(
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

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> isAdhocEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isAdhoc', value: value),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> isAdhocHlcEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isAdhocHlc', value: value),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition>
  isAdhocHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'isAdhocHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition>
  isAdhocHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'isAdhocHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> isAdhocHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'isAdhocHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> rankEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'rank',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> rankGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'rank',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> rankLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'rank',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> rankBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'rank',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> rankStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'rank',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> rankEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'rank',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> rankContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'rank',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> rankMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'rank',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> rankIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'rank', value: ''),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> rankIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'rank', value: ''),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> rankHlcEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'rankHlc', value: value),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition>
  rankHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'rankHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> rankHlcLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'rankHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition> rankHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'rankHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition>
  sourceContextIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'sourceContext'),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition>
  sourceContextIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'sourceContext'),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition>
  sourceContextEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sourceContext',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition>
  sourceContextGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sourceContext',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition>
  sourceContextLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sourceContext',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition>
  sourceContextBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sourceContext',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition>
  sourceContextStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sourceContext',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition>
  sourceContextEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sourceContext',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition>
  sourceContextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sourceContext',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition>
  sourceContextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sourceContext',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition>
  sourceContextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sourceContext', value: ''),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition>
  sourceContextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sourceContext', value: ''),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition>
  sourceContextHlcEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sourceContextHlc', value: value),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition>
  sourceContextHlcGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sourceContextHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition>
  sourceContextHlcLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sourceContextHlc',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterFilterCondition>
  sourceContextHlcBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sourceContextHlc',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension QueueEntryQueryObject
    on QueryBuilder<QueueEntry, QueueEntry, QFilterCondition> {}

extension QueueEntryQueryLinks
    on QueryBuilder<QueueEntry, QueueEntry, QFilterCondition> {}

extension QueueEntryQuerySortBy
    on QueryBuilder<QueueEntry, QueueEntry, QSortBy> {
  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> sortByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.asc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> sortByAddedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.desc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> sortByDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.asc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> sortByDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.desc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> sortByDeletedHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedHlc', Sort.asc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> sortByDeletedHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedHlc', Sort.desc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> sortByEntryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryId', Sort.asc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> sortByEntryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryId', Sort.desc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> sortByEpisodeKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeKey', Sort.asc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> sortByEpisodeKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeKey', Sort.desc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> sortByIsAdhoc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAdhoc', Sort.asc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> sortByIsAdhocDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAdhoc', Sort.desc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> sortByIsAdhocHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAdhocHlc', Sort.asc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> sortByIsAdhocHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAdhocHlc', Sort.desc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> sortByRank() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rank', Sort.asc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> sortByRankDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rank', Sort.desc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> sortByRankHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rankHlc', Sort.asc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> sortByRankHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rankHlc', Sort.desc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> sortBySourceContext() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceContext', Sort.asc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> sortBySourceContextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceContext', Sort.desc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> sortBySourceContextHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceContextHlc', Sort.asc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy>
  sortBySourceContextHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceContextHlc', Sort.desc);
    });
  }
}

extension QueueEntryQuerySortThenBy
    on QueryBuilder<QueueEntry, QueueEntry, QSortThenBy> {
  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> thenByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.asc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> thenByAddedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.desc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> thenByDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.asc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> thenByDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.desc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> thenByDeletedHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedHlc', Sort.asc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> thenByDeletedHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedHlc', Sort.desc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> thenByEntryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryId', Sort.asc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> thenByEntryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryId', Sort.desc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> thenByEpisodeKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeKey', Sort.asc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> thenByEpisodeKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeKey', Sort.desc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> thenByIsAdhoc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAdhoc', Sort.asc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> thenByIsAdhocDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAdhoc', Sort.desc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> thenByIsAdhocHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAdhocHlc', Sort.asc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> thenByIsAdhocHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAdhocHlc', Sort.desc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> thenByRank() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rank', Sort.asc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> thenByRankDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rank', Sort.desc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> thenByRankHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rankHlc', Sort.asc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> thenByRankHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rankHlc', Sort.desc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> thenBySourceContext() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceContext', Sort.asc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> thenBySourceContextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceContext', Sort.desc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy> thenBySourceContextHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceContextHlc', Sort.asc);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QAfterSortBy>
  thenBySourceContextHlcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceContextHlc', Sort.desc);
    });
  }
}

extension QueueEntryQueryWhereDistinct
    on QueryBuilder<QueueEntry, QueueEntry, QDistinct> {
  QueryBuilder<QueueEntry, QueueEntry, QDistinct> distinctByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'addedAt');
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QDistinct> distinctByDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deleted');
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QDistinct> distinctByDeletedHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedHlc');
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QDistinct> distinctByEntryId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entryId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QDistinct> distinctByEpisodeKey({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'episodeKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QDistinct> distinctByIsAdhoc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isAdhoc');
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QDistinct> distinctByIsAdhocHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isAdhocHlc');
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QDistinct> distinctByRank({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rank', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QDistinct> distinctByRankHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rankHlc');
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QDistinct> distinctBySourceContext({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'sourceContext',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<QueueEntry, QueueEntry, QDistinct> distinctBySourceContextHlc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceContextHlc');
    });
  }
}

extension QueueEntryQueryProperty
    on QueryBuilder<QueueEntry, QueueEntry, QQueryProperty> {
  QueryBuilder<QueueEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<QueueEntry, DateTime?, QQueryOperations> addedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'addedAt');
    });
  }

  QueryBuilder<QueueEntry, bool, QQueryOperations> deletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deleted');
    });
  }

  QueryBuilder<QueueEntry, int, QQueryOperations> deletedHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedHlc');
    });
  }

  QueryBuilder<QueueEntry, String, QQueryOperations> entryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entryId');
    });
  }

  QueryBuilder<QueueEntry, String, QQueryOperations> episodeKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodeKey');
    });
  }

  QueryBuilder<QueueEntry, bool, QQueryOperations> isAdhocProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isAdhoc');
    });
  }

  QueryBuilder<QueueEntry, int, QQueryOperations> isAdhocHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isAdhocHlc');
    });
  }

  QueryBuilder<QueueEntry, String, QQueryOperations> rankProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rank');
    });
  }

  QueryBuilder<QueueEntry, int, QQueryOperations> rankHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rankHlc');
    });
  }

  QueryBuilder<QueueEntry, String?, QQueryOperations> sourceContextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceContext');
    });
  }

  QueryBuilder<QueueEntry, int, QQueryOperations> sourceContextHlcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceContextHlc');
    });
  }
}
