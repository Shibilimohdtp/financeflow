import 'package:flutter/material.dart';
import '../../../core/formatting/date_formatter.dart';
import '../../../models/money_record.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../shared/widgets/ff_divider.dart';
import '../../../shared/widgets/ff_key_value_row.dart';
import '../../../theme/ff.dart';

class MoneyRecordFactsCard extends StatelessWidget {
  final MoneyRecord liveRecord;
  final DateTime effectiveDueDate;

  const MoneyRecordFactsCard({
    super.key,
    required this.liveRecord,
    required this.effectiveDueDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Relationship Details',
          style: context.ff.text.titleSm.copyWith(
            fontWeight: FontWeight.w700,
            color: context.ff.color.actionPrimary,
          ),
        ),
        const SizedBox(height: FfSpace.xs),
        FfCard(
          variant: FfCardVariant.standard,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              FfKeyValueRow(
                icon: Icons.calendar_today_outlined,
                label: 'Started On',
                value: DateFormatter.formatFullDate(liveRecord.transactionDate),
              ),
              const FfDivider(),
              FfKeyValueRow(
                icon: Icons.event_available_outlined,
                label: 'Next Due Date',
                value: DateFormatter.formatFullDate(effectiveDueDate),
              ),
              const FfDivider(),
              FfKeyValueRow(
                icon: Icons.notifications_none_rounded,
                label: 'Reminder',
                value:
                    liveRecord.isReminderEnabled
                        ? 'Enabled (${liveRecord.reminderDaysBefore} ${liveRecord.reminderDaysBefore == 1 ? 'day' : 'days'} before)'
                        : 'Disabled',
              ),
              if (liveRecord.notes != null && liveRecord.notes!.isNotEmpty) ...[
                const FfDivider(),
                FfKeyValueRow(
                  icon: Icons.notes_rounded,
                  label: 'Notes',
                  value: liveRecord.notes!,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
