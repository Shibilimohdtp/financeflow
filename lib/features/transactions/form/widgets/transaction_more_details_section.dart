import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/ff_divider.dart';
import '../../../../shared/widgets/ff_select.dart';
import '../../../../shared/widgets/ff_text_field.dart';
import '../../../../theme/ff.dart';

class TransactionMoreDetailsSection extends StatelessWidget {
  final bool initiallyExpanded;
  final ValueChanged<bool> onExpansionChanged;
  final String selectedPaymentMethod;
  final List<String> paymentMethods;
  final ValueChanged<String?> onPaymentMethodChanged;
  final TextEditingController notesController;
  final TextEditingController tagsController;

  const TransactionMoreDetailsSection({
    super.key,
    required this.initiallyExpanded,
    required this.onExpansionChanged,
    required this.selectedPaymentMethod,
    required this.paymentMethods,
    required this.onPaymentMethodChanged,
    required this.notesController,
    required this.tagsController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final hasActiveDetails =
        notesController.text.isNotEmpty || tagsController.text.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: context.ff.color.surfaceCard,
        borderRadius: BorderRadius.circular(FfRadius.lg),
        border: Border.all(
          color: context.ff.color.borderSubtle,
          width: FfBorderWidth.hairline,
        ),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          onExpansionChanged: onExpansionChanged,
          leading: Icon(
            Icons.tune_rounded,
            size: 20,
            color: context.ff.color.actionPrimary,
          ),
          title: Text(
            'More details',
            style: context.ff.text.title.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            hasActiveDetails
                ? 'Payment method, notes & tags (Active)'
                : 'Payment method, note, tags',
            style: context.ff.text.bodySm,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            FfSpace.md,
            0,
            FfSpace.md,
            FfSpace.md,
          ),
          children: [
            const FfDivider(),
            const SizedBox(height: FfSpace.md),

            // Payment Method Selector
            FfSelect<String>(
              value: selectedPaymentMethod,
              label: 'Payment method',
              icon: Icons.payment_outlined,
              items:
                  {...paymentMethods, selectedPaymentMethod}
                      .map(
                        (method) => DropdownMenuItem(
                          value: method,
                          child: Text(method),
                        ),
                      )
                      .toList(),
              onChanged: onPaymentMethodChanged,
            ),
            const SizedBox(height: FfSpace.md),

            // Notes Input
            FfTextField(
              controller: notesController,
              maxLines: 2,
              label: 'Notes',
              hint: 'Invoice number, reimbursement notes, or context',
              icon: Icons.notes_rounded,
            ),
            const SizedBox(height: FfSpace.md),

            // Tags Input
            FfTextField(
              controller: tagsController,
              label: 'Tags',
              hint: 'e.g. trip, office, reimbursement (comma-separated)',
              icon: Icons.tag_rounded,
            ),
            const SizedBox(height: FfSpace.sm),

            // Future capabilities disclosure
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: context.ff.color.textSecondary,
                ),
                const SizedBox(width: FfSpace.x2s),
                Expanded(
                  child: Text(
                    'Recurring schedules and split transactions will be saved when fully configured.',
                    style: context.ff.text.labelSm.copyWith(
                      color: context.ff.color.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
