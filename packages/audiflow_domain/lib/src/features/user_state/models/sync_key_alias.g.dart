// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_key_alias.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetSyncKeyAliasCollection on Isar {
  IsarCollection<SyncKeyAlias> get syncKeyAlias => this.collection();
}

const SyncKeyAliasSchema = CollectionSchema(
  name: r'SyncKeyAlias',
  id: -539948808304665436,
  properties: {
    r'foreignKey': PropertySchema(
      id: 0,
      name: r'foreignKey',
      type: IsarType.string,
    ),
    r'kind': PropertySchema(id: 1, name: r'kind', type: IsarType.string),
    r'localKey': PropertySchema(
      id: 2,
      name: r'localKey',
      type: IsarType.string,
    ),
  },

  estimateSize: _syncKeyAliasEstimateSize,
  serialize: _syncKeyAliasSerialize,
  deserialize: _syncKeyAliasDeserialize,
  deserializeProp: _syncKeyAliasDeserializeProp,
  idName: r'id',
  indexes: {
    r'kind_foreignKey': IndexSchema(
      id: 1756915257013331613,
      name: r'kind_foreignKey',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'kind',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'foreignKey',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _syncKeyAliasGetId,
  getLinks: _syncKeyAliasGetLinks,
  attach: _syncKeyAliasAttach,
  version: '3.3.2',
);

int _syncKeyAliasEstimateSize(
  SyncKeyAlias object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.foreignKey.length * 3;
  bytesCount += 3 + object.kind.length * 3;
  bytesCount += 3 + object.localKey.length * 3;
  return bytesCount;
}

void _syncKeyAliasSerialize(
  SyncKeyAlias object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.foreignKey);
  writer.writeString(offsets[1], object.kind);
  writer.writeString(offsets[2], object.localKey);
}

SyncKeyAlias _syncKeyAliasDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SyncKeyAlias();
  object.foreignKey = reader.readString(offsets[0]);
  object.id = id;
  object.kind = reader.readString(offsets[1]);
  object.localKey = reader.readString(offsets[2]);
  return object;
}

P _syncKeyAliasDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _syncKeyAliasGetId(SyncKeyAlias object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _syncKeyAliasGetLinks(SyncKeyAlias object) {
  return [];
}

void _syncKeyAliasAttach(
  IsarCollection<dynamic> col,
  Id id,
  SyncKeyAlias object,
) {
  object.id = id;
}

extension SyncKeyAliasByIndex on IsarCollection<SyncKeyAlias> {
  Future<SyncKeyAlias?> getByKindForeignKey(String kind, String foreignKey) {
    return getByIndex(r'kind_foreignKey', [kind, foreignKey]);
  }

  SyncKeyAlias? getByKindForeignKeySync(String kind, String foreignKey) {
    return getByIndexSync(r'kind_foreignKey', [kind, foreignKey]);
  }

  Future<bool> deleteByKindForeignKey(String kind, String foreignKey) {
    return deleteByIndex(r'kind_foreignKey', [kind, foreignKey]);
  }

  bool deleteByKindForeignKeySync(String kind, String foreignKey) {
    return deleteByIndexSync(r'kind_foreignKey', [kind, foreignKey]);
  }

  Future<List<SyncKeyAlias?>> getAllByKindForeignKey(
    List<String> kindValues,
    List<String> foreignKeyValues,
  ) {
    final len = kindValues.length;
    assert(
      foreignKeyValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([kindValues[i], foreignKeyValues[i]]);
    }

    return getAllByIndex(r'kind_foreignKey', values);
  }

  List<SyncKeyAlias?> getAllByKindForeignKeySync(
    List<String> kindValues,
    List<String> foreignKeyValues,
  ) {
    final len = kindValues.length;
    assert(
      foreignKeyValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([kindValues[i], foreignKeyValues[i]]);
    }

    return getAllByIndexSync(r'kind_foreignKey', values);
  }

  Future<int> deleteAllByKindForeignKey(
    List<String> kindValues,
    List<String> foreignKeyValues,
  ) {
    final len = kindValues.length;
    assert(
      foreignKeyValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([kindValues[i], foreignKeyValues[i]]);
    }

    return deleteAllByIndex(r'kind_foreignKey', values);
  }

  int deleteAllByKindForeignKeySync(
    List<String> kindValues,
    List<String> foreignKeyValues,
  ) {
    final len = kindValues.length;
    assert(
      foreignKeyValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([kindValues[i], foreignKeyValues[i]]);
    }

    return deleteAllByIndexSync(r'kind_foreignKey', values);
  }

  Future<Id> putByKindForeignKey(SyncKeyAlias object) {
    return putByIndex(r'kind_foreignKey', object);
  }

  Id putByKindForeignKeySync(SyncKeyAlias object, {bool saveLinks = true}) {
    return putByIndexSync(r'kind_foreignKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByKindForeignKey(List<SyncKeyAlias> objects) {
    return putAllByIndex(r'kind_foreignKey', objects);
  }

  List<Id> putAllByKindForeignKeySync(
    List<SyncKeyAlias> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'kind_foreignKey', objects, saveLinks: saveLinks);
  }
}

extension SyncKeyAliasQueryWhereSort
    on QueryBuilder<SyncKeyAlias, SyncKeyAlias, QWhere> {
  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SyncKeyAliasQueryWhere
    on QueryBuilder<SyncKeyAlias, SyncKeyAlias, QWhereClause> {
  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterWhereClause> idBetween(
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

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterWhereClause>
  kindEqualToAnyForeignKey(String kind) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'kind_foreignKey', value: [kind]),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterWhereClause>
  kindNotEqualToAnyForeignKey(String kind) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'kind_foreignKey',
                lower: [],
                upper: [kind],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'kind_foreignKey',
                lower: [kind],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'kind_foreignKey',
                lower: [kind],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'kind_foreignKey',
                lower: [],
                upper: [kind],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterWhereClause>
  kindForeignKeyEqualTo(String kind, String foreignKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'kind_foreignKey',
          value: [kind, foreignKey],
        ),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterWhereClause>
  kindEqualToForeignKeyNotEqualTo(String kind, String foreignKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'kind_foreignKey',
                lower: [kind],
                upper: [kind, foreignKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'kind_foreignKey',
                lower: [kind, foreignKey],
                includeLower: false,
                upper: [kind],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'kind_foreignKey',
                lower: [kind, foreignKey],
                includeLower: false,
                upper: [kind],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'kind_foreignKey',
                lower: [kind],
                upper: [kind, foreignKey],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension SyncKeyAliasQueryFilter
    on QueryBuilder<SyncKeyAlias, SyncKeyAlias, QFilterCondition> {
  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition>
  foreignKeyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'foreignKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition>
  foreignKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'foreignKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition>
  foreignKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'foreignKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition>
  foreignKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'foreignKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition>
  foreignKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'foreignKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition>
  foreignKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'foreignKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition>
  foreignKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'foreignKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition>
  foreignKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'foreignKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition>
  foreignKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'foreignKey', value: ''),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition>
  foreignKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'foreignKey', value: ''),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition> kindEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition>
  kindGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition> kindLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition> kindBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'kind',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition>
  kindStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition> kindEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition> kindContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition> kindMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'kind',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition>
  kindIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kind', value: ''),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition>
  kindIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'kind', value: ''),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition>
  localKeyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'localKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition>
  localKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'localKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition>
  localKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'localKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition>
  localKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'localKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition>
  localKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'localKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition>
  localKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'localKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition>
  localKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'localKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition>
  localKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'localKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition>
  localKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'localKey', value: ''),
      );
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterFilterCondition>
  localKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'localKey', value: ''),
      );
    });
  }
}

