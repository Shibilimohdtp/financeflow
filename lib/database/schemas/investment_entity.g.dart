// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investment_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetInvestmentEntityCollection on Isar {
  IsarCollection<InvestmentEntity> get investmentEntitys => this.collection();
}

const InvestmentEntitySchema = CollectionSchema(
  name: r'InvestmentEntity',
  id: 5009091176383748744,
  properties: {
    r'accountId': PropertySchema(
      id: 0,
      name: r'accountId',
      type: IsarType.string,
    ),
    r'assetType': PropertySchema(
      id: 1,
      name: r'assetType',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currentValue': PropertySchema(
      id: 3,
      name: r'currentValue',
      type: IsarType.double,
    ),
    r'investedAmount': PropertySchema(
      id: 4,
      name: r'investedAmount',
      type: IsarType.double,
    ),
    r'isArchived': PropertySchema(
      id: 5,
      name: r'isArchived',
      type: IsarType.bool,
    ),
    r'lastValuationDate': PropertySchema(
      id: 6,
      name: r'lastValuationDate',
      type: IsarType.dateTime,
    ),
    r'ledgerBaselineCurrentValue': PropertySchema(
      id: 7,
      name: r'ledgerBaselineCurrentValue',
      type: IsarType.double,
    ),
    r'ledgerBaselineInvestedAmount': PropertySchema(
      id: 8,
      name: r'ledgerBaselineInvestedAmount',
      type: IsarType.double,
    ),
    r'ledgerBaselineRealizedProfitLoss': PropertySchema(
      id: 9,
      name: r'ledgerBaselineRealizedProfitLoss',
      type: IsarType.double,
    ),
    r'name': PropertySchema(
      id: 10,
      name: r'name',
      type: IsarType.string,
    ),
    r'notes': PropertySchema(
      id: 11,
      name: r'notes',
      type: IsarType.string,
    ),
    r'purchaseDate': PropertySchema(
      id: 12,
      name: r'purchaseDate',
      type: IsarType.dateTime,
    ),
    r'purchasePrice': PropertySchema(
      id: 13,
      name: r'purchasePrice',
      type: IsarType.double,
    ),
    r'quantityOrUnits': PropertySchema(
      id: 14,
      name: r'quantityOrUnits',
      type: IsarType.double,
    ),
    r'realizedProfitLoss': PropertySchema(
      id: 15,
      name: r'realizedProfitLoss',
      type: IsarType.double,
    ),
    r'unrealizedProfitLoss': PropertySchema(
      id: 16,
      name: r'unrealizedProfitLoss',
      type: IsarType.double,
    ),
    r'updatedAt': PropertySchema(
      id: 17,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'uuid': PropertySchema(
      id: 18,
      name: r'uuid',
      type: IsarType.string,
    )
  },
  estimateSize: _investmentEntityEstimateSize,
  serialize: _investmentEntitySerialize,
  deserialize: _investmentEntityDeserialize,
  deserializeProp: _investmentEntityDeserializeProp,
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
        )
      ],
    ),
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'assetType': IndexSchema(
      id: 2557228192997929194,
      name: r'assetType',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'assetType',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'purchaseDate': IndexSchema(
      id: 1174684625301313566,
      name: r'purchaseDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'purchaseDate',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'isArchived': IndexSchema(
      id: 655844772568347876,
      name: r'isArchived',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isArchived',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _investmentEntityGetId,
  getLinks: _investmentEntityGetLinks,
  attach: _investmentEntityAttach,
  version: '3.1.0+1',
);

int _investmentEntityEstimateSize(
  InvestmentEntity object,
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
  bytesCount += 3 + object.assetType.length * 3;
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.uuid.length * 3;
  return bytesCount;
}

void _investmentEntitySerialize(
  InvestmentEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.accountId);
  writer.writeString(offsets[1], object.assetType);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeDouble(offsets[3], object.currentValue);
  writer.writeDouble(offsets[4], object.investedAmount);
  writer.writeBool(offsets[5], object.isArchived);
  writer.writeDateTime(offsets[6], object.lastValuationDate);
  writer.writeDouble(offsets[7], object.ledgerBaselineCurrentValue);
  writer.writeDouble(offsets[8], object.ledgerBaselineInvestedAmount);
  writer.writeDouble(offsets[9], object.ledgerBaselineRealizedProfitLoss);
  writer.writeString(offsets[10], object.name);
  writer.writeString(offsets[11], object.notes);
  writer.writeDateTime(offsets[12], object.purchaseDate);
  writer.writeDouble(offsets[13], object.purchasePrice);
  writer.writeDouble(offsets[14], object.quantityOrUnits);
  writer.writeDouble(offsets[15], object.realizedProfitLoss);
  writer.writeDouble(offsets[16], object.unrealizedProfitLoss);
  writer.writeDateTime(offsets[17], object.updatedAt);
  writer.writeString(offsets[18], object.uuid);
}

