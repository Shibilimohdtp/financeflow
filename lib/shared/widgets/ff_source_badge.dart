import 'package:flutter/material.dart';
import '../../core/extensions/context_extensions.dart';
import '../../models/transaction.dart';
import '../../theme/stillwater_tokens.dart';

class FfSourceBadge extends StatelessWidget {
  final TransactionSource source;
  final String? sourceName;
  final bool isMerged;
  final String? customLabel;

  const FfSourceBadge({
    super.key,
    required this.source,
    this.sourceName,
    this.isMerged = false,
    this.customLabel,
  });

  String get _displayLabel {
    if (customLabel != null && customLabel!.isNotEmpty) {
      return customLabel!;
    }
    if (isMerged) {
      return 'Merged Sources';
    }
    if (sourceName != null && sourceName!.isNotEmpty) {
      return '${source.displayName}: $sourceName';
    }
    return source.displayName;
  }

  IconData _getIcon() {
    if (isMerged) return Icons.call_merge_rounded;
    switch (source) {
      case TransactionSource.csv:
      case TransactionSource.xlsx:
      case TransactionSource.ofx:
      case TransactionSource.qif:
        return Icons.file_present_outlined;
      case TransactionSource.notification:
        return Icons.notifications_active_outlined;
      case TransactionSource.sms:
        return Icons.sms_outlined;
      case TransactionSource.email:
        return Icons.mail_outline_rounded;
      case TransactionSource.manual:
      default:
        return Icons.edit_note_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = context.aiColors.accent;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: StillwaterTokens.spaceXs,
        vertical: StillwaterTokens.space3Xs,
      ),
      decoration: BoxDecoration(
        color:
            isMerged
                ? accentColor.withValues(alpha: 0.12)
                : context.theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusXs),
        border: Border.all(
          color:
              isMerged
                  ? accentColor.withValues(alpha: 0.3)
                  : context.theme.dividerColor,
          width: StillwaterTokens.borderWidthHairline,
        ),
      ),
      child: ClipRect(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIcon(),
              size: 11,
              color:
                  isMerged
                      ? accentColor
                      : context.theme.textTheme.bodySmall?.color,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                _displayLabel,
                style: context.textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color:
                      isMerged
                          ? accentColor
                          : context.theme.textTheme.bodySmall?.color,
                  fontWeight: isMerged ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
