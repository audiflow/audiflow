// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station_duration_filter.dart';

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const StationDurationFilterSchema = Schema(
  name: r'StationDurationFilter',
  id: 3204769229078267805,
  properties: {
    r'durationMinutes': PropertySchema(
      id: 0,
      name: r'durationMinutes',
      type: IsarType.long,
    ),
    r'durationOperator': PropertySchema(
      id: 1,
      name: r'durationOperator',
      type: IsarType.string,
    ),
  },

  estimateSize: _stationDurationFilterEstimateSize,
  serialize: _stationDurationFilterSerialize,
  deserialize: _stationDurationFilterDeserialize,
  deserializeProp: _stationDurationFilterDeserializeProp,
);

int _stationDurationFilterEstimateSize(
  StationDurationFilter object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.durationOperator.length * 3;
  return bytesCount;
}

void _stationDurationFilterSerialize(
  StationDurationFilter object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.durationMinutes);
  writer.writeString(offsets[1], object.durationOperator);
}

StationDurationFilter _stationDurationFilterDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StationDurationFilter();
  object.durationMinutes = reader.readLong(offsets[0]);
  object.durationOperator = reader.readString(offsets[1]);
  return object;
}

P _stationDurationFilterDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension StationDurationFilterQueryFilter
    on
        QueryBuilder<
          StationDurationFilter,
          StationDurationFilter,
          QFilterCondition
        > {
  QueryBuilder<
    StationDurationFilter,
    StationDurationFilter,
    QAfterFilterCondition
  >
  durationMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'durationMinutes', value: value),
      );
    });
  }

  QueryBuilder<
    StationDurationFilter,
    StationDurationFilter,
    QAfterFilterCondition
  >
  durationMinutesGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'durationMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    StationDurationFilter,
    StationDurationFilter,
    QAfterFilterCondition
  >
  durationMinutesLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'durationMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    StationDurationFilter,
    StationDurationFilter,
    QAfterFilterCondition
  >
  durationMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'durationMinutes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    StationDurationFilter,
    StationDurationFilter,
    QAfterFilterCondition
  >
  durationOperatorEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'durationOperator',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    StationDurationFilter,
    StationDurationFilter,
    QAfterFilterCondition
  >
  durationOperatorGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'durationOperator',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    StationDurationFilter,
    StationDurationFilter,
    QAfterFilterCondition
  >
  durationOperatorLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'durationOperator',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    StationDurationFilter,
    StationDurationFilter,
    QAfterFilterCondition
  >
  durationOperatorBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'durationOperator',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    StationDurationFilter,
    StationDurationFilter,
    QAfterFilterCondition
  >
  durationOperatorStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'durationOperator',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    StationDurationFilter,
    StationDurationFilter,
    QAfterFilterCondition
  >
  durationOperatorEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'durationOperator',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    StationDurationFilter,
    StationDurationFilter,
    QAfterFilterCondition
  >
  durationOperatorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'durationOperator',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    StationDurationFilter,
    StationDurationFilter,
    QAfterFilterCondition
  >
  durationOperatorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'durationOperator',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    StationDurationFilter,
    StationDurationFilter,
    QAfterFilterCondition
  >
  durationOperatorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'durationOperator', value: ''),
      );
    });
  }

  QueryBuilder<
    StationDurationFilter,
    StationDurationFilter,
    QAfterFilterCondition
  >
  durationOperatorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'durationOperator', value: ''),
      );
    });
  }
}

extension StationDurationFilterQueryObject
    on
        QueryBuilder<
          StationDurationFilter,
          StationDurationFilter,
          QFilterCondition
        > {}