InvestmentEntity _investmentEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = InvestmentEntity();
  object.accountId = reader.readStringOrNull(offsets[0]);
  object.assetType = reader.readString(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.currentValue = reader.readDouble(offsets[3]);
  object.id = id;
  object.investedAmount = reader.readDouble(offsets[4]);
  object.isArchived = reader.readBool(offsets[5]);
  object.lastValuationDate = reader.readDateTimeOrNull(offsets[6]);
  object.ledgerBaselineCurrentValue = reader.readDoubleOrNull(offsets[7]);
  object.ledgerBaselineInvestedAmount = reader.readDoubleOrNull(offsets[8]);
  object.ledgerBaselineRealizedProfitLoss = reader.readDoubleOrNull(offsets[9]);
  object.name = reader.readString(offsets[10]);
  object.notes = reader.readStringOrNull(offsets[11]);
  object.purchaseDate = reader.readDateTime(offsets[12]);
  object.purchasePrice = reader.readDouble(offsets[13]);
  object.quantityOrUnits = reader.readDouble(offsets[14]);
  object.realizedProfitLoss = reader.readDoubleOrNull(offsets[15]);
  object.unrealizedProfitLoss = reader.readDouble(offsets[16]);
  object.updatedAt = reader.readDateTime(offsets[17]);
  object.uuid = reader.readString(offsets[18]);
  return object;
}

P _investmentEntityDeserializeProp<P>(
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
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readDoubleOrNull(offset)) as P;
    case 8:
      return (reader.readDoubleOrNull(offset)) as P;
    case 9:
      return (reader.readDoubleOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readDateTime(offset)) as P;
    case 13:
      return (reader.readDouble(offset)) as P;
    case 14:
      return (reader.readDouble(offset)) as P;
    case 15:
      return (reader.readDoubleOrNull(offset)) as P;
    case 16:
      return (reader.readDouble(offset)) as P;
    case 17:
      return (reader.readDateTime(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _investmentEntityGetId(InvestmentEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _investmentEntityGetLinks(InvestmentEntity object) {
  return [];
}

void _investmentEntityAttach(
    IsarCollection<dynamic> col, Id id, InvestmentEntity object) {
  object.id = id;
}

extension InvestmentEntityByIndex on IsarCollection<InvestmentEntity> {
  Future<InvestmentEntity?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  InvestmentEntity? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<InvestmentEntity?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<InvestmentEntity?> getAllByUuidSync(List<String> uuidValues) {
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

  Future<Id> putByUuid(InvestmentEntity object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(InvestmentEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<InvestmentEntity> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(List<InvestmentEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }
}

extension InvestmentEntityQueryWhereSort
    on QueryBuilder<InvestmentEntity, InvestmentEntity, QWhere> {
  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterWhere>
      anyPurchaseDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'purchaseDate'),
      );
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterWhere>
      anyIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isArchived'),
      );
    });
  }
}

