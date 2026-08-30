import 'package:flutter/material.dart';

import '../../models/transaction.dart';
import 'add_edit_transaction_screen.dart';

export 'add_edit_transaction_screen.dart';

/// Compatibility wrapper for [AddEditTransactionScreen].
/// Routes all `show` invocations to [AddEditTransactionScreen.push].
class AddEditTransactionSheet extends StatelessWidget {
  final Transaction? initialTransaction;
  final Future<void> Function(Transaction)? onSave;
  final String? headerTitle;
  final String? saveLabel;
  final Widget? sourceContext;

  const AddEditTransactionSheet({
    super.key,
    this.initialTransaction,
    this.onSave,
    this.headerTitle,
    this.saveLabel,
    this.sourceContext,
  });

  /// Pushes the full-screen [AddEditTransactionScreen].
  static Future<T?> show<T>(
    BuildContext context, {
    Transaction? initialTransaction,
    Future<void> Function(Transaction)? onSave,
    String? headerTitle,
    String? saveLabel,
    Widget? sourceContext,
    bool enableDrag = false,
  }) {
    return AddEditTransactionScreen.push<T>(
      context,
      initialTransaction: initialTransaction,
      onSave: onSave,
      headerTitle: headerTitle,
      saveLabel: saveLabel,
      sourceContext: sourceContext,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AddEditTransactionScreen(
      initialTransaction: initialTransaction,
      onSave: onSave,
      headerTitle: headerTitle,
      saveLabel: saveLabel,
      sourceContext: sourceContext,
    );
  }
}
