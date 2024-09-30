// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preference.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPreferenceCollection on Isar {
  IsarCollection<Preference> get preferences => this.collection();
}

const PreferenceSchema = CollectionSchema(
  name: r'Preference',
  id: -2412535530476531349,
  properties: {
    r'autoDeleteEpisodes': PropertySchema(
      id: 0,
      name: r'autoDeleteEpisodes',
      type: IsarType.bool,
    ),
    r'autoDownloadOnlyOnWifi': PropertySchema(
      id: 1,
      name: r'autoDownloadOnlyOnWifi',
      type: IsarType.bool,
    ),
    r'autoOpenNowPlaying': PropertySchema(
      id: 2,
      name: r'autoOpenNowPlaying',
      type: IsarType.bool,
    ),
    r'autoUpdateEpisodePeriod': PropertySchema(
      id: 3,
      name: r'autoUpdateEpisodePeriod',
      type: IsarType.long,
    ),
    r'downloadWarnMobileData': PropertySchema(
      id: 4,
      name: r'downloadWarnMobileData',
      type: IsarType.bool,
    ),
    r'externalLinkConsent': PropertySchema(
      id: 5,
      name: r'externalLinkConsent',
      type: IsarType.bool,
    ),
    r'layout': PropertySchema(
      id: 6,
      name: r'layout',
      type: IsarType.long,
    ),
    r'locale': PropertySchema(
      id: 7,
      name: r'locale',
      type: IsarType.string,
    ),
    r'markDeletedEpisodesAsPlayed': PropertySchema(
      id: 8,
      name: r'markDeletedEpisodesAsPlayed',
      type: IsarType.bool,
    ),
    r'playbackSleepMinutes': PropertySchema(
      id: 9,
      name: r'playbackSleepMinutes',
      type: IsarType.long,
    ),
    r'playbackSleepType': PropertySchema(
      id: 10,
      name: r'playbackSleepType',
      type: IsarType.byte,
      enumMap: _PreferenceplaybackSleepTypeEnumValueMap,
    ),
    r'playbackSpeed': PropertySchema(
      id: 11,
      name: r'playbackSpeed',
      type: IsarType.double,
    ),
    r'searchProvider': PropertySchema(
      id: 12,
      name: r'searchProvider',
      type: IsarType.string,
    ),
    r'searchProviders': PropertySchema(
      id: 13,
      name: r'searchProviders',
      type: IsarType.byteList,
      enumMap: _PreferencesearchProvidersEnumValueMap,
    ),
    r'showFunding': PropertySchema(
      id: 14,
      name: r'showFunding',
      type: IsarType.bool,
    ),
    r'storeDownloadsSDCard': PropertySchema(
      id: 15,
      name: r'storeDownloadsSDCard',
      type: IsarType.bool,
    ),
    r'streamWarnMobileData': PropertySchema(
      id: 16,
      name: r'streamWarnMobileData',
      type: IsarType.bool,
    ),
    r'theme': PropertySchema(
      id: 17,
      name: r'theme',
      type: IsarType.byte,
      enumMap: _PreferencethemeEnumValueMap,
    ),
    r'trimSilence': PropertySchema(
      id: 18,
      name: r'trimSilence',
      type: IsarType.bool,
    ),
    r'volumeBoost': PropertySchema(
      id: 19,
      name: r'volumeBoost',
      type: IsarType.bool,
    )
  },
  estimateSize: _preferenceEstimateSize,
  serialize: _preferenceSerialize,
  deserialize: _preferenceDeserialize,
  deserializeProp: _preferenceDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _preferenceGetId,
  getLinks: _preferenceGetLinks,
  attach: _preferenceAttach,
  version: '3.1.7',
);

int _preferenceEstimateSize(
  Preference object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.locale.length * 3;
  bytesCount += 3 + object.searchProvider.length * 3;
  bytesCount += 3 + object.searchProviders.length;
  return bytesCount;
}

