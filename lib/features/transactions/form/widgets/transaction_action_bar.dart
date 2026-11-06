import 'package:flutter/material.dart';

import '../../../../shared/widgets/ff_button.dart';
import '../../../../theme/ff.dart';

class TransactionActionBar extends StatelessWidget {
  final String label;
  final bool isSubmitting;
  final bool isValid;
  final String? disabledReason;
  final VoidCallback? onSubmit;

  const TransactionActionBar({
    super.key,
    required this.label,
    required this.isSubmitting,
    this.isValid = true,
    this.disabledReason,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        FfSpace.lg,
        FfSpace.sm,
        FfSpace.lg,
        FfSpace.md,
      ),
      decoration: BoxDecoration(
        color: context.ff.color.surfacePage,
        border: Border(
          top: BorderSide(
            color: context.ff.color.borderSubtle.withValues(
              alpha: FfTint.strong.alpha,
            ),
            width: FfBorderWidth.hairline,
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: FfButton(
                  label: label,
                  isLoading: isSubmitting,
                  variant: FfButtonVariant.primary,
                  onPressed: isSubmitting ? null : onSubmit,
                ),
              ),
              if (!isValid && disabledReason != null) ...[
                const SizedBox(height: FfSpace.xs),
                Text(
                  disabledReason!,
                  style: context.ff.text.labelSm.copyWith(
                    color: context.ff.color.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