extension SyncKeyAliasQueryObject
    on QueryBuilder<SyncKeyAlias, SyncKeyAlias, QFilterCondition> {}

extension SyncKeyAliasQueryLinks
    on QueryBuilder<SyncKeyAlias, SyncKeyAlias, QFilterCondition> {}

extension SyncKeyAliasQuerySortBy
    on QueryBuilder<SyncKeyAlias, SyncKeyAlias, QSortBy> {
  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterSortBy> sortByForeignKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foreignKey', Sort.asc);
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterSortBy>
  sortByForeignKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foreignKey', Sort.desc);
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterSortBy> sortByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterSortBy> sortByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterSortBy> sortByLocalKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localKey', Sort.asc);
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterSortBy> sortByLocalKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localKey', Sort.desc);
    });
  }
}

extension SyncKeyAliasQuerySortThenBy
    on QueryBuilder<SyncKeyAlias, SyncKeyAlias, QSortThenBy> {
  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterSortBy> thenByForeignKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foreignKey', Sort.asc);
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterSortBy>
  thenByForeignKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foreignKey', Sort.desc);
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterSortBy> thenByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterSortBy> thenByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterSortBy> thenByLocalKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localKey', Sort.asc);
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QAfterSortBy> thenByLocalKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localKey', Sort.desc);
    });
  }
}

extension SyncKeyAliasQueryWhereDistinct
    on QueryBuilder<SyncKeyAlias, SyncKeyAlias, QDistinct> {
  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QDistinct> distinctByForeignKey({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'foreignKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QDistinct> distinctByKind({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kind', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncKeyAlias, SyncKeyAlias, QDistinct> distinctByLocalKey({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localKey', caseSensitive: caseSensitive);
    });
  }
}

extension SyncKeyAliasQueryProperty
    on QueryBuilder<SyncKeyAlias, SyncKeyAlias, QQueryProperty> {
  QueryBuilder<SyncKeyAlias, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SyncKeyAlias, String, QQueryOperations> foreignKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'foreignKey');
    });
  }

  QueryBuilder<SyncKeyAlias, String, QQueryOperations> kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kind');
    });
  }

  QueryBuilder<SyncKeyAlias, String, QQueryOperations> localKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localKey');
    });
  }
}
