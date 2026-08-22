import 'package:flutter/material.dart';
import '../../core/extensions/context_extensions.dart';
import '../../theme/stillwater_tokens.dart';
import 'ff_button.dart';

class FfConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;
  final VoidCallback onConfirm;

  const FfConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.isDestructive = false,
    required this.onConfirm,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (ctx) => FfConfirmDialog(
            title: title,
            message: message,
            confirmLabel: confirmLabel,
            cancelLabel: cancelLabel,
            isDestructive: isDestructive,
            onConfirm: () => Navigator.of(ctx).pop(true),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: context.textTheme.titleLarge),
      content: Text(message, style: context.textTheme.bodyMedium),
      actionsPadding: const EdgeInsets.all(StillwaterTokens.spaceLg),
      actions: [
        Row(
          children: [
            Expanded(
              child: FfButton(
                label: cancelLabel,
                variant: FfButtonVariant.outlined,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),
            const SizedBox(width: StillwaterTokens.spaceSm),
            Expanded(
              child: FfButton(
                label: confirmLabel,
                variant:
                    isDestructive
                        ? FfButtonVariant.destructive
                        : FfButtonVariant.primary,
                onPressed: onConfirm,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
