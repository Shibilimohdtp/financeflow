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

    for (final record in records) {
      final recordRepayments = repaymentsByRecord[record.id] ?? const [];
      final remaining = record.calculateRemainingAmount(recordRepayments);
      final isSettled = record.isFullySettled(recordRepayments);
      final isOverdue = record.isOverdue(asOfDate: asOfDate, repayments: recordRepayments);
      final isDueSoon = record.isDueSoon(
        asOfDate: asOfDate,
        thresholdDays: dueSoonDays,
        repayments: recordRepayments,
      );

      if (record.type == MoneyRecordType.lent) {
        totalLent += record.originalAmount;
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
        totalBorrowed += record.originalAmount;
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
    DateTime? asOfDate,
    int dueSoonDays = 7,
  }) {
    final repaymentsByRecord = <String, List<MoneyRepayment>>{};
    for (final r in repayments) {
      repaymentsByRecord.putIfAbsent(r.moneyRecordId, () => []).add(r);
    }

    final list = List<MoneyRecord>.from(records);
    list.sort((a, b) {
      final aReps = repaymentsByRecord[a.id] ?? const [];
      final bReps = repaymentsByRecord[b.id] ?? const [];

      final aSettled = a.isFullySettled(aReps);
      final bSettled = b.isFullySettled(bReps);

      // Settled items go last
      if (aSettled && !bSettled) return 1;
      if (!aSettled && bSettled) return -1;
      if (aSettled && bSettled) {
        final aDate = a.settledAt ?? a.updatedAt;
        final bDate = b.settledAt ?? b.updatedAt;
        return bDate.compareTo(aDate);
      }

      final aOverdue = a.isOverdue(asOfDate: asOfDate, repayments: aReps);
      final bOverdue = b.isOverdue(asOfDate: asOfDate, repayments: bReps);

      // Overdue items go first
      if (aOverdue && !bOverdue) return -1;
      if (!aOverdue && bOverdue) return 1;

      // Nearest due date first
      return a.dueDate.compareTo(b.dueDate);
    });

    return list;
  }

  /// Filter records based on selected tab/filter
  static List<MoneyRecord> filterRecords(
    List<MoneyRecord> records,
    List<MoneyRepayment> repayments,
    MoneyRecordFilter filter, {
    DateTime? asOfDate,
    int dueSoonDays = 7,
  }) {
    final repaymentsByRecord = <String, List<MoneyRepayment>>{};
    for (final r in repayments) {
      repaymentsByRecord.putIfAbsent(r.moneyRecordId, () => []).add(r);
    }

    switch (filter) {
      case MoneyRecordFilter.all:
        return sortRecords(records, repayments, asOfDate: asOfDate, dueSoonDays: dueSoonDays);

      case MoneyRecordFilter.owedToMe:
        final filtered = records.where((r) => r.type == MoneyRecordType.lent).toList();
        return sortRecords(filtered, repayments, asOfDate: asOfDate, dueSoonDays: dueSoonDays);

      case MoneyRecordFilter.iOwe:
        final filtered = records.where((r) => r.type == MoneyRecordType.borrowed).toList();
        return sortRecords(filtered, repayments, asOfDate: asOfDate, dueSoonDays: dueSoonDays);

      case MoneyRecordFilter.overdue:
        final filtered = records.where((r) {
          final reps = repaymentsByRecord[r.id] ?? const [];
          return !r.isFullySettled(reps) &&
              r.isOverdue(asOfDate: asOfDate, repayments: reps);
        }).toList();
        return sortRecords(filtered, repayments, asOfDate: asOfDate, dueSoonDays: dueSoonDays);

      case MoneyRecordFilter.dueSoon:
        final filtered = records.where((r) {
          final reps = repaymentsByRecord[r.id] ?? const [];
          return !r.isFullySettled(reps) &&
              !r.isOverdue(asOfDate: asOfDate, repayments: reps) &&
              r.isDueSoon(asOfDate: asOfDate, thresholdDays: dueSoonDays, repayments: reps);
        }).toList();
        return sortRecords(filtered, repayments, asOfDate: asOfDate, dueSoonDays: dueSoonDays);

      case MoneyRecordFilter.settled:
        final filtered = records.where((r) {
          final reps = repaymentsByRecord[r.id] ?? const [];
          return r.isFullySettled(reps);
        }).toList();
        return sortRecords(filtered, repayments, asOfDate: asOfDate, dueSoonDays: dueSoonDays);
    }
  }
}