void _preferenceSerialize(
  Preference object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.autoDeleteEpisodes);
  writer.writeBool(offsets[1], object.autoDownloadOnlyOnWifi);
  writer.writeBool(offsets[2], object.autoOpenNowPlaying);
  writer.writeLong(offsets[3], object.autoUpdateEpisodePeriod);
  writer.writeBool(offsets[4], object.downloadWarnMobileData);
  writer.writeBool(offsets[5], object.externalLinkConsent);
  writer.writeLong(offsets[6], object.layout);
  writer.writeString(offsets[7], object.locale);
  writer.writeBool(offsets[8], object.markDeletedEpisodesAsPlayed);
  writer.writeLong(offsets[9], object.playbackSleepMinutes);
  writer.writeByte(offsets[10], object.playbackSleepType.index);
  writer.writeDouble(offsets[11], object.playbackSpeed);
  writer.writeString(offsets[12], object.searchProvider);
  writer.writeByteList(
      offsets[13], object.searchProviders.map((e) => e.index).toList());
  writer.writeBool(offsets[14], object.showFunding);
  writer.writeBool(offsets[15], object.storeDownloadsSDCard);
  writer.writeBool(offsets[16], object.streamWarnMobileData);
  writer.writeByte(offsets[17], object.theme.index);
  writer.writeBool(offsets[18], object.trimSilence);
  writer.writeBool(offsets[19], object.volumeBoost);
}

Preference _preferenceDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Preference(
    autoDeleteEpisodes: reader.readBool(offsets[0]),
    autoDownloadOnlyOnWifi: reader.readBool(offsets[1]),
    autoOpenNowPlaying: reader.readBool(offsets[2]),
    autoUpdateEpisodePeriod: reader.readLong(offsets[3]),
    downloadWarnMobileData: reader.readBool(offsets[4]),
    externalLinkConsent: reader.readBool(offsets[5]),
    layout: reader.readLong(offsets[6]),
    locale: reader.readString(offsets[7]),
    markDeletedEpisodesAsPlayed: reader.readBool(offsets[8]),
    playbackSleepMinutes: reader.readLong(offsets[9]),
    playbackSleepType: _PreferenceplaybackSleepTypeValueEnumMap[
            reader.readByteOrNull(offsets[10])] ??
        SleepType.none,
    playbackSpeed: reader.readDouble(offsets[11]),
    searchProvider: reader.readString(offsets[12]),
    searchProviders: reader
            .readByteList(offsets[13])
            ?.map((e) =>
                _PreferencesearchProvidersValueEnumMap[e] ??
                SearchProvider.itunes)
            .toList() ??
        [],
    showFunding: reader.readBool(offsets[14]),
    storeDownloadsSDCard: reader.readBool(offsets[15]),
    streamWarnMobileData: reader.readBool(offsets[16]),
    theme: _PreferencethemeValueEnumMap[reader.readByteOrNull(offsets[17])] ??
        ThemeMode.system,
    trimSilence: reader.readBool(offsets[18]),
    volumeBoost: reader.readBool(offsets[19]),
  );
  return object;
}