extension InvestmentEntityQueryWhere
    on QueryBuilder<InvestmentEntity, InvestmentEntity, QWhereClause> {
  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterWhereClause>
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

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterWhereClause>
      uuidEqualTo(String uuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uuid',
        value: [uuid],
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterWhereClause>
      uuidNotEqualTo(String uuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [],
              upper: [uuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [uuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [uuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [],
              upper: [uuid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterWhereClause>
      nameEqualTo(String name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [name],
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterWhereClause>
      nameNotEqualTo(String name) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterWhereClause>
      assetTypeEqualTo(String assetType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'assetType',
        value: [assetType],
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterWhereClause>
      assetTypeNotEqualTo(String assetType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'assetType',
              lower: [],
              upper: [assetType],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'assetType',
              lower: [assetType],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'assetType',
              lower: [assetType],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'assetType',
              lower: [],
              upper: [assetType],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterWhereClause>
      purchaseDateEqualTo(DateTime purchaseDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'purchaseDate',
        value: [purchaseDate],
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterWhereClause>
      purchaseDateNotEqualTo(DateTime purchaseDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'purchaseDate',
              lower: [],
              upper: [purchaseDate],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'purchaseDate',
              lower: [purchaseDate],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'purchaseDate',
              lower: [purchaseDate],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'purchaseDate',
              lower: [],
              upper: [purchaseDate],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterWhereClause>
      purchaseDateGreaterThan(
    DateTime purchaseDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'purchaseDate',
        lower: [purchaseDate],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterWhereClause>
      purchaseDateLessThan(
    DateTime purchaseDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'purchaseDate',
        lower: [],
        upper: [purchaseDate],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterWhereClause>
      purchaseDateBetween(
    DateTime lowerPurchaseDate,
    DateTime upperPurchaseDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'purchaseDate',
        lower: [lowerPurchaseDate],
        includeLower: includeLower,
        upper: [upperPurchaseDate],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterWhereClause>
      isArchivedEqualTo(bool isArchived) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isArchived',
        value: [isArchived],
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterWhereClause>
      isArchivedNotEqualTo(bool isArchived) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived',
              lower: [],
              upper: [isArchived],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived',
              lower: [isArchived],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived',
              lower: [isArchived],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived',
              lower: [],
              upper: [isArchived],
              includeUpper: false,
            ));
      }
    });
  }
}

extension InvestmentEntityQueryFilter
    on QueryBuilder<InvestmentEntity, InvestmentEntity, QFilterCondition> {
  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      accountIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'accountId',
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      accountIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'accountId',
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      accountIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accountId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      accountIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'accountId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      accountIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'accountId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      accountIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'accountId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      accountIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'accountId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      accountIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'accountId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      accountIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'accountId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      accountIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'accountId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      accountIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accountId',
        value: '',
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      accountIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'accountId',
        value: '',
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      assetTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assetType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      assetTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assetType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      assetTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assetType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      assetTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assetType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      assetTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'assetType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      assetTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'assetType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      assetTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'assetType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      assetTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'assetType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      assetTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assetType',
        value: '',
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      assetTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'assetType',
        value: '',
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      currentValueEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      currentValueGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      currentValueLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      currentValueBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
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

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
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

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
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

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      investedAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'investedAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      investedAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'investedAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      investedAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'investedAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      investedAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'investedAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      isArchivedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isArchived',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      lastValuationDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastValuationDate',
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      lastValuationDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastValuationDate',
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      lastValuationDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastValuationDate',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      lastValuationDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastValuationDate',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      lastValuationDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastValuationDate',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      lastValuationDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastValuationDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      ledgerBaselineCurrentValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ledgerBaselineCurrentValue',
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      ledgerBaselineCurrentValueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ledgerBaselineCurrentValue',
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      ledgerBaselineCurrentValueEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ledgerBaselineCurrentValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      ledgerBaselineCurrentValueGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ledgerBaselineCurrentValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      ledgerBaselineCurrentValueLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ledgerBaselineCurrentValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      ledgerBaselineCurrentValueBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ledgerBaselineCurrentValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      ledgerBaselineInvestedAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ledgerBaselineInvestedAmount',
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      ledgerBaselineInvestedAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ledgerBaselineInvestedAmount',
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      ledgerBaselineInvestedAmountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ledgerBaselineInvestedAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      ledgerBaselineInvestedAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ledgerBaselineInvestedAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      ledgerBaselineInvestedAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ledgerBaselineInvestedAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      ledgerBaselineInvestedAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ledgerBaselineInvestedAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      ledgerBaselineRealizedProfitLossIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ledgerBaselineRealizedProfitLoss',
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      ledgerBaselineRealizedProfitLossIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ledgerBaselineRealizedProfitLoss',
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      ledgerBaselineRealizedProfitLossEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ledgerBaselineRealizedProfitLoss',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      ledgerBaselineRealizedProfitLossGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ledgerBaselineRealizedProfitLoss',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      ledgerBaselineRealizedProfitLossLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ledgerBaselineRealizedProfitLoss',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      ledgerBaselineRealizedProfitLossBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ledgerBaselineRealizedProfitLoss',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      purchaseDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'purchaseDate',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      purchaseDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'purchaseDate',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      purchaseDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'purchaseDate',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      purchaseDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'purchaseDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      purchasePriceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'purchasePrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      purchasePriceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'purchasePrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      purchasePriceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'purchasePrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      purchasePriceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'purchasePrice',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      quantityOrUnitsEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantityOrUnits',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      quantityOrUnitsGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quantityOrUnits',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      quantityOrUnitsLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quantityOrUnits',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      quantityOrUnitsBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quantityOrUnits',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      realizedProfitLossIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'realizedProfitLoss',
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      realizedProfitLossIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'realizedProfitLoss',
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      realizedProfitLossEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'realizedProfitLoss',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      realizedProfitLossGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'realizedProfitLoss',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      realizedProfitLossLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'realizedProfitLoss',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      realizedProfitLossBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'realizedProfitLoss',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      unrealizedProfitLossEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unrealizedProfitLoss',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      unrealizedProfitLossGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unrealizedProfitLoss',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      unrealizedProfitLossLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unrealizedProfitLoss',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      unrealizedProfitLossBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unrealizedProfitLoss',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      uuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      uuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      uuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      uuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      uuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      uuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      uuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      uuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterFilterCondition>
      uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uuid',
        value: '',
      ));
    });
  }
}

extension InvestmentEntityQueryObject
    on QueryBuilder<InvestmentEntity, InvestmentEntity, QFilterCondition> {}

extension InvestmentEntityQueryLinks
    on QueryBuilder<InvestmentEntity, InvestmentEntity, QFilterCondition> {}

extension InvestmentEntityQuerySortBy
    on QueryBuilder<InvestmentEntity, InvestmentEntity, QSortBy> {
  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByAssetType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetType', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByAssetTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetType', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByCurrentValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentValue', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByCurrentValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentValue', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByInvestedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investedAmount', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByInvestedAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investedAmount', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByIsArchivedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByLastValuationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastValuationDate', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByLastValuationDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastValuationDate', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByLedgerBaselineCurrentValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ledgerBaselineCurrentValue', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByLedgerBaselineCurrentValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ledgerBaselineCurrentValue', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByLedgerBaselineInvestedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ledgerBaselineInvestedAmount', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByLedgerBaselineInvestedAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ledgerBaselineInvestedAmount', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByLedgerBaselineRealizedProfitLoss() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ledgerBaselineRealizedProfitLoss', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByLedgerBaselineRealizedProfitLossDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ledgerBaselineRealizedProfitLoss', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByPurchaseDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseDate', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByPurchaseDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseDate', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByPurchasePrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchasePrice', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByPurchasePriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchasePrice', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByQuantityOrUnits() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantityOrUnits', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByQuantityOrUnitsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantityOrUnits', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByRealizedProfitLoss() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'realizedProfitLoss', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByRealizedProfitLossDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'realizedProfitLoss', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByUnrealizedProfitLoss() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unrealizedProfitLoss', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByUnrealizedProfitLossDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unrealizedProfitLoss', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy> sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension InvestmentEntityQuerySortThenBy
    on QueryBuilder<InvestmentEntity, InvestmentEntity, QSortThenBy> {
  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByAssetType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetType', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByAssetTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetType', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByCurrentValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentValue', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByCurrentValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentValue', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByInvestedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investedAmount', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByInvestedAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investedAmount', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByIsArchivedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByLastValuationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastValuationDate', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByLastValuationDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastValuationDate', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByLedgerBaselineCurrentValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ledgerBaselineCurrentValue', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByLedgerBaselineCurrentValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ledgerBaselineCurrentValue', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByLedgerBaselineInvestedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ledgerBaselineInvestedAmount', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByLedgerBaselineInvestedAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ledgerBaselineInvestedAmount', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByLedgerBaselineRealizedProfitLoss() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ledgerBaselineRealizedProfitLoss', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByLedgerBaselineRealizedProfitLossDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ledgerBaselineRealizedProfitLoss', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByPurchaseDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseDate', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByPurchaseDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseDate', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByPurchasePrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchasePrice', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByPurchasePriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchasePrice', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByQuantityOrUnits() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantityOrUnits', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByQuantityOrUnitsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantityOrUnits', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByRealizedProfitLoss() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'realizedProfitLoss', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByRealizedProfitLossDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'realizedProfitLoss', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByUnrealizedProfitLoss() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unrealizedProfitLoss', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByUnrealizedProfitLossDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unrealizedProfitLoss', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy> thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QAfterSortBy>
      thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension InvestmentEntityQueryWhereDistinct
    on QueryBuilder<InvestmentEntity, InvestmentEntity, QDistinct> {
  QueryBuilder<InvestmentEntity, InvestmentEntity, QDistinct>
      distinctByAccountId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accountId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QDistinct>
      distinctByAssetType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assetType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QDistinct>
      distinctByCurrentValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentValue');
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QDistinct>
      distinctByInvestedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'investedAmount');
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QDistinct>
      distinctByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isArchived');
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QDistinct>
      distinctByLastValuationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastValuationDate');
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QDistinct>
      distinctByLedgerBaselineCurrentValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ledgerBaselineCurrentValue');
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QDistinct>
      distinctByLedgerBaselineInvestedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ledgerBaselineInvestedAmount');
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QDistinct>
      distinctByLedgerBaselineRealizedProfitLoss() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ledgerBaselineRealizedProfitLoss');
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QDistinct>
      distinctByPurchaseDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'purchaseDate');
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QDistinct>
      distinctByPurchasePrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'purchasePrice');
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QDistinct>
      distinctByQuantityOrUnits() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quantityOrUnits');
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QDistinct>
      distinctByRealizedProfitLoss() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'realizedProfitLoss');
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QDistinct>
      distinctByUnrealizedProfitLoss() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unrealizedProfitLoss');
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<InvestmentEntity, InvestmentEntity, QDistinct> distinctByUuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }
}

