import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../theme/stillwater_typography.dart';
import 'subscriptions_controller.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_divider.dart';
import '../../shared/widgets/ff_progress.dart';
import '../../theme/ff.dart';

class RecurringSuggestionsSheet extends ConsumerWidget {
  const RecurringSuggestionsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(recurringSuggestionsProvider);

    return FfSheet(
      children: [
        const FfSheetHeader(
          title: 'Recurring Patterns',
          subtitle: 'Detected on-device from transaction history',
          trailing: FfPrivacyBadge(label: 'On-device'),
        ),
        const FfDivider(),
        Flexible(
          child: suggestionsAsync.when(
            data: (suggestions) {
              if (suggestions.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(FfSpace.x2l),
                    child: FfEmptyState(
                      icon: Icons.check_circle_outline_rounded,
                      title: 'No unconfirmed recurring patterns',
                      description:
                          'FinanceFlow scans local transactions for recurring charges. All patterns are already tracked.',
                    ),
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: FfSpace.lg,
                  vertical: FfSpace.md,
                ),
                children: [
                  FfSectionHeader(
                    title: 'Detected Patterns (${suggestions.length})',
                  ),
                  FfGroupedContainer(
                    children:
                        suggestions.map((sug) {
                          return Padding(
                            padding: const EdgeInsets.all(FfSpace.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        sug.merchant,
                                        style: context.ff.text.titleSm.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '${CurrencyFormatter.formatAmount(sug.suggestedAmount)} / ${sug.suggestedFrequency.name}',
                                      style: StillwaterTypography.numMd(
                                        color: context.ff.color.actionPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: FfSpace.x2s),
                                Text(
                                  'Matched ${sug.matchingTransactions.length} past payments · Last: ${DateFormatter.formatShortDate(sug.lastPaymentDate)}',
                                  style: context.ff.text.bodySm.copyWith(
                                    color: context.ff.color.secondary,
                                  ),
                                ),
                                const SizedBox(height: FfSpace.md),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    FfButton(
                                      label: 'Track Subscription',
                                      size: FfButtonSize.sm,
                                      leadingIcon: const Icon(
                                        Icons.add_rounded,
                                        size: 16,
                                      ),
                                      onPressed: () async {
                                        await ref
                                            .read(
                                              subscriptionsControllerProvider
                                                  .notifier,
                                            )
                                            .addFromSuggestion(sug);
                                        ref.invalidate(
                                          recurringSuggestionsProvider,
                                        );
                                        if (context.mounted) {
                                          FfToast.show(
                                            context,
                                            message:
                                                'Subscription tracked for ${sug.merchant}.',
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ],
              );
            },
            loading:
                () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(FfSpace.x4l),
                    child: FfLoading(),
                  ),
                ),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }
}
