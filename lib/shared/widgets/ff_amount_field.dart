import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/extensions/context_extensions.dart';
import '../../theme/stillwater_tokens.dart';
import '../../theme/stillwater_typography.dart';

class FfAmountField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final bool autoFocus;

  const FfAmountField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.errorText,
    this.onChanged,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(labelText!, style: theme.textTheme.labelMedium),
          const SizedBox(height: StillwaterTokens.space2Xs),
        ],
        Container(
          height: StillwaterTokens.amountFieldHeight,
          padding: const EdgeInsets.symmetric(
            horizontal: StillwaterTokens.spaceMd,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
            border: Border.all(
              color:
                  errorText != null
                      ? theme.colorScheme.error
                      : theme.colorScheme.outline,
              width:
                  errorText != null
                      ? StillwaterTokens.borderWidthFocus
                      : StillwaterTokens.borderWidthDefault,
            ),
          ),
          child: Row(
            children: [
              Text(
                '₹ ',
                style: StillwaterTypography.numHero(
                  color: theme.colorScheme.primary,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  autofocus: autoFocus,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  style: StillwaterTypography.numHero(
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: hintText ?? '0',
                    suffixIcon:
                        controller.text.isEmpty
                            ? null
                            : IconButton(
                              tooltip: 'Clear amount',
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: controller.clear,
                            ),
                  ),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: StillwaterTokens.space2Xs),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}
