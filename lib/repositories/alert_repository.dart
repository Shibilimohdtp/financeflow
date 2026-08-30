import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../database/isar_service.dart';
import '../database/schemas/alert_entity.dart';
import '../models/alert_item.dart';

abstract class AlertRepository {
  Future<List<AlertItem>> getActiveAlerts();
  Stream<List<AlertItem>> watchActiveAlerts();
  Future<List<AlertItem>> getAllAlerts();
  Future<void> saveAlert(AlertItem alert);
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> dismissAlert(String id);
  Future<void> clearAllAlerts();

  /// Removes duplicate records left by older alert scans, keeping the newest.
  Future<void> deduplicateAlerts();
  Future<bool> alertExistsForEntity({
    required AlertType type,
    required String relatedEntityId,
    required DateTime sinceDate,
  });
}

class IsarAlertRepository implements AlertRepository {
  final Isar isar;

  IsarAlertRepository({Isar? isarInstance})
    : isar = isarInstance ?? IsarService.instance.isar;

  AlertItem _toDomain(AlertEntity entity) {
    return AlertItem(
      id: entity.uuid,
      type: AlertType.fromString(entity.type),
      title: entity.title,
      message: entity.message,
      severity: AlertSeverity.fromString(entity.severity),
      relatedEntityType: entity.relatedEntityType,
      relatedEntityId: entity.relatedEntityId,
      scheduledAt: entity.scheduledAt,
      createdAt: entity.createdAt,
      isRead: entity.isRead,
      isDismissed: entity.isDismissed,
      localNotificationId: entity.localNotificationId,
    );
  }

  AlertEntity _toEntity(AlertItem domain) {
    return AlertEntity()
      ..uuid = domain.id
      ..type = domain.type.toDbString()
      ..title = domain.title
      ..message = domain.message
      ..severity = domain.severity.toDbString()
      ..relatedEntityType = domain.relatedEntityType
      ..relatedEntityId = domain.relatedEntityId
      ..scheduledAt = domain.scheduledAt
      ..createdAt = domain.createdAt
      ..isRead = domain.isRead
      ..isDismissed = domain.isDismissed
      ..localNotificationId = domain.localNotificationId;
  }

  @override
  Future<List<AlertItem>> getActiveAlerts() async {
    final entities =
        await isar.alertEntitys
            .where()
            .filter()
            .isDismissedEqualTo(false)
            .sortByCreatedAtDesc()
            .findAll();
    return entities.map(_toDomain).toList();
  }

  @override
  Stream<List<AlertItem>> watchActiveAlerts() {
    return isar.alertEntitys
        .where()
        .filter()
        .isDismissedEqualTo(false)
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true)
        .map((entities) => entities.map(_toDomain).toList());
  }

  @override
  Future<List<AlertItem>> getAllAlerts() async {
    final entities =
        await isar.alertEntitys.where().sortByCreatedAtDesc().findAll();
    return entities.map(_toDomain).toList();
  }

  @override
  Future<void> saveAlert(AlertItem alert) async {
    await isar.writeTxn(() async {
      final existing =
          await isar.alertEntitys.filter().uuidEqualTo(alert.id).findFirst();
      final entity = _toEntity(alert);
      if (existing != null) {
        entity.id = existing.id;
      }
      await isar.alertEntitys.put(entity);
    });
  }

  @override
  Future<void> markAsRead(String id) async {
    await isar.writeTxn(() async {
      final entity =
          await isar.alertEntitys.filter().uuidEqualTo(id).findFirst();
      if (entity != null) {
        entity.isRead = true;
        await isar.alertEntitys.put(entity);
      }
    });
  }

  @override
  Future<void> markAllAsRead() async {
    await isar.writeTxn(() async {
      final entities =
          await isar.alertEntitys.filter().isReadEqualTo(false).findAll();
      for (final e in entities) {
        e.isRead = true;
      }
      await isar.alertEntitys.putAll(entities);
    });
  }

  @override
  Future<void> dismissAlert(String id) async {
    await isar.writeTxn(() async {
      final entity =
          await isar.alertEntitys.filter().uuidEqualTo(id).findFirst();
      if (entity != null) {
        entity.isDismissed = true;
        entity.isRead = true;
        await isar.alertEntitys.put(entity);
      }
    });
  }

  @override
  Future<void> clearAllAlerts() async {
    await isar.writeTxn(() async {
      await isar.alertEntitys.clear();
    });
  }

  @override
  Future<void> deduplicateAlerts() async {
    await isar.writeTxn(() async {
      final alerts = await isar.alertEntitys.where().findAll();
      final newestByKey = <String, AlertEntity>{};
      final duplicates = <Id>[];

      for (final alert in alerts) {
        final day =
            '${alert.createdAt.year}-${alert.createdAt.month}-${alert.createdAt.day}';
        // New alerts have a stable entity identity. The title/message fallback
        // also repairs duplicate budget alerts created before that identity was
        // persisted.
        final identity =
            alert.relatedEntityId ?? '${alert.title}\u0000${alert.message}';
        final key = '${alert.type}\u0000$identity\u0000$day';
        final current = newestByKey[key];
        if (current == null || alert.createdAt.isAfter(current.createdAt)) {
          if (current != null) duplicates.add(current.id);
          newestByKey[key] = alert;
        } else {
          duplicates.add(alert.id);
        }
      }

      if (duplicates.isNotEmpty) {
        await isar.alertEntitys.deleteAll(duplicates);
      }
    });
  }

  @override
  Future<bool> alertExistsForEntity({
    required AlertType type,
    required String relatedEntityId,
    required DateTime sinceDate,
  }) async {
    final count =
        await isar.alertEntitys
            .filter()
            .typeEqualTo(type.toDbString())
            .relatedEntityIdEqualTo(relatedEntityId)
            .createdAtGreaterThan(sinceDate)
            .count();
    return count > 0;
  }
}

final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  return IsarAlertRepository();
});

final activeAlertsStreamProvider = StreamProvider<List<AlertItem>>((ref) {
  try {
    final repo = ref.watch(alertRepositoryProvider);
    return repo.watchActiveAlerts();
  } catch (_) {
    return Stream.value(const []);
  }
});

final unreadAlertsCountProvider = Provider<int>((ref) {
  try {
    final alerts = ref.watch(activeAlertsStreamProvider).value ?? const [];
    return alerts.where((a) => !a.isRead).length;
  } catch (_) {
    return 0;
  }
});