P _preferenceDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (_PreferenceplaybackSleepTypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SleepType.none) as P;
    case 11:
      return (reader.readDouble(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader
              .readByteList(offset)
              ?.map((e) =>
                  _PreferencesearchProvidersValueEnumMap[e] ??
                  SearchProvider.itunes)
              .toList() ??
          []) as P;
    case 14:
      return (reader.readBool(offset)) as P;
    case 15:
      return (reader.readBool(offset)) as P;
    case 16:
      return (reader.readBool(offset)) as P;
    case 17:
      return (_PreferencethemeValueEnumMap[reader.readByteOrNull(offset)] ??
          ThemeMode.system) as P;
    case 18:
      return (reader.readBool(offset)) as P;
    case 19:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PreferenceplaybackSleepTypeEnumValueMap = {
  'none': 0,
  'episode': 1,
  'time': 2,
};
const _PreferenceplaybackSleepTypeValueEnumMap = {
  0: SleepType.none,
  1: SleepType.episode,
  2: SleepType.time,
};
const _PreferencesearchProvidersEnumValueMap = {
  'itunes': 0,
  'podcastIndex': 1,
};
const _PreferencesearchProvidersValueEnumMap = {
  0: SearchProvider.itunes,
  1: SearchProvider.podcastIndex,
};
const _PreferencethemeEnumValueMap = {
  'system': 0,
  'light': 1,
  'dark': 2,
};
const _PreferencethemeValueEnumMap = {
  0: ThemeMode.system,
  1: ThemeMode.light,
  2: ThemeMode.dark,
};

Id _preferenceGetId(Preference object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _preferenceGetLinks(Preference object) {
  return [];
}

void _preferenceAttach(IsarCollection<dynamic> col, Id id, Preference object) {}

extension PreferenceQueryWhereSort
    on QueryBuilder<Preference, Preference, QWhere> {
  QueryBuilder<Preference, Preference, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PreferenceQueryWhere
    on QueryBuilder<Preference, Preference, QWhereClause> {
  QueryBuilder<Preference, Preference, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Preference, Preference, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Preference, Preference, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Preference, Preference, QAfterWhereClause> idBetween(
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

extension PreferenceQueryFilter
    on QueryBuilder<Preference, Preference, QFilterCondition> {
  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      autoDeleteEpisodesEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autoDeleteEpisodes',
        value: value,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      autoDownloadOnlyOnWifiEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autoDownloadOnlyOnWifi',
        value: value,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      autoOpenNowPlayingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autoOpenNowPlaying',
        value: value,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      autoUpdateEpisodePeriodEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autoUpdateEpisodePeriod',
        value: value,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      autoUpdateEpisodePeriodGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'autoUpdateEpisodePeriod',
        value: value,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      autoUpdateEpisodePeriodLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'autoUpdateEpisodePeriod',
        value: value,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      autoUpdateEpisodePeriodBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'autoUpdateEpisodePeriod',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      downloadWarnMobileDataEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'downloadWarnMobileData',
        value: value,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      externalLinkConsentEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'externalLinkConsent',
        value: value,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Preference, Preference, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Preference, Preference, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Preference, Preference, QAfterFilterCondition> layoutEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'layout',
        value: value,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition> layoutGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'layout',
        value: value,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition> layoutLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'layout',
        value: value,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition> layoutBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'layout',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition> localeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition> localeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'locale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition> localeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'locale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition> localeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'locale',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition> localeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'locale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition> localeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'locale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition> localeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'locale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition> localeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'locale',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition> localeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locale',
        value: '',
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      localeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'locale',
        value: '',
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      markDeletedEpisodesAsPlayedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'markDeletedEpisodesAsPlayed',
        value: value,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      playbackSleepMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playbackSleepMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      playbackSleepMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playbackSleepMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      playbackSleepMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playbackSleepMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      playbackSleepMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playbackSleepMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      playbackSleepTypeEqualTo(SleepType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playbackSleepType',
        value: value,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      playbackSleepTypeGreaterThan(
    SleepType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playbackSleepType',
        value: value,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      playbackSleepTypeLessThan(
    SleepType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playbackSleepType',
        value: value,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      playbackSleepTypeBetween(
    SleepType lower,
    SleepType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playbackSleepType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      playbackSpeedEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playbackSpeed',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      playbackSpeedGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playbackSpeed',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      playbackSpeedLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playbackSpeed',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      playbackSpeedBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playbackSpeed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      searchProviderEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'searchProvider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      searchProviderGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'searchProvider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      searchProviderLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'searchProvider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      searchProviderBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'searchProvider',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      searchProviderStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'searchProvider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      searchProviderEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'searchProvider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      searchProviderContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'searchProvider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      searchProviderMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'searchProvider',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      searchProviderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'searchProvider',
        value: '',
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      searchProviderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'searchProvider',
        value: '',
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      searchProvidersElementEqualTo(SearchProvider value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'searchProviders',
        value: value,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      searchProvidersElementGreaterThan(
    SearchProvider value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'searchProviders',
        value: value,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      searchProvidersElementLessThan(
    SearchProvider value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'searchProviders',
        value: value,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      searchProvidersElementBetween(
    SearchProvider lower,
    SearchProvider upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'searchProviders',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      searchProvidersLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'searchProviders',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      searchProvidersIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'searchProviders',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      searchProvidersIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'searchProviders',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      searchProvidersLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'searchProviders',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      searchProvidersLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'searchProviders',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      searchProvidersLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'searchProviders',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      showFundingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showFunding',
        value: value,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      storeDownloadsSDCardEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'storeDownloadsSDCard',
        value: value,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      streamWarnMobileDataEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streamWarnMobileData',
        value: value,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition> themeEqualTo(
      ThemeMode value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'theme',
        value: value,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition> themeGreaterThan(
    ThemeMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'theme',
        value: value,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition> themeLessThan(
    ThemeMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'theme',
        value: value,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition> themeBetween(
    ThemeMode lower,
    ThemeMode upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'theme',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      trimSilenceEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trimSilence',
        value: value,
      ));
    });
  }

  QueryBuilder<Preference, Preference, QAfterFilterCondition>
      volumeBoostEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'volumeBoost',
        value: value,
      ));
    });
  }
}

extension PreferenceQueryObject
    on QueryBuilder<Preference, Preference, QFilterCondition> {}

extension PreferenceQueryLinks
    on QueryBuilder<Preference, Preference, QFilterCondition> {}

extension PreferenceQuerySortBy
    on QueryBuilder<Preference, Preference, QSortBy> {
  QueryBuilder<Preference, Preference, QAfterSortBy>
      sortByAutoDeleteEpisodes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoDeleteEpisodes', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      sortByAutoDeleteEpisodesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoDeleteEpisodes', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      sortByAutoDownloadOnlyOnWifi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoDownloadOnlyOnWifi', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      sortByAutoDownloadOnlyOnWifiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoDownloadOnlyOnWifi', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      sortByAutoOpenNowPlaying() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoOpenNowPlaying', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      sortByAutoOpenNowPlayingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoOpenNowPlaying', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      sortByAutoUpdateEpisodePeriod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoUpdateEpisodePeriod', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      sortByAutoUpdateEpisodePeriodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoUpdateEpisodePeriod', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      sortByDownloadWarnMobileData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadWarnMobileData', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      sortByDownloadWarnMobileDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadWarnMobileData', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      sortByExternalLinkConsent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalLinkConsent', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      sortByExternalLinkConsentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalLinkConsent', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> sortByLayout() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'layout', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> sortByLayoutDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'layout', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> sortByLocale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> sortByLocaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      sortByMarkDeletedEpisodesAsPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markDeletedEpisodesAsPlayed', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      sortByMarkDeletedEpisodesAsPlayedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markDeletedEpisodesAsPlayed', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      sortByPlaybackSleepMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackSleepMinutes', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      sortByPlaybackSleepMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackSleepMinutes', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> sortByPlaybackSleepType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackSleepType', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      sortByPlaybackSleepTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackSleepType', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> sortByPlaybackSpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackSpeed', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> sortByPlaybackSpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackSpeed', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> sortBySearchProvider() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchProvider', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      sortBySearchProviderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchProvider', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> sortByShowFunding() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showFunding', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> sortByShowFundingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showFunding', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      sortByStoreDownloadsSDCard() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storeDownloadsSDCard', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      sortByStoreDownloadsSDCardDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storeDownloadsSDCard', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      sortByStreamWarnMobileData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamWarnMobileData', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      sortByStreamWarnMobileDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamWarnMobileData', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> sortByTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theme', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> sortByThemeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theme', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> sortByTrimSilence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trimSilence', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> sortByTrimSilenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trimSilence', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> sortByVolumeBoost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volumeBoost', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> sortByVolumeBoostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volumeBoost', Sort.desc);
    });
  }
}

extension PreferenceQuerySortThenBy
    on QueryBuilder<Preference, Preference, QSortThenBy> {
  QueryBuilder<Preference, Preference, QAfterSortBy>
      thenByAutoDeleteEpisodes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoDeleteEpisodes', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      thenByAutoDeleteEpisodesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoDeleteEpisodes', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      thenByAutoDownloadOnlyOnWifi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoDownloadOnlyOnWifi', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      thenByAutoDownloadOnlyOnWifiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoDownloadOnlyOnWifi', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      thenByAutoOpenNowPlaying() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoOpenNowPlaying', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      thenByAutoOpenNowPlayingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoOpenNowPlaying', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      thenByAutoUpdateEpisodePeriod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoUpdateEpisodePeriod', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      thenByAutoUpdateEpisodePeriodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoUpdateEpisodePeriod', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      thenByDownloadWarnMobileData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadWarnMobileData', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      thenByDownloadWarnMobileDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadWarnMobileData', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      thenByExternalLinkConsent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalLinkConsent', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      thenByExternalLinkConsentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalLinkConsent', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> thenByLayout() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'layout', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> thenByLayoutDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'layout', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> thenByLocale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> thenByLocaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      thenByMarkDeletedEpisodesAsPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markDeletedEpisodesAsPlayed', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      thenByMarkDeletedEpisodesAsPlayedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markDeletedEpisodesAsPlayed', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      thenByPlaybackSleepMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackSleepMinutes', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      thenByPlaybackSleepMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackSleepMinutes', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> thenByPlaybackSleepType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackSleepType', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      thenByPlaybackSleepTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackSleepType', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> thenByPlaybackSpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackSpeed', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> thenByPlaybackSpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackSpeed', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> thenBySearchProvider() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchProvider', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      thenBySearchProviderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchProvider', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> thenByShowFunding() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showFunding', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> thenByShowFundingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showFunding', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      thenByStoreDownloadsSDCard() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storeDownloadsSDCard', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      thenByStoreDownloadsSDCardDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storeDownloadsSDCard', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      thenByStreamWarnMobileData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamWarnMobileData', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy>
      thenByStreamWarnMobileDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamWarnMobileData', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> thenByTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theme', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> thenByThemeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theme', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> thenByTrimSilence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trimSilence', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> thenByTrimSilenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trimSilence', Sort.desc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> thenByVolumeBoost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volumeBoost', Sort.asc);
    });
  }

  QueryBuilder<Preference, Preference, QAfterSortBy> thenByVolumeBoostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volumeBoost', Sort.desc);
    });
  }
}

