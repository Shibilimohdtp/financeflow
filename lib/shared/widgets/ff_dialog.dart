import 'package:flutter/material.dart';

import '../../theme/ff.dart';
import 'ff_button.dart';

/// Optional status shown as an icon beside a dialog title.
enum FfDialogTone { neutral, success, warning, error }

/// Every dialog in FinanceFlow. Use the static helpers; they return when the
/// dialog closes.
abstract final class FfDialog {
  /// Asks a yes/no question. Resolves to true when confirmed, false when
  /// cancelled and null when dismissed by tapping outside.
  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool destructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (ctx) => _FfDialogFrame(
            title: title,
            content: Text(message, style: ctx.ff.text.body),
            actions: _ActionRow(
              secondaryLabel: cancelLabel,
              onSecondary: () => Navigator.of(ctx).pop(false),
              primaryLabel: confirmLabel,
              primaryVariant:
                  destructive
                      ? FfButtonVariant.destructive
                      : FfButtonVariant.primary,
              onPrimary: () => Navigator.of(ctx).pop(true),
            ),
          ),
    );
  }

  /// A destructive confirmation that only enables the confirm button once
  /// the user types [confirmWord]. For irreversible, high-impact actions such
  /// as wiping all data.
  static Future<bool?> confirmTyped(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmWord,
    String confirmLabel = 'Delete',
    String cancelLabel = 'Cancel',
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (ctx) => _TypedConfirmDialog(
            title: title,
            message: message,
            confirmWord: confirmWord,
            confirmLabel: confirmLabel,
            cancelLabel: cancelLabel,
          ),
    );
  }

  /// Tells the user something happened. Shows [message] or a custom
  /// [content], a close button, and optionally one follow-up action (the
  /// dialog closes before [onAction] runs).
  static Future<void> info(
    BuildContext context, {
    required String title,
    String? message,
    Widget? content,
    FfDialogTone tone = FfDialogTone.neutral,
    String closeLabel = 'Done',
    String? actionLabel,
    IconData? actionIcon,
    VoidCallback? onAction,
    bool dismissible = true,
  }) {
    assert(message != null || content != null);
    return showDialog<void>(
      context: context,
      barrierDismissible: dismissible,
      builder: (ctx) {
        final hasAction = actionLabel != null && onAction != null;
        return _FfDialogFrame(
          title: title,
          tone: tone,
          content: content ?? Text(message!, style: ctx.ff.text.body),
          actions:
              hasAction
                  ? _ActionRow(
                    secondaryLabel: closeLabel,
                    onSecondary: () => Navigator.of(ctx).pop(),
                    primaryLabel: actionLabel,
                    primaryIcon: actionIcon,
                    onPrimary: () {
                      Navigator.of(ctx).pop();
                      onAction();
                    },
                  )
                  : SizedBox(
                    width: double.infinity,
                    child: FfButton(
                      label: closeLabel,
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ),
        );
      },
    );
  }

  /// Runs [task] behind a blocking progress dialog with [message], then
  /// closes it and returns the task's result (or rethrows its error).
  static Future<T> withProgress<T>(
    BuildContext context, {
    required String message,
    required Future<T> Function() task,
  }) async {
    final navigator = Navigator.of(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => PopScope(
            canPop: false,
            child: _FfDialogFrame(
              content: Row(
                children: [
                  const SizedBox.square(
                    dimension: FfButtonTokens.spinnerSize,
                    child: CircularProgressIndicator(
                      strokeWidth: FfButtonTokens.spinnerStroke,
                    ),
                  ),
                  const SizedBox(width: FfSpace.md),
                  Expanded(child: Text(message, style: ctx.ff.text.body)),
                ],
              ),
            ),
          ),
    );
    try {
      return await task();
    } finally {
      if (navigator.mounted) navigator.pop();
    }
  }
}

class _FfDialogFrame extends StatelessWidget {
  const _FfDialogFrame({
    this.title,
    this.tone = FfDialogTone.neutral,
    required this.content,
    this.actions,
  });

  final String? title;
  final FfDialogTone tone;
  final Widget content;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final (IconData? icon, Color? iconColor) = switch (tone) {
      FfDialogTone.neutral => (null, null),
      FfDialogTone.success => (
        Icons.check_circle_outline_rounded,
        ff.color.statusSuccess,
      ),
      FfDialogTone.warning => (
        Icons.warning_amber_rounded,
        ff.color.statusWarning,
      ),
      FfDialogTone.error => (Icons.error_outline_rounded, ff.color.statusError),
    };

    return AlertDialog(
      title:
          title == null
              ? null
              : Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: iconColor, size: FfIconSize.xl),
                    const SizedBox(width: FfSpace.xs),
                  ],
                  Expanded(child: Text(title!, style: ff.text.titleLg)),
                ],
              ),
      content: SingleChildScrollView(child: content),
      actionsPadding: const EdgeInsets.all(FfDialogActionTokens.padding),
      actions: actions == null ? null : [actions!],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.secondaryLabel,
    required this.onSecondary,
    required this.primaryLabel,
    required this.onPrimary,
    this.primaryVariant = FfButtonVariant.primary,
    this.primaryIcon,
  });

  final String secondaryLabel;
  final VoidCallback onSecondary;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final FfButtonVariant primaryVariant;
  final IconData? primaryIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FfButton(
            label: secondaryLabel,
            variant: FfButtonVariant.outlined,
            onPressed: onSecondary,
          ),
        ),
        const SizedBox(width: FfDialogActionTokens.gap),
        Expanded(
          child: FfButton(
            label: primaryLabel,
            variant: primaryVariant,
            leadingIcon:
                primaryIcon == null
                    ? null
                    : Icon(primaryIcon, size: FfIconSize.sm),
            onPressed: onPrimary,
          ),
        ),
      ],
    );
  }
}

class _TypedConfirmDialog extends StatefulWidget {
  const _TypedConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmWord,
    required this.confirmLabel,
    required this.cancelLabel,
  });

  final String title;
  final String message;
  final String confirmWord;
  final String confirmLabel;
  final String cancelLabel;

  @override
  State<_TypedConfirmDialog> createState() => _TypedConfirmDialogState();
}

class _TypedConfirmDialogState extends State<_TypedConfirmDialog> {
  final _controller = TextEditingController();
  bool _matches = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    return _FfDialogFrame(
      title: widget.title,
      tone: FfDialogTone.warning,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.message, style: ff.text.body),
          const SizedBox(height: FfSpace.md),
          Text('Type ${widget.confirmWord} to continue', style: ff.text.label),
          const SizedBox(height: FfSpace.xs),
          TextField(
            controller: _controller,
            autofocus: true,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(hintText: widget.confirmWord),
            onChanged:
                (v) =>
                    setState(() => _matches = v.trim() == widget.confirmWord),
          ),
        ],
      ),
      actions: _ActionRow(
        secondaryLabel: widget.cancelLabel,
        onSecondary: () => Navigator.of(context).pop(false),
        primaryLabel: widget.confirmLabel,
        primaryVariant: FfButtonVariant.destructive,
        onPrimary: _matches ? () => Navigator.of(context).pop(true) : null,
      ),
    );
  }
}
