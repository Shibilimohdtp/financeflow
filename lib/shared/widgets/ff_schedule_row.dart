import 'package:flutter/material.dart';

import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import 'ff_amount_text.dart';
import 'ff_badge.dart';
import 'ff_button.dart';
import 'ff_due_chip.dart';

/// Where one installment sits in its schedule.
enum FfScheduleRowState { paid, overdue, next, upcoming }

/// One installment of a repayment schedule (EMI, instalment plan).
///
/// Shows the instalment number as a state marker, the due date, a split
/// breakdown, the amount, a status word (never colour alone) and the one
/// action that applies: "Mark paid" for the next or overdue instalment,
/// "Undo" for a paid one, nothing for a future one.
///
/// Amounts go through [FfAmountText]; when [isBlurred] is true, the breakdown
/// line and the semantics read no figures at all.
class FfScheduleRow extends StatelessWidget {
  const FfScheduleRow({
    super.key,
    required this.number,
    required this.dueDate,
    required this.emiAmount,
    required this.principal,
    required this.interest,
    required this.balance,
    required this.state,
    this.paidOn,
    this.onAction,
    this.isBlurred = false,
  });

  /// Instalment number, shown as "#n" in the marker.
  final int number;

  final DateTime dueDate;
  final double emiAmount;
  final double principal;
  final double interest;

  /// Outstanding principal after this instalment.
  final double balance;

  final FfScheduleRowState state;

  /// Date the instalment was paid; shown in the paid badge when known.
  final DateTime? paidOn;

  /// Mark paid (next, overdue) or undo (paid). Null hides the action.
  final VoidCallback? onAction;

  final bool isBlurred;

  bool get _isPaid => state == FfScheduleRowState.paid;

  String get _stateWord => switch (state) {
    FfScheduleRowState.paid => 'paid',
    FfScheduleRowState.overdue => 'overdue',
    FfScheduleRowState.next => 'next due',
    FfScheduleRowState.upcoming => 'upcoming',
  };

  String get _semanticsLabel {
    final date = DateFormatter.formatFullDate(dueDate);
    if (isBlurred) {
      return 'Installment $number, $date, $_stateWord';
    }
    return 'Installment $number, $date, $_stateWord, EMI '
        '${CurrencyFormatter.formatAmount(emiAmount)}, principal '
        '${CurrencyFormatter.formatAmount(principal)}, interest '
        '${CurrencyFormatter.formatAmount(interest)}, balance '
        '${CurrencyFormatter.formatAmount(balance)}';
  }

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final text = ff.text;

    final breakdown =
        isBlurred
            ? null
            : 'Principal ${CurrencyFormatter.formatAmount(principal)} · '
                'Interest ${CurrencyFormatter.formatAmount(interest)}';

    final status = _buildStatus();
    final action = _buildAction();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: FfSpace.sm,
        vertical: FfSpace.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Marker(number: number, state: state),
          const SizedBox(width: FfSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  label: _semanticsLabel,
                  excludeSemantics: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              DateFormatter.formatFullDate(dueDate),
                              style: text.titleSm,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: FfSpace.xs),
                          FfAmountText(
                            amount: emiAmount,
                            size: FfAmountSize.sm,
                            showSign: false,
                            isBlurred: isBlurred,
                          ),
                        ],
                      ),
                      if (breakdown != null) ...[
                        const SizedBox(height: FfSpace.x3s),
                        Text(
                          breakdown,
                          style: text.labelSm.copyWith(
                            color: ff.color.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (status != null || action != null) ...[
                  const SizedBox(height: FfSpace.xs),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: FfSpace.xs,
                    runSpacing: FfSpace.x2s,
                    children: [
                      if (status != null) status,
                      if (action != null) action,
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildStatus() {
    if (_isPaid) {
      final paidText =
          paidOn == null
              ? 'Paid'
              : 'Paid ${DateFormatter.formatShortDate(paidOn!)}';
      return FfBadge(
        label: paidText,
        tone: FfTone.income,
        icon: Icons.check_rounded,
      );
    }
    if (state == FfScheduleRowState.overdue ||
        state == FfScheduleRowState.next) {
      return FfDueChip(dueDate: dueDate);
    }
    return null;
  }

  Widget? _buildAction() {
    if (onAction == null) return null;
    if (_isPaid) {
      return FfButton(
        label: 'Undo',
        variant: FfButtonVariant.text,
        size: FfButtonSize.sm,
        leadingIcon: const Icon(Icons.undo_rounded),
        onPressed: onAction,
      );
    }
    return FfButton(
      label: 'Mark paid',
      size: FfButtonSize.sm,
      leadingIcon: const Icon(Icons.check_circle_outline_rounded),
      onPressed: onAction,
    );
  }
}

/// Round marker: spark check when paid, ink fill for the next one, a tinted
/// error ring when overdue, and a quiet number when upcoming.
class _Marker extends StatelessWidget {
  const _Marker({required this.number, required this.state});

  final int number;
  final FfScheduleRowState state;

  @override
  Widget build(BuildContext context) {
    final c = context.ff.color;
    final text = context.ff.text;

    final (Color fill, Color ink) = switch (state) {
      FfScheduleRowState.paid => (c.spark, c.onSpark),
      FfScheduleRowState.next => (c.actionPrimary, c.onActionPrimary),
      FfScheduleRowState.overdue => (
        c.statusError.withValues(alpha: FfTint.subtle.alpha),
        c.statusError,
      ),
      FfScheduleRowState.upcoming => (c.surfaceContainerHigh, c.textSecondary),
    };

    return Container(
      width: FfRoundButtonTokens.sizeSm,
      height: FfRoundButtonTokens.sizeSm,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
      child:
          state == FfScheduleRowState.paid
              ? Icon(Icons.check_rounded, size: FfIconSize.md, color: ink)
              : ExcludeSemantics(
                child: Text(
                  '#$number',
                  style: text.labelSm.copyWith(color: ink),
                ),
              ),
    );
  }
}
