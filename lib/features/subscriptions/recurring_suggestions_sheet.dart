import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/formatting/date_formatter.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import 'subscriptions_controller.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_amount_text.dart';
import '../../shared/widgets/ff_field_label.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_progress.dart';
import '../../theme/ff.dart';

class RecurringSuggestionsSheet extends ConsumerWidget {
  const RecurringSuggestionsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(recurringSuggestionsProvider);

    return FfSheet(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FfSheetHeader(
          title: 'Repeating payments',
          subtitle: 'Found in your transactions; track the ones that matter',
        ),
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
                shrinkWrap: true,
                padding: FfSheetBody.standardPadding,
                children: [
                  FfFieldLabel('${suggestions.length} found'),
                  const SizedBox(height: FfSheetTokens.labelGap),
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
                                        style: context.ff.text.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    FfAmountText(
                                      amount: sug.suggestedAmount,
                                      size: FfAmountSize.sm,
                                      showSign: false,
                                    ),
                                    Text(
                                      '/${sug.suggestedFrequency.shortLabel}',
                                      style: context.ff.text.label.copyWith(
                                        color: context.ff.color.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: FfSpace.x2s),
                                Text(
                                  'Matched ${sug.matchingTransactions.length} past payments · Last: ${DateFormatter.formatShortDate(sug.lastPaymentDate)}',
                                  style: context.ff.text.bodySm.copyWith(
                                    color: context.ff.color.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: FfSpace.md),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    FfButton(
                                      label: 'Track it',
                                      size: FfButtonSize.sm,
                                      leadingIcon: const Icon(
                                        Icons.add_rounded,
                                        size: FfIconSize.sm,
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
