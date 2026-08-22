// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_activity_log_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAiActivityLogEntityCollection on Isar {
  IsarCollection<AiActivityLogEntity> get aiActivityLogEntitys =>
      this.collection();
}

const AiActivityLogEntitySchema = CollectionSchema(
  name: r'AiActivityLogEntity',
  id: -2165516249351818812,
  properties: {
    r'dataCategoriesSent': PropertySchema(
      id: 0,
      name: r'dataCategoriesSent',
      type: IsarType.stringList,
    ),
    r'errorState': PropertySchema(
      id: 1,
      name: r'errorState',
      type: IsarType.string,
    ),
    r'featureUsed': PropertySchema(
      id: 2,
      name: r'featureUsed',
      type: IsarType.string,
    ),
    r'resultSummary': PropertySchema(
      id: 3,
      name: r'resultSummary',
      type: IsarType.string,
    ),
    r'sanitizedPayloadSummary': PropertySchema(
      id: 4,
      name: r'sanitizedPayloadSummary',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 5,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
    r'userAccepted': PropertySchema(
      id: 6,
      name: r'userAccepted',
      type: IsarType.bool,
    ),
    r'uuid': PropertySchema(id: 7, name: r'uuid', type: IsarType.string),
  },
  estimateSize: _aiActivityLogEntityEstimateSize,
  serialize: _aiActivityLogEntitySerialize,
  deserialize: _aiActivityLogEntityDeserialize,
  deserializeProp: _aiActivityLogEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'uuid': IndexSchema(
      id: 2134397340427724972,
      name: r'uuid',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'uuid',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'timestamp': IndexSchema(
      id: 1852253767416892198,
      name: r'timestamp',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'timestamp',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _aiActivityLogEntityGetId,
  getLinks: _aiActivityLogEntityGetLinks,
  attach: _aiActivityLogEntityAttach,
  version: '3.1.0+1',
);

int _aiActivityLogEntityEstimateSize(
  AiActivityLogEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.dataCategoriesSent.length * 3;
  {
    for (var i = 0; i < object.dataCategoriesSent.length; i++) {
      final value = object.dataCategoriesSent[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.errorState;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.featureUsed.length * 3;
  bytesCount += 3 + object.resultSummary.length * 3;
  bytesCount += 3 + object.sanitizedPayloadSummary.length * 3;
  bytesCount += 3 + object.uuid.length * 3;
  return bytesCount;
}

void _aiActivityLogEntitySerialize(
  AiActivityLogEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.dataCategoriesSent);
  writer.writeString(offsets[1], object.errorState);
  writer.writeString(offsets[2], object.featureUsed);
  writer.writeString(offsets[3], object.resultSummary);
  writer.writeString(offsets[4], object.sanitizedPayloadSummary);
  writer.writeDateTime(offsets[5], object.timestamp);
  writer.writeBool(offsets[6], object.userAccepted);
  writer.writeString(offsets[7], object.uuid);
}

AiActivityLogEntity _aiActivityLogEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AiActivityLogEntity();
  object.dataCategoriesSent = reader.readStringList(offsets[0]) ?? [];
  object.errorState = reader.readStringOrNull(offsets[1]);
  object.featureUsed = reader.readString(offsets[2]);
  object.id = id;
  object.resultSummary = reader.readString(offsets[3]);
  object.sanitizedPayloadSummary = reader.readString(offsets[4]);
  object.timestamp = reader.readDateTime(offsets[5]);
  object.userAccepted = reader.readBoolOrNull(offsets[6]);
  object.uuid = reader.readString(offsets[7]);
  return object;
}

P _aiActivityLogEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readBoolOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _aiActivityLogEntityGetId(AiActivityLogEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _aiActivityLogEntityGetLinks(
  AiActivityLogEntity object,
) {
  return [];
}

void _aiActivityLogEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  AiActivityLogEntity object,
) {
  object.id = id;
}

extension AiActivityLogEntityByIndex on IsarCollection<AiActivityLogEntity> {
  Future<AiActivityLogEntity?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  AiActivityLogEntity? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<AiActivityLogEntity?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<AiActivityLogEntity?> getAllByUuidSync(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uuid', values);
  }

  Future<int> deleteAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uuid', values);
  }

  int deleteAllByUuidSync(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uuid', values);
  }

  Future<Id> putByUuid(AiActivityLogEntity object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(AiActivityLogEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<AiActivityLogEntity> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(
    List<AiActivityLogEntity> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }
}

extension AiActivityLogEntityQueryWhereSort
    on QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QWhere> {
  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterWhere>
  anyTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'timestamp'),
      );
    });
  }
}

