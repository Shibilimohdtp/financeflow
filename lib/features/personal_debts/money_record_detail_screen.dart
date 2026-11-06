import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../models/account.dart';
import '../../models/money_record.dart';
import '../../models/money_repayment.dart';
import '../accounts/accounts_controller.dart';
import 'add_advance_sheet.dart';
import 'add_edit_money_record_sheet.dart';
import 'add_repayment_sheet.dart';
import 'money_records_controller.dart';
import 'widgets/money_record_advances_card.dart';
import 'widgets/money_record_detail_hero.dart';
import 'widgets/money_record_facts_card.dart';
import 'widgets/money_record_repayments_card.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_dialog.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../theme/ff.dart';

class MoneyRecordDetailScreen extends ConsumerWidget {
  final MoneyRecord record;

  const MoneyRecordDetailScreen({super.key, required this.record});

  void _openEditSheet(BuildContext context, MoneyRecord liveRecord) {
    showFfSheet(
      context,
      builder: (_) => AddEditMoneyRecordSheet(initialRecord: liveRecord),
    );
  }

  void _openAddAdvanceSheet(BuildContext context, MoneyRecord liveRecord) {
    showFfSheet(context, builder: (_) => AddAdvanceSheet(record: liveRecord));
  }

  void _openRepaymentSheet(
    BuildContext context,
    MoneyRecord liveRecord,
    double remaining,
  ) {
    showFfSheet(
      context,
      builder:
          (_) => AddRepaymentSheet(
            record: liveRecord,
            remainingBalance: remaining,
          ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    MoneyRecord liveRecord,
  ) async {
    final confirmed = await FfDialog.confirm(
      context,
      title: 'Delete Record?',
      message:
          'Deleting this relationship will also remove all its advance and repayment logs (${liveRecord.personName}). This cannot be undone.',
      confirmLabel: 'Delete Record',
      destructive: true,
    );

    if (confirmed == true && context.mounted) {
      final controller = ref.read(moneyRecordsControllerProvider.notifier);
      try {
        await controller.deleteRecord(liveRecord.id);
        if (context.mounted) {
          Navigator.of(context).pop();
          FfToast.show(context, message: 'Record deleted.');
        }
      } catch (e) {
        if (context.mounted) {
          FfToast.show(
            context,
            tone: FfToastTone.error,
            message: 'Failed to delete record: $e',
          );
        }
      }
    }
  }

  Future<void> _confirmDeleteRepayment(
    BuildContext context,
    WidgetRef ref,
    MoneyRepayment repayment,
  ) async {
    final confirmed = await FfDialog.confirm(
      context,
      title: 'Delete Repayment?',
      message:
          'Remove this repayment of ${CurrencyFormatter.format(repayment.amount)}? The remaining balance will be recalculated.',
      confirmLabel: 'Delete',
      destructive: true,
    );

    if (confirmed == true && context.mounted) {
      final controller = ref.read(moneyRecordsControllerProvider.notifier);
      try {
        await controller.deleteRepayment(repayment.id, record.id);
        if (context.mounted) {
          FfToast.show(context, message: 'Repayment deleted.');
        }
      } catch (e) {
        if (context.mounted) {
          FfToast.show(
            context,
            tone: FfToastTone.error,
            message: 'Failed to delete repayment: $e',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch live record from database
    final allRecords = ref.watch(allMoneyRecordsStreamProvider).value ?? [];
    final liveRecord = allRecords.firstWhere(
      (r) => r.id == record.id,
      orElse: () => record,
    );

    final advancesAsync = ref.watch(moneyRecordAdvancesProvider(liveRecord.id));
    final advances = advancesAsync.value ?? [];

    final repaymentsAsync = ref.watch(
      moneyRecordRepaymentsProvider(liveRecord.id),
    );
    final repayments = repaymentsAsync.value ?? [];

    final accounts =
        ref.watch(rawAccountsStreamProvider).valueOrNull ?? const <Account>[];
    final accountMap = {for (final a in accounts) a.id: a.name};

    final remaining = liveRecord.calculateRemainingAmount(
      repayments,
      advances: advances,
    );
    final effectiveDueDate = liveRecord.calculateEffectiveDueDate(
      advances: advances,
      repayments: repayments,
    );

    return Scaffold(
      appBar: FfAppBar(
        title: liveRecord.personName,
        actions: [
          IconButton(
            tooltip: 'Edit record',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _openEditSheet(context, liveRecord),
          ),
          IconButton(
            tooltip: 'Delete record',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _confirmDelete(context, ref, liveRecord),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          FfSpace.lg,
          FfSpace.md,
          FfSpace.lg,
          FfSpace.x3l,
        ),
        children: [
          MoneyRecordDetailHero(
            liveRecord: liveRecord,
            advances: advances,
            repayments: repayments,
            remaining: remaining,
            onRecordRepayment:
                () => _openRepaymentSheet(context, liveRecord, remaining),
            onAddAdvance: () => _openAddAdvanceSheet(context, liveRecord),
          ),
          const SizedBox(height: FfSpace.xl),
          MoneyRecordAdvancesCard(
            liveRecord: liveRecord,
            advances: advances,
            repayments: repayments,
            accountMap: accountMap,
            onAddAdvance: () => _openAddAdvanceSheet(context, liveRecord),
          ),
          const SizedBox(height: FfSpace.xl),
          MoneyRecordRepaymentsCard(
            liveRecord: liveRecord,
            advances: advances,
            repayments: repayments,
            remaining: remaining,
            onAddRepayment:
                () => _openRepaymentSheet(context, liveRecord, remaining),
            onDeleteRepayment:
                (rep) => _confirmDeleteRepayment(context, ref, rep),
          ),
          const SizedBox(height: FfSpace.xl),
          MoneyRecordFactsCard(
            liveRecord: liveRecord,
            effectiveDueDate: effectiveDueDate,
          ),
        ],
      ),
    );
  }
}
