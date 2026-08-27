import '../models/money_advance.dart';
import '../models/money_record.dart';
import '../models/money_repayment.dart';

enum MoneyRecordFilter {
  all,
  owedToMe, // lent
  iOwe, // borrowed
  overdue,
  dueSoon,
  settled;

  String get displayName {
    switch (this) {
      case MoneyRecordFilter.all:
        return 'All';
      case MoneyRecordFilter.owedToMe:
        return 'Owed to Me';
      case MoneyRecordFilter.iOwe:
        return 'I Owe';
      case MoneyRecordFilter.overdue:
        return 'Overdue';
      case MoneyRecordFilter.dueSoon:
        return 'Due Soon';
      case MoneyRecordFilter.settled:
        return 'Settled';
    }
  }
}

class MoneyLendingSummary {
  final double totalLent;
  final double totalBorrowed;
  final double totalOwedToMe;
  final double totalIOwe;
  final double overdueOwedToMe;
  final double overdueIOwe;
  final double dueSoonOwedToMe;
  final double dueSoonIOwe;
  final int activeLentCount;
  final int activeBorrowedCount;
  final int unsettledCount;
  final int settledCount;
  final int overdueCount;
  final int dueSoonCount;

  const MoneyLendingSummary({
    required this.totalLent,
    required this.totalBorrowed,
    required this.totalOwedToMe,
    required this.totalIOwe,
    required this.overdueOwedToMe,
    required this.overdueIOwe,
    required this.dueSoonOwedToMe,
    required this.dueSoonIOwe,
    required this.activeLentCount,
    required this.activeBorrowedCount,
    required this.unsettledCount,
    required this.settledCount,
    required this.overdueCount,
    required this.dueSoonCount,
  });

  factory MoneyLendingSummary.empty() => const MoneyLendingSummary(
    totalLent: 0.0,
    totalBorrowed: 0.0,
    totalOwedToMe: 0.0,
    totalIOwe: 0.0,
    overdueOwedToMe: 0.0,
    overdueIOwe: 0.0,
    dueSoonOwedToMe: 0.0,
    dueSoonIOwe: 0.0,
    activeLentCount: 0,
    activeBorrowedCount: 0,
    unsettledCount: 0,
    settledCount: 0,
    overdueCount: 0,
    dueSoonCount: 0,
  );
}

class MoneyLendingCalculator {
  MoneyLendingCalculator._();

