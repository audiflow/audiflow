// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parental_control_settings.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetParentalControlSettingsCollection on Isar {
  IsarCollection<ParentalControlSettings> get parentalControlSettings =>
      this.collection();
}

const ParentalControlSettingsSchema = CollectionSchema(
  name: r'ParentalControlSettings',
  id: -6262205566896115046,
  properties: {
    r'failedAttempts': PropertySchema(
      id: 0,
      name: r'failedAttempts',
      type: IsarType.long,
    ),
    r'lockoutUntil': PropertySchema(
      id: 1,
      name: r'lockoutUntil',
      type: IsarType.dateTime,
    ),
    r'pinHashBase64': PropertySchema(
      id: 2,
      name: r'pinHashBase64',
      type: IsarType.string,
    ),
    r'pinIterations': PropertySchema(
      id: 3,
      name: r'pinIterations',
      type: IsarType.long,
    ),
    r'pinSaltBase64': PropertySchema(
      id: 4,
      name: r'pinSaltBase64',
      type: IsarType.string,
    ),
    r'restrictedModeEnabled': PropertySchema(
      id: 5,
      name: r'restrictedModeEnabled',
      type: IsarType.bool,
    ),
    r'unlockTimeoutMs': PropertySchema(
      id: 6,
      name: r'unlockTimeoutMs',
      type: IsarType.long,
    ),
  },

  estimateSize: _parentalControlSettingsEstimateSize,
  serialize: _parentalControlSettingsSerialize,
  deserialize: _parentalControlSettingsDeserialize,
  deserializeProp: _parentalControlSettingsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _parentalControlSettingsGetId,
  getLinks: _parentalControlSettingsGetLinks,
  attach: _parentalControlSettingsAttach,
  version: '3.3.2',
);

int _parentalControlSettingsEstimateSize(
  ParentalControlSettings object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.pinHashBase64;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.pinSaltBase64;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _parentalControlSettingsSerialize(
  ParentalControlSettings object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.failedAttempts);
  writer.writeDateTime(offsets[1], object.lockoutUntil);
  writer.writeString(offsets[2], object.pinHashBase64);
  writer.writeLong(offsets[3], object.pinIterations);
  writer.writeString(offsets[4], object.pinSaltBase64);
  writer.writeBool(offsets[5], object.restrictedModeEnabled);
  writer.writeLong(offsets[6], object.unlockTimeoutMs);
}

ParentalControlSettings _parentalControlSettingsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ParentalControlSettings();
  object.failedAttempts = reader.readLong(offsets[0]);
  object.id = id;
  object.lockoutUntil = reader.readDateTimeOrNull(offsets[1]);
  object.pinHashBase64 = reader.readStringOrNull(offsets[2]);
  object.pinIterations = reader.readLong(offsets[3]);
  object.pinSaltBase64 = reader.readStringOrNull(offsets[4]);
  object.restrictedModeEnabled = reader.readBool(offsets[5]);
  object.unlockTimeoutMs = reader.readLong(offsets[6]);
  return object;
}

