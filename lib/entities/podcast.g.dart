// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPodcastCollection on Isar {
  IsarCollection<Podcast> get podcasts => this.collection();
}

const PodcastSchema = CollectionSchema(
  name: r'Podcast',
  id: -1143728065732125040,
  properties: {
    r'author': PropertySchema(
      id: 0,
      name: r'author',
      type: IsarType.string,
    ),
    r'category': PropertySchema(
      id: 1,
      name: r'category',
      type: IsarType.string,
    ),
    r'collectionId': PropertySchema(
      id: 2,
      name: r'collectionId',
      type: IsarType.long,
    ),
    r'complete': PropertySchema(
      id: 3,
      name: r'complete',
      type: IsarType.bool,
    ),
    r'copyright': PropertySchema(
      id: 4,
      name: r'copyright',
      type: IsarType.string,
    ),
    r'description': PropertySchema(
      id: 5,
      name: r'description',
      type: IsarType.string,
    ),
    r'explicit': PropertySchema(
      id: 6,
      name: r'explicit',
      type: IsarType.bool,
    ),
    r'feedUrl': PropertySchema(
      id: 7,
      name: r'feedUrl',
      type: IsarType.string,
    ),
    r'guid': PropertySchema(
      id: 8,
      name: r'guid',
      type: IsarType.string,
    ),
    r'image': PropertySchema(
      id: 9,
      name: r'image',
      type: IsarType.string,
    ),
    r'language': PropertySchema(
      id: 10,
      name: r'language',
      type: IsarType.string,
    ),
    r'link': PropertySchema(
      id: 11,
      name: r'link',
      type: IsarType.string,
    ),
    r'newFeedUrl': PropertySchema(
      id: 12,
      name: r'newFeedUrl',
      type: IsarType.string,
    ),
    r'subcategory': PropertySchema(
      id: 13,
      name: r'subcategory',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 14,
      name: r'title',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 15,
      name: r'type',
      type: IsarType.byte,
      enumMap: _PodcasttypeEnumValueMap,
    )
  },
  estimateSize: _podcastEstimateSize,
  serialize: _podcastSerialize,
  deserialize: _podcastDeserialize,
  deserializeProp: _podcastDeserializeProp,
  idName: r'id',
  indexes: {
    r'feedUrl': IndexSchema(
      id: 2504832307170622621,
      name: r'feedUrl',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'feedUrl',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'collectionId': IndexSchema(
      id: -7489395134515229581,
      name: r'collectionId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'collectionId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {
    r'locked': LinkSchema(
      id: -6464416755416982514,
      name: r'locked',
      target: r'Locked',
      single: false,
    ),
    r'funding': LinkSchema(
      id: -825647095737691059,
      name: r'funding',
      target: r'Funding',
      single: false,
    ),
    r'value': LinkSchema(
      id: -4784660625393050535,
      name: r'value',
      target: r'Value',
      single: false,
    ),
    r'block': LinkSchema(
      id: 5157706608492392178,
      name: r'block',
      target: r'Block',
      single: false,
    ),
    r'person': LinkSchema(
      id: 4617996789789514658,
      name: r'person',
      target: r'Person',
      single: false,
    )
  },
  embeddedSchemas: {},
  getId: _podcastGetId,
  getLinks: _podcastGetLinks,
  attach: _podcastAttach,
  version: '3.1.0+1',
);

int _podcastEstimateSize(
  Podcast object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.author;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.category.length * 3;
  {
    final value = object.copyright;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.description.length * 3;
  bytesCount += 3 + object.feedUrl.length * 3;
  {
    final value = object.guid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.image.length * 3;
  bytesCount += 3 + object.language.length * 3;
  {
    final value = object.link;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.newFeedUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.subcategory;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _podcastSerialize(
  Podcast object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.author);
  writer.writeString(offsets[1], object.category);
  writer.writeLong(offsets[2], object.collectionId);
  writer.writeBool(offsets[3], object.complete);
  writer.writeString(offsets[4], object.copyright);
  writer.writeString(offsets[5], object.description);
  writer.writeBool(offsets[6], object.explicit);
  writer.writeString(offsets[7], object.feedUrl);
  writer.writeString(offsets[8], object.guid);
  writer.writeString(offsets[9], object.image);
  writer.writeString(offsets[10], object.language);
  writer.writeString(offsets[11], object.link);
  writer.writeString(offsets[12], object.newFeedUrl);
  writer.writeString(offsets[13], object.subcategory);
  writer.writeString(offsets[14], object.title);
  writer.writeByte(offsets[15], object.type.index);
}

Podcast _podcastDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Podcast(
    author: reader.readStringOrNull(offsets[0]),
    category: reader.readString(offsets[1]),
    collectionId: reader.readLong(offsets[2]),
    complete: reader.readBoolOrNull(offsets[3]) ?? false,
    copyright: reader.readStringOrNull(offsets[4]),
    description: reader.readString(offsets[5]),
    explicit: reader.readBool(offsets[6]),
    feedUrl: reader.readString(offsets[7]),
    guid: reader.readStringOrNull(offsets[8]),
    image: reader.readString(offsets[9]),
    language: reader.readString(offsets[10]),
    link: reader.readStringOrNull(offsets[11]),
    newFeedUrl: reader.readStringOrNull(offsets[12]),
    subcategory: reader.readStringOrNull(offsets[13]),
    title: reader.readString(offsets[14]),
    type: _PodcasttypeValueEnumMap[reader.readByteOrNull(offsets[15])] ??
        ShowType.episodic,
  );
  return object;
}

P _podcastDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (_PodcasttypeValueEnumMap[reader.readByteOrNull(offset)] ??
          ShowType.episodic) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PodcasttypeEnumValueMap = {
  'episodic': 0,
  'serial': 1,
};
const _PodcasttypeValueEnumMap = {
  0: ShowType.episodic,
  1: ShowType.serial,
};

Id _podcastGetId(Podcast object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _podcastGetLinks(Podcast object) {
  return [
    object.locked,
    object.funding,
    object.value,
    object.block,
    object.person
  ];
}

void _podcastAttach(IsarCollection<dynamic> col, Id id, Podcast object) {
  object.locked.attach(col, col.isar.collection<Locked>(), r'locked', id);
  object.funding.attach(col, col.isar.collection<Funding>(), r'funding', id);
  object.value.attach(col, col.isar.collection<Value>(), r'value', id);
  object.block.attach(col, col.isar.collection<Block>(), r'block', id);
  object.person.attach(col, col.isar.collection<Person>(), r'person', id);
}

extension PodcastByIndex on IsarCollection<Podcast> {
  Future<Podcast?> getByFeedUrl(String feedUrl) {
    return getByIndex(r'feedUrl', [feedUrl]);
  }

  Podcast? getByFeedUrlSync(String feedUrl) {
    return getByIndexSync(r'feedUrl', [feedUrl]);
  }

  Future<bool> deleteByFeedUrl(String feedUrl) {
    return deleteByIndex(r'feedUrl', [feedUrl]);
  }

  bool deleteByFeedUrlSync(String feedUrl) {
    return deleteByIndexSync(r'feedUrl', [feedUrl]);
  }

  Future<List<Podcast?>> getAllByFeedUrl(List<String> feedUrlValues) {
    final values = feedUrlValues.map((e) => [e]).toList();
    return getAllByIndex(r'feedUrl', values);
  }

  List<Podcast?> getAllByFeedUrlSync(List<String> feedUrlValues) {
    final values = feedUrlValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'feedUrl', values);
  }

  Future<int> deleteAllByFeedUrl(List<String> feedUrlValues) {
    final values = feedUrlValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'feedUrl', values);
  }

  int deleteAllByFeedUrlSync(List<String> feedUrlValues) {
    final values = feedUrlValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'feedUrl', values);
  }

  Future<Id> putByFeedUrl(Podcast object) {
    return putByIndex(r'feedUrl', object);
  }

  Id putByFeedUrlSync(Podcast object, {bool saveLinks = true}) {
    return putByIndexSync(r'feedUrl', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByFeedUrl(List<Podcast> objects) {
    return putAllByIndex(r'feedUrl', objects);
  }

  List<Id> putAllByFeedUrlSync(List<Podcast> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'feedUrl', objects, saveLinks: saveLinks);
  }

  Future<Podcast?> getByCollectionId(int collectionId) {
    return getByIndex(r'collectionId', [collectionId]);
  }

  Podcast? getByCollectionIdSync(int collectionId) {
    return getByIndexSync(r'collectionId', [collectionId]);
  }

  Future<bool> deleteByCollectionId(int collectionId) {
    return deleteByIndex(r'collectionId', [collectionId]);
  }

  bool deleteByCollectionIdSync(int collectionId) {
    return deleteByIndexSync(r'collectionId', [collectionId]);
  }

  Future<List<Podcast?>> getAllByCollectionId(List<int> collectionIdValues) {
    final values = collectionIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'collectionId', values);
  }

  List<Podcast?> getAllByCollectionIdSync(List<int> collectionIdValues) {
    final values = collectionIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'collectionId', values);
  }

  Future<int> deleteAllByCollectionId(List<int> collectionIdValues) {
    final values = collectionIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'collectionId', values);
  }

  int deleteAllByCollectionIdSync(List<int> collectionIdValues) {
    final values = collectionIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'collectionId', values);
  }

  Future<Id> putByCollectionId(Podcast object) {
    return putByIndex(r'collectionId', object);
  }

  Id putByCollectionIdSync(Podcast object, {bool saveLinks = true}) {
    return putByIndexSync(r'collectionId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCollectionId(List<Podcast> objects) {
    return putAllByIndex(r'collectionId', objects);
  }

  List<Id> putAllByCollectionIdSync(List<Podcast> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'collectionId', objects, saveLinks: saveLinks);
  }
}