extension AiActivityLogEntityQueryWhere
    on QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QWhereClause> {
  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterWhereClause>
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

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterWhereClause>
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

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterWhereClause>
  uuidEqualTo(String uuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'uuid', value: [uuid]),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterWhereClause>
  uuidNotEqualTo(String uuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uuid',
                lower: [],
                upper: [uuid],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uuid',
                lower: [uuid],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uuid',
                lower: [uuid],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uuid',
                lower: [],
                upper: [uuid],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterWhereClause>
  timestampEqualTo(DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'timestamp', value: [timestamp]),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterWhereClause>
  timestampNotEqualTo(DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'timestamp',
                lower: [],
                upper: [timestamp],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'timestamp',
                lower: [timestamp],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'timestamp',
                lower: [timestamp],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'timestamp',
                lower: [],
                upper: [timestamp],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterWhereClause>
  timestampGreaterThan(DateTime timestamp, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'timestamp',
          lower: [timestamp],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterWhereClause>
  timestampLessThan(DateTime timestamp, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'timestamp',
          lower: [],
          upper: [timestamp],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterWhereClause>
  timestampBetween(
    DateTime lowerTimestamp,
    DateTime upperTimestamp, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'timestamp',
          lower: [lowerTimestamp],
          includeLower: includeLower,
          upper: [upperTimestamp],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension AiActivityLogEntityQueryFilter
    on
        QueryBuilder<
          AiActivityLogEntity,
          AiActivityLogEntity,
          QFilterCondition
        > {
  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  dataCategoriesSentElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'dataCategoriesSent',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  dataCategoriesSentElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dataCategoriesSent',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  dataCategoriesSentElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dataCategoriesSent',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  dataCategoriesSentElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dataCategoriesSent',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  dataCategoriesSentElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'dataCategoriesSent',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  dataCategoriesSentElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'dataCategoriesSent',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  dataCategoriesSentElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'dataCategoriesSent',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  dataCategoriesSentElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'dataCategoriesSent',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  dataCategoriesSentElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dataCategoriesSent', value: ''),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  dataCategoriesSentElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'dataCategoriesSent', value: ''),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  dataCategoriesSentLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dataCategoriesSent',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  dataCategoriesSentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'dataCategoriesSent', 0, true, 0, true);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  dataCategoriesSentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'dataCategoriesSent', 0, false, 999999, true);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  dataCategoriesSentLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'dataCategoriesSent', 0, true, length, include);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  dataCategoriesSentLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dataCategoriesSent',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  dataCategoriesSentLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dataCategoriesSent',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  errorStateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'errorState'),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  errorStateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'errorState'),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  errorStateEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'errorState',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  errorStateGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'errorState',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  errorStateLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'errorState',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  errorStateBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'errorState',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  errorStateStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'errorState',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  errorStateEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'errorState',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  errorStateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'errorState',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  errorStateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'errorState',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  errorStateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'errorState', value: ''),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  errorStateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'errorState', value: ''),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  featureUsedEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'featureUsed',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  featureUsedGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'featureUsed',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  featureUsedLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'featureUsed',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  featureUsedBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'featureUsed',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  featureUsedStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'featureUsed',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  featureUsedEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'featureUsed',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  featureUsedContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'featureUsed',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  featureUsedMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'featureUsed',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  featureUsedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'featureUsed', value: ''),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  featureUsedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'featureUsed', value: ''),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
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

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
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

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
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

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  resultSummaryEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'resultSummary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  resultSummaryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'resultSummary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  resultSummaryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'resultSummary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  resultSummaryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'resultSummary',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  resultSummaryStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'resultSummary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  resultSummaryEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'resultSummary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  resultSummaryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'resultSummary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  resultSummaryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'resultSummary',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  resultSummaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'resultSummary', value: ''),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  resultSummaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'resultSummary', value: ''),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  sanitizedPayloadSummaryEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sanitizedPayloadSummary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  sanitizedPayloadSummaryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sanitizedPayloadSummary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  sanitizedPayloadSummaryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sanitizedPayloadSummary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  sanitizedPayloadSummaryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sanitizedPayloadSummary',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  sanitizedPayloadSummaryStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sanitizedPayloadSummary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  sanitizedPayloadSummaryEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sanitizedPayloadSummary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  sanitizedPayloadSummaryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sanitizedPayloadSummary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  sanitizedPayloadSummaryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sanitizedPayloadSummary',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  sanitizedPayloadSummaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sanitizedPayloadSummary',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  sanitizedPayloadSummaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'sanitizedPayloadSummary',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timestamp', value: value),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  timestampGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'timestamp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  timestampLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'timestamp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'timestamp',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  userAcceptedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'userAccepted'),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  userAcceptedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'userAccepted'),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  userAcceptedEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'userAccepted', value: value),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  uuidEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  uuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  uuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  uuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'uuid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  uuidStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  uuidEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  uuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  uuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'uuid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'uuid', value: ''),
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterFilterCondition>
  uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'uuid', value: ''),
      );
    });
  }
}

