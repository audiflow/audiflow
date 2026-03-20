// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStationCollection on Isar {
  IsarCollection<Station> get stations => this.collection();
}

const StationSchema = CollectionSchema(
  name: r'Station',
  id: -7402908366279132245,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'durationFilter': PropertySchema(
      id: 1,
      name: r'durationFilter',
      type: IsarType.object,

      target: r'StationDurationFilter',
    ),
    r'episodeSortType': PropertySchema(
      id: 2,
      name: r'episodeSortType',
      type: IsarType.string,
    ),
    r'filterDownloaded': PropertySchema(
      id: 3,
      name: r'filterDownloaded',
      type: IsarType.bool,
    ),
    r'filterFavorited': PropertySchema(
      id: 4,
      name: r'filterFavorited',
      type: IsarType.bool,
    ),
    r'name': PropertySchema(id: 5, name: r'name', type: IsarType.string),
    r'playbackState': PropertySchema(
      id: 6,
      name: r'playbackState',
      type: IsarType.string,
    ),
    r'publishedWithinDays': PropertySchema(
      id: 7,
      name: r'publishedWithinDays',
      type: IsarType.long,
    ),
    r'sortOrder': PropertySchema(
      id: 8,
      name: r'sortOrder',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 9,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _stationEstimateSize,
  serialize: _stationSerialize,
  deserialize: _stationDeserialize,
  deserializeProp: _stationDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'StationDurationFilter': StationDurationFilterSchema},

  getId: _stationGetId,
  getLinks: _stationGetLinks,
  attach: _stationAttach,
  version: '3.3.0',
);

int _stationEstimateSize(
  Station object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.durationFilter;
    if (value != null) {
      bytesCount +=
          3 +
          StationDurationFilterSchema.estimateSize(
            value,
            allOffsets[StationDurationFilter]!,
            allOffsets,
          );
    }
  }
  bytesCount += 3 + object.episodeSortType.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.playbackState.length * 3;
  return bytesCount;
}

void _stationSerialize(
  Station object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeObject<StationDurationFilter>(
    offsets[1],
    allOffsets,
    StationDurationFilterSchema.serialize,
    object.durationFilter,
  );
  writer.writeString(offsets[2], object.episodeSortType);
  writer.writeBool(offsets[3], object.filterDownloaded);
  writer.writeBool(offsets[4], object.filterFavorited);
  writer.writeString(offsets[5], object.name);
  writer.writeString(offsets[6], object.playbackState);
  writer.writeLong(offsets[7], object.publishedWithinDays);
  writer.writeLong(offsets[8], object.sortOrder);
  writer.writeDateTime(offsets[9], object.updatedAt);
}

Station _stationDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Station();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.durationFilter = reader.readObjectOrNull<StationDurationFilter>(
    offsets[1],
    StationDurationFilterSchema.deserialize,
    allOffsets,
  );
  object.episodeSortType = reader.readString(offsets[2]);
  object.filterDownloaded = reader.readBool(offsets[3]);
  object.filterFavorited = reader.readBool(offsets[4]);
  object.id = id;
  object.name = reader.readString(offsets[5]);
  object.playbackState = reader.readString(offsets[6]);
  object.publishedWithinDays = reader.readLongOrNull(offsets[7]);
  object.sortOrder = reader.readLong(offsets[8]);
  object.updatedAt = reader.readDateTime(offsets[9]);
  return object;
}

P _stationDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readObjectOrNull<StationDurationFilter>(
            offset,
            StationDurationFilterSchema.deserialize,
            allOffsets,
          ))
          as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _stationGetId(Station object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _stationGetLinks(Station object) {
  return [];
}

void _stationAttach(IsarCollection<dynamic> col, Id id, Station object) {
  object.id = id;
}

extension StationQueryWhereSort on QueryBuilder<Station, Station, QWhere> {
  QueryBuilder<Station, Station, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension StationQueryWhere on QueryBuilder<Station, Station, QWhereClause> {
  QueryBuilder<Station, Station, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<Station, Station, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Station, Station, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterWhereClause> idBetween(
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

extension StationQueryFilter
    on QueryBuilder<Station, Station, QFilterCondition> {
  QueryBuilder<Station, Station, QAfterFilterCondition> createdAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> durationFilterIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'durationFilter'),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition>
  durationFilterIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'durationFilter'),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> episodeSortTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'episodeSortType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition>
  episodeSortTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'episodeSortType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> episodeSortTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'episodeSortType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> episodeSortTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'episodeSortType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition>
  episodeSortTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'episodeSortType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> episodeSortTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'episodeSortType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> episodeSortTypeContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'episodeSortType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> episodeSortTypeMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'episodeSortType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition>
  episodeSortTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'episodeSortType', value: ''),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition>
  episodeSortTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'episodeSortType', value: ''),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> filterDownloadedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'filterDownloaded', value: value),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> filterFavoritedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'filterFavorited', value: value),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Station, Station, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Station, Station, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Station, Station, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> nameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> nameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> playbackStateEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'playbackState',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition>
  playbackStateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'playbackState',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> playbackStateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'playbackState',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> playbackStateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'playbackState',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> playbackStateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'playbackState',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> playbackStateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'playbackState',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> playbackStateContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'playbackState',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> playbackStateMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'playbackState',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> playbackStateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'playbackState', value: ''),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition>
  playbackStateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'playbackState', value: ''),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition>
  publishedWithinDaysIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'publishedWithinDays'),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition>
  publishedWithinDaysIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'publishedWithinDays'),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition>
  publishedWithinDaysEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'publishedWithinDays', value: value),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition>
  publishedWithinDaysGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'publishedWithinDays',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition>
  publishedWithinDaysLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'publishedWithinDays',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition>
  publishedWithinDaysBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'publishedWithinDays',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> sortOrderEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sortOrder', value: value),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> sortOrderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sortOrder',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> sortOrderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sortOrder',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> sortOrderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sortOrder',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> updatedAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Station, Station, QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension StationQueryObject
    on QueryBuilder<Station, Station, QFilterCondition> {
  QueryBuilder<Station, Station, QAfterFilterCondition> durationFilter(
    FilterQuery<StationDurationFilter> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'durationFilter');
    });
  }
}