extension PodcastQueryWhereSort on QueryBuilder<Podcast, Podcast, QWhere> {
  QueryBuilder<Podcast, Podcast, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterWhere> anyCollectionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'collectionId'),
      );
    });
  }
}

extension PodcastQueryWhere on QueryBuilder<Podcast, Podcast, QWhereClause> {
  QueryBuilder<Podcast, Podcast, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Podcast, Podcast, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterWhereClause> idBetween(
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

  QueryBuilder<Podcast, Podcast, QAfterWhereClause> feedUrlEqualTo(
      String feedUrl) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'feedUrl',
        value: [feedUrl],
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterWhereClause> feedUrlNotEqualTo(
      String feedUrl) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'feedUrl',
              lower: [],
              upper: [feedUrl],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'feedUrl',
              lower: [feedUrl],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'feedUrl',
              lower: [feedUrl],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'feedUrl',
              lower: [],
              upper: [feedUrl],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterWhereClause> collectionIdEqualTo(
      int collectionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'collectionId',
        value: [collectionId],
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterWhereClause> collectionIdNotEqualTo(
      int collectionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collectionId',
              lower: [],
              upper: [collectionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collectionId',
              lower: [collectionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collectionId',
              lower: [collectionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collectionId',
              lower: [],
              upper: [collectionId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterWhereClause> collectionIdGreaterThan(
    int collectionId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'collectionId',
        lower: [collectionId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterWhereClause> collectionIdLessThan(
    int collectionId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'collectionId',
        lower: [],
        upper: [collectionId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterWhereClause> collectionIdBetween(
    int lowerCollectionId,
    int upperCollectionId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'collectionId',
        lower: [lowerCollectionId],
        includeLower: includeLower,
        upper: [upperCollectionId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PodcastQueryFilter
    on QueryBuilder<Podcast, Podcast, QFilterCondition> {
  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> authorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'author',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> authorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'author',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> authorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> authorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> authorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> authorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'author',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> authorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> authorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> authorContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> authorMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'author',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> authorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'author',
        value: '',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> authorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'author',
        value: '',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> categoryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> categoryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> categoryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> categoryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'category',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> categoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> categoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> categoryContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> categoryMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'category',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> collectionIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collectionId',
        value: value,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> collectionIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'collectionId',
        value: value,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> collectionIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'collectionId',
        value: value,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> collectionIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'collectionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> completeEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'complete',
        value: value,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> copyrightIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'copyright',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> copyrightIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'copyright',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> copyrightEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'copyright',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> copyrightGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'copyright',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> copyrightLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'copyright',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> copyrightBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'copyright',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> copyrightStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'copyright',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> copyrightEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'copyright',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> copyrightContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'copyright',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> copyrightMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'copyright',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> copyrightIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'copyright',
        value: '',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> copyrightIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'copyright',
        value: '',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> descriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> descriptionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> descriptionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> explicitEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'explicit',
        value: value,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> feedUrlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'feedUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> feedUrlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'feedUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> feedUrlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'feedUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> feedUrlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'feedUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> feedUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'feedUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> feedUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'feedUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> feedUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'feedUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> feedUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'feedUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> feedUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'feedUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> feedUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'feedUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> guidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'guid',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> guidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'guid',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> guidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'guid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> guidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'guid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> guidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'guid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> guidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'guid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> guidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'guid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> guidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'guid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> guidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'guid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> guidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'guid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> guidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'guid',
        value: '',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> guidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'guid',
        value: '',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> imageEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'image',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> imageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'image',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> imageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'image',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> imageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'image',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> imageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'image',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> imageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'image',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> imageContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'image',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> imageMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'image',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> imageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'image',
        value: '',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> imageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'image',
        value: '',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> languageEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> languageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> languageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> languageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'language',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> languageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> languageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> languageContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> languageMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'language',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> languageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'language',
        value: '',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> languageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'language',
        value: '',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> linkIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'link',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> linkIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'link',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> linkEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'link',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> linkGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'link',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> linkLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'link',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> linkBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'link',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> linkStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'link',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> linkEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'link',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> linkContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'link',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> linkMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'link',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> linkIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'link',
        value: '',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> linkIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'link',
        value: '',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> newFeedUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'newFeedUrl',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> newFeedUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'newFeedUrl',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> newFeedUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'newFeedUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> newFeedUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'newFeedUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> newFeedUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'newFeedUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> newFeedUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'newFeedUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> newFeedUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'newFeedUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> newFeedUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'newFeedUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> newFeedUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'newFeedUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> newFeedUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'newFeedUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> newFeedUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'newFeedUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> newFeedUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'newFeedUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> subcategoryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'subcategory',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> subcategoryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'subcategory',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> subcategoryEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subcategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> subcategoryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subcategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> subcategoryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subcategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> subcategoryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subcategory',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> subcategoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subcategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> subcategoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subcategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> subcategoryContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subcategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> subcategoryMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subcategory',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> subcategoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subcategory',
        value: '',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
      subcategoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subcategory',
        value: '',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> typeEqualTo(
      ShowType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> typeGreaterThan(
    ShowType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> typeLessThan(
    ShowType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> typeBetween(
    ShowType lower,
    ShowType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PodcastQueryObject
    on QueryBuilder<Podcast, Podcast, QFilterCondition> {}

extension PodcastQueryLinks
    on QueryBuilder<Podcast, Podcast, QFilterCondition> {
  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> locked(
      FilterQuery<Locked> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'locked');
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> lockedLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'locked', length, true, length, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> lockedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'locked', 0, true, 0, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> lockedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'locked', 0, false, 999999, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> lockedLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'locked', 0, true, length, include);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> lockedLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'locked', length, include, 999999, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> lockedLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'locked', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> funding(
      FilterQuery<Funding> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'funding');
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> fundingLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'funding', length, true, length, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> fundingIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'funding', 0, true, 0, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> fundingIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'funding', 0, false, 999999, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> fundingLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'funding', 0, true, length, include);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition>
      fundingLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'funding', length, include, 999999, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> fundingLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'funding', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> value(
      FilterQuery<Value> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'value');
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> valueLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'value', length, true, length, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> valueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'value', 0, true, 0, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> valueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'value', 0, false, 999999, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> valueLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'value', 0, true, length, include);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> valueLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'value', length, include, 999999, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> valueLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'value', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> block(
      FilterQuery<Block> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'block');
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> blockLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'block', length, true, length, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> blockIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'block', 0, true, 0, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> blockIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'block', 0, false, 999999, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> blockLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'block', 0, true, length, include);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> blockLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'block', length, include, 999999, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> blockLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'block', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> person(
      FilterQuery<Person> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'person');
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> personLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'person', length, true, length, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> personIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'person', 0, true, 0, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> personIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'person', 0, false, 999999, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> personLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'person', 0, true, length, include);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> personLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'person', length, include, 999999, true);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterFilterCondition> personLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'person', lower, includeLower, upper, includeUpper);
    });
  }
}

extension PodcastQuerySortBy on QueryBuilder<Podcast, Podcast, QSortBy> {
  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByAuthor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByAuthorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByCollectionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionId', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByCollectionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionId', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'complete', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByCompleteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'complete', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByCopyright() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'copyright', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByCopyrightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'copyright', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByExplicit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'explicit', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByExplicitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'explicit', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByFeedUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedUrl', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByFeedUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedUrl', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByImage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'image', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByImageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'image', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByLink() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'link', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByLinkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'link', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByNewFeedUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newFeedUrl', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByNewFeedUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newFeedUrl', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortBySubcategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subcategory', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortBySubcategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subcategory', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension PodcastQuerySortThenBy
    on QueryBuilder<Podcast, Podcast, QSortThenBy> {
  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByAuthor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByAuthorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByCollectionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionId', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByCollectionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionId', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'complete', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByCompleteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'complete', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByCopyright() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'copyright', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByCopyrightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'copyright', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByExplicit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'explicit', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByExplicitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'explicit', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByFeedUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedUrl', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByFeedUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedUrl', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByImage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'image', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByImageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'image', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByLink() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'link', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByLinkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'link', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByNewFeedUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newFeedUrl', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByNewFeedUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newFeedUrl', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenBySubcategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subcategory', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenBySubcategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subcategory', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<Podcast, Podcast, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension PodcastQueryWhereDistinct
    on QueryBuilder<Podcast, Podcast, QDistinct> {
  QueryBuilder<Podcast, Podcast, QDistinct> distinctByAuthor(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'author', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByCategory(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'category', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByCollectionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'collectionId');
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'complete');
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByCopyright(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'copyright', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByExplicit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'explicit');
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByFeedUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'feedUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'guid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByImage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'image', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByLanguage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'language', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByLink(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'link', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByNewFeedUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'newFeedUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctBySubcategory(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subcategory', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Podcast, Podcast, QDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }
}

extension PodcastQueryProperty
    on QueryBuilder<Podcast, Podcast, QQueryProperty> {
  QueryBuilder<Podcast, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Podcast, String?, QQueryOperations> authorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'author');
    });
  }

  QueryBuilder<Podcast, String, QQueryOperations> categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'category');
    });
  }

  QueryBuilder<Podcast, int, QQueryOperations> collectionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'collectionId');
    });
  }

  QueryBuilder<Podcast, bool, QQueryOperations> completeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'complete');
    });
  }

  QueryBuilder<Podcast, String?, QQueryOperations> copyrightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'copyright');
    });
  }

  QueryBuilder<Podcast, String, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<Podcast, bool, QQueryOperations> explicitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'explicit');
    });
  }

  QueryBuilder<Podcast, String, QQueryOperations> feedUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'feedUrl');
    });
  }

  QueryBuilder<Podcast, String?, QQueryOperations> guidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'guid');
    });
  }

  QueryBuilder<Podcast, String, QQueryOperations> imageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'image');
    });
  }

  QueryBuilder<Podcast, String, QQueryOperations> languageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'language');
    });
  }

  QueryBuilder<Podcast, String?, QQueryOperations> linkProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'link');
    });
  }

  QueryBuilder<Podcast, String?, QQueryOperations> newFeedUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'newFeedUrl');
    });
  }

  QueryBuilder<Podcast, String?, QQueryOperations> subcategoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subcategory');
    });
  }

  QueryBuilder<Podcast, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<Podcast, ShowType, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPodcastStatsCollection on Isar {
  IsarCollection<PodcastStats> get podcastStats => this.collection();
}

