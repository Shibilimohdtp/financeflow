import 'package:flutter/material.dart';
import '../../../core/formatting/date_formatter.dart';
import '../../../theme/ff.dart';

class MoneyRecordDatePickers extends StatelessWidget {
  final DateTime transactionDate;
  final DateTime dueDate;
  final VoidCallback onPickTransactionDate;
  final VoidCallback onPickDueDate;

  const MoneyRecordDatePickers({
    super.key,
    required this.transactionDate,
    required this.dueDate,
    required this.onPickTransactionDate,
    required this.onPickDueDate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date',
                style: context.ff.text.label.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: FfSpace.xs),
              InkWell(
                onTap: onPickTransactionDate,
                borderRadius: BorderRadius.circular(FfRadius.md),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FfSpace.md,
                    vertical: FfSpace.md,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: context.ff.color.borderSubtle),
                    borderRadius: BorderRadius.circular(FfRadius.md),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: context.ff.color.actionPrimary,
                      ),
                      const SizedBox(width: FfSpace.sm),
                      Expanded(
                        child: Text(
                          DateFormatter.formatShortDate(transactionDate),
                          style: context.ff.text.bodySm.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: FfSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Expected Due Date',
                style: context.ff.text.label.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: FfSpace.xs),
              InkWell(
                onTap: onPickDueDate,
                borderRadius: BorderRadius.circular(FfRadius.md),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FfSpace.md,
                    vertical: FfSpace.md,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: context.ff.color.borderSubtle),
                    borderRadius: BorderRadius.circular(FfRadius.md),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event_available_outlined,
                        size: 16,
                        color: context.ff.color.actionPrimary,
                      ),
                      const SizedBox(width: FfSpace.sm),
                      Expanded(
                        child: Text(
                          DateFormatter.formatShortDate(dueDate),
                          style: context.ff.text.bodySm.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
