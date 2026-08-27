// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_transaction_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPendingTransactionEntityCollection on Isar {
  IsarCollection<PendingTransactionEntity> get pendingTransactionEntitys =>
      this.collection();
}

const PendingTransactionEntitySchema = CollectionSchema(
  name: r'PendingTransactionEntity',
  id: 6485408335619684386,
  properties: {
    r'accountId': PropertySchema(
      id: 0,
      name: r'accountId',
      type: IsarType.string,
    ),
    r'amount': PropertySchema(id: 1, name: r'amount', type: IsarType.double),
    r'categorizationConfidence': PropertySchema(
      id: 2,
      name: r'categorizationConfidence',
      type: IsarType.double,
    ),
    r'categorizationReason': PropertySchema(
      id: 3,
      name: r'categorizationReason',
      type: IsarType.string,
    ),
    r'categoryColor': PropertySchema(
      id: 4,
      name: r'categoryColor',
      type: IsarType.string,
    ),
    r'categoryIcon': PropertySchema(
      id: 5,
      name: r'categoryIcon',
      type: IsarType.string,
    ),
    r'categoryId': PropertySchema(
      id: 6,
      name: r'categoryId',
      type: IsarType.string,
    ),
    r'categoryName': PropertySchema(
      id: 7,
      name: r'categoryName',
      type: IsarType.string,
    ),
    r'date': PropertySchema(id: 8, name: r'date', type: IsarType.dateTime),
    r'detectedAt': PropertySchema(
      id: 9,
      name: r'detectedAt',
      type: IsarType.dateTime,
    ),
    r'direction': PropertySchema(
      id: 10,
      name: r'direction',
      type: IsarType.string,
    ),
    r'duplicateConfidence': PropertySchema(
      id: 11,
      name: r'duplicateConfidence',
      type: IsarType.double,
    ),
    r'duplicateReasons': PropertySchema(
      id: 12,
      name: r'duplicateReasons',
      type: IsarType.stringList,
    ),
    r'duplicateResolution': PropertySchema(
      id: 13,
      name: r'duplicateResolution',
      type: IsarType.string,
    ),
    r'duplicateStatus': PropertySchema(
      id: 14,
      name: r'duplicateStatus',
      type: IsarType.string,
    ),
    r'externalCounterpartyName': PropertySchema(
      id: 15,
      name: r'externalCounterpartyName',
      type: IsarType.string,
    ),
    r'feeComponent': PropertySchema(
      id: 16,
      name: r'feeComponent',
      type: IsarType.double,
    ),
    r'fingerprint': PropertySchema(
      id: 17,
      name: r'fingerprint',
      type: IsarType.string,
    ),
    r'importedAt': PropertySchema(
      id: 18,
      name: r'importedAt',
      type: IsarType.dateTime,
    ),
    r'interestComponent': PropertySchema(
      id: 19,
      name: r'interestComponent',
      type: IsarType.double,
    ),
    r'isIncluded': PropertySchema(
      id: 20,
      name: r'isIncluded',
      type: IsarType.bool,
    ),
    r'linkedInvestmentId': PropertySchema(
      id: 21,
      name: r'linkedInvestmentId',
      type: IsarType.string,
    ),
    r'linkedLoanId': PropertySchema(
      id: 22,
      name: r'linkedLoanId',
      type: IsarType.string,
    ),
    r'linkedMoneyRecordId': PropertySchema(
      id: 23,
      name: r'linkedMoneyRecordId',
      type: IsarType.string,
    ),
    r'matchedTransactionId': PropertySchema(
      id: 24,
      name: r'matchedTransactionId',
      type: IsarType.string,
    ),
    r'merchantDisplayName': PropertySchema(
      id: 25,
      name: r'merchantDisplayName',
      type: IsarType.string,
    ),
    r'normalizedMerchant': PropertySchema(
      id: 26,
      name: r'normalizedMerchant',
      type: IsarType.string,
    ),
    r'notes': PropertySchema(id: 27, name: r'notes', type: IsarType.string),
    r'paymentMethod': PropertySchema(
      id: 28,
      name: r'paymentMethod',
      type: IsarType.string,
    ),
    r'principalComponent': PropertySchema(
      id: 29,
      name: r'principalComponent',
      type: IsarType.double,
    ),
    r'purpose': PropertySchema(id: 30, name: r'purpose', type: IsarType.string),
    r'rawMerchant': PropertySchema(
      id: 31,
      name: r'rawMerchant',
      type: IsarType.string,
    ),
    r'rawSource': PropertySchema(
      id: 32,
      name: r'rawSource',
      type: IsarType.string,
    ),
    r'referenceNumber': PropertySchema(
      id: 33,
      name: r'referenceNumber',
      type: IsarType.string,
    ),
    r'reviewStatus': PropertySchema(
      id: 34,
      name: r'reviewStatus',
      type: IsarType.string,
    ),
    r'source': PropertySchema(id: 35, name: r'source', type: IsarType.string),
    r'sourceIdentifier': PropertySchema(
      id: 36,
      name: r'sourceIdentifier',
      type: IsarType.string,
    ),
    r'sourceName': PropertySchema(
      id: 37,
      name: r'sourceName',
      type: IsarType.string,
    ),
    r'tags': PropertySchema(id: 38, name: r'tags', type: IsarType.stringList),
    r'tempId': PropertySchema(id: 39, name: r'tempId', type: IsarType.string),
    r'time': PropertySchema(id: 40, name: r'time', type: IsarType.dateTime),
    r'toAccountId': PropertySchema(
      id: 41,
      name: r'toAccountId',
      type: IsarType.string,
    ),
    r'type': PropertySchema(id: 42, name: r'type', type: IsarType.string),
    r'validationErrors': PropertySchema(
      id: 43,
      name: r'validationErrors',
      type: IsarType.stringList,
    ),
    r'warnings': PropertySchema(
      id: 44,
      name: r'warnings',
      type: IsarType.stringList,
    ),
  },
  estimateSize: _pendingTransactionEntityEstimateSize,
  serialize: _pendingTransactionEntitySerialize,
  deserialize: _pendingTransactionEntityDeserialize,
  deserializeProp: _pendingTransactionEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'tempId': IndexSchema(
      id: 2461988663639479411,
      name: r'tempId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'tempId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'source': IndexSchema(
      id: -836881197531269605,
      name: r'source',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'source',
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
    r'normalizedMerchant': IndexSchema(
      id: -6734704055320559733,
      name: r'normalizedMerchant',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'normalizedMerchant',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'accountId': IndexSchema(
      id: -1591555361937770434,
      name: r'accountId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'accountId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'categoryId': IndexSchema(
      id: -8798048739239305339,
      name: r'categoryId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'categoryId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'referenceNumber': IndexSchema(
      id: -1505394869653403563,
      name: r'referenceNumber',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'referenceNumber',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'fingerprint': IndexSchema(
      id: -8135929981755050833,
      name: r'fingerprint',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'fingerprint',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'duplicateStatus': IndexSchema(
      id: -5303599256565741229,
      name: r'duplicateStatus',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'duplicateStatus',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'reviewStatus': IndexSchema(
      id: -8918604983176032830,
      name: r'reviewStatus',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'reviewStatus',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'importedAt': IndexSchema(
      id: 5552566418050361863,
      name: r'importedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'importedAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'detectedAt': IndexSchema(
      id: 1372738187187420158,
      name: r'detectedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'detectedAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _pendingTransactionEntityGetId,
  getLinks: _pendingTransactionEntityGetLinks,
  attach: _pendingTransactionEntityAttach,
  version: '3.1.0+1',
);

int _pendingTransactionEntityEstimateSize(
  PendingTransactionEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.accountId.length * 3;
  {
    final value = object.categorizationReason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.categoryColor.length * 3;
  bytesCount += 3 + object.categoryIcon.length * 3;
  bytesCount += 3 + object.categoryId.length * 3;
  bytesCount += 3 + object.categoryName.length * 3;
  {
    final value = object.direction;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.duplicateReasons.length * 3;
  {
    for (var i = 0; i < object.duplicateReasons.length; i++) {
      final value = object.duplicateReasons[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.duplicateResolution.length * 3;
  bytesCount += 3 + object.duplicateStatus.length * 3;
  {
    final value = object.externalCounterpartyName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.fingerprint.length * 3;
  {
    final value = object.linkedInvestmentId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.linkedLoanId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.linkedMoneyRecordId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.matchedTransactionId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.merchantDisplayName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
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
    final value = object.purpose;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.rawMerchant.length * 3;
  {
    final value = object.rawSource;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.referenceNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.reviewStatus.length * 3;
  bytesCount += 3 + object.source.length * 3;
  {
    final value = object.sourceIdentifier;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.sourceName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.tags.length * 3;
  {
    for (var i = 0; i < object.tags.length; i++) {
      final value = object.tags[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.tempId.length * 3;
  {
    final value = object.toAccountId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.type.length * 3;
  bytesCount += 3 + object.validationErrors.length * 3;
  {
    for (var i = 0; i < object.validationErrors.length; i++) {
      final value = object.validationErrors[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.warnings.length * 3;
  {
    for (var i = 0; i < object.warnings.length; i++) {
      final value = object.warnings[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _pendingTransactionEntitySerialize(
  PendingTransactionEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.accountId);
  writer.writeDouble(offsets[1], object.amount);
  writer.writeDouble(offsets[2], object.categorizationConfidence);
  writer.writeString(offsets[3], object.categorizationReason);
  writer.writeString(offsets[4], object.categoryColor);
  writer.writeString(offsets[5], object.categoryIcon);
  writer.writeString(offsets[6], object.categoryId);
  writer.writeString(offsets[7], object.categoryName);
  writer.writeDateTime(offsets[8], object.date);
  writer.writeDateTime(offsets[9], object.detectedAt);
  writer.writeString(offsets[10], object.direction);
  writer.writeDouble(offsets[11], object.duplicateConfidence);
  writer.writeStringList(offsets[12], object.duplicateReasons);
  writer.writeString(offsets[13], object.duplicateResolution);
  writer.writeString(offsets[14], object.duplicateStatus);
  writer.writeString(offsets[15], object.externalCounterpartyName);
  writer.writeDouble(offsets[16], object.feeComponent);
  writer.writeString(offsets[17], object.fingerprint);
  writer.writeDateTime(offsets[18], object.importedAt);
  writer.writeDouble(offsets[19], object.interestComponent);
  writer.writeBool(offsets[20], object.isIncluded);
  writer.writeString(offsets[21], object.linkedInvestmentId);
  writer.writeString(offsets[22], object.linkedLoanId);
  writer.writeString(offsets[23], object.linkedMoneyRecordId);
  writer.writeString(offsets[24], object.matchedTransactionId);
  writer.writeString(offsets[25], object.merchantDisplayName);
  writer.writeString(offsets[26], object.normalizedMerchant);
  writer.writeString(offsets[27], object.notes);
  writer.writeString(offsets[28], object.paymentMethod);
  writer.writeDouble(offsets[29], object.principalComponent);
  writer.writeString(offsets[30], object.purpose);
  writer.writeString(offsets[31], object.rawMerchant);
  writer.writeString(offsets[32], object.rawSource);
  writer.writeString(offsets[33], object.referenceNumber);
  writer.writeString(offsets[34], object.reviewStatus);
  writer.writeString(offsets[35], object.source);
  writer.writeString(offsets[36], object.sourceIdentifier);
  writer.writeString(offsets[37], object.sourceName);
  writer.writeStringList(offsets[38], object.tags);
  writer.writeString(offsets[39], object.tempId);
  writer.writeDateTime(offsets[40], object.time);
  writer.writeString(offsets[41], object.toAccountId);
  writer.writeString(offsets[42], object.type);
  writer.writeStringList(offsets[43], object.validationErrors);
  writer.writeStringList(offsets[44], object.warnings);
}

PendingTransactionEntity _pendingTransactionEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PendingTransactionEntity();
  object.accountId = reader.readString(offsets[0]);
  object.amount = reader.readDouble(offsets[1]);
  object.categorizationConfidence = reader.readDouble(offsets[2]);
  object.categorizationReason = reader.readStringOrNull(offsets[3]);
  object.categoryColor = reader.readString(offsets[4]);
  object.categoryIcon = reader.readString(offsets[5]);
  object.categoryId = reader.readString(offsets[6]);
  object.categoryName = reader.readString(offsets[7]);
  object.date = reader.readDateTime(offsets[8]);
  object.detectedAt = reader.readDateTime(offsets[9]);
  object.direction = reader.readStringOrNull(offsets[10]);
  object.duplicateConfidence = reader.readDouble(offsets[11]);
  object.duplicateReasons = reader.readStringList(offsets[12]) ?? [];
  object.duplicateResolution = reader.readString(offsets[13]);
  object.duplicateStatus = reader.readString(offsets[14]);
  object.externalCounterpartyName = reader.readStringOrNull(offsets[15]);
  object.feeComponent = reader.readDoubleOrNull(offsets[16]);
  object.fingerprint = reader.readString(offsets[17]);
  object.id = id;
  object.importedAt = reader.readDateTime(offsets[18]);
  object.interestComponent = reader.readDoubleOrNull(offsets[19]);
  object.isIncluded = reader.readBool(offsets[20]);
  object.linkedInvestmentId = reader.readStringOrNull(offsets[21]);
  object.linkedLoanId = reader.readStringOrNull(offsets[22]);
  object.linkedMoneyRecordId = reader.readStringOrNull(offsets[23]);
  object.matchedTransactionId = reader.readStringOrNull(offsets[24]);
  object.merchantDisplayName = reader.readStringOrNull(offsets[25]);
  object.normalizedMerchant = reader.readString(offsets[26]);
  object.notes = reader.readStringOrNull(offsets[27]);
  object.paymentMethod = reader.readStringOrNull(offsets[28]);
  object.principalComponent = reader.readDoubleOrNull(offsets[29]);
  object.purpose = reader.readStringOrNull(offsets[30]);
  object.rawMerchant = reader.readString(offsets[31]);
  object.rawSource = reader.readStringOrNull(offsets[32]);
  object.referenceNumber = reader.readStringOrNull(offsets[33]);
  object.reviewStatus = reader.readString(offsets[34]);
  object.source = reader.readString(offsets[35]);
  object.sourceIdentifier = reader.readStringOrNull(offsets[36]);
  object.sourceName = reader.readStringOrNull(offsets[37]);
  object.tags = reader.readStringList(offsets[38]) ?? [];
  object.tempId = reader.readString(offsets[39]);
  object.time = reader.readDateTimeOrNull(offsets[40]);
  object.toAccountId = reader.readStringOrNull(offsets[41]);
  object.type = reader.readString(offsets[42]);
  object.validationErrors = reader.readStringList(offsets[43]) ?? [];
  object.warnings = reader.readStringList(offsets[44]) ?? [];
  return object;
}

P _pendingTransactionEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readDouble(offset)) as P;
    case 12:
      return (reader.readStringList(offset) ?? []) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readDoubleOrNull(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readDateTime(offset)) as P;
    case 19:
      return (reader.readDoubleOrNull(offset)) as P;
    case 20:
      return (reader.readBool(offset)) as P;
    case 21:
      return (reader.readStringOrNull(offset)) as P;
    case 22:
      return (reader.readStringOrNull(offset)) as P;
    case 23:
      return (reader.readStringOrNull(offset)) as P;
    case 24:
      return (reader.readStringOrNull(offset)) as P;
    case 25:
      return (reader.readStringOrNull(offset)) as P;
    case 26:
      return (reader.readString(offset)) as P;
    case 27:
      return (reader.readStringOrNull(offset)) as P;
    case 28:
      return (reader.readStringOrNull(offset)) as P;
    case 29:
      return (reader.readDoubleOrNull(offset)) as P;
    case 30:
      return (reader.readStringOrNull(offset)) as P;
    case 31:
      return (reader.readString(offset)) as P;
    case 32:
      return (reader.readStringOrNull(offset)) as P;
    case 33:
      return (reader.readStringOrNull(offset)) as P;
    case 34:
      return (reader.readString(offset)) as P;
    case 35:
      return (reader.readString(offset)) as P;
    case 36:
      return (reader.readStringOrNull(offset)) as P;
    case 37:
      return (reader.readStringOrNull(offset)) as P;
    case 38:
      return (reader.readStringList(offset) ?? []) as P;
    case 39:
      return (reader.readString(offset)) as P;
    case 40:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 41:
      return (reader.readStringOrNull(offset)) as P;
    case 42:
      return (reader.readString(offset)) as P;
    case 43:
      return (reader.readStringList(offset) ?? []) as P;
    case 44:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _pendingTransactionEntityGetId(PendingTransactionEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _pendingTransactionEntityGetLinks(
  PendingTransactionEntity object,
) {
  return [];
}

void _pendingTransactionEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  PendingTransactionEntity object,
) {
  object.id = id;
}

extension PendingTransactionEntityByIndex
    on IsarCollection<PendingTransactionEntity> {
  Future<PendingTransactionEntity?> getByTempId(String tempId) {
    return getByIndex(r'tempId', [tempId]);
  }

  PendingTransactionEntity? getByTempIdSync(String tempId) {
    return getByIndexSync(r'tempId', [tempId]);
  }

  Future<bool> deleteByTempId(String tempId) {
    return deleteByIndex(r'tempId', [tempId]);
  }

  bool deleteByTempIdSync(String tempId) {
    return deleteByIndexSync(r'tempId', [tempId]);
  }

  Future<List<PendingTransactionEntity?>> getAllByTempId(
    List<String> tempIdValues,
  ) {
    final values = tempIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'tempId', values);
  }

  List<PendingTransactionEntity?> getAllByTempIdSync(
    List<String> tempIdValues,
  ) {
    final values = tempIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'tempId', values);
  }

  Future<int> deleteAllByTempId(List<String> tempIdValues) {
    final values = tempIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'tempId', values);
  }

  int deleteAllByTempIdSync(List<String> tempIdValues) {
    final values = tempIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'tempId', values);
  }

  Future<Id> putByTempId(PendingTransactionEntity object) {
    return putByIndex(r'tempId', object);
  }

  Id putByTempIdSync(PendingTransactionEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'tempId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByTempId(List<PendingTransactionEntity> objects) {
    return putAllByIndex(r'tempId', objects);
  }

  List<Id> putAllByTempIdSync(
    List<PendingTransactionEntity> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'tempId', objects, saveLinks: saveLinks);
  }
}

extension PendingTransactionEntityQueryWhereSort
    on
        QueryBuilder<
          PendingTransactionEntity,
          PendingTransactionEntity,
          QWhere
        > {
  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterWhere>
  anyNormalizedMerchant() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'normalizedMerchant'),
      );
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterWhere>
  anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterWhere>
  anyImportedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'importedAt'),
      );
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterWhere>
  anyDetectedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'detectedAt'),
      );
    });
  }
}

extension PendingTransactionEntityQueryWhere
    on
        QueryBuilder<
          PendingTransactionEntity,
          PendingTransactionEntity,
          QWhereClause
        > {
  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
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
    PendingTransactionEntity,
    PendingTransactionEntity,
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
    PendingTransactionEntity,
    PendingTransactionEntity,
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
    PendingTransactionEntity,
    PendingTransactionEntity,
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  tempIdEqualTo(String tempId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'tempId', value: [tempId]),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  tempIdNotEqualTo(String tempId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'tempId',
                lower: [],
                upper: [tempId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'tempId',
                lower: [tempId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'tempId',
                lower: [tempId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'tempId',
                lower: [],
                upper: [tempId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  sourceEqualTo(String source) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'source', value: [source]),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  sourceNotEqualTo(String source) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'source',
                lower: [],
                upper: [source],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'source',
                lower: [source],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'source',
                lower: [source],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'source',
                lower: [],
                upper: [source],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  typeEqualTo(String type) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'type', value: [type]),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  normalizedMerchantGreaterThan(
    String normalizedMerchant, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'normalizedMerchant',
          lower: [normalizedMerchant],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  normalizedMerchantLessThan(
    String normalizedMerchant, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'normalizedMerchant',
          lower: [],
          upper: [normalizedMerchant],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  normalizedMerchantBetween(
    String lowerNormalizedMerchant,
    String upperNormalizedMerchant, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'normalizedMerchant',
          lower: [lowerNormalizedMerchant],
          includeLower: includeLower,
          upper: [upperNormalizedMerchant],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  normalizedMerchantStartsWith(String NormalizedMerchantPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'normalizedMerchant',
          lower: [NormalizedMerchantPrefix],
          upper: ['$NormalizedMerchantPrefix\u{FFFFF}'],
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  normalizedMerchantIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'normalizedMerchant', value: ['']),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  normalizedMerchantIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.lessThan(
                indexName: r'normalizedMerchant',
                upper: [''],
              ),
            )
            .addWhereClause(
              IndexWhereClause.greaterThan(
                indexName: r'normalizedMerchant',
                lower: [''],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.greaterThan(
                indexName: r'normalizedMerchant',
                lower: [''],
              ),
            )
            .addWhereClause(
              IndexWhereClause.lessThan(
                indexName: r'normalizedMerchant',
                upper: [''],
              ),
            );
      }
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  dateEqualTo(DateTime date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'date', value: [date]),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  dateNotEqualTo(DateTime date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'date',
                lower: [],
                upper: [date],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'date',
                lower: [date],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'date',
                lower: [date],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'date',
                lower: [],
                upper: [date],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  dateGreaterThan(DateTime date, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'date',
          lower: [date],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  dateLessThan(DateTime date, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'date',
          lower: [],
          upper: [date],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  dateBetween(
    DateTime lowerDate,
    DateTime upperDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'date',
          lower: [lowerDate],
          includeLower: includeLower,
          upper: [upperDate],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  accountIdEqualTo(String accountId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'accountId', value: [accountId]),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  accountIdNotEqualTo(String accountId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'accountId',
                lower: [],
                upper: [accountId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'accountId',
                lower: [accountId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'accountId',
                lower: [accountId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'accountId',
                lower: [],
                upper: [accountId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  categoryIdEqualTo(String categoryId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'categoryId', value: [categoryId]),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  categoryIdNotEqualTo(String categoryId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'categoryId',
                lower: [],
                upper: [categoryId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'categoryId',
                lower: [categoryId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'categoryId',
                lower: [categoryId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'categoryId',
                lower: [],
                upper: [categoryId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  referenceNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'referenceNumber', value: [null]),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  referenceNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'referenceNumber',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  referenceNumberEqualTo(String? referenceNumber) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'referenceNumber',
          value: [referenceNumber],
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  referenceNumberNotEqualTo(String? referenceNumber) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'referenceNumber',
                lower: [],
                upper: [referenceNumber],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'referenceNumber',
                lower: [referenceNumber],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'referenceNumber',
                lower: [referenceNumber],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'referenceNumber',
                lower: [],
                upper: [referenceNumber],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  fingerprintEqualTo(String fingerprint) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'fingerprint',
          value: [fingerprint],
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  fingerprintNotEqualTo(String fingerprint) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'fingerprint',
                lower: [],
                upper: [fingerprint],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'fingerprint',
                lower: [fingerprint],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'fingerprint',
                lower: [fingerprint],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'fingerprint',
                lower: [],
                upper: [fingerprint],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  duplicateStatusEqualTo(String duplicateStatus) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'duplicateStatus',
          value: [duplicateStatus],
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  duplicateStatusNotEqualTo(String duplicateStatus) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'duplicateStatus',
                lower: [],
                upper: [duplicateStatus],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'duplicateStatus',
                lower: [duplicateStatus],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'duplicateStatus',
                lower: [duplicateStatus],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'duplicateStatus',
                lower: [],
                upper: [duplicateStatus],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  reviewStatusEqualTo(String reviewStatus) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'reviewStatus',
          value: [reviewStatus],
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  reviewStatusNotEqualTo(String reviewStatus) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'reviewStatus',
                lower: [],
                upper: [reviewStatus],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'reviewStatus',
                lower: [reviewStatus],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'reviewStatus',
                lower: [reviewStatus],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'reviewStatus',
                lower: [],
                upper: [reviewStatus],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  importedAtEqualTo(DateTime importedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'importedAt', value: [importedAt]),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  importedAtNotEqualTo(DateTime importedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'importedAt',
                lower: [],
                upper: [importedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'importedAt',
                lower: [importedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'importedAt',
                lower: [importedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'importedAt',
                lower: [],
                upper: [importedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  importedAtGreaterThan(DateTime importedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'importedAt',
          lower: [importedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  importedAtLessThan(DateTime importedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'importedAt',
          lower: [],
          upper: [importedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  importedAtBetween(
    DateTime lowerImportedAt,
    DateTime upperImportedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'importedAt',
          lower: [lowerImportedAt],
          includeLower: includeLower,
          upper: [upperImportedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  detectedAtEqualTo(DateTime detectedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'detectedAt', value: [detectedAt]),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  detectedAtNotEqualTo(DateTime detectedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'detectedAt',
                lower: [],
                upper: [detectedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'detectedAt',
                lower: [detectedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'detectedAt',
                lower: [detectedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'detectedAt',
                lower: [],
                upper: [detectedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  detectedAtGreaterThan(DateTime detectedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'detectedAt',
          lower: [detectedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  detectedAtLessThan(DateTime detectedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'detectedAt',
          lower: [],
          upper: [detectedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterWhereClause
  >
  detectedAtBetween(
    DateTime lowerDetectedAt,
    DateTime upperDetectedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'detectedAt',
          lower: [lowerDetectedAt],
          includeLower: includeLower,
          upper: [upperDetectedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension PendingTransactionEntityQueryFilter
    on
        QueryBuilder<
          PendingTransactionEntity,
          PendingTransactionEntity,
          QFilterCondition
        > {
  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  accountIdEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  accountIdGreaterThan(
    String value, {
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  accountIdLessThan(
    String value, {
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  accountIdBetween(
    String lower,
    String upper, {
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  accountIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'accountId', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  accountIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'accountId', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categorizationConfidenceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'categorizationConfidence',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categorizationConfidenceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'categorizationConfidence',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categorizationConfidenceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'categorizationConfidence',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categorizationConfidenceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'categorizationConfidence',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categorizationReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'categorizationReason'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categorizationReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'categorizationReason'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categorizationReasonEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'categorizationReason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categorizationReasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'categorizationReason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categorizationReasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'categorizationReason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categorizationReasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'categorizationReason',
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
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categorizationReasonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'categorizationReason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categorizationReasonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'categorizationReason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categorizationReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'categorizationReason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categorizationReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'categorizationReason',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categorizationReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'categorizationReason', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categorizationReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'categorizationReason',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryColorEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'categoryColor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryColorGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'categoryColor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryColorLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'categoryColor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryColorBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'categoryColor',
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
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryColorStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'categoryColor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryColorEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'categoryColor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryColorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'categoryColor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryColorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'categoryColor',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryColorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'categoryColor', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryColorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'categoryColor', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryIconEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'categoryIcon',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryIconGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'categoryIcon',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryIconLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'categoryIcon',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryIconBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'categoryIcon',
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
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryIconStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'categoryIcon',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryIconEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'categoryIcon',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryIconContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'categoryIcon',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryIconMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'categoryIcon',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryIconIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'categoryIcon', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryIconIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'categoryIcon', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'categoryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'categoryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'categoryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'categoryId',
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
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'categoryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'categoryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'categoryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'categoryId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'categoryId', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'categoryId', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'categoryName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'categoryName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'categoryName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'categoryName',
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
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'categoryName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'categoryName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'categoryName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'categoryName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'categoryName', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  categoryNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'categoryName', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'date', value: value),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  dateGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'date',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  dateLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'date',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'date',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  detectedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'detectedAt', value: value),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  detectedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'detectedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  detectedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'detectedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  detectedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'detectedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  directionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'direction'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  directionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'direction'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  directionEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'direction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  directionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'direction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  directionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'direction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  directionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'direction',
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
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  directionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'direction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  directionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'direction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  directionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'direction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  directionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'direction',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  directionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'direction', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  directionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'direction', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateConfidenceEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'duplicateConfidence',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateConfidenceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'duplicateConfidence',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateConfidenceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'duplicateConfidence',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateConfidenceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'duplicateConfidence',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateReasonsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'duplicateReasons',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateReasonsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'duplicateReasons',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateReasonsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'duplicateReasons',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateReasonsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'duplicateReasons',
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
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateReasonsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'duplicateReasons',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateReasonsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'duplicateReasons',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateReasonsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'duplicateReasons',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateReasonsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'duplicateReasons',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateReasonsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'duplicateReasons', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateReasonsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'duplicateReasons', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateReasonsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'duplicateReasons', length, true, length, true);
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateReasonsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'duplicateReasons', 0, true, 0, true);
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateReasonsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'duplicateReasons', 0, false, 999999, true);
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateReasonsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'duplicateReasons', 0, true, length, include);
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateReasonsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'duplicateReasons',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateReasonsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'duplicateReasons',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateResolutionEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'duplicateResolution',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateResolutionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'duplicateResolution',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateResolutionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'duplicateResolution',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateResolutionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'duplicateResolution',
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
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateResolutionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'duplicateResolution',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateResolutionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'duplicateResolution',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateResolutionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'duplicateResolution',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateResolutionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'duplicateResolution',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateResolutionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'duplicateResolution', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateResolutionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'duplicateResolution',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateStatusEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'duplicateStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateStatusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'duplicateStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateStatusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'duplicateStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateStatusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'duplicateStatus',
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
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateStatusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'duplicateStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateStatusEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'duplicateStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'duplicateStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'duplicateStatus',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'duplicateStatus', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  duplicateStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'duplicateStatus', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  externalCounterpartyNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'externalCounterpartyName'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  externalCounterpartyNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'externalCounterpartyName'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  externalCounterpartyNameEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'externalCounterpartyName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  externalCounterpartyNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'externalCounterpartyName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  externalCounterpartyNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'externalCounterpartyName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  externalCounterpartyNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'externalCounterpartyName',
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
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  externalCounterpartyNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'externalCounterpartyName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  externalCounterpartyNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'externalCounterpartyName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  externalCounterpartyNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'externalCounterpartyName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  externalCounterpartyNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'externalCounterpartyName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  externalCounterpartyNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'externalCounterpartyName',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  externalCounterpartyNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'externalCounterpartyName',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  feeComponentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'feeComponent'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  feeComponentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'feeComponent'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  feeComponentEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'feeComponent',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  feeComponentGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'feeComponent',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  feeComponentLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'feeComponent',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  feeComponentBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'feeComponent',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  fingerprintEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'fingerprint',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  fingerprintGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fingerprint',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  fingerprintLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fingerprint',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  fingerprintBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fingerprint',
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
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  fingerprintStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'fingerprint',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  fingerprintEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'fingerprint',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  fingerprintContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'fingerprint',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  fingerprintMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'fingerprint',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  fingerprintIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fingerprint', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  fingerprintIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'fingerprint', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
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
    PendingTransactionEntity,
    PendingTransactionEntity,
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
    PendingTransactionEntity,
    PendingTransactionEntity,
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
    PendingTransactionEntity,
    PendingTransactionEntity,
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
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  importedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'importedAt', value: value),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  importedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'importedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  importedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'importedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  importedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'importedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  interestComponentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'interestComponent'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  interestComponentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'interestComponent'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  interestComponentEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'interestComponent',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  interestComponentGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'interestComponent',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  interestComponentLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'interestComponent',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  interestComponentBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'interestComponent',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  isIncludedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isIncluded', value: value),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedInvestmentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'linkedInvestmentId'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedInvestmentIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'linkedInvestmentId'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedInvestmentIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'linkedInvestmentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedInvestmentIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'linkedInvestmentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedInvestmentIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'linkedInvestmentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedInvestmentIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'linkedInvestmentId',
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
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedInvestmentIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'linkedInvestmentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedInvestmentIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'linkedInvestmentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedInvestmentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'linkedInvestmentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedInvestmentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'linkedInvestmentId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedInvestmentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'linkedInvestmentId', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedInvestmentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'linkedInvestmentId', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedLoanIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'linkedLoanId'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedLoanIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'linkedLoanId'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedLoanIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'linkedLoanId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedLoanIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'linkedLoanId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedLoanIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'linkedLoanId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedLoanIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'linkedLoanId',
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
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedLoanIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'linkedLoanId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedLoanIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'linkedLoanId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedLoanIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'linkedLoanId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedLoanIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'linkedLoanId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedLoanIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'linkedLoanId', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedLoanIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'linkedLoanId', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedMoneyRecordIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'linkedMoneyRecordId'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedMoneyRecordIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'linkedMoneyRecordId'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedMoneyRecordIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'linkedMoneyRecordId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedMoneyRecordIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'linkedMoneyRecordId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedMoneyRecordIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'linkedMoneyRecordId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedMoneyRecordIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'linkedMoneyRecordId',
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
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedMoneyRecordIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'linkedMoneyRecordId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedMoneyRecordIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'linkedMoneyRecordId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedMoneyRecordIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'linkedMoneyRecordId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedMoneyRecordIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'linkedMoneyRecordId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedMoneyRecordIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'linkedMoneyRecordId', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  linkedMoneyRecordIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'linkedMoneyRecordId',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  matchedTransactionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'matchedTransactionId'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  matchedTransactionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'matchedTransactionId'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  matchedTransactionIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'matchedTransactionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  matchedTransactionIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'matchedTransactionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  matchedTransactionIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'matchedTransactionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  matchedTransactionIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'matchedTransactionId',
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
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  matchedTransactionIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'matchedTransactionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  matchedTransactionIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'matchedTransactionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  matchedTransactionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'matchedTransactionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  matchedTransactionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'matchedTransactionId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  matchedTransactionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'matchedTransactionId', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  matchedTransactionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'matchedTransactionId',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  merchantDisplayNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'merchantDisplayName'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  merchantDisplayNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'merchantDisplayName'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  merchantDisplayNameEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'merchantDisplayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  merchantDisplayNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'merchantDisplayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  merchantDisplayNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'merchantDisplayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  merchantDisplayNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'merchantDisplayName',
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
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  merchantDisplayNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'merchantDisplayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  merchantDisplayNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'merchantDisplayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  merchantDisplayNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'merchantDisplayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  merchantDisplayNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'merchantDisplayName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  merchantDisplayNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'merchantDisplayName', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  merchantDisplayNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'merchantDisplayName',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  normalizedMerchantIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'normalizedMerchant', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  normalizedMerchantIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'normalizedMerchant', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  paymentMethodIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'paymentMethod'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  paymentMethodIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'paymentMethod'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  paymentMethodIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'paymentMethod', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  paymentMethodIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'paymentMethod', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  principalComponentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'principalComponent'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  principalComponentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'principalComponent'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  principalComponentEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'principalComponent',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  principalComponentGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'principalComponent',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  principalComponentLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'principalComponent',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  principalComponentBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'principalComponent',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  purposeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'purpose'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  purposeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'purpose'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  purposeEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'purpose',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  purposeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'purpose',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  purposeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'purpose',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  purposeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'purpose',
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
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  purposeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'purpose',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  purposeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'purpose',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  purposeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'purpose',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  purposeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'purpose',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  purposeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'purpose', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  purposeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'purpose', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  rawMerchantEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'rawMerchant',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  rawMerchantGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'rawMerchant',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  rawMerchantLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'rawMerchant',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  rawMerchantBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'rawMerchant',
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
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  rawMerchantStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'rawMerchant',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  rawMerchantEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'rawMerchant',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  rawMerchantContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'rawMerchant',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  rawMerchantMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'rawMerchant',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  rawMerchantIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'rawMerchant', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  rawMerchantIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'rawMerchant', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  rawSourceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'rawSource'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  rawSourceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'rawSource'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  rawSourceEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'rawSource',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  rawSourceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'rawSource',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  rawSourceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'rawSource',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  rawSourceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'rawSource',
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
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  rawSourceStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'rawSource',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  rawSourceEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'rawSource',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  rawSourceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'rawSource',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  rawSourceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'rawSource',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  rawSourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'rawSource', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  rawSourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'rawSource', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  referenceNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'referenceNumber'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  referenceNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'referenceNumber'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  referenceNumberEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'referenceNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  referenceNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'referenceNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  referenceNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'referenceNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  referenceNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'referenceNumber',
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
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  referenceNumberStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'referenceNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  referenceNumberEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'referenceNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  referenceNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'referenceNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  referenceNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'referenceNumber',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  referenceNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'referenceNumber', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  referenceNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'referenceNumber', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  reviewStatusEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'reviewStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  reviewStatusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'reviewStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  reviewStatusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'reviewStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  reviewStatusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'reviewStatus',
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
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  reviewStatusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'reviewStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  reviewStatusEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'reviewStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  reviewStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'reviewStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  reviewStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'reviewStatus',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  reviewStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'reviewStatus', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  reviewStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'reviewStatus', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'source',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'source',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'source',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'source',
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
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'source',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'source',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'source',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'source',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'source', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'source', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceIdentifierIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'sourceIdentifier'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceIdentifierIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'sourceIdentifier'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceIdentifierEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sourceIdentifier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceIdentifierGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sourceIdentifier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceIdentifierLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sourceIdentifier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceIdentifierBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sourceIdentifier',
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
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceIdentifierStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sourceIdentifier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceIdentifierEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sourceIdentifier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceIdentifierContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sourceIdentifier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceIdentifierMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sourceIdentifier',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceIdentifierIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sourceIdentifier', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceIdentifierIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sourceIdentifier', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'sourceName'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'sourceName'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceNameEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sourceName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sourceName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sourceName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sourceName',
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
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sourceName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sourceName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sourceName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sourceName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sourceName', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  sourceNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sourceName', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  tagsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  tagsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  tagsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  tagsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tags',
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
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  tagsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  tagsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  tagsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  tagsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'tags',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  tagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tags', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  tagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'tags', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  tagsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', length, true, length, true);
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  tagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', 0, true, 0, true);
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', 0, false, 999999, true);
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  tagsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', 0, true, length, include);
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  tagsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', length, include, 999999, true);
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  tagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  tempIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'tempId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  tempIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tempId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  tempIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tempId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  tempIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tempId',
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
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  tempIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'tempId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  tempIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'tempId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  tempIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'tempId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  tempIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'tempId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  tempIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tempId', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  tempIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'tempId', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  timeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'time'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  timeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'time'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  timeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'time', value: value),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  timeGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'time',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  timeLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'time',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  timeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'time',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  toAccountIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'toAccountId'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  toAccountIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'toAccountId'),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  toAccountIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'toAccountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  toAccountIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'toAccountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  toAccountIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'toAccountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  toAccountIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'toAccountId',
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
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  toAccountIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'toAccountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  toAccountIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'toAccountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  toAccountIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'toAccountId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  toAccountIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'toAccountId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  toAccountIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'toAccountId', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  toAccountIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'toAccountId', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'type', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'type', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  validationErrorsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'validationErrors',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  validationErrorsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'validationErrors',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  validationErrorsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'validationErrors',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  validationErrorsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'validationErrors',
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
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  validationErrorsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'validationErrors',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  validationErrorsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'validationErrors',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  validationErrorsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'validationErrors',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  validationErrorsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'validationErrors',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  validationErrorsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'validationErrors', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  validationErrorsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'validationErrors', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  validationErrorsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'validationErrors', length, true, length, true);
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  validationErrorsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'validationErrors', 0, true, 0, true);
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  validationErrorsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'validationErrors', 0, false, 999999, true);
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  validationErrorsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'validationErrors', 0, true, length, include);
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  validationErrorsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'validationErrors',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  validationErrorsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'validationErrors',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  warningsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'warnings',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  warningsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'warnings',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  warningsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'warnings',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  warningsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'warnings',
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
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  warningsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'warnings',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  warningsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'warnings',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  warningsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'warnings',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  warningsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'warnings',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  warningsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'warnings', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  warningsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'warnings', value: ''),
      );
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  warningsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'warnings', length, true, length, true);
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  warningsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'warnings', 0, true, 0, true);
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  warningsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'warnings', 0, false, 999999, true);
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  warningsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'warnings', 0, true, length, include);
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  warningsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'warnings', length, include, 999999, true);
    });
  }

  QueryBuilder<
    PendingTransactionEntity,
    PendingTransactionEntity,
    QAfterFilterCondition
  >
  warningsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'warnings',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension PendingTransactionEntityQueryObject
    on
        QueryBuilder<
          PendingTransactionEntity,
          PendingTransactionEntity,
          QFilterCondition
        > {}

extension PendingTransactionEntityQueryLinks
    on
        QueryBuilder<
          PendingTransactionEntity,
          PendingTransactionEntity,
          QFilterCondition
        > {}

extension PendingTransactionEntityQuerySortBy
    on
        QueryBuilder<
          PendingTransactionEntity,
          PendingTransactionEntity,
          QSortBy
        > {
  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByCategorizationConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categorizationConfidence', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByCategorizationConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categorizationConfidence', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByCategorizationReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categorizationReason', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByCategorizationReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categorizationReason', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByCategoryColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryColor', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByCategoryColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryColor', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByCategoryIcon() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryIcon', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByCategoryIconDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryIcon', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByCategoryName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryName', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByCategoryNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryName', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByDetectedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detectedAt', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByDetectedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detectedAt', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByDirection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByDirectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByDuplicateConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duplicateConfidence', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByDuplicateConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duplicateConfidence', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByDuplicateResolution() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duplicateResolution', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByDuplicateResolutionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duplicateResolution', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByDuplicateStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duplicateStatus', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByDuplicateStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duplicateStatus', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByExternalCounterpartyName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalCounterpartyName', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByExternalCounterpartyNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalCounterpartyName', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByFeeComponent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feeComponent', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByFeeComponentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feeComponent', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fingerprint', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fingerprint', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByImportedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importedAt', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByImportedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importedAt', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByInterestComponent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestComponent', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByInterestComponentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestComponent', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByIsIncluded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isIncluded', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByIsIncludedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isIncluded', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByLinkedInvestmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedInvestmentId', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByLinkedInvestmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedInvestmentId', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByLinkedLoanId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedLoanId', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByLinkedLoanIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedLoanId', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByLinkedMoneyRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedMoneyRecordId', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByLinkedMoneyRecordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedMoneyRecordId', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByMatchedTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'matchedTransactionId', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByMatchedTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'matchedTransactionId', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByMerchantDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantDisplayName', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByMerchantDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantDisplayName', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByNormalizedMerchant() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedMerchant', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByNormalizedMerchantDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedMerchant', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByPaymentMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByPaymentMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByPrincipalComponent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'principalComponent', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByPrincipalComponentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'principalComponent', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByPurpose() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purpose', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByPurposeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purpose', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByRawMerchant() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawMerchant', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByRawMerchantDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawMerchant', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByRawSource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawSource', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByRawSourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawSource', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByReferenceNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceNumber', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByReferenceNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceNumber', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByReviewStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewStatus', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByReviewStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewStatus', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortBySourceIdentifier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceIdentifier', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortBySourceIdentifierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceIdentifier', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortBySourceName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceName', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortBySourceNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceName', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByTempId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tempId', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByTempIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tempId', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByToAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toAccountId', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByToAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toAccountId', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension PendingTransactionEntityQuerySortThenBy
    on
        QueryBuilder<
          PendingTransactionEntity,
          PendingTransactionEntity,
          QSortThenBy
        > {
  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByCategorizationConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categorizationConfidence', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByCategorizationConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categorizationConfidence', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByCategorizationReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categorizationReason', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByCategorizationReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categorizationReason', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByCategoryColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryColor', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByCategoryColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryColor', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByCategoryIcon() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryIcon', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByCategoryIconDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryIcon', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByCategoryName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryName', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByCategoryNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryName', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByDetectedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detectedAt', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByDetectedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detectedAt', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByDirection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByDirectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByDuplicateConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duplicateConfidence', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByDuplicateConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duplicateConfidence', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByDuplicateResolution() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duplicateResolution', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByDuplicateResolutionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duplicateResolution', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByDuplicateStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duplicateStatus', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByDuplicateStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duplicateStatus', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByExternalCounterpartyName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalCounterpartyName', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByExternalCounterpartyNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalCounterpartyName', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByFeeComponent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feeComponent', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByFeeComponentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feeComponent', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fingerprint', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fingerprint', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByImportedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importedAt', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByImportedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importedAt', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByInterestComponent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestComponent', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByInterestComponentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestComponent', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByIsIncluded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isIncluded', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByIsIncludedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isIncluded', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByLinkedInvestmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedInvestmentId', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByLinkedInvestmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedInvestmentId', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByLinkedLoanId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedLoanId', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByLinkedLoanIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedLoanId', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByLinkedMoneyRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedMoneyRecordId', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByLinkedMoneyRecordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedMoneyRecordId', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByMatchedTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'matchedTransactionId', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByMatchedTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'matchedTransactionId', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByMerchantDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantDisplayName', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByMerchantDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantDisplayName', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByNormalizedMerchant() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedMerchant', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByNormalizedMerchantDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedMerchant', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByPaymentMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByPaymentMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByPrincipalComponent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'principalComponent', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByPrincipalComponentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'principalComponent', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByPurpose() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purpose', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByPurposeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purpose', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByRawMerchant() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawMerchant', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByRawMerchantDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawMerchant', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByRawSource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawSource', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByRawSourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawSource', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByReferenceNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceNumber', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByReferenceNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceNumber', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByReviewStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewStatus', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByReviewStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewStatus', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenBySourceIdentifier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceIdentifier', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenBySourceIdentifierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceIdentifier', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenBySourceName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceName', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenBySourceNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceName', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByTempId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tempId', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByTempIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tempId', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByToAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toAccountId', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByToAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toAccountId', Sort.desc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QAfterSortBy>
  thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension PendingTransactionEntityQueryWhereDistinct
    on
        QueryBuilder<
          PendingTransactionEntity,
          PendingTransactionEntity,
          QDistinct
        > {
  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByAccountId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accountId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByCategorizationConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categorizationConfidence');
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByCategorizationReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'categorizationReason',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByCategoryColor({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'categoryColor',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByCategoryIcon({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryIcon', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByCategoryId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByCategoryName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByDetectedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'detectedAt');
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByDirection({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'direction', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByDuplicateConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'duplicateConfidence');
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByDuplicateReasons() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'duplicateReasons');
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByDuplicateResolution({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'duplicateResolution',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByDuplicateStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'duplicateStatus',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByExternalCounterpartyName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'externalCounterpartyName',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByFeeComponent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'feeComponent');
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByFingerprint({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fingerprint', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByImportedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'importedAt');
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByInterestComponent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'interestComponent');
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByIsIncluded() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isIncluded');
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByLinkedInvestmentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'linkedInvestmentId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByLinkedLoanId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'linkedLoanId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByLinkedMoneyRecordId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'linkedMoneyRecordId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByMatchedTransactionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'matchedTransactionId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByMerchantDisplayName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'merchantDisplayName',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByNormalizedMerchant({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'normalizedMerchant',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByNotes({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByPaymentMethod({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'paymentMethod',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByPrincipalComponent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'principalComponent');
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByPurpose({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'purpose', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByRawMerchant({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rawMerchant', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByRawSource({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rawSource', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByReferenceNumber({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'referenceNumber',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByReviewStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reviewStatus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctBySource({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'source', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctBySourceIdentifier({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'sourceIdentifier',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctBySourceName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tags');
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByTempId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tempId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'time');
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByToAccountId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'toAccountId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByValidationErrors() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'validationErrors');
    });
  }

  QueryBuilder<PendingTransactionEntity, PendingTransactionEntity, QDistinct>
  distinctByWarnings() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'warnings');
    });
  }
}

extension PendingTransactionEntityQueryProperty
    on
        QueryBuilder<
          PendingTransactionEntity,
          PendingTransactionEntity,
          QQueryProperty
        > {
  QueryBuilder<PendingTransactionEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PendingTransactionEntity, String, QQueryOperations>
  accountIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accountId');
    });
  }

  QueryBuilder<PendingTransactionEntity, double, QQueryOperations>
  amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<PendingTransactionEntity, double, QQueryOperations>
  categorizationConfidenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categorizationConfidence');
    });
  }

  QueryBuilder<PendingTransactionEntity, String?, QQueryOperations>
  categorizationReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categorizationReason');
    });
  }

  QueryBuilder<PendingTransactionEntity, String, QQueryOperations>
  categoryColorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryColor');
    });
  }

  QueryBuilder<PendingTransactionEntity, String, QQueryOperations>
  categoryIconProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryIcon');
    });
  }

  QueryBuilder<PendingTransactionEntity, String, QQueryOperations>
  categoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryId');
    });
  }

  QueryBuilder<PendingTransactionEntity, String, QQueryOperations>
  categoryNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryName');
    });
  }

  QueryBuilder<PendingTransactionEntity, DateTime, QQueryOperations>
  dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<PendingTransactionEntity, DateTime, QQueryOperations>
  detectedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'detectedAt');
    });
  }

  QueryBuilder<PendingTransactionEntity, String?, QQueryOperations>
  directionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'direction');
    });
  }

  QueryBuilder<PendingTransactionEntity, double, QQueryOperations>
  duplicateConfidenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'duplicateConfidence');
    });
  }

  QueryBuilder<PendingTransactionEntity, List<String>, QQueryOperations>
  duplicateReasonsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'duplicateReasons');
    });
  }

  QueryBuilder<PendingTransactionEntity, String, QQueryOperations>
  duplicateResolutionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'duplicateResolution');
    });
  }

  QueryBuilder<PendingTransactionEntity, String, QQueryOperations>
  duplicateStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'duplicateStatus');
    });
  }

  QueryBuilder<PendingTransactionEntity, String?, QQueryOperations>
  externalCounterpartyNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'externalCounterpartyName');
    });
  }

  QueryBuilder<PendingTransactionEntity, double?, QQueryOperations>
  feeComponentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'feeComponent');
    });
  }

  QueryBuilder<PendingTransactionEntity, String, QQueryOperations>
  fingerprintProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fingerprint');
    });
  }

  QueryBuilder<PendingTransactionEntity, DateTime, QQueryOperations>
  importedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'importedAt');
    });
  }

  QueryBuilder<PendingTransactionEntity, double?, QQueryOperations>
  interestComponentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'interestComponent');
    });
  }

  QueryBuilder<PendingTransactionEntity, bool, QQueryOperations>
  isIncludedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isIncluded');
    });
  }

  QueryBuilder<PendingTransactionEntity, String?, QQueryOperations>
  linkedInvestmentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkedInvestmentId');
    });
  }

  QueryBuilder<PendingTransactionEntity, String?, QQueryOperations>
  linkedLoanIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkedLoanId');
    });
  }

  QueryBuilder<PendingTransactionEntity, String?, QQueryOperations>
  linkedMoneyRecordIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkedMoneyRecordId');
    });
  }

  QueryBuilder<PendingTransactionEntity, String?, QQueryOperations>
  matchedTransactionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'matchedTransactionId');
    });
  }

  QueryBuilder<PendingTransactionEntity, String?, QQueryOperations>
  merchantDisplayNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'merchantDisplayName');
    });
  }

  QueryBuilder<PendingTransactionEntity, String, QQueryOperations>
  normalizedMerchantProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'normalizedMerchant');
    });
  }

  QueryBuilder<PendingTransactionEntity, String?, QQueryOperations>
  notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<PendingTransactionEntity, String?, QQueryOperations>
  paymentMethodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paymentMethod');
    });
  }

  QueryBuilder<PendingTransactionEntity, double?, QQueryOperations>
  principalComponentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'principalComponent');
    });
  }

  QueryBuilder<PendingTransactionEntity, String?, QQueryOperations>
  purposeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'purpose');
    });
  }

  QueryBuilder<PendingTransactionEntity, String, QQueryOperations>
  rawMerchantProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rawMerchant');
    });
  }

  QueryBuilder<PendingTransactionEntity, String?, QQueryOperations>
  rawSourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rawSource');
    });
  }

  QueryBuilder<PendingTransactionEntity, String?, QQueryOperations>
  referenceNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'referenceNumber');
    });
  }

  QueryBuilder<PendingTransactionEntity, String, QQueryOperations>
  reviewStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reviewStatus');
    });
  }

  QueryBuilder<PendingTransactionEntity, String, QQueryOperations>
  sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'source');
    });
  }

  QueryBuilder<PendingTransactionEntity, String?, QQueryOperations>
  sourceIdentifierProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceIdentifier');
    });
  }

  QueryBuilder<PendingTransactionEntity, String?, QQueryOperations>
  sourceNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceName');
    });
  }

  QueryBuilder<PendingTransactionEntity, List<String>, QQueryOperations>
  tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tags');
    });
  }

  QueryBuilder<PendingTransactionEntity, String, QQueryOperations>
  tempIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tempId');
    });
  }

  QueryBuilder<PendingTransactionEntity, DateTime?, QQueryOperations>
  timeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'time');
    });
  }

  QueryBuilder<PendingTransactionEntity, String?, QQueryOperations>
  toAccountIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'toAccountId');
    });
  }

  QueryBuilder<PendingTransactionEntity, String, QQueryOperations>
  typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<PendingTransactionEntity, List<String>, QQueryOperations>
  validationErrorsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'validationErrors');
    });
  }

  QueryBuilder<PendingTransactionEntity, List<String>, QQueryOperations>
  warningsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'warnings');
    });
  }
}