const PodcastStatsSchema = CollectionSchema(
  name: r'PodcastStats',
  id: 7298669046056592682,
  properties: {
    r'lastCheckedAt': PropertySchema(
      id: 0,
      name: r'lastCheckedAt',
      type: IsarType.dateTime,
    ),
    r'subscribedDate': PropertySchema(
      id: 1,
      name: r'subscribedDate',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _podcastStatsEstimateSize,
  serialize: _podcastStatsSerialize,
  deserialize: _podcastStatsDeserialize,
  deserializeProp: _podcastStatsDeserializeProp,
  idName: r'id',
  indexes: {
    r'subscribedDate': IndexSchema(
      id: -9177708408589377138,
      name: r'subscribedDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'subscribedDate',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _podcastStatsGetId,
  getLinks: _podcastStatsGetLinks,
  attach: _podcastStatsAttach,
  version: '3.1.0+1',
);

int _podcastStatsEstimateSize(
  PodcastStats object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _podcastStatsSerialize(
  PodcastStats object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.lastCheckedAt);
  writer.writeDateTime(offsets[1], object.subscribedDate);
}

PodcastStats _podcastStatsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PodcastStats(
    id: id,
    lastCheckedAt: reader.readDateTimeOrNull(offsets[0]),
    subscribedDate: reader.readDateTimeOrNull(offsets[1]),
  );
  return object;
}

P _podcastStatsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _podcastStatsGetId(PodcastStats object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _podcastStatsGetLinks(PodcastStats object) {
  return [];
}

void _podcastStatsAttach(
    IsarCollection<dynamic> col, Id id, PodcastStats object) {}

extension PodcastStatsQueryWhereSort
    on QueryBuilder<PodcastStats, PodcastStats, QWhere> {
  QueryBuilder<PodcastStats, PodcastStats, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PodcastStats, PodcastStats, QAfterWhere> anySubscribedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'subscribedDate'),
      );
    });
  }
}

