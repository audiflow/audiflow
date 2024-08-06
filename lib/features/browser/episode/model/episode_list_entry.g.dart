// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode_list_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetEpisodeListEntryCollection on Isar {
  IsarCollection<EpisodeListEntry> get episodeListEntrys => this.collection();
}

const EpisodeListEntrySchema = CollectionSchema(
  name: r'EpisodeListEntry',
  id: 4283138658395295381,
  properties: {
    r'eid': PropertySchema(
      id: 0,
      name: r'eid',
      type: IsarType.long,
    ),
    r'order': PropertySchema(
      id: 1,
      name: r'order',
      type: IsarType.long,
    ),
    r'pid': PropertySchema(
      id: 2,
      name: r'pid',
      type: IsarType.long,
    ),
    r'role': PropertySchema(
      id: 3,
      name: r'role',
      type: IsarType.byte,
      enumMap: _EpisodeListEntryroleEnumValueMap,
    )
  },
  estimateSize: _episodeListEntryEstimateSize,
  serialize: _episodeListEntrySerialize,
  deserialize: _episodeListEntryDeserialize,
  deserializeProp: _episodeListEntryDeserializeProp,
  idName: r'id',
  indexes: {
    r'pid_role_order': IndexSchema(
      id: -7891615254324960812,
      name: r'pid_role_order',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'pid',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'role',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'order',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _episodeListEntryGetId,
  getLinks: _episodeListEntryGetLinks,
  attach: _episodeListEntryAttach,
  version: '3.1.7',
);

int _episodeListEntryEstimateSize(
  EpisodeListEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _episodeListEntrySerialize(
  EpisodeListEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.eid);
  writer.writeLong(offsets[1], object.order);
  writer.writeLong(offsets[2], object.pid);
  writer.writeByte(offsets[3], object.role.index);
}

EpisodeListEntry _episodeListEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EpisodeListEntry(
    eid: reader.readLong(offsets[0]),
    order: reader.readLong(offsets[1]),
    pid: reader.readLong(offsets[2]),
    role:
        _EpisodeListEntryroleValueEnumMap[reader.readByteOrNull(offsets[3])] ??
            EpisodeListEntryRole.page,
  );
  return object;
}

P _episodeListEntryDeserializeProp<P>(
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
    case 3:
      return (_EpisodeListEntryroleValueEnumMap[
              reader.readByteOrNull(offset)] ??
          EpisodeListEntryRole.page) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _EpisodeListEntryroleEnumValueMap = {
  'page': 0,
  'queue': 1,
};
const _EpisodeListEntryroleValueEnumMap = {
  0: EpisodeListEntryRole.page,
  1: EpisodeListEntryRole.queue,
};

Id _episodeListEntryGetId(EpisodeListEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _episodeListEntryGetLinks(EpisodeListEntry object) {
  return [];
}

void _episodeListEntryAttach(
    IsarCollection<dynamic> col, Id id, EpisodeListEntry object) {}

extension EpisodeListEntryQueryWhereSort
    on QueryBuilder<EpisodeListEntry, EpisodeListEntry, QWhere> {
  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterWhere>
      anyPidRoleOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'pid_role_order'),
      );
    });
  }
}