extension PreferenceQueryWhereDistinct
    on QueryBuilder<Preference, Preference, QDistinct> {
  QueryBuilder<Preference, Preference, QDistinct>
      distinctByAutoDeleteEpisodes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoDeleteEpisodes');
    });
  }

  QueryBuilder<Preference, Preference, QDistinct>
      distinctByAutoDownloadOnlyOnWifi() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoDownloadOnlyOnWifi');
    });
  }

  QueryBuilder<Preference, Preference, QDistinct>
      distinctByAutoOpenNowPlaying() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoOpenNowPlaying');
    });
  }

  QueryBuilder<Preference, Preference, QDistinct>
      distinctByAutoUpdateEpisodePeriod() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoUpdateEpisodePeriod');
    });
  }

  QueryBuilder<Preference, Preference, QDistinct>
      distinctByDownloadWarnMobileData() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'downloadWarnMobileData');
    });
  }

  QueryBuilder<Preference, Preference, QDistinct>
      distinctByExternalLinkConsent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'externalLinkConsent');
    });
  }

  QueryBuilder<Preference, Preference, QDistinct> distinctByLayout() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'layout');
    });
  }

  QueryBuilder<Preference, Preference, QDistinct> distinctByLocale(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'locale', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Preference, Preference, QDistinct>
      distinctByMarkDeletedEpisodesAsPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'markDeletedEpisodesAsPlayed');
    });
  }

  QueryBuilder<Preference, Preference, QDistinct>
      distinctByPlaybackSleepMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playbackSleepMinutes');
    });
  }

  QueryBuilder<Preference, Preference, QDistinct>
      distinctByPlaybackSleepType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playbackSleepType');
    });
  }

  QueryBuilder<Preference, Preference, QDistinct> distinctByPlaybackSpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playbackSpeed');
    });
  }

  QueryBuilder<Preference, Preference, QDistinct> distinctBySearchProvider(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'searchProvider',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Preference, Preference, QDistinct> distinctBySearchProviders() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'searchProviders');
    });
  }

  QueryBuilder<Preference, Preference, QDistinct> distinctByShowFunding() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showFunding');
    });
  }

  QueryBuilder<Preference, Preference, QDistinct>
      distinctByStoreDownloadsSDCard() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'storeDownloadsSDCard');
    });
  }

  QueryBuilder<Preference, Preference, QDistinct>
      distinctByStreamWarnMobileData() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streamWarnMobileData');
    });
  }

  QueryBuilder<Preference, Preference, QDistinct> distinctByTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'theme');
    });
  }

  QueryBuilder<Preference, Preference, QDistinct> distinctByTrimSilence() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trimSilence');
    });
  }

  QueryBuilder<Preference, Preference, QDistinct> distinctByVolumeBoost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'volumeBoost');
    });
  }
}