extension PodcastStatsQueryWhere
    on QueryBuilder<PodcastStats, PodcastStats, QWhereClause> {
  QueryBuilder<PodcastStats, PodcastStats, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PodcastStats, PodcastStats, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<PodcastStats, PodcastStats, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PodcastStats, PodcastStats, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PodcastStats, PodcastStats, QAfterWhereClause> idBetween(
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

  QueryBuilder<PodcastStats, PodcastStats, QAfterWhereClause>
      subscribedDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'subscribedDate',
        value: [null],
      ));
    });
  }

  QueryBuilder<PodcastStats, PodcastStats, QAfterWhereClause>
      subscribedDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'subscribedDate',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<PodcastStats, PodcastStats, QAfterWhereClause>
      subscribedDateEqualTo(DateTime? subscribedDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'subscribedDate',
        value: [subscribedDate],
      ));
    });
  }

  QueryBuilder<PodcastStats, PodcastStats, QAfterWhereClause>
      subscribedDateNotEqualTo(DateTime? subscribedDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subscribedDate',
              lower: [],
              upper: [subscribedDate],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subscribedDate',
              lower: [subscribedDate],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subscribedDate',
              lower: [subscribedDate],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subscribedDate',
              lower: [],
              upper: [subscribedDate],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PodcastStats, PodcastStats, QAfterWhereClause>
      subscribedDateGreaterThan(
    DateTime? subscribedDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'subscribedDate',
        lower: [subscribedDate],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PodcastStats, PodcastStats, QAfterWhereClause>
      subscribedDateLessThan(
    DateTime? subscribedDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'subscribedDate',
        lower: [],
        upper: [subscribedDate],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PodcastStats, PodcastStats, QAfterWhereClause>
      subscribedDateBetween(
    DateTime? lowerSubscribedDate,
    DateTime? upperSubscribedDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'subscribedDate',
        lower: [lowerSubscribedDate],
        includeLower: includeLower,
        upper: [upperSubscribedDate],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PodcastStatsQueryFilter
    on QueryBuilder<PodcastStats, PodcastStats, QFilterCondition> {
  QueryBuilder<PodcastStats, PodcastStats, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PodcastStats, PodcastStats, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<PodcastStats, PodcastStats, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PodcastStats, PodcastStats, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PodcastStats, PodcastStats, QAfterFilterCondition>
      lastCheckedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastCheckedAt',
      ));
    });
  }

  QueryBuilder<PodcastStats, PodcastStats, QAfterFilterCondition>
      lastCheckedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastCheckedAt',
      ));
    });
  }

  QueryBuilder<PodcastStats, PodcastStats, QAfterFilterCondition>
      lastCheckedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastCheckedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PodcastStats, PodcastStats, QAfterFilterCondition>
      lastCheckedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastCheckedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PodcastStats, PodcastStats, QAfterFilterCondition>
      lastCheckedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastCheckedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PodcastStats, PodcastStats, QAfterFilterCondition>
      lastCheckedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastCheckedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PodcastStats, PodcastStats, QAfterFilterCondition>
      subscribedDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'subscribedDate',
      ));
    });
  }

  QueryBuilder<PodcastStats, PodcastStats, QAfterFilterCondition>
      subscribedDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'subscribedDate',
      ));
    });
  }

  QueryBuilder<PodcastStats, PodcastStats, QAfterFilterCondition>
      subscribedDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subscribedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PodcastStats, PodcastStats, QAfterFilterCondition>
      subscribedDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subscribedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PodcastStats, PodcastStats, QAfterFilterCondition>
      subscribedDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subscribedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PodcastStats, PodcastStats, QAfterFilterCondition>
      subscribedDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subscribedDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PodcastStatsQueryObject
    on QueryBuilder<PodcastStats, PodcastStats, QFilterCondition> {}