  static MoneyLendingSummary calculateSummary(
    List<MoneyRecord> records,
    List<MoneyRepayment> repayments, {
    List<MoneyAdvance> advances = const [],
    DateTime? asOfDate,
    int dueSoonDays = 7,
  }) {
    double totalLent = 0.0;
    double totalBorrowed = 0.0;
    double totalOwedToMe = 0.0;
    double totalIOwe = 0.0;
    double overdueOwedToMe = 0.0;
    double overdueIOwe = 0.0;
    double dueSoonOwedToMe = 0.0;
    double dueSoonIOwe = 0.0;
    int activeLentCount = 0;
    int activeBorrowedCount = 0;
    int unsettledCount = 0;
    int settledCount = 0;
    int overdueCount = 0;
    int dueSoonCount = 0;

    final repaymentsByRecord = <String, List<MoneyRepayment>>{};
    for (final r in repayments) {
      repaymentsByRecord.putIfAbsent(r.moneyRecordId, () => []).add(r);
    }

    final advancesByRecord = <String, List<MoneyAdvance>>{};
    for (final a in advances) {
      advancesByRecord.putIfAbsent(a.moneyRecordId, () => []).add(a);
    }

    for (final record in records) {
      final recordRepayments = repaymentsByRecord[record.id] ?? const [];
      final recordAdvances = advancesByRecord[record.id] ?? const [];
      final totalAdvanced = record.calculateTotalAdvanced(recordAdvances);
      final remaining = record.calculateRemainingAmount(
        recordRepayments,
        advances: recordAdvances,
      );
      final isSettled = record.isFullySettled(
        recordRepayments,
        advances: recordAdvances,
      );
      final isOverdue = record.isOverdue(
        asOfDate: asOfDate,
        repayments: recordRepayments,
        advances: recordAdvances,
      );
      final isDueSoon = record.isDueSoon(
        asOfDate: asOfDate,
        thresholdDays: dueSoonDays,
        repayments: recordRepayments,
        advances: recordAdvances,
      );

      if (record.type == MoneyRecordType.lent) {
        totalLent += totalAdvanced;
        if (!isSettled) {
          totalOwedToMe += remaining;
          activeLentCount++;
          unsettledCount++;
          if (isOverdue) {
            overdueOwedToMe += remaining;
            overdueCount++;
          } else if (isDueSoon) {
            dueSoonOwedToMe += remaining;
            dueSoonCount++;
          }
        } else {
          settledCount++;
        }
      } else {
        totalBorrowed += totalAdvanced;
        if (!isSettled) {
          totalIOwe += remaining;
          activeBorrowedCount++;
          unsettledCount++;
          if (isOverdue) {
            overdueIOwe += remaining;
            overdueCount++;
          } else if (isDueSoon) {
            dueSoonIOwe += remaining;
            dueSoonCount++;
          }
        } else {
          settledCount++;
        }
      }
    }

    return MoneyLendingSummary(
      totalLent: totalLent,
      totalBorrowed: totalBorrowed,
      totalOwedToMe: totalOwedToMe,
      totalIOwe: totalIOwe,
      overdueOwedToMe: overdueOwedToMe,
      overdueIOwe: overdueIOwe,
      dueSoonOwedToMe: dueSoonOwedToMe,
      dueSoonIOwe: dueSoonIOwe,
      activeLentCount: activeLentCount,
      activeBorrowedCount: activeBorrowedCount,
      unsettledCount: unsettledCount,
      settledCount: settledCount,
      overdueCount: overdueCount,
      dueSoonCount: dueSoonCount,
    );
  }

  /// Sort records:
  /// 1. Unsettled Overdue records first (ordered by nearest overdue date)
  /// 2. Unsettled Due Soon records next (ordered by due date ascending)
  /// 3. Unsettled Other records next (ordered by due date ascending)
  /// 4. Settled records last (ordered by settled date or updated date descending)
  static List<MoneyRecord> sortRecords(
    List<MoneyRecord> records,
    List<MoneyRepayment> repayments, {
    List<MoneyAdvance> advances = const [],
    DateTime? asOfDate,
    int dueSoonDays = 7,
  }) {
    final repaymentsByRecord = <String, List<MoneyRepayment>>{};
    for (final r in repayments) {
      repaymentsByRecord.putIfAbsent(r.moneyRecordId, () => []).add(r);
    }

    final advancesByRecord = <String, List<MoneyAdvance>>{};
    for (final a in advances) {
      advancesByRecord.putIfAbsent(a.moneyRecordId, () => []).add(a);
    }

    final list = List<MoneyRecord>.from(records);
    list.sort((a, b) {
      final aReps = repaymentsByRecord[a.id] ?? const [];
      final bReps = repaymentsByRecord[b.id] ?? const [];
      final aAdvs = advancesByRecord[a.id] ?? const [];
      final bAdvs = advancesByRecord[b.id] ?? const [];

      final aSettled = a.isFullySettled(aReps, advances: aAdvs);
      final bSettled = b.isFullySettled(bReps, advances: bAdvs);

      // Settled items go last
      if (aSettled && !bSettled) return 1;
      if (!aSettled && bSettled) return -1;
      if (aSettled && bSettled) {
        final aDate = a.settledAt ?? a.updatedAt;
        final bDate = b.settledAt ?? b.updatedAt;
        return bDate.compareTo(aDate);
      }

      final aOverdue = a.isOverdue(
        asOfDate: asOfDate,
        repayments: aReps,
        advances: aAdvs,
      );
      final bOverdue = b.isOverdue(
        asOfDate: asOfDate,
        repayments: bReps,
        advances: bAdvs,
      );

      // Overdue items go first
      if (aOverdue && !bOverdue) return -1;
      if (!aOverdue && bOverdue) return 1;

      // Effective due date comparison
      final aDue = a.calculateEffectiveDueDate(
        advances: aAdvs,
        repayments: aReps,
      );
      final bDue = b.calculateEffectiveDueDate(
        advances: bAdvs,
        repayments: bReps,
      );
      return aDue.compareTo(bDue);
    });

    return list;
  }

