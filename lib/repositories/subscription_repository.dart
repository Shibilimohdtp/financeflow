import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../database/isar_service.dart';
import '../database/schemas/subscription_entity.dart';
import '../models/subscription.dart';

abstract class SubscriptionRepository {
  Future<List<Subscription>> getAllSubscriptions();
  Stream<List<Subscription>> watchAllSubscriptions();
  Future<Subscription?> getSubscriptionById(String id);
  Future<void> saveSubscription(Subscription subscription);
  Future<void> deleteSubscription(String id);
  Future<void> updateStatus(String id, SubscriptionStatus status);
}

class IsarSubscriptionRepository implements SubscriptionRepository {
  final Isar isar;

  IsarSubscriptionRepository({Isar? isarInstance})
    : isar = isarInstance ?? IsarService.instance.isar;

  Subscription _toDomain(SubscriptionEntity entity) {
    return Subscription(
      id: entity.uuid,
      merchant: entity.merchant,
      normalizedMerchant: entity.normalizedMerchant,
      amount: entity.amount,
      currency: entity.currency,
      billingFrequency: SubscriptionFrequency.fromString(
        entity.billingFrequency,
      ),
      nextRenewalDate: entity.nextRenewalDate,
      lastPaymentDate: entity.lastPaymentDate,
      accountId: entity.accountId,
      category: entity.category,
      paymentMethod: entity.paymentMethod,
      sourceTransactionId: entity.sourceTransactionId,
      status: SubscriptionStatus.fromString(entity.status),
      reminderDaysBefore: entity.reminderDaysBefore,
      isReminderEnabled: entity.isReminderEnabled,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  SubscriptionEntity _toEntity(Subscription domain) {
    return SubscriptionEntity()
      ..uuid = domain.id
      ..merchant = domain.merchant
      ..normalizedMerchant = domain.normalizedMerchant
      ..amount = domain.amount
      ..currency = domain.currency
      ..billingFrequency = domain.billingFrequency.toDbString()
      ..nextRenewalDate = domain.nextRenewalDate
      ..lastPaymentDate = domain.lastPaymentDate
      ..accountId = domain.accountId
      ..category = domain.category
      ..paymentMethod = domain.paymentMethod
      ..sourceTransactionId = domain.sourceTransactionId
      ..status = domain.status.toDbString()
      ..reminderDaysBefore = domain.reminderDaysBefore
      ..isReminderEnabled = domain.isReminderEnabled
      ..notes = domain.notes
      ..createdAt = domain.createdAt
      ..updatedAt = domain.updatedAt;
  }

  @override
  Future<List<Subscription>> getAllSubscriptions() async {
    final entities =
        await isar.subscriptionEntitys
            .where()
            .sortByNextRenewalDate()
            .findAll();
    return entities.map(_toDomain).toList();
  }

  @override
  Stream<List<Subscription>> watchAllSubscriptions() {
    return isar.subscriptionEntitys
        .where()
        .sortByNextRenewalDate()
        .watch(fireImmediately: true)
        .map((entities) => entities.map(_toDomain).toList());
  }

  @override
  Future<Subscription?> getSubscriptionById(String id) async {
    final entity =
        await isar.subscriptionEntitys.filter().uuidEqualTo(id).findFirst();
    return entity != null ? _toDomain(entity) : null;
  }

  @override
  Future<void> saveSubscription(Subscription subscription) async {
    await isar.writeTxn(() async {
      final existing =
          await isar.subscriptionEntitys
              .filter()
              .uuidEqualTo(subscription.id)
              .findFirst();

      final entity = _toEntity(subscription);
      if (existing != null) {
        entity.id = existing.id;
      }
      await isar.subscriptionEntitys.put(entity);
    });
  }

  @override
  Future<void> deleteSubscription(String id) async {
    await isar.writeTxn(() async {
      final entity =
          await isar.subscriptionEntitys.filter().uuidEqualTo(id).findFirst();
      if (entity != null) {
        await isar.subscriptionEntitys.delete(entity.id);
      }
    });
  }

  @override
  Future<void> updateStatus(String id, SubscriptionStatus status) async {
    await isar.writeTxn(() async {
      final entity =
          await isar.subscriptionEntitys.filter().uuidEqualTo(id).findFirst();
      if (entity != null) {
        entity.status = status.toDbString();
        entity.updatedAt = DateTime.now();
        await isar.subscriptionEntitys.put(entity);
      }
    });
  }
}

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return IsarSubscriptionRepository();
});

final allSubscriptionsStreamProvider = StreamProvider<List<Subscription>>((
  ref,
) {
  try {
    final repo = ref.watch(subscriptionRepositoryProvider);
    return repo.watchAllSubscriptions();
  } catch (_) {
    return Stream.value(const []);
  }
});