extension PodcastStatsQueryLinks
    on QueryBuilder<PodcastStats, PodcastStats, QFilterCondition> {}

extension PodcastStatsQuerySortBy
    on QueryBuilder<PodcastStats, PodcastStats, QSortBy> {
  QueryBuilder<PodcastStats, PodcastStats, QAfterSortBy> sortByLastCheckedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCheckedAt', Sort.asc);
    });
  }

  QueryBuilder<PodcastStats, PodcastStats, QAfterSortBy>
      sortByLastCheckedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCheckedAt', Sort.desc);
    });
  }

  QueryBuilder<PodcastStats, PodcastStats, QAfterSortBy>
      sortBySubscribedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subscribedDate', Sort.asc);
    });
  }

  QueryBuilder<PodcastStats, PodcastStats, QAfterSortBy>
      sortBySubscribedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subscribedDate', Sort.desc);
    });
  }
}

extension PodcastStatsQuerySortThenBy
    on QueryBuilder<PodcastStats, PodcastStats, QSortThenBy> {
  QueryBuilder<PodcastStats, PodcastStats, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PodcastStats, PodcastStats, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PodcastStats, PodcastStats, QAfterSortBy> thenByLastCheckedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCheckedAt', Sort.asc);
    });
  }

  QueryBuilder<PodcastStats, PodcastStats, QAfterSortBy>
      thenByLastCheckedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCheckedAt', Sort.desc);
    });
  }

  QueryBuilder<PodcastStats, PodcastStats, QAfterSortBy>
      thenBySubscribedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subscribedDate', Sort.asc);
    });
  }

  QueryBuilder<PodcastStats, PodcastStats, QAfterSortBy>
      thenBySubscribedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subscribedDate', Sort.desc);
    });
  }
}