P _parentalControlSettingsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _parentalControlSettingsGetId(ParentalControlSettings object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _parentalControlSettingsGetLinks(
  ParentalControlSettings object,
) {
  return [];
}

void _parentalControlSettingsAttach(
  IsarCollection<dynamic> col,
  Id id,
  ParentalControlSettings object,
) {
  object.id = id;
}

extension ParentalControlSettingsQueryWhereSort
    on QueryBuilder<ParentalControlSettings, ParentalControlSettings, QWhere> {
  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ParentalControlSettingsQueryWhere
    on
        QueryBuilder<
          ParentalControlSettings,
          ParentalControlSettings,
          QWhereClause
        > {
  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterWhereClause
  >
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

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterWhereClause
  >
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterWhereClause
  >
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterWhereClause
  >
  idBetween(
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

extension ParentalControlSettingsQueryFilter
    on
        QueryBuilder<
          ParentalControlSettings,
          ParentalControlSettings,
          QFilterCondition
        > {
  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  failedAttemptsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'failedAttempts', value: value),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  failedAttemptsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'failedAttempts',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  failedAttemptsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'failedAttempts',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  failedAttemptsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'failedAttempts',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  idGreaterThan(Id value, {bool include = false}) {
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

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  idLessThan(Id value, {bool include = false}) {
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

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  idBetween(
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

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  lockoutUntilIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lockoutUntil'),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  lockoutUntilIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lockoutUntil'),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  lockoutUntilEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lockoutUntil', value: value),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  lockoutUntilGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lockoutUntil',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  lockoutUntilLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lockoutUntil',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  lockoutUntilBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lockoutUntil',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  pinHashBase64IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'pinHashBase64'),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  pinHashBase64IsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'pinHashBase64'),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  pinHashBase64EqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'pinHashBase64',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  pinHashBase64GreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'pinHashBase64',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  pinHashBase64LessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'pinHashBase64',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  pinHashBase64Between(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'pinHashBase64',
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
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  pinHashBase64StartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'pinHashBase64',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  pinHashBase64EndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'pinHashBase64',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  pinHashBase64Contains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'pinHashBase64',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  pinHashBase64Matches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'pinHashBase64',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  pinHashBase64IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'pinHashBase64', value: ''),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  pinHashBase64IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'pinHashBase64', value: ''),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  pinIterationsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'pinIterations', value: value),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  pinIterationsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'pinIterations',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  pinIterationsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'pinIterations',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  pinIterationsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'pinIterations',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  pinSaltBase64IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'pinSaltBase64'),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  pinSaltBase64IsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'pinSaltBase64'),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  pinSaltBase64EqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'pinSaltBase64',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  pinSaltBase64GreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'pinSaltBase64',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  pinSaltBase64LessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'pinSaltBase64',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  pinSaltBase64Between(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'pinSaltBase64',
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
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  pinSaltBase64StartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'pinSaltBase64',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  pinSaltBase64EndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'pinSaltBase64',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  pinSaltBase64Contains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'pinSaltBase64',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  pinSaltBase64Matches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'pinSaltBase64',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  pinSaltBase64IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'pinSaltBase64', value: ''),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  pinSaltBase64IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'pinSaltBase64', value: ''),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  restrictedModeEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'restrictedModeEnabled',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  unlockTimeoutMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'unlockTimeoutMs', value: value),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  unlockTimeoutMsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'unlockTimeoutMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  unlockTimeoutMsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'unlockTimeoutMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ParentalControlSettings,
    ParentalControlSettings,
    QAfterFilterCondition
  >
  unlockTimeoutMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'unlockTimeoutMs',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension ParentalControlSettingsQueryObject
    on
        QueryBuilder<
          ParentalControlSettings,
          ParentalControlSettings,
          QFilterCondition
        > {}

extension ParentalControlSettingsQueryLinks
    on
        QueryBuilder<
          ParentalControlSettings,
          ParentalControlSettings,
          QFilterCondition
        > {}

extension ParentalControlSettingsQuerySortBy
    on QueryBuilder<ParentalControlSettings, ParentalControlSettings, QSortBy> {
  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QAfterSortBy>
  sortByFailedAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failedAttempts', Sort.asc);
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QAfterSortBy>
  sortByFailedAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failedAttempts', Sort.desc);
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QAfterSortBy>
  sortByLockoutUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lockoutUntil', Sort.asc);
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QAfterSortBy>
  sortByLockoutUntilDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lockoutUntil', Sort.desc);
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QAfterSortBy>
  sortByPinHashBase64() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinHashBase64', Sort.asc);
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QAfterSortBy>
  sortByPinHashBase64Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinHashBase64', Sort.desc);
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QAfterSortBy>
  sortByPinIterations() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinIterations', Sort.asc);
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QAfterSortBy>
  sortByPinIterationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinIterations', Sort.desc);
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QAfterSortBy>
  sortByPinSaltBase64() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinSaltBase64', Sort.asc);
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QAfterSortBy>
  sortByPinSaltBase64Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinSaltBase64', Sort.desc);
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QAfterSortBy>
  sortByRestrictedModeEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'restrictedModeEnabled', Sort.asc);
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QAfterSortBy>
  sortByRestrictedModeEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'restrictedModeEnabled', Sort.desc);
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QAfterSortBy>
  sortByUnlockTimeoutMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockTimeoutMs', Sort.asc);
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QAfterSortBy>
  sortByUnlockTimeoutMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockTimeoutMs', Sort.desc);
    });
  }
}