extension EpisodeListEntryQueryWhere
    on QueryBuilder<EpisodeListEntry, EpisodeListEntry, QWhereClause> {
  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterWhereClause>
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

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterWhereClause> idBetween(
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

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterWhereClause>
      pidEqualToAnyRoleOrder(int pid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'pid_role_order',
        value: [pid],
      ));
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterWhereClause>
      pidNotEqualToAnyRoleOrder(int pid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pid_role_order',
              lower: [],
              upper: [pid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pid_role_order',
              lower: [pid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pid_role_order',
              lower: [pid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pid_role_order',
              lower: [],
              upper: [pid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterWhereClause>
      pidGreaterThanAnyRoleOrder(
    int pid, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'pid_role_order',
        lower: [pid],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterWhereClause>
      pidLessThanAnyRoleOrder(
    int pid, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'pid_role_order',
        lower: [],
        upper: [pid],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterWhereClause>
      pidBetweenAnyRoleOrder(
    int lowerPid,
    int upperPid, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'pid_role_order',
        lower: [lowerPid],
        includeLower: includeLower,
        upper: [upperPid],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterWhereClause>
      pidRoleEqualToAnyOrder(int pid, EpisodeListEntryRole role) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'pid_role_order',
        value: [pid, role],
      ));
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterWhereClause>
      pidEqualToRoleNotEqualToAnyOrder(int pid, EpisodeListEntryRole role) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pid_role_order',
              lower: [pid],
              upper: [pid, role],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pid_role_order',
              lower: [pid, role],
              includeLower: false,
              upper: [pid],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pid_role_order',
              lower: [pid, role],
              includeLower: false,
              upper: [pid],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pid_role_order',
              lower: [pid],
              upper: [pid, role],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterWhereClause>
      pidEqualToRoleGreaterThanAnyOrder(
    int pid,
    EpisodeListEntryRole role, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'pid_role_order',
        lower: [pid, role],
        includeLower: include,
        upper: [pid],
      ));
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterWhereClause>
      pidEqualToRoleLessThanAnyOrder(
    int pid,
    EpisodeListEntryRole role, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'pid_role_order',
        lower: [pid],
        upper: [pid, role],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterWhereClause>
      pidEqualToRoleBetweenAnyOrder(
    int pid,
    EpisodeListEntryRole lowerRole,
    EpisodeListEntryRole upperRole, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'pid_role_order',
        lower: [pid, lowerRole],
        includeLower: includeLower,
        upper: [pid, upperRole],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterWhereClause>
      pidRoleOrderEqualTo(int pid, EpisodeListEntryRole role, int order) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'pid_role_order',
        value: [pid, role, order],
      ));
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterWhereClause>
      pidRoleEqualToOrderNotEqualTo(
          int pid, EpisodeListEntryRole role, int order) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pid_role_order',
              lower: [pid, role],
              upper: [pid, role, order],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pid_role_order',
              lower: [pid, role, order],
              includeLower: false,
              upper: [pid, role],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pid_role_order',
              lower: [pid, role, order],
              includeLower: false,
              upper: [pid, role],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pid_role_order',
              lower: [pid, role],
              upper: [pid, role, order],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterWhereClause>
      pidRoleEqualToOrderGreaterThan(
    int pid,
    EpisodeListEntryRole role,
    int order, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'pid_role_order',
        lower: [pid, role, order],
        includeLower: include,
        upper: [pid, role],
      ));
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterWhereClause>
      pidRoleEqualToOrderLessThan(
    int pid,
    EpisodeListEntryRole role,
    int order, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'pid_role_order',
        lower: [pid, role],
        upper: [pid, role, order],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterWhereClause>
      pidRoleEqualToOrderBetween(
    int pid,
    EpisodeListEntryRole role,
    int lowerOrder,
    int upperOrder, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'pid_role_order',
        lower: [pid, role, lowerOrder],
        includeLower: includeLower,
        upper: [pid, role, upperOrder],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension EpisodeListEntryQueryFilter
    on QueryBuilder<EpisodeListEntry, EpisodeListEntry, QFilterCondition> {
  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterFilterCondition>
      eidEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eid',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterFilterCondition>
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

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterFilterCondition>
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

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterFilterCondition>
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

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterFilterCondition>
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

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterFilterCondition>
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

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterFilterCondition>
      orderEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterFilterCondition>
      orderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterFilterCondition>
      orderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterFilterCondition>
      orderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'order',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterFilterCondition>
      pidEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pid',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterFilterCondition>
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

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterFilterCondition>
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

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterFilterCondition>
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

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterFilterCondition>
      roleEqualTo(EpisodeListEntryRole value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'role',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterFilterCondition>
      roleGreaterThan(
    EpisodeListEntryRole value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'role',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterFilterCondition>
      roleLessThan(
    EpisodeListEntryRole value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'role',
        value: value,
      ));
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterFilterCondition>
      roleBetween(
    EpisodeListEntryRole lower,
    EpisodeListEntryRole upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'role',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension EpisodeListEntryQueryObject
    on QueryBuilder<EpisodeListEntry, EpisodeListEntry, QFilterCondition> {}

extension EpisodeListEntryQueryLinks
    on QueryBuilder<EpisodeListEntry, EpisodeListEntry, QFilterCondition> {}

extension EpisodeListEntryQuerySortBy
    on QueryBuilder<EpisodeListEntry, EpisodeListEntry, QSortBy> {
  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterSortBy> sortByEid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eid', Sort.asc);
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterSortBy>
      sortByEidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eid', Sort.desc);
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterSortBy> sortByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterSortBy>
      sortByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterSortBy> sortByPid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pid', Sort.asc);
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterSortBy>
      sortByPidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pid', Sort.desc);
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterSortBy> sortByRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'role', Sort.asc);
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterSortBy>
      sortByRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'role', Sort.desc);
    });
  }
}

extension EpisodeListEntryQuerySortThenBy
    on QueryBuilder<EpisodeListEntry, EpisodeListEntry, QSortThenBy> {
  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterSortBy> thenByEid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eid', Sort.asc);
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterSortBy>
      thenByEidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eid', Sort.desc);
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterSortBy> thenByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterSortBy>
      thenByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterSortBy> thenByPid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pid', Sort.asc);
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterSortBy>
      thenByPidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pid', Sort.desc);
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterSortBy> thenByRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'role', Sort.asc);
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QAfterSortBy>
      thenByRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'role', Sort.desc);
    });
  }
}

extension EpisodeListEntryQueryWhereDistinct
    on QueryBuilder<EpisodeListEntry, EpisodeListEntry, QDistinct> {
  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QDistinct> distinctByEid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'eid');
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QDistinct>
      distinctByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'order');
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QDistinct> distinctByPid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pid');
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntry, QDistinct> distinctByRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'role');
    });
  }
}

extension EpisodeListEntryQueryProperty
    on QueryBuilder<EpisodeListEntry, EpisodeListEntry, QQueryProperty> {
  QueryBuilder<EpisodeListEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<EpisodeListEntry, int, QQueryOperations> eidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'eid');
    });
  }

  QueryBuilder<EpisodeListEntry, int, QQueryOperations> orderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'order');
    });
  }

  QueryBuilder<EpisodeListEntry, int, QQueryOperations> pidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pid');
    });
  }

  QueryBuilder<EpisodeListEntry, EpisodeListEntryRole, QQueryOperations>
      roleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'role');
    });
  }
}
