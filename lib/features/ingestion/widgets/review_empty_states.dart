import 'package:flutter/material.dart';

import '../../../shared/widgets/ff_empty_state.dart';

/// Contextual empty state for each filter in the Needs Review queue.
class ReviewFilterEmptyState extends StatelessWidget {
  const ReviewFilterEmptyState({
    super.key,
    required this.filter,
    required this.onResetFilter,
  });

  final String filter;
  final VoidCallback onResetFilter;

  @override
  Widget build(BuildContext context) {
    switch (filter) {
      case 'duplicates':
        return FfEmptyState(
          icon: Icons.copy_rounded,
          title: 'No duplicate transactions',
          description:
              'None of your pending imports match existing ledger entries.',
          actionLabel: 'View all items',
          onAction: onResetFilter,
        );
      case 'uncertain':
        return FfEmptyState(
          icon: Icons.category_outlined,
          title: 'All categories confirmed',
          description:
              'All pending transactions have confident categories assigned.',
          actionLabel: 'View all items',
          onAction: onResetFilter,
        );
      case 'errors':
        return FfEmptyState(
          icon: Icons.check_circle_outline_rounded,
          title: 'No invalid transactions',
          description:
              'All pending transactions have valid amounts, dates, and accounts.',
          actionLabel: 'View all items',
          onAction: onResetFilter,
        );
      default:
        return const FfEmptyState(
          icon: Icons.check_circle_outline_rounded,
          title: 'All Clear',
          description: 'No transactions are currently pending review.',
        );
    }
  }
}