  /// Filter records based on selected tab/filter
  static List<MoneyRecord> filterRecords(
    List<MoneyRecord> records,
    List<MoneyRepayment> repayments,
    MoneyRecordFilter filter, {
    List<MoneyAdvance> advances = const [],
    DateTime? asOfDate,
    int dueSoonDays = 7,
  }) {
    final repaymentsByRecord = <String, List<MoneyRepayment>>{};
    for (final r in repayments) {
      repaymentsByRecord.putIfAbsent(r.moneyRecordId, () => []).add(r);
    }

    final advancesByRecord = <String, List<MoneyAdvance>>{};
    for (final a in advances) {
      advancesByRecord.putIfAbsent(a.moneyRecordId, () => []).add(a);
    }

    switch (filter) {
      case MoneyRecordFilter.all:
        return sortRecords(
          records,
          repayments,
          advances: advances,
          asOfDate: asOfDate,
          dueSoonDays: dueSoonDays,
        );

      case MoneyRecordFilter.owedToMe:
        final filtered =
            records.where((r) => r.type == MoneyRecordType.lent).toList();
        return sortRecords(
          filtered,
          repayments,
          advances: advances,
          asOfDate: asOfDate,
          dueSoonDays: dueSoonDays,
        );

      case MoneyRecordFilter.iOwe:
        final filtered =
            records.where((r) => r.type == MoneyRecordType.borrowed).toList();
        return sortRecords(
          filtered,
          repayments,
          advances: advances,
          asOfDate: asOfDate,
          dueSoonDays: dueSoonDays,
        );

      case MoneyRecordFilter.overdue:
        final filtered =
            records.where((r) {
              final reps = repaymentsByRecord[r.id] ?? const [];
              final advs = advancesByRecord[r.id] ?? const [];
              return !r.isFullySettled(reps, advances: advs) &&
                  r.isOverdue(
                    asOfDate: asOfDate,
                    repayments: reps,
                    advances: advs,
                  );
            }).toList();
        return sortRecords(
          filtered,
          repayments,
          advances: advances,
          asOfDate: asOfDate,
          dueSoonDays: dueSoonDays,
        );

      case MoneyRecordFilter.dueSoon:
        final filtered =
            records.where((r) {
              final reps = repaymentsByRecord[r.id] ?? const [];
              final advs = advancesByRecord[r.id] ?? const [];
              return !r.isFullySettled(reps, advances: advs) &&
                  !r.isOverdue(
                    asOfDate: asOfDate,
                    repayments: reps,
                    advances: advs,
                  ) &&
                  r.isDueSoon(
                    asOfDate: asOfDate,
                    thresholdDays: dueSoonDays,
                    repayments: reps,
                    advances: advs,
                  );
            }).toList();
        return sortRecords(
          filtered,
          repayments,
          advances: advances,
          asOfDate: asOfDate,
          dueSoonDays: dueSoonDays,
        );

      case MoneyRecordFilter.settled:
        final filtered =
            records.where((r) {
              final reps = repaymentsByRecord[r.id] ?? const [];
              final advs = advancesByRecord[r.id] ?? const [];
              return r.isFullySettled(reps, advances: advs);
            }).toList();
        return sortRecords(
          filtered,
          repayments,
          advances: advances,
          asOfDate: asOfDate,
          dueSoonDays: dueSoonDays,
        );
    }
  }
}
