import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../database/isar_service.dart';
import '../database/schemas/goal_contribution_entity.dart';
import '../database/schemas/savings_goal_entity.dart';
import '../models/goal_contribution.dart';
import '../models/savings_goal.dart';

final savingsGoalRepositoryProvider = Provider<SavingsGoalRepository>((ref) {
  return IsarSavingsGoalRepository();
});

abstract class SavingsGoalRepository {
  Future<List<SavingsGoal>> getAllGoals();
  Stream<List<SavingsGoal>> watchAllGoals();
  Future<SavingsGoal?> getGoalById(String id);
  Future<void> saveGoal(SavingsGoal goal);
  Future<void> deleteGoal(String id);

  Future<List<GoalContribution>> getAllContributions();
  Future<List<GoalContribution>> getContributionsForGoal(String goalId);
  Stream<List<GoalContribution>> watchContributionsForGoal(String goalId);
  Stream<List<GoalContribution>> watchAllContributions();
  Future<void> addContribution(GoalContribution contribution);
  Future<void> deleteContribution(String id);
}

class IsarSavingsGoalRepository implements SavingsGoalRepository {
  final Isar isar;

  IsarSavingsGoalRepository({Isar? isarInstance})
    : isar = isarInstance ?? IsarService.instance.isar;

  SavingsGoal _toGoalDomain(SavingsGoalEntity entity) {
    return SavingsGoal(
      id: entity.uuid,
      name: entity.name,
      targetAmount: entity.targetAmount,
      targetDate: entity.targetDate,
      linkedAccountId: entity.linkedAccountId,
      notes: entity.notes,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  SavingsGoalEntity _toGoalEntity(
    SavingsGoal domain, [
    SavingsGoalEntity? existing,
  ]) {
    final entity = existing ?? SavingsGoalEntity();
    entity.uuid = domain.id;
    entity.name = domain.name;
    entity.targetAmount = domain.targetAmount;
    entity.targetDate = domain.targetDate;
    entity.linkedAccountId = domain.linkedAccountId;
    entity.notes = domain.notes;
    entity.isCompleted = domain.isCompleted;
    entity.createdAt = domain.createdAt;
    entity.updatedAt = domain.updatedAt;
    return entity;
  }

  GoalContribution _toContribDomain(GoalContributionEntity entity) {
    return GoalContribution(
      id: entity.uuid,
      goalId: entity.goalId,
      amount: entity.amount,
      date: entity.date,
      accountId: entity.accountId,
      notes: entity.notes,
      createdAt: entity.createdAt,
    );
  }

  GoalContributionEntity _toContribEntity(
    GoalContribution domain, [
    GoalContributionEntity? existing,
  ]) {
    final entity = existing ?? GoalContributionEntity();
    entity.uuid = domain.id;
    entity.goalId = domain.goalId;
    entity.amount = domain.amount;
    entity.date = domain.date;
    entity.accountId = domain.accountId;
    entity.notes = domain.notes;
    entity.createdAt = domain.createdAt;
    return entity;
  }

  @override
  Future<List<SavingsGoal>> getAllGoals() async {
    final entities =
        await isar.savingsGoalEntitys.where().sortByCreatedAtDesc().findAll();
    return entities.map(_toGoalDomain).toList();
  }

  @override
  Stream<List<SavingsGoal>> watchAllGoals() {
    return isar.savingsGoalEntitys
        .where()
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true)
        .map((entities) => entities.map(_toGoalDomain).toList());
  }

  @override
  Future<SavingsGoal?> getGoalById(String id) async {
    final entity =
        await isar.savingsGoalEntitys.filter().uuidEqualTo(id).findFirst();
    return entity != null ? _toGoalDomain(entity) : null;
  }

  @override
  Future<void> saveGoal(SavingsGoal goal) async {
    goal.validate();
    await isar.writeTxn(() async {
      final existing =
          await isar.savingsGoalEntitys
              .filter()
              .uuidEqualTo(goal.id)
              .findFirst();
      final entity = _toGoalEntity(goal, existing);
      await isar.savingsGoalEntitys.put(entity);
    });
  }

  @override
  Future<void> deleteGoal(String id) async {
    await isar.writeTxn(() async {
      await isar.savingsGoalEntitys.filter().uuidEqualTo(id).deleteAll();
      // Also delete all contributions belonging to this goal
      await isar.goalContributionEntitys.filter().goalIdEqualTo(id).deleteAll();
    });
  }

  @override
  Future<List<GoalContribution>> getContributionsForGoal(String goalId) async {
    final entities =
        await isar.goalContributionEntitys
            .filter()
            .goalIdEqualTo(goalId)
            .sortByDateDesc()
            .findAll();
    return entities.map(_toContribDomain).toList();
  }

  @override
  Stream<List<GoalContribution>> watchContributionsForGoal(String goalId) {
    return isar.goalContributionEntitys
        .filter()
        .goalIdEqualTo(goalId)
        .sortByDateDesc()
        .watch(fireImmediately: true)
        .map((entities) => entities.map(_toContribDomain).toList());
  }

  @override
  Future<List<GoalContribution>> getAllContributions() async {
    final entities =
        await isar.goalContributionEntitys.where().sortByDateDesc().findAll();
    return entities.map(_toContribDomain).toList();
  }

  @override
  Stream<List<GoalContribution>> watchAllContributions() {
    return isar.goalContributionEntitys
        .where()
        .sortByDateDesc()
        .watch(fireImmediately: true)
        .map((entities) => entities.map(_toContribDomain).toList());
  }

  @override
  Future<void> addContribution(GoalContribution contribution) async {
    contribution.validate();
    await isar.writeTxn(() async {
      final existing =
          await isar.goalContributionEntitys
              .filter()
              .uuidEqualTo(contribution.id)
              .findFirst();
      final entity = _toContribEntity(contribution, existing);
      await isar.goalContributionEntitys.put(entity);
    });
  }

  @override
  Future<void> deleteContribution(String id) async {
    await isar.writeTxn(() async {
      await isar.goalContributionEntitys.filter().uuidEqualTo(id).deleteAll();
    });
  }
}
