// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_preference.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAppPreferenceCollection on Isar {
  IsarCollection<AppPreference> get appPreferences => this.collection();
}

const AppPreferenceSchema = CollectionSchema(
  name: r'AppPreference',
  id: -632636125728214278,
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
    r'playbackSpeed': PropertySchema(
      id: 9,
      name: r'playbackSpeed',
      type: IsarType.double,
    ),
    r'searchProvider': PropertySchema(
      id: 10,
      name: r'searchProvider',
      type: IsarType.string,
    ),
    r'searchProviders': PropertySchema(
      id: 11,
      name: r'searchProviders',
      type: IsarType.byteList,
      enumMap: _AppPreferencesearchProvidersEnumValueMap,
    ),
    r'showFunding': PropertySchema(
      id: 12,
      name: r'showFunding',
      type: IsarType.bool,
    ),
    r'storeDownloadsSDCard': PropertySchema(
      id: 13,
      name: r'storeDownloadsSDCard',
      type: IsarType.bool,
    ),
    r'streamWarnMobileData': PropertySchema(
      id: 14,
      name: r'streamWarnMobileData',
      type: IsarType.bool,
    ),
    r'theme': PropertySchema(
      id: 15,
      name: r'theme',
      type: IsarType.byte,
      enumMap: _AppPreferencethemeEnumValueMap,
    ),
    r'trimSilence': PropertySchema(
      id: 16,
      name: r'trimSilence',
      type: IsarType.bool,
    ),
    r'volumeBoost': PropertySchema(
      id: 17,
      name: r'volumeBoost',
      type: IsarType.bool,
    )
  },
  estimateSize: _appPreferenceEstimateSize,
  serialize: _appPreferenceSerialize,
  deserialize: _appPreferenceDeserialize,
  deserializeProp: _appPreferenceDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _appPreferenceGetId,
  getLinks: _appPreferenceGetLinks,
  attach: _appPreferenceAttach,
  version: '3.1.7',
);

int _appPreferenceEstimateSize(
  AppPreference object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.locale.length * 3;
  bytesCount += 3 + object.searchProvider.length * 3;
  bytesCount += 3 + object.searchProviders.length;
  return bytesCount;
}

void _appPreferenceSerialize(
  AppPreference object,
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
  writer.writeDouble(offsets[9], object.playbackSpeed);
  writer.writeString(offsets[10], object.searchProvider);
  writer.writeByteList(
      offsets[11], object.searchProviders.map((e) => e.index).toList());
  writer.writeBool(offsets[12], object.showFunding);
  writer.writeBool(offsets[13], object.storeDownloadsSDCard);
  writer.writeBool(offsets[14], object.streamWarnMobileData);
  writer.writeByte(offsets[15], object.theme.index);
  writer.writeBool(offsets[16], object.trimSilence);
  writer.writeBool(offsets[17], object.volumeBoost);
}

AppPreference _appPreferenceDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppPreference(
    autoDeleteEpisodes: reader.readBool(offsets[0]),
    autoDownloadOnlyOnWifi: reader.readBool(offsets[1]),
    autoOpenNowPlaying: reader.readBool(offsets[2]),
    autoUpdateEpisodePeriod: reader.readLong(offsets[3]),
    downloadWarnMobileData: reader.readBool(offsets[4]),
    externalLinkConsent: reader.readBool(offsets[5]),
    layout: reader.readLong(offsets[6]),
    locale: reader.readString(offsets[7]),
    markDeletedEpisodesAsPlayed: reader.readBool(offsets[8]),
    playbackSpeed: reader.readDouble(offsets[9]),
    searchProvider: reader.readString(offsets[10]),
    searchProviders: reader
            .readByteList(offsets[11])
            ?.map((e) =>
                _AppPreferencesearchProvidersValueEnumMap[e] ??
                SearchProvider.itunes)
            .toList() ??
        [],
    showFunding: reader.readBool(offsets[12]),
    storeDownloadsSDCard: reader.readBool(offsets[13]),
    streamWarnMobileData: reader.readBool(offsets[14]),
    theme:
        _AppPreferencethemeValueEnumMap[reader.readByteOrNull(offsets[15])] ??
            ThemeMode.system,
    trimSilence: reader.readBool(offsets[16]),
    volumeBoost: reader.readBool(offsets[17]),
  );
  return object;
}

