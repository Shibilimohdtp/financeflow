// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSubscriptionEntityCollection on Isar {
  IsarCollection<SubscriptionEntity> get subscriptionEntitys =>
      this.collection();
}

const SubscriptionEntitySchema = CollectionSchema(
  name: r'SubscriptionEntity',
  id: 7454646760815216241,
  properties: {
    r'accountId': PropertySchema(
      id: 0,
      name: r'accountId',
      type: IsarType.string,
    ),
    r'amount': PropertySchema(id: 1, name: r'amount', type: IsarType.double),
    r'billingFrequency': PropertySchema(
      id: 2,
      name: r'billingFrequency',
      type: IsarType.string,
    ),
    r'category': PropertySchema(
      id: 3,
      name: r'category',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 4,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currency': PropertySchema(
      id: 5,
      name: r'currency',
      type: IsarType.string,
    ),
    r'isReminderEnabled': PropertySchema(
      id: 6,
      name: r'isReminderEnabled',
      type: IsarType.bool,
    ),
    r'lastPaymentDate': PropertySchema(
      id: 7,
      name: r'lastPaymentDate',
      type: IsarType.dateTime,
    ),
    r'merchant': PropertySchema(
      id: 8,
      name: r'merchant',
      type: IsarType.string,
    ),
    r'nextRenewalDate': PropertySchema(
      id: 9,
      name: r'nextRenewalDate',
      type: IsarType.dateTime,
    ),
    r'normalizedMerchant': PropertySchema(
      id: 10,
      name: r'normalizedMerchant',
      type: IsarType.string,
    ),
    r'notes': PropertySchema(id: 11, name: r'notes', type: IsarType.string),
    r'paymentMethod': PropertySchema(
      id: 12,
      name: r'paymentMethod',
      type: IsarType.string,
    ),
    r'reminderDaysBefore': PropertySchema(
      id: 13,
      name: r'reminderDaysBefore',
      type: IsarType.long,
    ),
    r'sourceTransactionId': PropertySchema(
      id: 14,
      name: r'sourceTransactionId',
      type: IsarType.string,
    ),
    r'status': PropertySchema(id: 15, name: r'status', type: IsarType.string),
    r'updatedAt': PropertySchema(
      id: 16,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'uuid': PropertySchema(id: 17, name: r'uuid', type: IsarType.string),
  },
  estimateSize: _subscriptionEntityEstimateSize,
  serialize: _subscriptionEntitySerialize,
  deserialize: _subscriptionEntityDeserialize,
  deserializeProp: _subscriptionEntityDeserializeProp,
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
    r'merchant': IndexSchema(
      id: 6264094425997380025,
      name: r'merchant',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'merchant',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'normalizedMerchant': IndexSchema(
      id: -6734704055320559733,
      name: r'normalizedMerchant',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'normalizedMerchant',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'nextRenewalDate': IndexSchema(
      id: 4825061543962352251,
      name: r'nextRenewalDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'nextRenewalDate',
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
  },
  links: {},
  embeddedSchemas: {},
  getId: _subscriptionEntityGetId,
  getLinks: _subscriptionEntityGetLinks,
  attach: _subscriptionEntityAttach,
  version: '3.1.0+1',
);

int _subscriptionEntityEstimateSize(
  SubscriptionEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.accountId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.billingFrequency.length * 3;
  bytesCount += 3 + object.category.length * 3;
  bytesCount += 3 + object.currency.length * 3;
  bytesCount += 3 + object.merchant.length * 3;
  bytesCount += 3 + object.normalizedMerchant.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.paymentMethod;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.sourceTransactionId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.uuid.length * 3;
  return bytesCount;
}

void _subscriptionEntitySerialize(
  SubscriptionEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.accountId);
  writer.writeDouble(offsets[1], object.amount);
  writer.writeString(offsets[2], object.billingFrequency);
  writer.writeString(offsets[3], object.category);
  writer.writeDateTime(offsets[4], object.createdAt);
  writer.writeString(offsets[5], object.currency);
  writer.writeBool(offsets[6], object.isReminderEnabled);
  writer.writeDateTime(offsets[7], object.lastPaymentDate);
  writer.writeString(offsets[8], object.merchant);
  writer.writeDateTime(offsets[9], object.nextRenewalDate);
  writer.writeString(offsets[10], object.normalizedMerchant);
  writer.writeString(offsets[11], object.notes);
  writer.writeString(offsets[12], object.paymentMethod);
  writer.writeLong(offsets[13], object.reminderDaysBefore);
  writer.writeString(offsets[14], object.sourceTransactionId);
  writer.writeString(offsets[15], object.status);
  writer.writeDateTime(offsets[16], object.updatedAt);
  writer.writeString(offsets[17], object.uuid);
}

SubscriptionEntity _subscriptionEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SubscriptionEntity();
  object.accountId = reader.readStringOrNull(offsets[0]);
  object.amount = reader.readDouble(offsets[1]);
  object.billingFrequency = reader.readString(offsets[2]);
  object.category = reader.readString(offsets[3]);
  object.createdAt = reader.readDateTime(offsets[4]);
  object.currency = reader.readString(offsets[5]);
  object.id = id;
  object.isReminderEnabled = reader.readBool(offsets[6]);
  object.lastPaymentDate = reader.readDateTimeOrNull(offsets[7]);
  object.merchant = reader.readString(offsets[8]);
  object.nextRenewalDate = reader.readDateTime(offsets[9]);
  object.normalizedMerchant = reader.readString(offsets[10]);
  object.notes = reader.readStringOrNull(offsets[11]);
  object.paymentMethod = reader.readStringOrNull(offsets[12]);
  object.reminderDaysBefore = reader.readLong(offsets[13]);
  object.sourceTransactionId = reader.readStringOrNull(offsets[14]);
  object.status = reader.readString(offsets[15]);
  object.updatedAt = reader.readDateTime(offsets[16]);
  object.uuid = reader.readString(offsets[17]);
  return object;
}

P _subscriptionEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readDateTime(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _subscriptionEntityGetId(SubscriptionEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _subscriptionEntityGetLinks(
  SubscriptionEntity object,
) {
  return [];
}

void _subscriptionEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  SubscriptionEntity object,
) {
  object.id = id;
}

extension SubscriptionEntityByIndex on IsarCollection<SubscriptionEntity> {
  Future<SubscriptionEntity?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  SubscriptionEntity? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<SubscriptionEntity?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<SubscriptionEntity?> getAllByUuidSync(List<String> uuidValues) {
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

  Future<Id> putByUuid(SubscriptionEntity object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(SubscriptionEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<SubscriptionEntity> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(
    List<SubscriptionEntity> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }
}

extension SubscriptionEntityQueryWhereSort
    on QueryBuilder<SubscriptionEntity, SubscriptionEntity, QWhere> {
  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterWhere>
  anyNextRenewalDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'nextRenewalDate'),
      );
    });
  }
}

