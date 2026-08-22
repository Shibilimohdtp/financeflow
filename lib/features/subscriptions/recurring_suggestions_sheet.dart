import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../theme/stillwater_tokens.dart';
import 'subscriptions_controller.dart';

class RecurringSuggestionsSheet extends ConsumerWidget {
  const RecurringSuggestionsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final suggestionsAsync = ref.watch(recurringSuggestionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Recurring Suggestions')),
      body: suggestionsAsync.when(
        data: (suggestions) {
          if (suggestions.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(StillwaterTokens.spaceLg),
                child: FfEmptyState(
                  icon: Icons.check_circle_outline_rounded,
                  title: 'No new recurring patterns',
                  description:
                      'FinanceFlow scans your local transaction history for repeated charges. No unconfirmed subscriptions found.',
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
            itemCount: suggestions.length,
            separatorBuilder:
                (_, __) => const SizedBox(height: StillwaterTokens.spaceMd),
            itemBuilder: (context, index) {
              final sug = suggestions[index];
              return FfCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            sug.merchant,
                            style: theme.textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${CurrencyFormatter.formatINR(sug.suggestedAmount)} / ${sug.suggestedFrequency.name}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: StillwaterTokens.spaceXs),
                    Text(
                      'Detected from ${sug.matchingTransactions.length} past payments (Last: ${DateFormatter.formatTransactionDate(sug.lastPaymentDate)})',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: StillwaterTokens.spaceMd),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FfButton(
                          label: 'Track Subscription',
                          size: FfButtonSize.sm,
                          onPressed: () async {
                            await ref
                                .read(subscriptionsControllerProvider.notifier)
                                .addFromSuggestion(sug);
                            ref.invalidate(recurringSuggestionsProvider);
                            if (context.mounted) {
                              FfSnackbar.show(
                                context,
                                message:
                                    'Subscription created for ${sug.merchant}.',
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