extension PodcastStatsQueryWhereDistinct
    on QueryBuilder<PodcastStats, PodcastStats, QDistinct> {
  QueryBuilder<PodcastStats, PodcastStats, QDistinct>
      distinctByLastCheckedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastCheckedAt');
    });
  }

  QueryBuilder<PodcastStats, PodcastStats, QDistinct>
      distinctBySubscribedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subscribedDate');
    });
  }
}

extension PodcastStatsQueryProperty
    on QueryBuilder<PodcastStats, PodcastStats, QQueryProperty> {
  QueryBuilder<PodcastStats, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PodcastStats, DateTime?, QQueryOperations>
      lastCheckedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastCheckedAt');
    });
  }

  QueryBuilder<PodcastStats, DateTime?, QQueryOperations>
      subscribedDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subscribedDate');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPodcastViewStatsCollection on Isar {
  IsarCollection<PodcastViewStats> get podcastViewStats => this.collection();
}

const PodcastViewStatsSchema = CollectionSchema(
  name: r'PodcastViewStats',
  id: -6481807344989111892,
  properties: {
    r'ascend': PropertySchema(
      id: 0,
      name: r'ascend',
      type: IsarType.bool,
    ),
    r'ascendSeasonEpisodes': PropertySchema(
      id: 1,
      name: r'ascendSeasonEpisodes',
      type: IsarType.bool,
    ),
    r'viewMode': PropertySchema(
      id: 2,
      name: r'viewMode',
      type: IsarType.byte,
      enumMap: _PodcastViewStatsviewModeEnumValueMap,
    )
  },
  estimateSize: _podcastViewStatsEstimateSize,
  serialize: _podcastViewStatsSerialize,
  deserialize: _podcastViewStatsDeserialize,
  deserializeProp: _podcastViewStatsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _podcastViewStatsGetId,
  getLinks: _podcastViewStatsGetLinks,
  attach: _podcastViewStatsAttach,
  version: '3.1.0+1',
);