extension SubscriptionEntityQueryWhere
    on QueryBuilder<SubscriptionEntity, SubscriptionEntity, QWhereClause> {
  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterWhereClause>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterWhereClause>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterWhereClause>
  uuidEqualTo(String uuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'uuid', value: [uuid]),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterWhereClause>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterWhereClause>
  merchantEqualTo(String merchant) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'merchant', value: [merchant]),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterWhereClause>
  merchantNotEqualTo(String merchant) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'merchant',
                lower: [],
                upper: [merchant],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'merchant',
                lower: [merchant],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'merchant',
                lower: [merchant],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'merchant',
                lower: [],
                upper: [merchant],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterWhereClause>
  normalizedMerchantEqualTo(String normalizedMerchant) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'normalizedMerchant',
          value: [normalizedMerchant],
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterWhereClause>
  normalizedMerchantNotEqualTo(String normalizedMerchant) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'normalizedMerchant',
                lower: [],
                upper: [normalizedMerchant],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'normalizedMerchant',
                lower: [normalizedMerchant],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'normalizedMerchant',
                lower: [normalizedMerchant],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'normalizedMerchant',
                lower: [],
                upper: [normalizedMerchant],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterWhereClause>
  nextRenewalDateEqualTo(DateTime nextRenewalDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'nextRenewalDate',
          value: [nextRenewalDate],
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterWhereClause>
  nextRenewalDateNotEqualTo(DateTime nextRenewalDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nextRenewalDate',
                lower: [],
                upper: [nextRenewalDate],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nextRenewalDate',
                lower: [nextRenewalDate],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nextRenewalDate',
                lower: [nextRenewalDate],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nextRenewalDate',
                lower: [],
                upper: [nextRenewalDate],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterWhereClause>
  nextRenewalDateGreaterThan(DateTime nextRenewalDate, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'nextRenewalDate',
          lower: [nextRenewalDate],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterWhereClause>
  nextRenewalDateLessThan(DateTime nextRenewalDate, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'nextRenewalDate',
          lower: [],
          upper: [nextRenewalDate],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterWhereClause>
  nextRenewalDateBetween(
    DateTime lowerNextRenewalDate,
    DateTime upperNextRenewalDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'nextRenewalDate',
          lower: [lowerNextRenewalDate],
          includeLower: includeLower,
          upper: [upperNextRenewalDate],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterWhereClause>
  statusEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'status', value: [status]),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterWhereClause>
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
}

extension SubscriptionEntityQueryFilter
    on QueryBuilder<SubscriptionEntity, SubscriptionEntity, QFilterCondition> {
  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  accountIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'accountId'),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  accountIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'accountId'),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  accountIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'accountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  accountIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'accountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  accountIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'accountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  accountIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'accountId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  accountIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'accountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  accountIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'accountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  accountIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'accountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  accountIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'accountId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  accountIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'accountId', value: ''),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  accountIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'accountId', value: ''),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  amountEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'amount',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  amountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'amount',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  amountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'amount',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  amountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'amount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  billingFrequencyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'billingFrequency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  billingFrequencyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'billingFrequency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  billingFrequencyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'billingFrequency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  billingFrequencyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'billingFrequency',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  billingFrequencyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'billingFrequency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  billingFrequencyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'billingFrequency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  billingFrequencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'billingFrequency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  billingFrequencyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'billingFrequency',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  billingFrequencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'billingFrequency', value: ''),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  billingFrequencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'billingFrequency', value: ''),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  categoryEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  categoryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  categoryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  categoryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'category',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  categoryStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  categoryEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  categoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  categoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'category',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'category', value: ''),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'category', value: ''),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  currencyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'currency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  currencyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  currencyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  currencyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currency',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  currencyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'currency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  currencyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'currency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  currencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'currency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  currencyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'currency',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  currencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currency', value: ''),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  currencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'currency', value: ''),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  isReminderEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isReminderEnabled', value: value),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  lastPaymentDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastPaymentDate'),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  lastPaymentDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastPaymentDate'),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  lastPaymentDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastPaymentDate', value: value),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  lastPaymentDateGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastPaymentDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  lastPaymentDateLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastPaymentDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  lastPaymentDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastPaymentDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  merchantEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'merchant',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  merchantGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'merchant',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  merchantLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'merchant',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  merchantBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'merchant',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  merchantStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'merchant',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  merchantEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'merchant',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  merchantContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'merchant',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  merchantMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'merchant',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  merchantIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'merchant', value: ''),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  merchantIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'merchant', value: ''),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  nextRenewalDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nextRenewalDate', value: value),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  nextRenewalDateGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nextRenewalDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  nextRenewalDateLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nextRenewalDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  nextRenewalDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nextRenewalDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  normalizedMerchantEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'normalizedMerchant',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  normalizedMerchantGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'normalizedMerchant',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  normalizedMerchantLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'normalizedMerchant',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  normalizedMerchantBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'normalizedMerchant',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  normalizedMerchantStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'normalizedMerchant',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  normalizedMerchantEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'normalizedMerchant',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  normalizedMerchantContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'normalizedMerchant',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  normalizedMerchantMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'normalizedMerchant',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  normalizedMerchantIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'normalizedMerchant', value: ''),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  normalizedMerchantIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'normalizedMerchant', value: ''),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  paymentMethodIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'paymentMethod'),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  paymentMethodIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'paymentMethod'),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  paymentMethodEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'paymentMethod',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  paymentMethodGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'paymentMethod',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  paymentMethodLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'paymentMethod',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  paymentMethodBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'paymentMethod',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  paymentMethodStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'paymentMethod',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  paymentMethodEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'paymentMethod',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  paymentMethodContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'paymentMethod',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  paymentMethodMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'paymentMethod',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  paymentMethodIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'paymentMethod', value: ''),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  paymentMethodIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'paymentMethod', value: ''),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  reminderDaysBeforeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'reminderDaysBefore', value: value),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  sourceTransactionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'sourceTransactionId'),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  sourceTransactionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'sourceTransactionId'),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  sourceTransactionIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sourceTransactionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  sourceTransactionIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sourceTransactionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  sourceTransactionIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sourceTransactionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  sourceTransactionIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sourceTransactionId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  sourceTransactionIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sourceTransactionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  sourceTransactionIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sourceTransactionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  sourceTransactionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sourceTransactionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  sourceTransactionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sourceTransactionId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  sourceTransactionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sourceTransactionId', value: ''),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  sourceTransactionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'sourceTransactionId',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'uuid', value: ''),
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterFilterCondition>
  uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'uuid', value: ''),
      );
    });
  }
}

