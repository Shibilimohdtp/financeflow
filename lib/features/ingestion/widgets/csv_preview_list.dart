import 'package:flutter/material.dart';

import '../../../core/formatting/date_formatter.dart';
import '../../../models/account.dart';
import '../../../models/category.dart';
import '../../../models/ingestion/parsed_transaction.dart';
import '../../../models/transaction.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_badge.dart';
import '../../../shared/widgets/ff_button.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../shared/widgets/ff_divider.dart';
import '../../../shared/widgets/ff_grouped_container.dart';
import '../../../shared/widgets/ff_icon_tile.dart';
import '../../../shared/widgets/ff_section_header.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';

/// Preview list for parsed CSV transactions with summary stats and column editing.
class CsvPreviewList extends StatelessWidget {
  const CsvPreviewList({
    super.key,
    required this.session,
    required this.categories,
    required this.accounts,
    required this.onEditColumns,
  });

  final ImportReviewSession session;
  final List<Category> categories;
  final List<Account> accounts;
  final VoidCallback onEditColumns;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: FfSpace.pageMargin,
        vertical: FfSpace.md,
      ),
      children: [
        // ── 1. Session Summary Card ──────────────────────────────────
        FfCard(
          padding: const EdgeInsets.all(FfSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      session.sourceName,
                      style: ff.text.titleSm,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  FfButton(
                    label: 'Edit Columns',
                    variant: FfButtonVariant.text,
                    size: FfButtonSize.sm,
                    leadingIcon: const Icon(Icons.tune_rounded, size: 16),
                    onPressed: onEditColumns,
                  ),
                ],
              ),
              const SizedBox(height: FfSpace.sm),
              Wrap(
                spacing: FfSpace.xs,
                runSpacing: FfSpace.xs,
                children: [
                  FfBadge(
                    label: '${session.totalCount} Total',
                    tone: FfTone.neutral,
                  ),
                  FfBadge(
                    label: '${session.validCount} Valid',
                    tone: FfTone.success,
                    icon: Icons.check_circle_rounded,
                  ),
                  if (session.duplicateCount > 0)
                    FfBadge(
                      label: '${session.duplicateCount} Duplicates',
                      tone: FfTone.error,
                      icon: Icons.warning_amber_rounded,
                    ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: FfSpace.xl),

        // ── 2. Parsed Rows Preview ───────────────────────────────────
        FfSectionHeader(title: 'Parsed Transactions (${session.items.length})'),
        FfGroupedContainer(
          dividerInset: FfRowLeading.icon,
          children: [
            for (final item in session.items)
              _ParsedTransactionItem(item: item),
          ],
        ),

        const SizedBox(height: FfSpace.x4l),
      ],
    );
  }
}

class _ParsedTransactionItem extends StatelessWidget {
  const _ParsedTransactionItem({required this.item});

  final ParsedTransaction item;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final isIncome = item.type == TransactionType.income;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: FfSpace.md,
        vertical: FfSpace.sm,
      ),
      child: Row(
        children: [
          FfIconTile(
            icon:
                isIncome
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
            tone: isIncome ? FfTone.success : FfTone.neutral,
          ),
          const SizedBox(width: FfSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.normalizedMerchant,
                  style: ff.text.body.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: FfSpace.x3s),
                Text(
                  '${DateFormatter.formatTransactionDate(item.date)} · ${item.categoryName}',
                  style: ff.text.labelSm.copyWith(
                    color: ff.color.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: FfSpace.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FfAmountText(
                amount: item.amount,
                type: item.type,
                size: FfAmountSize.md,
              ),
              if (item.duplicateStatus != DuplicateMatchLevel.none) ...[
                const SizedBox(height: FfSpace.x3s),
                const FfBadge(label: 'Duplicate', tone: FfTone.error),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
