import '../../models/ingestion/parsed_transaction.dart';
import '../../models/transaction.dart';

class TransactionMergeService {
  TransactionMergeService._();

  /// Merge an incoming ParsedTransaction into an existing saved Transaction
  static Transaction mergeWithExisting({
    required Transaction existing,
    required ParsedTransaction incoming,
  }) {
    // 1. Amount: Preserve existing if positive, otherwise incoming
    final amount = existing.amount > 0 ? existing.amount : incoming.amount;

    // 2. Date: Preserve the date with more precision (e.g. non-midnight time if available)
    DateTime resolvedDate = existing.date;
    final exHasTime =
        existing.date.hour != 0 ||
        existing.date.minute != 0 ||
        existing.date.second != 0;
    final inHasTime =
        incoming.date.hour != 0 ||
        incoming.date.minute != 0 ||
        incoming.date.second != 0;

    if (!exHasTime && inHasTime) {
      resolvedDate = incoming.date;
    }

    // 3. Merchant: Canonical normalized merchant
    final merchant =
        incoming.merchantDisplayName != null
            ? incoming.normalizedMerchant
            : existing.normalizedMerchant ?? incoming.normalizedMerchant;
    final originalMerchant = existing.originalMerchant ?? existing.merchant;

    // 4. Reference Number: Combine/preserve non-empty
    final refNo =
        existing.sourceReference != null && existing.sourceReference!.isNotEmpty
            ? existing.sourceReference
            : incoming.referenceNumber;

    // 5. Payment Method: Preserve non-empty
    final paymentMethod = existing.paymentMethod ?? incoming.paymentMethod;

    // 6. Notes: Combine notes without duplicating
    String? combinedNotes = existing.notes;
    if (incoming.notes != null && incoming.notes!.isNotEmpty) {
      if (combinedNotes == null || combinedNotes.isEmpty) {
        combinedNotes = incoming.notes;
      } else if (!combinedNotes.contains(incoming.notes!)) {
        combinedNotes = '$combinedNotes · ${incoming.notes}';
      }
    }

    // 7. Combine Source Provenance
    final mergedSources = List<String>.from(existing.mergedSources);
    final incomingSourceLabel =
        incoming.sourceName != null && incoming.sourceName!.isNotEmpty
            ? '${incoming.source.displayName}: ${incoming.sourceName}'
            : incoming.source.displayName;

    if (!mergedSources.contains(incomingSourceLabel)) {
      mergedSources.add(incomingSourceLabel);
    }
    if (mergedSources.isEmpty) {
      final existingLabel =
          existing.sourceName != null && existing.sourceName!.isNotEmpty
              ? '${existing.source.displayName}: ${existing.sourceName}'
              : existing.source.displayName;
      mergedSources.add(existingLabel);
      if (!mergedSources.contains(incomingSourceLabel)) {
        mergedSources.add(incomingSourceLabel);
      }
    }

    // 8. Category: Keep existing category (user choice or rule), fallback to incoming if confidence higher
    String categoryId = existing.categoryId;
    String categoryName = existing.categoryName;
    String categoryIcon = existing.categoryIcon;
    String categoryColor = existing.categoryColor;

    if (categoryId == 'cat_miscellaneous' &&
        incoming.categoryId != 'cat_miscellaneous' &&
        incoming.categorizationConfidence >
            (existing.categorizationConfidence ?? 0.0)) {
      categoryId = incoming.categoryId;
      categoryName = incoming.categoryName;
      categoryIcon = incoming.categoryIcon;
      categoryColor = incoming.categoryColor;
    }

    return existing.copyWith(
      amount: amount,
      merchant:
          incoming.merchantDisplayName ??
          (merchant.isNotEmpty ? merchant : existing.merchant),
      originalMerchant: originalMerchant,
      normalizedMerchant: merchant,
      date: resolvedDate,
      sourceReference: refNo,
      paymentMethod: paymentMethod,
      notes: combinedNotes,
      categoryId: categoryId,
      categoryName: categoryName,
      categoryIcon: categoryIcon,
      categoryColor: categoryColor,
      mergedSources: mergedSources,
      duplicateGroupId: existing.id,
      reviewStatus: 'merged',
      updatedAt: DateTime.now(),
    );
  }

  /// Format a user-friendly provenance summary for a transaction
  static String formatProvenanceSummary(Transaction tx) {
    if (tx.mergedSources.length > 1) {
      return 'Merged from ${tx.mergedSources.join(' + ')}';
    }
    if (tx.sourceName != null && tx.sourceName!.isNotEmpty) {
      switch (tx.source) {
        case TransactionSource.notification:
          return 'Detected on-device from ${tx.sourceName} notification';
        case TransactionSource.sms:
          return 'Parsed on-device from ${tx.sourceName} SMS';
        case TransactionSource.csv:
          return 'Imported from ${tx.sourceName}';
        default:
          return '${tx.source.displayName}: ${tx.sourceName}';
      }
    }
    switch (tx.source) {
      case TransactionSource.notification:
        return 'Detected on-device from notification';
      case TransactionSource.sms:
        return 'Parsed on-device from bank SMS';
      case TransactionSource.csv:
        return 'Imported from CSV';
      case TransactionSource.manual:
        return 'Manually entered';
      default:
        return tx.source.displayName;
    }
  }
}