extension SubscriptionEntityQueryObject
    on QueryBuilder<SubscriptionEntity, SubscriptionEntity, QFilterCondition> {}

extension SubscriptionEntityQueryLinks
    on QueryBuilder<SubscriptionEntity, SubscriptionEntity, QFilterCondition> {}

extension SubscriptionEntityQuerySortBy
    on QueryBuilder<SubscriptionEntity, SubscriptionEntity, QSortBy> {
  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByBillingFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billingFrequency', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByBillingFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billingFrequency', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByIsReminderEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReminderEnabled', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByIsReminderEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReminderEnabled', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByLastPaymentDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPaymentDate', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByLastPaymentDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPaymentDate', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByMerchant() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchant', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByMerchantDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchant', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByNextRenewalDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextRenewalDate', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByNextRenewalDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextRenewalDate', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByNormalizedMerchant() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedMerchant', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByNormalizedMerchantDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedMerchant', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByPaymentMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByPaymentMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByReminderDaysBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderDaysBefore', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByReminderDaysBeforeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderDaysBefore', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortBySourceTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceTransactionId', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortBySourceTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceTransactionId', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension SubscriptionEntityQuerySortThenBy
    on QueryBuilder<SubscriptionEntity, SubscriptionEntity, QSortThenBy> {
  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByBillingFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billingFrequency', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByBillingFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billingFrequency', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByIsReminderEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReminderEnabled', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByIsReminderEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReminderEnabled', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByLastPaymentDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPaymentDate', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByLastPaymentDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPaymentDate', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByMerchant() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchant', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByMerchantDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchant', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByNextRenewalDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextRenewalDate', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByNextRenewalDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextRenewalDate', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByNormalizedMerchant() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedMerchant', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByNormalizedMerchantDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedMerchant', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByPaymentMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByPaymentMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByReminderDaysBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderDaysBefore', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByReminderDaysBeforeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderDaysBefore', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenBySourceTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceTransactionId', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenBySourceTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceTransactionId', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QAfterSortBy>
  thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension SubscriptionEntityQueryWhereDistinct
    on QueryBuilder<SubscriptionEntity, SubscriptionEntity, QDistinct> {
  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QDistinct>
  distinctByAccountId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accountId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QDistinct>
  distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QDistinct>
  distinctByBillingFrequency({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'billingFrequency',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QDistinct>
  distinctByCategory({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'category', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QDistinct>
  distinctByCurrency({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QDistinct>
  distinctByIsReminderEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isReminderEnabled');
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QDistinct>
  distinctByLastPaymentDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPaymentDate');
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QDistinct>
  distinctByMerchant({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'merchant', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QDistinct>
  distinctByNextRenewalDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nextRenewalDate');
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QDistinct>
  distinctByNormalizedMerchant({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'normalizedMerchant',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QDistinct>
  distinctByNotes({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QDistinct>
  distinctByPaymentMethod({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'paymentMethod',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QDistinct>
  distinctByReminderDaysBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reminderDaysBefore');
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QDistinct>
  distinctBySourceTransactionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'sourceTransactionId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QDistinct>
  distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<SubscriptionEntity, SubscriptionEntity, QDistinct>
  distinctByUuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }
}

extension SubscriptionEntityQueryProperty
    on QueryBuilder<SubscriptionEntity, SubscriptionEntity, QQueryProperty> {
  QueryBuilder<SubscriptionEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SubscriptionEntity, String?, QQueryOperations>
  accountIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accountId');
    });
  }

  QueryBuilder<SubscriptionEntity, double, QQueryOperations> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<SubscriptionEntity, String, QQueryOperations>
  billingFrequencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'billingFrequency');
    });
  }

  QueryBuilder<SubscriptionEntity, String, QQueryOperations>
  categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'category');
    });
  }

  QueryBuilder<SubscriptionEntity, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<SubscriptionEntity, String, QQueryOperations>
  currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<SubscriptionEntity, bool, QQueryOperations>
  isReminderEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isReminderEnabled');
    });
  }

  QueryBuilder<SubscriptionEntity, DateTime?, QQueryOperations>
  lastPaymentDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPaymentDate');
    });
  }

  QueryBuilder<SubscriptionEntity, String, QQueryOperations>
  merchantProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'merchant');
    });
  }

  QueryBuilder<SubscriptionEntity, DateTime, QQueryOperations>
  nextRenewalDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nextRenewalDate');
    });
  }

  QueryBuilder<SubscriptionEntity, String, QQueryOperations>
  normalizedMerchantProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'normalizedMerchant');
    });
  }

  QueryBuilder<SubscriptionEntity, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<SubscriptionEntity, String?, QQueryOperations>
  paymentMethodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paymentMethod');
    });
  }

  QueryBuilder<SubscriptionEntity, int, QQueryOperations>
  reminderDaysBeforeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderDaysBefore');
    });
  }

  QueryBuilder<SubscriptionEntity, String?, QQueryOperations>
  sourceTransactionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceTransactionId');
    });
  }

  QueryBuilder<SubscriptionEntity, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<SubscriptionEntity, DateTime, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<SubscriptionEntity, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }
}
