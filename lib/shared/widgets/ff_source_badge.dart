import 'package:flutter/material.dart';
import '../../models/transaction.dart';
import '../../theme/ff.dart';

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
    final accentColor = context.ff.color.statusInfo;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FfSpace.xs,
        vertical: FfSpace.x3s,
      ),
      decoration: BoxDecoration(
        color:
            isMerged
                ? accentColor.withValues(alpha: FfTint.subtle.alpha)
                : context.ff.color.surfaceContainerLow,
        borderRadius: BorderRadius.circular(FfRadius.xs),
        border: Border.all(
          color:
              isMerged
                  ? accentColor.withValues(alpha: FfTint.strong.alpha)
                  : context.ff.color.borderSubtle,
          width: FfBorderWidth.hairline,
        ),
      ),
      child: ClipRect(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIcon(),
              size: 11,
              color: isMerged ? accentColor : context.ff.text.bodySm.color,
            ),
            const SizedBox(width: FfSpace.x2s),
            Flexible(
              child: Text(
                _displayLabel,
                style: context.ff.text.labelSm.copyWith(
                  color: isMerged ? accentColor : context.ff.text.bodySm.color,
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