int _podcastViewStatsEstimateSize(
  PodcastViewStats object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _podcastViewStatsSerialize(
  PodcastViewStats object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.ascend);
  writer.writeBool(offsets[1], object.ascendSeasonEpisodes);
  writer.writeByte(offsets[2], object.viewMode.index);
}

PodcastViewStats _podcastViewStatsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PodcastViewStats(
    ascend: reader.readBoolOrNull(offsets[0]) ?? false,
    ascendSeasonEpisodes: reader.readBoolOrNull(offsets[1]) ?? true,
    id: id,
    viewMode: _PodcastViewStatsviewModeValueEnumMap[
            reader.readByteOrNull(offsets[2])] ??
        PodcastDetailViewMode.seasons,
  );
  return object;
}

P _podcastViewStatsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 1:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 2:
      return (_PodcastViewStatsviewModeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          PodcastDetailViewMode.seasons) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PodcastViewStatsviewModeEnumValueMap = {
  'episodes': 0,
  'seasons': 1,
  'played': 2,
  'unplayed': 3,
  'downloaded': 4,
};
const _PodcastViewStatsviewModeValueEnumMap = {
  0: PodcastDetailViewMode.episodes,
  1: PodcastDetailViewMode.seasons,
  2: PodcastDetailViewMode.played,
  3: PodcastDetailViewMode.unplayed,
  4: PodcastDetailViewMode.downloaded,
};