P _appPreferenceDeserializeProp<P>(
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
      return (reader.readDouble(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader
              .readByteList(offset)
              ?.map((e) =>
                  _AppPreferencesearchProvidersValueEnumMap[e] ??
                  SearchProvider.itunes)
              .toList() ??
          []) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readBool(offset)) as P;
    case 14:
      return (reader.readBool(offset)) as P;
    case 15:
      return (_AppPreferencethemeValueEnumMap[reader.readByteOrNull(offset)] ??
          ThemeMode.system) as P;
    case 16:
      return (reader.readBool(offset)) as P;
    case 17:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _AppPreferencesearchProvidersEnumValueMap = {
  'itunes': 0,
  'podcastIndex': 1,
};
const _AppPreferencesearchProvidersValueEnumMap = {
  0: SearchProvider.itunes,
  1: SearchProvider.podcastIndex,
};
const _AppPreferencethemeEnumValueMap = {
  'system': 0,
  'light': 1,
  'dark': 2,
};
const _AppPreferencethemeValueEnumMap = {
  0: ThemeMode.system,
  1: ThemeMode.light,
  2: ThemeMode.dark,
};

Id _appPreferenceGetId(AppPreference object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _appPreferenceGetLinks(AppPreference object) {
  return [];
}

void _appPreferenceAttach(
    IsarCollection<dynamic> col, Id id, AppPreference object) {}

extension AppPreferenceQueryWhereSort
    on QueryBuilder<AppPreference, AppPreference, QWhere> {
  QueryBuilder<AppPreference, AppPreference, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppPreferenceQueryWhere
    on QueryBuilder<AppPreference, AppPreference, QWhereClause> {
  QueryBuilder<AppPreference, AppPreference, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<AppPreference, AppPreference, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterWhereClause> idBetween(
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

extension AppPreferenceQueryFilter
    on QueryBuilder<AppPreference, AppPreference, QFilterCondition> {
  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      autoDeleteEpisodesEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autoDeleteEpisodes',
        value: value,
      ));
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      autoDownloadOnlyOnWifiEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autoDownloadOnlyOnWifi',
        value: value,
      ));
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      autoOpenNowPlayingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autoOpenNowPlaying',
        value: value,
      ));
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      autoUpdateEpisodePeriodEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autoUpdateEpisodePeriod',
        value: value,
      ));
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      downloadWarnMobileDataEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'downloadWarnMobileData',
        value: value,
      ));
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      externalLinkConsentEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'externalLinkConsent',
        value: value,
      ));
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition> idBetween(
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      layoutEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'layout',
        value: value,
      ));
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      layoutGreaterThan(
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      layoutLessThan(
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      layoutBetween(
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      localeEqualTo(
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      localeGreaterThan(
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      localeLessThan(
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      localeBetween(
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      localeStartsWith(
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      localeEndsWith(
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      localeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'locale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      localeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'locale',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      localeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locale',
        value: '',
      ));
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      localeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'locale',
        value: '',
      ));
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      markDeletedEpisodesAsPlayedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'markDeletedEpisodesAsPlayed',
        value: value,
      ));
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      searchProviderContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'searchProvider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      searchProviderMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'searchProvider',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      searchProviderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'searchProvider',
        value: '',
      ));
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      searchProviderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'searchProvider',
        value: '',
      ));
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      searchProvidersElementEqualTo(SearchProvider value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'searchProviders',
        value: value,
      ));
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      showFundingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showFunding',
        value: value,
      ));
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      storeDownloadsSDCardEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'storeDownloadsSDCard',
        value: value,
      ));
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      streamWarnMobileDataEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streamWarnMobileData',
        value: value,
      ));
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      themeEqualTo(ThemeMode value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'theme',
        value: value,
      ));
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      themeGreaterThan(
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      themeLessThan(
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      themeBetween(
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      trimSilenceEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trimSilence',
        value: value,
      ));
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
      volumeBoostEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'volumeBoost',
        value: value,
      ));
    });
  }
}

extension AppPreferenceQueryObject
    on QueryBuilder<AppPreference, AppPreference, QFilterCondition> {}

extension AppPreferenceQueryLinks
    on QueryBuilder<AppPreference, AppPreference, QFilterCondition> {}

