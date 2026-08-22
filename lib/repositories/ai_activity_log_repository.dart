import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../database/isar_service.dart';
import '../database/schemas/ai_activity_log_entity.dart';
import '../models/ai_activity_log.dart';

abstract class AiActivityLogRepository {
  Future<List<AiActivityLog>> getAllLogs();
  Stream<List<AiActivityLog>> watchAllLogs();
  Future<void> logActivity(AiActivityLog log);
  Future<void> updateAccepted(String id, bool accepted);
  Future<void> clearLogs();
}

class IsarAiActivityLogRepository implements AiActivityLogRepository {
  final Isar isar;

  IsarAiActivityLogRepository({Isar? isarInstance})
    : isar = isarInstance ?? IsarService.instance.isar;

  AiActivityLog _toDomain(AiActivityLogEntity entity) {
    return AiActivityLog(
      id: entity.uuid,
      timestamp: entity.timestamp,
      featureUsed: entity.featureUsed,
      dataCategoriesSent: List<String>.from(entity.dataCategoriesSent),
      sanitizedPayloadSummary: entity.sanitizedPayloadSummary,
      resultSummary: entity.resultSummary,
      userAccepted: entity.userAccepted,
      errorState: entity.errorState,
    );
  }

  AiActivityLogEntity _toEntity(AiActivityLog domain) {
    return AiActivityLogEntity()
      ..uuid = domain.id
      ..timestamp = domain.timestamp
      ..featureUsed = domain.featureUsed
      ..dataCategoriesSent = domain.dataCategoriesSent
      ..sanitizedPayloadSummary = domain.sanitizedPayloadSummary
      ..resultSummary = domain.resultSummary
      ..userAccepted = domain.userAccepted
      ..errorState = domain.errorState;
  }

  @override
  Future<List<AiActivityLog>> getAllLogs() async {
    final entities =
        await isar.aiActivityLogEntitys.where().sortByTimestampDesc().findAll();
    return entities.map(_toDomain).toList();
  }

  @override
  Stream<List<AiActivityLog>> watchAllLogs() {
    return isar.aiActivityLogEntitys
        .where()
        .sortByTimestampDesc()
        .watch(fireImmediately: true)
        .map((entities) => entities.map(_toDomain).toList());
  }

  @override
  Future<void> logActivity(AiActivityLog log) async {
    await isar.writeTxn(() async {
      final entity = _toEntity(log);
      await isar.aiActivityLogEntitys.put(entity);
    });
  }

  @override
  Future<void> updateAccepted(String id, bool accepted) async {
    await isar.writeTxn(() async {
      final entity =
          await isar.aiActivityLogEntitys.filter().uuidEqualTo(id).findFirst();
      if (entity != null) {
        entity.userAccepted = accepted;
        await isar.aiActivityLogEntitys.put(entity);
      }
    });
  }

  @override
  Future<void> clearLogs() async {
    await isar.writeTxn(() async {
      await isar.aiActivityLogEntitys.clear();
    });
  }
}

final aiActivityLogRepositoryProvider = Provider<AiActivityLogRepository>((
  ref,
) {
  return IsarAiActivityLogRepository();
});

final allAiLogsStreamProvider = StreamProvider<List<AiActivityLog>>((ref) {
  final repo = ref.watch(aiActivityLogRepositoryProvider);
  return repo.watchAllLogs();
});
