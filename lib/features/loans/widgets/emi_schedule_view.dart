import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../core/formatting/date_formatter.dart';
import '../../../models/loan.dart';
import '../../../services/loan_calculator.dart';
import '../../../theme/stillwater_tokens.dart';

class EmiScheduleView extends StatelessWidget {
  final Loan loan;

  const EmiScheduleView({super.key, required this.loan});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final schedule = LoanCalculator.generateSchedule(loan);

    return Scaffold(
      appBar: AppBar(title: Text('${loan.name} Amortization')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
            color: theme.colorScheme.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Calculated Locally',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.secColors.verified,
                  ),
                ),
                Text(
                  '${schedule.length} Installments',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
              itemCount: schedule.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = schedule[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: StillwaterTokens.space2Xs,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '#${item.monthNumber}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: StillwaterTokens.spaceMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormatter.formatFullDate(item.dueDate),
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Principal: ${CurrencyFormatter.formatINR(item.principalPaid)} · Interest: ${CurrencyFormatter.formatINR(item.interestPaid)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormatter.formatINR(item.emiAmount),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Bal: ${CurrencyFormatter.formatINR(item.closingBalance)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