extension AppPreferenceQuerySortBy
    on QueryBuilder<AppPreference, AppPreference, QSortBy> {
  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      sortByAutoDeleteEpisodes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoDeleteEpisodes', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      sortByAutoDeleteEpisodesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoDeleteEpisodes', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      sortByAutoDownloadOnlyOnWifi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoDownloadOnlyOnWifi', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      sortByAutoDownloadOnlyOnWifiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoDownloadOnlyOnWifi', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      sortByAutoOpenNowPlaying() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoOpenNowPlaying', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      sortByAutoOpenNowPlayingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoOpenNowPlaying', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      sortByAutoUpdateEpisodePeriod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoUpdateEpisodePeriod', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      sortByAutoUpdateEpisodePeriodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoUpdateEpisodePeriod', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      sortByDownloadWarnMobileData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadWarnMobileData', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      sortByDownloadWarnMobileDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadWarnMobileData', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      sortByExternalLinkConsent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalLinkConsent', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      sortByExternalLinkConsentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalLinkConsent', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy> sortByLayout() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'layout', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy> sortByLayoutDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'layout', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy> sortByLocale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy> sortByLocaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      sortByMarkDeletedEpisodesAsPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markDeletedEpisodesAsPlayed', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      sortByMarkDeletedEpisodesAsPlayedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markDeletedEpisodesAsPlayed', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      sortByPlaybackSpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackSpeed', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      sortByPlaybackSpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackSpeed', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      sortBySearchProvider() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchProvider', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      sortBySearchProviderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchProvider', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy> sortByShowFunding() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showFunding', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      sortByShowFundingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showFunding', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      sortByStoreDownloadsSDCard() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storeDownloadsSDCard', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      sortByStoreDownloadsSDCardDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storeDownloadsSDCard', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      sortByStreamWarnMobileData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamWarnMobileData', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      sortByStreamWarnMobileDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamWarnMobileData', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy> sortByTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theme', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy> sortByThemeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theme', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy> sortByTrimSilence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trimSilence', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      sortByTrimSilenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trimSilence', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy> sortByVolumeBoost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volumeBoost', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      sortByVolumeBoostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volumeBoost', Sort.desc);
    });
  }
}

extension AppPreferenceQuerySortThenBy
    on QueryBuilder<AppPreference, AppPreference, QSortThenBy> {
  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      thenByAutoDeleteEpisodes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoDeleteEpisodes', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      thenByAutoDeleteEpisodesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoDeleteEpisodes', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      thenByAutoDownloadOnlyOnWifi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoDownloadOnlyOnWifi', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      thenByAutoDownloadOnlyOnWifiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoDownloadOnlyOnWifi', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      thenByAutoOpenNowPlaying() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoOpenNowPlaying', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      thenByAutoOpenNowPlayingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoOpenNowPlaying', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      thenByAutoUpdateEpisodePeriod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoUpdateEpisodePeriod', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      thenByAutoUpdateEpisodePeriodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoUpdateEpisodePeriod', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      thenByDownloadWarnMobileData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadWarnMobileData', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      thenByDownloadWarnMobileDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadWarnMobileData', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      thenByExternalLinkConsent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalLinkConsent', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      thenByExternalLinkConsentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalLinkConsent', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy> thenByLayout() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'layout', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy> thenByLayoutDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'layout', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy> thenByLocale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy> thenByLocaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      thenByMarkDeletedEpisodesAsPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markDeletedEpisodesAsPlayed', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      thenByMarkDeletedEpisodesAsPlayedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markDeletedEpisodesAsPlayed', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      thenByPlaybackSpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackSpeed', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      thenByPlaybackSpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playbackSpeed', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      thenBySearchProvider() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchProvider', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      thenBySearchProviderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchProvider', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy> thenByShowFunding() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showFunding', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      thenByShowFundingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showFunding', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      thenByStoreDownloadsSDCard() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storeDownloadsSDCard', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      thenByStoreDownloadsSDCardDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storeDownloadsSDCard', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      thenByStreamWarnMobileData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamWarnMobileData', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      thenByStreamWarnMobileDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamWarnMobileData', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy> thenByTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theme', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy> thenByThemeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theme', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy> thenByTrimSilence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trimSilence', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      thenByTrimSilenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trimSilence', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy> thenByVolumeBoost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volumeBoost', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
      thenByVolumeBoostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volumeBoost', Sort.desc);
    });
  }
}