extension AiActivityLogEntityQueryObject
    on
        QueryBuilder<
          AiActivityLogEntity,
          AiActivityLogEntity,
          QFilterCondition
        > {}

extension AiActivityLogEntityQueryLinks
    on
        QueryBuilder<
          AiActivityLogEntity,
          AiActivityLogEntity,
          QFilterCondition
        > {}

extension AiActivityLogEntityQuerySortBy
    on QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QSortBy> {
  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterSortBy>
  sortByErrorState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorState', Sort.asc);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterSortBy>
  sortByErrorStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorState', Sort.desc);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterSortBy>
  sortByFeatureUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'featureUsed', Sort.asc);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterSortBy>
  sortByFeatureUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'featureUsed', Sort.desc);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterSortBy>
  sortByResultSummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resultSummary', Sort.asc);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterSortBy>
  sortByResultSummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resultSummary', Sort.desc);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterSortBy>
  sortBySanitizedPayloadSummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sanitizedPayloadSummary', Sort.asc);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterSortBy>
  sortBySanitizedPayloadSummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sanitizedPayloadSummary', Sort.desc);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterSortBy>
  sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterSortBy>
  sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterSortBy>
  sortByUserAccepted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userAccepted', Sort.asc);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterSortBy>
  sortByUserAcceptedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userAccepted', Sort.desc);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterSortBy>
  sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterSortBy>
  sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension AiActivityLogEntityQuerySortThenBy
    on QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QSortThenBy> {
  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterSortBy>
  thenByErrorState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorState', Sort.asc);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterSortBy>
  thenByErrorStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorState', Sort.desc);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterSortBy>
  thenByFeatureUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'featureUsed', Sort.asc);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterSortBy>
  thenByFeatureUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'featureUsed', Sort.desc);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterSortBy>
  thenByResultSummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resultSummary', Sort.asc);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterSortBy>
  thenByResultSummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resultSummary', Sort.desc);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterSortBy>
  thenBySanitizedPayloadSummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sanitizedPayloadSummary', Sort.asc);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterSortBy>
  thenBySanitizedPayloadSummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sanitizedPayloadSummary', Sort.desc);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterSortBy>
  thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterSortBy>
  thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterSortBy>
  thenByUserAccepted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userAccepted', Sort.asc);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterSortBy>
  thenByUserAcceptedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userAccepted', Sort.desc);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterSortBy>
  thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QAfterSortBy>
  thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension AiActivityLogEntityQueryWhereDistinct
    on QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QDistinct> {
  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QDistinct>
  distinctByDataCategoriesSent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dataCategoriesSent');
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QDistinct>
  distinctByErrorState({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'errorState', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QDistinct>
  distinctByFeatureUsed({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'featureUsed', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QDistinct>
  distinctByResultSummary({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'resultSummary',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QDistinct>
  distinctBySanitizedPayloadSummary({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'sanitizedPayloadSummary',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QDistinct>
  distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QDistinct>
  distinctByUserAccepted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userAccepted');
    });
  }

  QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QDistinct>
  distinctByUuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }
}

extension AiActivityLogEntityQueryProperty
    on QueryBuilder<AiActivityLogEntity, AiActivityLogEntity, QQueryProperty> {
  QueryBuilder<AiActivityLogEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AiActivityLogEntity, List<String>, QQueryOperations>
  dataCategoriesSentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataCategoriesSent');
    });
  }

  QueryBuilder<AiActivityLogEntity, String?, QQueryOperations>
  errorStateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'errorState');
    });
  }

  QueryBuilder<AiActivityLogEntity, String, QQueryOperations>
  featureUsedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'featureUsed');
    });
  }

  QueryBuilder<AiActivityLogEntity, String, QQueryOperations>
  resultSummaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'resultSummary');
    });
  }

  QueryBuilder<AiActivityLogEntity, String, QQueryOperations>
  sanitizedPayloadSummaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sanitizedPayloadSummary');
    });
  }

  QueryBuilder<AiActivityLogEntity, DateTime, QQueryOperations>
  timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<AiActivityLogEntity, bool?, QQueryOperations>
  userAcceptedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userAccepted');
    });
  }

  QueryBuilder<AiActivityLogEntity, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }
}
