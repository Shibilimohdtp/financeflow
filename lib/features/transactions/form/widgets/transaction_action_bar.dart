import 'package:flutter/material.dart';

import '../../../../shared/widgets/ff_button.dart';
import '../../../../theme/ff.dart';
import '../../../../theme/stillwater_colors.dart';

class TransactionActionBar extends StatelessWidget {
  final String label;
  final bool isSubmitting;
  final VoidCallback? onSubmit;

  const TransactionActionBar({
    super.key,
    required this.label,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        FfSpace.lg,
        FfSpace.sm,
        FfSpace.lg,
        FfSpace.md,
      ),
      decoration: BoxDecoration(
        color:
            isDark
                ? StillwaterColors.darkSurfaceDefault
                : StillwaterColors.lightSurfaceDefault,
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
          child: SizedBox(
            width: double.infinity,
            child: FfButton(
              label: label,
              isLoading: isSubmitting,
              variant: FfButtonVariant.primary,
              onPressed: isSubmitting ? null : onSubmit,
            ),
          ),
        ),
      ),
    );
  }
}