extension AppPreferenceQueryWhereDistinct
    on QueryBuilder<AppPreference, AppPreference, QDistinct> {
  QueryBuilder<AppPreference, AppPreference, QDistinct>
      distinctByAutoDeleteEpisodes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoDeleteEpisodes');
    });
  }

  QueryBuilder<AppPreference, AppPreference, QDistinct>
      distinctByAutoDownloadOnlyOnWifi() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoDownloadOnlyOnWifi');
    });
  }

  QueryBuilder<AppPreference, AppPreference, QDistinct>
      distinctByAutoOpenNowPlaying() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoOpenNowPlaying');
    });
  }

  QueryBuilder<AppPreference, AppPreference, QDistinct>
      distinctByAutoUpdateEpisodePeriod() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoUpdateEpisodePeriod');
    });
  }

  QueryBuilder<AppPreference, AppPreference, QDistinct>
      distinctByDownloadWarnMobileData() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'downloadWarnMobileData');
    });
  }

  QueryBuilder<AppPreference, AppPreference, QDistinct>
      distinctByExternalLinkConsent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'externalLinkConsent');
    });
  }

  QueryBuilder<AppPreference, AppPreference, QDistinct> distinctByLayout() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'layout');
    });
  }

  QueryBuilder<AppPreference, AppPreference, QDistinct> distinctByLocale(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'locale', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QDistinct>
      distinctByMarkDeletedEpisodesAsPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'markDeletedEpisodesAsPlayed');
    });
  }

  QueryBuilder<AppPreference, AppPreference, QDistinct>
      distinctByPlaybackSpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playbackSpeed');
    });
  }

  QueryBuilder<AppPreference, AppPreference, QDistinct>
      distinctBySearchProvider({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'searchProvider',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QDistinct>
      distinctBySearchProviders() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'searchProviders');
    });
  }

  QueryBuilder<AppPreference, AppPreference, QDistinct>
      distinctByShowFunding() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showFunding');
    });
  }

  QueryBuilder<AppPreference, AppPreference, QDistinct>
      distinctByStoreDownloadsSDCard() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'storeDownloadsSDCard');
    });
  }

  QueryBuilder<AppPreference, AppPreference, QDistinct>
      distinctByStreamWarnMobileData() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streamWarnMobileData');
    });
  }

  QueryBuilder<AppPreference, AppPreference, QDistinct> distinctByTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'theme');
    });
  }

  QueryBuilder<AppPreference, AppPreference, QDistinct>
      distinctByTrimSilence() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trimSilence');
    });
  }

  QueryBuilder<AppPreference, AppPreference, QDistinct>
      distinctByVolumeBoost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'volumeBoost');
    });
  }
}

extension AppPreferenceQueryProperty
    on QueryBuilder<AppPreference, AppPreference, QQueryProperty> {
  QueryBuilder<AppPreference, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AppPreference, bool, QQueryOperations>
      autoDeleteEpisodesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoDeleteEpisodes');
    });
  }

  QueryBuilder<AppPreference, bool, QQueryOperations>
      autoDownloadOnlyOnWifiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoDownloadOnlyOnWifi');
    });
  }

  QueryBuilder<AppPreference, bool, QQueryOperations>
      autoOpenNowPlayingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoOpenNowPlaying');
    });
  }

  QueryBuilder<AppPreference, int, QQueryOperations>
      autoUpdateEpisodePeriodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoUpdateEpisodePeriod');
    });
  }

  QueryBuilder<AppPreference, bool, QQueryOperations>
      downloadWarnMobileDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'downloadWarnMobileData');
    });
  }

  QueryBuilder<AppPreference, bool, QQueryOperations>
      externalLinkConsentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'externalLinkConsent');
    });
  }

  QueryBuilder<AppPreference, int, QQueryOperations> layoutProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'layout');
    });
  }

  QueryBuilder<AppPreference, String, QQueryOperations> localeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'locale');
    });
  }

  QueryBuilder<AppPreference, bool, QQueryOperations>
      markDeletedEpisodesAsPlayedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'markDeletedEpisodesAsPlayed');
    });
  }

  QueryBuilder<AppPreference, double, QQueryOperations>
      playbackSpeedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playbackSpeed');
    });
  }

  QueryBuilder<AppPreference, String, QQueryOperations>
      searchProviderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'searchProvider');
    });
  }

  QueryBuilder<AppPreference, List<SearchProvider>, QQueryOperations>
      searchProvidersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'searchProviders');
    });
  }

  QueryBuilder<AppPreference, bool, QQueryOperations> showFundingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showFunding');
    });
  }

  QueryBuilder<AppPreference, bool, QQueryOperations>
      storeDownloadsSDCardProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'storeDownloadsSDCard');
    });
  }

  QueryBuilder<AppPreference, bool, QQueryOperations>
      streamWarnMobileDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streamWarnMobileData');
    });
  }

  QueryBuilder<AppPreference, ThemeMode, QQueryOperations> themeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'theme');
    });
  }

  QueryBuilder<AppPreference, bool, QQueryOperations> trimSilenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trimSilence');
    });
  }

  QueryBuilder<AppPreference, bool, QQueryOperations> volumeBoostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'volumeBoost');
    });
  }
}