Id _podcastViewStatsGetId(PodcastViewStats object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _podcastViewStatsGetLinks(PodcastViewStats object) {
  return [];
}

void _podcastViewStatsAttach(
    IsarCollection<dynamic> col, Id id, PodcastViewStats object) {}

extension PodcastViewStatsQueryWhereSort
    on QueryBuilder<PodcastViewStats, PodcastViewStats, QWhere> {
  QueryBuilder<PodcastViewStats, PodcastViewStats, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PodcastViewStatsQueryWhere
    on QueryBuilder<PodcastViewStats, PodcastViewStats, QWhereClause> {
  QueryBuilder<PodcastViewStats, PodcastViewStats, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PodcastViewStats, PodcastViewStats, QAfterWhereClause>
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

  QueryBuilder<PodcastViewStats, PodcastViewStats, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PodcastViewStats, PodcastViewStats, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PodcastViewStats, PodcastViewStats, QAfterWhereClause> idBetween(
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

extension PodcastViewStatsQueryFilter
    on QueryBuilder<PodcastViewStats, PodcastViewStats, QFilterCondition> {
  QueryBuilder<PodcastViewStats, PodcastViewStats, QAfterFilterCondition>
      ascendEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ascend',
        value: value,
      ));
    });
  }

  QueryBuilder<PodcastViewStats, PodcastViewStats, QAfterFilterCondition>
      ascendSeasonEpisodesEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ascendSeasonEpisodes',
        value: value,
      ));
    });
  }

  QueryBuilder<PodcastViewStats, PodcastViewStats, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PodcastViewStats, PodcastViewStats, QAfterFilterCondition>
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

  QueryBuilder<PodcastViewStats, PodcastViewStats, QAfterFilterCondition>
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

  QueryBuilder<PodcastViewStats, PodcastViewStats, QAfterFilterCondition>
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

  QueryBuilder<PodcastViewStats, PodcastViewStats, QAfterFilterCondition>
      viewModeEqualTo(PodcastDetailViewMode value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'viewMode',
        value: value,
      ));
    });
  }

  QueryBuilder<PodcastViewStats, PodcastViewStats, QAfterFilterCondition>
      viewModeGreaterThan(
    PodcastDetailViewMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'viewMode',
        value: value,
      ));
    });
  }

  QueryBuilder<PodcastViewStats, PodcastViewStats, QAfterFilterCondition>
      viewModeLessThan(
    PodcastDetailViewMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'viewMode',
        value: value,
      ));
    });
  }

  QueryBuilder<PodcastViewStats, PodcastViewStats, QAfterFilterCondition>
      viewModeBetween(
    PodcastDetailViewMode lower,
    PodcastDetailViewMode upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'viewMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PodcastViewStatsQueryObject
    on QueryBuilder<PodcastViewStats, PodcastViewStats, QFilterCondition> {}

extension PodcastViewStatsQueryLinks
    on QueryBuilder<PodcastViewStats, PodcastViewStats, QFilterCondition> {}

extension PodcastViewStatsQuerySortBy
    on QueryBuilder<PodcastViewStats, PodcastViewStats, QSortBy> {
  QueryBuilder<PodcastViewStats, PodcastViewStats, QAfterSortBy>
      sortByAscend() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ascend', Sort.asc);
    });
  }

  QueryBuilder<PodcastViewStats, PodcastViewStats, QAfterSortBy>
      sortByAscendDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ascend', Sort.desc);
    });
  }

  QueryBuilder<PodcastViewStats, PodcastViewStats, QAfterSortBy>
      sortByAscendSeasonEpisodes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ascendSeasonEpisodes', Sort.asc);
    });
  }

  QueryBuilder<PodcastViewStats, PodcastViewStats, QAfterSortBy>
      sortByAscendSeasonEpisodesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ascendSeasonEpisodes', Sort.desc);
    });
  }

  QueryBuilder<PodcastViewStats, PodcastViewStats, QAfterSortBy>
      sortByViewMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.asc);
    });
  }

  QueryBuilder<PodcastViewStats, PodcastViewStats, QAfterSortBy>
      sortByViewModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.desc);
    });
  }
}

extension PodcastViewStatsQuerySortThenBy
    on QueryBuilder<PodcastViewStats, PodcastViewStats, QSortThenBy> {
  QueryBuilder<PodcastViewStats, PodcastViewStats, QAfterSortBy>
      thenByAscend() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ascend', Sort.asc);
    });
  }

  QueryBuilder<PodcastViewStats, PodcastViewStats, QAfterSortBy>
      thenByAscendDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ascend', Sort.desc);
    });
  }

  QueryBuilder<PodcastViewStats, PodcastViewStats, QAfterSortBy>
      thenByAscendSeasonEpisodes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ascendSeasonEpisodes', Sort.asc);
    });
  }

  QueryBuilder<PodcastViewStats, PodcastViewStats, QAfterSortBy>
      thenByAscendSeasonEpisodesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ascendSeasonEpisodes', Sort.desc);
    });
  }

  QueryBuilder<PodcastViewStats, PodcastViewStats, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PodcastViewStats, PodcastViewStats, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PodcastViewStats, PodcastViewStats, QAfterSortBy>
      thenByViewMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.asc);
    });
  }

  QueryBuilder<PodcastViewStats, PodcastViewStats, QAfterSortBy>
      thenByViewModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.desc);
    });
  }
}

extension PodcastViewStatsQueryWhereDistinct
    on QueryBuilder<PodcastViewStats, PodcastViewStats, QDistinct> {
  QueryBuilder<PodcastViewStats, PodcastViewStats, QDistinct>
      distinctByAscend() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ascend');
    });
  }

  QueryBuilder<PodcastViewStats, PodcastViewStats, QDistinct>
      distinctByAscendSeasonEpisodes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ascendSeasonEpisodes');
    });
  }

  QueryBuilder<PodcastViewStats, PodcastViewStats, QDistinct>
      distinctByViewMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'viewMode');
    });
  }
}

extension PodcastViewStatsQueryProperty
    on QueryBuilder<PodcastViewStats, PodcastViewStats, QQueryProperty> {
  QueryBuilder<PodcastViewStats, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PodcastViewStats, bool, QQueryOperations> ascendProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ascend');
    });
  }

  QueryBuilder<PodcastViewStats, bool, QQueryOperations>
      ascendSeasonEpisodesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ascendSeasonEpisodes');
    });
  }

  QueryBuilder<PodcastViewStats, PodcastDetailViewMode, QQueryOperations>
      viewModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'viewMode');
    });
  }
}