extension PreferenceQueryProperty
    on QueryBuilder<Preference, Preference, QQueryProperty> {
  QueryBuilder<Preference, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Preference, bool, QQueryOperations>
      autoDeleteEpisodesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoDeleteEpisodes');
    });
  }

  QueryBuilder<Preference, bool, QQueryOperations>
      autoDownloadOnlyOnWifiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoDownloadOnlyOnWifi');
    });
  }

  QueryBuilder<Preference, bool, QQueryOperations>
      autoOpenNowPlayingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoOpenNowPlaying');
    });
  }

  QueryBuilder<Preference, int, QQueryOperations>
      autoUpdateEpisodePeriodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoUpdateEpisodePeriod');
    });
  }

  QueryBuilder<Preference, bool, QQueryOperations>
      downloadWarnMobileDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'downloadWarnMobileData');
    });
  }

  QueryBuilder<Preference, bool, QQueryOperations>
      externalLinkConsentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'externalLinkConsent');
    });
  }

  QueryBuilder<Preference, int, QQueryOperations> layoutProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'layout');
    });
  }

  QueryBuilder<Preference, String, QQueryOperations> localeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'locale');
    });
  }

  QueryBuilder<Preference, bool, QQueryOperations>
      markDeletedEpisodesAsPlayedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'markDeletedEpisodesAsPlayed');
    });
  }

  QueryBuilder<Preference, int, QQueryOperations>
      playbackSleepMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playbackSleepMinutes');
    });
  }

  QueryBuilder<Preference, SleepType, QQueryOperations>
      playbackSleepTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playbackSleepType');
    });
  }

  QueryBuilder<Preference, double, QQueryOperations> playbackSpeedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playbackSpeed');
    });
  }

  QueryBuilder<Preference, String, QQueryOperations> searchProviderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'searchProvider');
    });
  }

  QueryBuilder<Preference, List<SearchProvider>, QQueryOperations>
      searchProvidersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'searchProviders');
    });
  }

  QueryBuilder<Preference, bool, QQueryOperations> showFundingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showFunding');
    });
  }

  QueryBuilder<Preference, bool, QQueryOperations>
      storeDownloadsSDCardProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'storeDownloadsSDCard');
    });
  }

  QueryBuilder<Preference, bool, QQueryOperations>
      streamWarnMobileDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streamWarnMobileData');
    });
  }

  QueryBuilder<Preference, ThemeMode, QQueryOperations> themeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'theme');
    });
  }

  QueryBuilder<Preference, bool, QQueryOperations> trimSilenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trimSilence');
    });
  }

  QueryBuilder<Preference, bool, QQueryOperations> volumeBoostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'volumeBoost');
    });
  }
}
