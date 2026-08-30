// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'money_record_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMoneyRecordEntityCollection on Isar {
  IsarCollection<MoneyRecordEntity> get moneyRecordEntitys => this.collection();
}

const MoneyRecordEntitySchema = CollectionSchema(
  name: r'MoneyRecordEntity',
  id: -8228148273932252229,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'dueDate': PropertySchema(
      id: 1,
      name: r'dueDate',
      type: IsarType.dateTime,
    ),
    r'isCustomSeparateObligation': PropertySchema(
      id: 2,
      name: r'isCustomSeparateObligation',
      type: IsarType.bool,
    ),
    r'isReminderEnabled': PropertySchema(
      id: 3,
      name: r'isReminderEnabled',
      type: IsarType.bool,
    ),
    r'normalizedPersonName': PropertySchema(
      id: 4,
      name: r'normalizedPersonName',
      type: IsarType.string,
    ),
    r'notes': PropertySchema(id: 5, name: r'notes', type: IsarType.string),
    r'originTransactionId': PropertySchema(
      id: 6,
      name: r'originTransactionId',
      type: IsarType.string,
    ),
    r'originalAmount': PropertySchema(
      id: 7,
      name: r'originalAmount',
      type: IsarType.double,
    ),
    r'personName': PropertySchema(
      id: 8,
      name: r'personName',
      type: IsarType.string,
    ),
    r'reminderDaysBefore': PropertySchema(
      id: 9,
      name: r'reminderDaysBefore',
      type: IsarType.long,
    ),
    r'settledAt': PropertySchema(
      id: 10,
      name: r'settledAt',
      type: IsarType.dateTime,
    ),
    r'status': PropertySchema(id: 11, name: r'status', type: IsarType.string),
    r'transactionDate': PropertySchema(
      id: 12,
      name: r'transactionDate',
      type: IsarType.dateTime,
    ),
    r'type': PropertySchema(id: 13, name: r'type', type: IsarType.string),
    r'updatedAt': PropertySchema(
      id: 14,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'userId': PropertySchema(id: 15, name: r'userId', type: IsarType.string),
    r'uuid': PropertySchema(id: 16, name: r'uuid', type: IsarType.string),
  },
  estimateSize: _moneyRecordEntityEstimateSize,
  serialize: _moneyRecordEntitySerialize,
  deserialize: _moneyRecordEntityDeserialize,
  deserializeProp: _moneyRecordEntityDeserializeProp,
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
    r'userId': IndexSchema(
      id: -2005826577402374815,
      name: r'userId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'type': IndexSchema(
      id: 5117122708147080838,
      name: r'type',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'type',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'personName': IndexSchema(
      id: 1248926044822021493,
      name: r'personName',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'personName',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'normalizedPersonName': IndexSchema(
      id: 4435071431045847272,
      name: r'normalizedPersonName',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'normalizedPersonName',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'transactionDate': IndexSchema(
      id: 3386085016894654755,
      name: r'transactionDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'transactionDate',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'dueDate': IndexSchema(
      id: -7871003637559820552,
      name: r'dueDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'dueDate',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'settledAt': IndexSchema(
      id: -8752221925073050752,
      name: r'settledAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'settledAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'status': IndexSchema(
      id: -107785170620420283,
      name: r'status',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'status',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'originTransactionId': IndexSchema(
      id: -7936780316081175059,
      name: r'originTransactionId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'originTransactionId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'isCustomSeparateObligation': IndexSchema(
      id: -3255281153115788202,
      name: r'isCustomSeparateObligation',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isCustomSeparateObligation',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _moneyRecordEntityGetId,
  getLinks: _moneyRecordEntityGetLinks,
  attach: _moneyRecordEntityAttach,
  version: '3.1.0+1',
);

int _moneyRecordEntityEstimateSize(
  MoneyRecordEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.normalizedPersonName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.originTransactionId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.personName.length * 3;
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.type.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  bytesCount += 3 + object.uuid.length * 3;
  return bytesCount;
}

void _moneyRecordEntitySerialize(
  MoneyRecordEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeDateTime(offsets[1], object.dueDate);
  writer.writeBool(offsets[2], object.isCustomSeparateObligation);
  writer.writeBool(offsets[3], object.isReminderEnabled);
  writer.writeString(offsets[4], object.normalizedPersonName);
  writer.writeString(offsets[5], object.notes);
  writer.writeString(offsets[6], object.originTransactionId);
  writer.writeDouble(offsets[7], object.originalAmount);
  writer.writeString(offsets[8], object.personName);
  writer.writeLong(offsets[9], object.reminderDaysBefore);
  writer.writeDateTime(offsets[10], object.settledAt);
  writer.writeString(offsets[11], object.status);
  writer.writeDateTime(offsets[12], object.transactionDate);
  writer.writeString(offsets[13], object.type);
  writer.writeDateTime(offsets[14], object.updatedAt);
  writer.writeString(offsets[15], object.userId);
  writer.writeString(offsets[16], object.uuid);
}

MoneyRecordEntity _moneyRecordEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MoneyRecordEntity();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.dueDate = reader.readDateTime(offsets[1]);
  object.id = id;
  object.isCustomSeparateObligation = reader.readBool(offsets[2]);
  object.isReminderEnabled = reader.readBool(offsets[3]);
  object.normalizedPersonName = reader.readStringOrNull(offsets[4]);
  object.notes = reader.readStringOrNull(offsets[5]);
  object.originTransactionId = reader.readStringOrNull(offsets[6]);
  object.originalAmount = reader.readDouble(offsets[7]);
  object.personName = reader.readString(offsets[8]);
  object.reminderDaysBefore = reader.readLong(offsets[9]);
  object.settledAt = reader.readDateTimeOrNull(offsets[10]);
  object.status = reader.readString(offsets[11]);
  object.transactionDate = reader.readDateTime(offsets[12]);
  object.type = reader.readString(offsets[13]);
  object.updatedAt = reader.readDateTime(offsets[14]);
  object.userId = reader.readString(offsets[15]);
  object.uuid = reader.readString(offsets[16]);
  return object;
}

P _moneyRecordEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readDateTime(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readDateTime(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _moneyRecordEntityGetId(MoneyRecordEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _moneyRecordEntityGetLinks(
  MoneyRecordEntity object,
) {
  return [];
}

void _moneyRecordEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  MoneyRecordEntity object,
) {
  object.id = id;
}

extension MoneyRecordEntityByIndex on IsarCollection<MoneyRecordEntity> {
  Future<MoneyRecordEntity?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  MoneyRecordEntity? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<MoneyRecordEntity?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<MoneyRecordEntity?> getAllByUuidSync(List<String> uuidValues) {
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

  Future<Id> putByUuid(MoneyRecordEntity object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(MoneyRecordEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<MoneyRecordEntity> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(
    List<MoneyRecordEntity> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }
}

extension MoneyRecordEntityQueryWhereSort
    on QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QWhere> {
  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhere>
  anyTransactionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'transactionDate'),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhere> anyDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'dueDate'),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhere>
  anySettledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'settledAt'),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhere>
  anyIsCustomSeparateObligation() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isCustomSeparateObligation'),
      );
    });
  }
}

extension MoneyRecordEntityQueryWhere
    on QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QWhereClause> {
  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
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

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
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

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  uuidEqualTo(String uuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'uuid', value: [uuid]),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
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

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'userId', value: [userId]),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  userIdNotEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'userId',
                lower: [],
                upper: [userId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'userId',
                lower: [userId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'userId',
                lower: [userId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'userId',
                lower: [],
                upper: [userId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  typeEqualTo(String type) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'type', value: [type]),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  typeNotEqualTo(String type) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'type',
                lower: [],
                upper: [type],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'type',
                lower: [type],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'type',
                lower: [type],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'type',
                lower: [],
                upper: [type],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  personNameEqualTo(String personName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'personName', value: [personName]),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  personNameNotEqualTo(String personName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'personName',
                lower: [],
                upper: [personName],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'personName',
                lower: [personName],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'personName',
                lower: [personName],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'personName',
                lower: [],
                upper: [personName],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  normalizedPersonNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'normalizedPersonName',
          value: [null],
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  normalizedPersonNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'normalizedPersonName',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  normalizedPersonNameEqualTo(String? normalizedPersonName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'normalizedPersonName',
          value: [normalizedPersonName],
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  normalizedPersonNameNotEqualTo(String? normalizedPersonName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'normalizedPersonName',
                lower: [],
                upper: [normalizedPersonName],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'normalizedPersonName',
                lower: [normalizedPersonName],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'normalizedPersonName',
                lower: [normalizedPersonName],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'normalizedPersonName',
                lower: [],
                upper: [normalizedPersonName],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  transactionDateEqualTo(DateTime transactionDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'transactionDate',
          value: [transactionDate],
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  transactionDateNotEqualTo(DateTime transactionDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'transactionDate',
                lower: [],
                upper: [transactionDate],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'transactionDate',
                lower: [transactionDate],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'transactionDate',
                lower: [transactionDate],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'transactionDate',
                lower: [],
                upper: [transactionDate],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  transactionDateGreaterThan(DateTime transactionDate, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'transactionDate',
          lower: [transactionDate],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  transactionDateLessThan(DateTime transactionDate, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'transactionDate',
          lower: [],
          upper: [transactionDate],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  transactionDateBetween(
    DateTime lowerTransactionDate,
    DateTime upperTransactionDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'transactionDate',
          lower: [lowerTransactionDate],
          includeLower: includeLower,
          upper: [upperTransactionDate],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  dueDateEqualTo(DateTime dueDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'dueDate', value: [dueDate]),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  dueDateNotEqualTo(DateTime dueDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'dueDate',
                lower: [],
                upper: [dueDate],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'dueDate',
                lower: [dueDate],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'dueDate',
                lower: [dueDate],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'dueDate',
                lower: [],
                upper: [dueDate],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  dueDateGreaterThan(DateTime dueDate, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'dueDate',
          lower: [dueDate],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  dueDateLessThan(DateTime dueDate, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'dueDate',
          lower: [],
          upper: [dueDate],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  dueDateBetween(
    DateTime lowerDueDate,
    DateTime upperDueDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'dueDate',
          lower: [lowerDueDate],
          includeLower: includeLower,
          upper: [upperDueDate],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  settledAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'settledAt', value: [null]),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  settledAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'settledAt',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  settledAtEqualTo(DateTime? settledAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'settledAt', value: [settledAt]),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  settledAtNotEqualTo(DateTime? settledAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'settledAt',
                lower: [],
                upper: [settledAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'settledAt',
                lower: [settledAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'settledAt',
                lower: [settledAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'settledAt',
                lower: [],
                upper: [settledAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  settledAtGreaterThan(DateTime? settledAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'settledAt',
          lower: [settledAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  settledAtLessThan(DateTime? settledAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'settledAt',
          lower: [],
          upper: [settledAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  settledAtBetween(
    DateTime? lowerSettledAt,
    DateTime? upperSettledAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'settledAt',
          lower: [lowerSettledAt],
          includeLower: includeLower,
          upper: [upperSettledAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  statusEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'status', value: [status]),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  statusNotEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'status',
                lower: [],
                upper: [status],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'status',
                lower: [status],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'status',
                lower: [status],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'status',
                lower: [],
                upper: [status],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  originTransactionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'originTransactionId',
          value: [null],
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  originTransactionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'originTransactionId',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  originTransactionIdEqualTo(String? originTransactionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'originTransactionId',
          value: [originTransactionId],
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  originTransactionIdNotEqualTo(String? originTransactionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'originTransactionId',
                lower: [],
                upper: [originTransactionId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'originTransactionId',
                lower: [originTransactionId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'originTransactionId',
                lower: [originTransactionId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'originTransactionId',
                lower: [],
                upper: [originTransactionId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  isCustomSeparateObligationEqualTo(bool isCustomSeparateObligation) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'isCustomSeparateObligation',
          value: [isCustomSeparateObligation],
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterWhereClause>
  isCustomSeparateObligationNotEqualTo(bool isCustomSeparateObligation) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isCustomSeparateObligation',
                lower: [],
                upper: [isCustomSeparateObligation],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isCustomSeparateObligation',
                lower: [isCustomSeparateObligation],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isCustomSeparateObligation',
                lower: [isCustomSeparateObligation],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isCustomSeparateObligation',
                lower: [],
                upper: [isCustomSeparateObligation],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension MoneyRecordEntityQueryFilter
    on QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QFilterCondition> {
  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
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

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
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

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  createdAtBetween(
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

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  dueDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dueDate', value: value),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  dueDateGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dueDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  dueDateLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dueDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  dueDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dueDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  isCustomSeparateObligationEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'isCustomSeparateObligation',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  isReminderEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isReminderEnabled', value: value),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  normalizedPersonNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'normalizedPersonName'),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  normalizedPersonNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'normalizedPersonName'),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  normalizedPersonNameEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'normalizedPersonName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  normalizedPersonNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'normalizedPersonName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  normalizedPersonNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'normalizedPersonName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  normalizedPersonNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'normalizedPersonName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  normalizedPersonNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'normalizedPersonName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  normalizedPersonNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'normalizedPersonName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  normalizedPersonNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'normalizedPersonName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  normalizedPersonNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'normalizedPersonName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  normalizedPersonNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'normalizedPersonName', value: ''),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  normalizedPersonNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'normalizedPersonName',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  notesEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'notes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  notesStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  notesEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'notes',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  originTransactionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'originTransactionId'),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  originTransactionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'originTransactionId'),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  originTransactionIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'originTransactionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  originTransactionIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'originTransactionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  originTransactionIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'originTransactionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  originTransactionIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'originTransactionId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  originTransactionIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'originTransactionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  originTransactionIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'originTransactionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  originTransactionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'originTransactionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  originTransactionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'originTransactionId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  originTransactionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'originTransactionId', value: ''),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  originTransactionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'originTransactionId',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  originalAmountEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'originalAmount',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  originalAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'originalAmount',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  originalAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'originalAmount',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  originalAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'originalAmount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  personNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'personName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  personNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'personName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  personNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'personName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  personNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'personName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  personNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'personName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  personNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'personName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  personNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'personName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  personNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'personName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  personNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'personName', value: ''),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  personNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'personName', value: ''),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  reminderDaysBeforeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'reminderDaysBefore', value: value),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  reminderDaysBeforeGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'reminderDaysBefore',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  reminderDaysBeforeLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'reminderDaysBefore',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  reminderDaysBeforeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'reminderDaysBefore',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  settledAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'settledAt'),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  settledAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'settledAt'),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  settledAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'settledAt', value: value),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  settledAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'settledAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  settledAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'settledAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  settledAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'settledAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  statusEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'status',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  statusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  statusEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'status',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  transactionDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'transactionDate', value: value),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  transactionDateGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'transactionDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  transactionDateLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'transactionDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  transactionDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'transactionDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  typeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  typeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  typeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  typeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'type',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  typeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  typeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'type',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'type', value: ''),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'type', value: ''),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime value, {bool include = false}) {
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

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  updatedAtLessThan(DateTime value, {bool include = false}) {
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

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  updatedAtBetween(
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

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  userIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'userId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  userIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'userId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  userIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'userId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  userIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'userId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  userIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'userId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  userIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'userId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'userId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'userId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'userId', value: ''),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'userId', value: ''),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
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

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'uuid', value: ''),
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterFilterCondition>
  uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'uuid', value: ''),
      );
    });
  }
}

extension MoneyRecordEntityQueryObject
    on QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QFilterCondition> {}

extension MoneyRecordEntityQueryLinks
    on QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QFilterCondition> {}

extension MoneyRecordEntityQuerySortBy
    on QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QSortBy> {
  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortByDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortByIsCustomSeparateObligation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCustomSeparateObligation', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortByIsCustomSeparateObligationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCustomSeparateObligation', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortByIsReminderEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReminderEnabled', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortByIsReminderEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReminderEnabled', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortByNormalizedPersonName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedPersonName', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortByNormalizedPersonNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedPersonName', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortByOriginTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originTransactionId', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortByOriginTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originTransactionId', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortByOriginalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalAmount', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortByOriginalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalAmount', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortByPersonName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personName', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortByPersonNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personName', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortByReminderDaysBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderDaysBefore', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortByReminderDaysBeforeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderDaysBefore', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortBySettledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settledAt', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortBySettledAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settledAt', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortByTransactionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionDate', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortByTransactionDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionDate', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension MoneyRecordEntityQuerySortThenBy
    on QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QSortThenBy> {
  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByIsCustomSeparateObligation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCustomSeparateObligation', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByIsCustomSeparateObligationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCustomSeparateObligation', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByIsReminderEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReminderEnabled', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByIsReminderEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReminderEnabled', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByNormalizedPersonName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedPersonName', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByNormalizedPersonNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedPersonName', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByOriginTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originTransactionId', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByOriginTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originTransactionId', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByOriginalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalAmount', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByOriginalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalAmount', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByPersonName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personName', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByPersonNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personName', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByReminderDaysBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderDaysBefore', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByReminderDaysBeforeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderDaysBefore', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenBySettledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settledAt', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenBySettledAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settledAt', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByTransactionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionDate', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByTransactionDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionDate', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QAfterSortBy>
  thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension MoneyRecordEntityQueryWhereDistinct
    on QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QDistinct> {
  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QDistinct>
  distinctByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dueDate');
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QDistinct>
  distinctByIsCustomSeparateObligation() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCustomSeparateObligation');
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QDistinct>
  distinctByIsReminderEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isReminderEnabled');
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QDistinct>
  distinctByNormalizedPersonName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'normalizedPersonName',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QDistinct>
  distinctByNotes({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QDistinct>
  distinctByOriginTransactionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'originTransactionId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QDistinct>
  distinctByOriginalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'originalAmount');
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QDistinct>
  distinctByPersonName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'personName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QDistinct>
  distinctByReminderDaysBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reminderDaysBefore');
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QDistinct>
  distinctBySettledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'settledAt');
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QDistinct>
  distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QDistinct>
  distinctByTransactionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'transactionDate');
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QDistinct> distinctByType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QDistinct>
  distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QDistinct> distinctByUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }
}

extension MoneyRecordEntityQueryProperty
    on QueryBuilder<MoneyRecordEntity, MoneyRecordEntity, QQueryProperty> {
  QueryBuilder<MoneyRecordEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MoneyRecordEntity, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<MoneyRecordEntity, DateTime, QQueryOperations>
  dueDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dueDate');
    });
  }

  QueryBuilder<MoneyRecordEntity, bool, QQueryOperations>
  isCustomSeparateObligationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCustomSeparateObligation');
    });
  }

  QueryBuilder<MoneyRecordEntity, bool, QQueryOperations>
  isReminderEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isReminderEnabled');
    });
  }

  QueryBuilder<MoneyRecordEntity, String?, QQueryOperations>
  normalizedPersonNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'normalizedPersonName');
    });
  }

  QueryBuilder<MoneyRecordEntity, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<MoneyRecordEntity, String?, QQueryOperations>
  originTransactionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'originTransactionId');
    });
  }

  QueryBuilder<MoneyRecordEntity, double, QQueryOperations>
  originalAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'originalAmount');
    });
  }

  QueryBuilder<MoneyRecordEntity, String, QQueryOperations>
  personNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'personName');
    });
  }

  QueryBuilder<MoneyRecordEntity, int, QQueryOperations>
  reminderDaysBeforeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderDaysBefore');
    });
  }

  QueryBuilder<MoneyRecordEntity, DateTime?, QQueryOperations>
  settledAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'settledAt');
    });
  }

  QueryBuilder<MoneyRecordEntity, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<MoneyRecordEntity, DateTime, QQueryOperations>
  transactionDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'transactionDate');
    });
  }

  QueryBuilder<MoneyRecordEntity, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<MoneyRecordEntity, DateTime, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<MoneyRecordEntity, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }

  QueryBuilder<MoneyRecordEntity, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }
}