extension InvestmentEntityQueryProperty
    on QueryBuilder<InvestmentEntity, InvestmentEntity, QQueryProperty> {
  QueryBuilder<InvestmentEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<InvestmentEntity, String?, QQueryOperations>
      accountIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accountId');
    });
  }

  QueryBuilder<InvestmentEntity, String, QQueryOperations> assetTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assetType');
    });
  }

  QueryBuilder<InvestmentEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<InvestmentEntity, double, QQueryOperations>
      currentValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentValue');
    });
  }

  QueryBuilder<InvestmentEntity, double, QQueryOperations>
      investedAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'investedAmount');
    });
  }

  QueryBuilder<InvestmentEntity, bool, QQueryOperations> isArchivedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isArchived');
    });
  }

  QueryBuilder<InvestmentEntity, DateTime?, QQueryOperations>
      lastValuationDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastValuationDate');
    });
  }

  QueryBuilder<InvestmentEntity, double?, QQueryOperations>
      ledgerBaselineCurrentValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ledgerBaselineCurrentValue');
    });
  }

  QueryBuilder<InvestmentEntity, double?, QQueryOperations>
      ledgerBaselineInvestedAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ledgerBaselineInvestedAmount');
    });
  }

  QueryBuilder<InvestmentEntity, double?, QQueryOperations>
      ledgerBaselineRealizedProfitLossProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ledgerBaselineRealizedProfitLoss');
    });
  }

  QueryBuilder<InvestmentEntity, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<InvestmentEntity, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<InvestmentEntity, DateTime, QQueryOperations>
      purchaseDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'purchaseDate');
    });
  }

  QueryBuilder<InvestmentEntity, double, QQueryOperations>
      purchasePriceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'purchasePrice');
    });
  }

  QueryBuilder<InvestmentEntity, double, QQueryOperations>
      quantityOrUnitsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quantityOrUnits');
    });
  }

  QueryBuilder<InvestmentEntity, double?, QQueryOperations>
      realizedProfitLossProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'realizedProfitLoss');
    });
  }

  QueryBuilder<InvestmentEntity, double, QQueryOperations>
      unrealizedProfitLossProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unrealizedProfitLoss');
    });
  }

  QueryBuilder<InvestmentEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<InvestmentEntity, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }
}