extension StationQueryLinks
    on QueryBuilder<Station, Station, QFilterCondition> {}

extension StationQuerySortBy on QueryBuilder<Station, Station, QSortBy> {
  QueryBuilder<Station, Station, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> sortByEpisodeSortType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeSortType', Sort.asc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> sortByEpisodeSortTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeSortType', Sort.desc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> sortByFilterDownloaded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterDownloaded', Sort.asc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> sortByFilterDownloadedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterDownloaded', Sort.desc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> sortByFilterFavorited() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterFavorited', Sort.asc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> sortByFilterFavoritedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterFavorited', Sort.desc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> sortByPlaybackState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackState', Sort.asc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> sortByPlaybackStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackState', Sort.desc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> sortByPublishedWithinDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publishedWithinDays', Sort.asc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> sortByPublishedWithinDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publishedWithinDays', Sort.desc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> sortBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> sortBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension StationQuerySortThenBy
    on QueryBuilder<Station, Station, QSortThenBy> {
  QueryBuilder<Station, Station, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> thenByEpisodeSortType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeSortType', Sort.asc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> thenByEpisodeSortTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodeSortType', Sort.desc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> thenByFilterDownloaded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterDownloaded', Sort.asc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> thenByFilterDownloadedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterDownloaded', Sort.desc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> thenByFilterFavorited() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterFavorited', Sort.asc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> thenByFilterFavoritedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterFavorited', Sort.desc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> thenByPlaybackState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackState', Sort.asc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> thenByPlaybackStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackState', Sort.desc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> thenByPublishedWithinDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publishedWithinDays', Sort.asc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> thenByPublishedWithinDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publishedWithinDays', Sort.desc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> thenBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> thenBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Station, Station, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension StationQueryWhereDistinct
    on QueryBuilder<Station, Station, QDistinct> {
  QueryBuilder<Station, Station, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<Station, Station, QDistinct> distinctByEpisodeSortType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'episodeSortType',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Station, Station, QDistinct> distinctByFilterDownloaded() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'filterDownloaded');
    });
  }

  QueryBuilder<Station, Station, QDistinct> distinctByFilterFavorited() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'filterFavorited');
    });
  }

  QueryBuilder<Station, Station, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Station, Station, QDistinct> distinctByPlaybackState({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'playbackState',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Station, Station, QDistinct> distinctByPublishedWithinDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'publishedWithinDays');
    });
  }

  QueryBuilder<Station, Station, QDistinct> distinctBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortOrder');
    });
  }

  QueryBuilder<Station, Station, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension StationQueryProperty
    on QueryBuilder<Station, Station, QQueryProperty> {
  QueryBuilder<Station, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Station, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<Station, StationDurationFilter?, QQueryOperations>
  durationFilterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationFilter');
    });
  }

  QueryBuilder<Station, String, QQueryOperations> episodeSortTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodeSortType');
    });
  }

  QueryBuilder<Station, bool, QQueryOperations> filterDownloadedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filterDownloaded');
    });
  }

  QueryBuilder<Station, bool, QQueryOperations> filterFavoritedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filterFavorited');
    });
  }

  QueryBuilder<Station, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Station, String, QQueryOperations> playbackStateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playbackState');
    });
  }

  QueryBuilder<Station, int?, QQueryOperations> publishedWithinDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'publishedWithinDays');
    });
  }

  QueryBuilder<Station, int, QQueryOperations> sortOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortOrder');
    });
  }

  QueryBuilder<Station, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