extension ParentalControlSettingsQuerySortThenBy
    on
        QueryBuilder<
          ParentalControlSettings,
          ParentalControlSettings,
          QSortThenBy
        > {
  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QAfterSortBy>
  thenByFailedAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failedAttempts', Sort.asc);
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QAfterSortBy>
  thenByFailedAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failedAttempts', Sort.desc);
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QAfterSortBy>
  thenByLockoutUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lockoutUntil', Sort.asc);
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QAfterSortBy>
  thenByLockoutUntilDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lockoutUntil', Sort.desc);
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QAfterSortBy>
  thenByPinHashBase64() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinHashBase64', Sort.asc);
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QAfterSortBy>
  thenByPinHashBase64Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinHashBase64', Sort.desc);
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QAfterSortBy>
  thenByPinIterations() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinIterations', Sort.asc);
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QAfterSortBy>
  thenByPinIterationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinIterations', Sort.desc);
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QAfterSortBy>
  thenByPinSaltBase64() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinSaltBase64', Sort.asc);
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QAfterSortBy>
  thenByPinSaltBase64Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinSaltBase64', Sort.desc);
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QAfterSortBy>
  thenByRestrictedModeEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'restrictedModeEnabled', Sort.asc);
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QAfterSortBy>
  thenByRestrictedModeEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'restrictedModeEnabled', Sort.desc);
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QAfterSortBy>
  thenByUnlockTimeoutMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockTimeoutMs', Sort.asc);
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QAfterSortBy>
  thenByUnlockTimeoutMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockTimeoutMs', Sort.desc);
    });
  }
}

extension ParentalControlSettingsQueryWhereDistinct
    on
        QueryBuilder<
          ParentalControlSettings,
          ParentalControlSettings,
          QDistinct
        > {
  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QDistinct>
  distinctByFailedAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'failedAttempts');
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QDistinct>
  distinctByLockoutUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lockoutUntil');
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QDistinct>
  distinctByPinHashBase64({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'pinHashBase64',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QDistinct>
  distinctByPinIterations() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pinIterations');
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QDistinct>
  distinctByPinSaltBase64({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'pinSaltBase64',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QDistinct>
  distinctByRestrictedModeEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'restrictedModeEnabled');
    });
  }

  QueryBuilder<ParentalControlSettings, ParentalControlSettings, QDistinct>
  distinctByUnlockTimeoutMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unlockTimeoutMs');
    });
  }
}

extension ParentalControlSettingsQueryProperty
    on
        QueryBuilder<
          ParentalControlSettings,
          ParentalControlSettings,
          QQueryProperty
        > {
  QueryBuilder<ParentalControlSettings, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ParentalControlSettings, int, QQueryOperations>
  failedAttemptsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'failedAttempts');
    });
  }

  QueryBuilder<ParentalControlSettings, DateTime?, QQueryOperations>
  lockoutUntilProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lockoutUntil');
    });
  }

  QueryBuilder<ParentalControlSettings, String?, QQueryOperations>
  pinHashBase64Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pinHashBase64');
    });
  }

  QueryBuilder<ParentalControlSettings, int, QQueryOperations>
  pinIterationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pinIterations');
    });
  }

  QueryBuilder<ParentalControlSettings, String?, QQueryOperations>
  pinSaltBase64Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pinSaltBase64');
    });
  }

  QueryBuilder<ParentalControlSettings, bool, QQueryOperations>
  restrictedModeEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'restrictedModeEnabled');
    });
  }

  QueryBuilder<ParentalControlSettings, int, QQueryOperations>
  unlockTimeoutMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unlockTimeoutMs');
    });
  }
}
