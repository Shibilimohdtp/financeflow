class CsvColumnMapping {
  final int? dateIndex;
  final int? timeIndex;
  final int? amountIndex;
  final int? debitIndex;
  final int? creditIndex;
  final int? typeIndex;
  final int? merchantIndex;
  final int? categoryIndex;
  final int? accountIndex;
  final int? paymentMethodIndex;
  final int? referenceIndex;
  final int? notesIndex;

  const CsvColumnMapping({
    this.dateIndex,
    this.timeIndex,
    this.amountIndex,
    this.debitIndex,
    this.creditIndex,
    this.typeIndex,
    this.merchantIndex,
    this.categoryIndex,
    this.accountIndex,
    this.paymentMethodIndex,
    this.referenceIndex,
    this.notesIndex,
  });

  bool get hasDate => dateIndex != null;
  bool get hasAmount =>
      amountIndex != null || (debitIndex != null || creditIndex != null);
  bool get hasMerchant => merchantIndex != null;
  bool get hasSeparateDebitCredit => debitIndex != null && creditIndex != null;

  bool get isValid => hasDate && hasAmount;

  CsvColumnMapping copyWith({
    int? dateIndex,
    bool clearDate = false,
    int? timeIndex,
    bool clearTime = false,
    int? amountIndex,
    bool clearAmount = false,
    int? debitIndex,
    bool clearDebit = false,
    int? creditIndex,
    bool clearCredit = false,
    int? typeIndex,
    bool clearType = false,
    int? merchantIndex,
    bool clearMerchant = false,
    int? categoryIndex,
    bool clearCategory = false,
    int? accountIndex,
    bool clearAccount = false,
    int? paymentMethodIndex,
    bool clearPaymentMethod = false,
    int? referenceIndex,
    bool clearReference = false,
    int? notesIndex,
    bool clearNotes = false,
  }) {
    return CsvColumnMapping(
      dateIndex: clearDate ? null : (dateIndex ?? this.dateIndex),
      timeIndex: clearTime ? null : (timeIndex ?? this.timeIndex),
      amountIndex: clearAmount ? null : (amountIndex ?? this.amountIndex),
      debitIndex: clearDebit ? null : (debitIndex ?? this.debitIndex),
      creditIndex: clearCredit ? null : (creditIndex ?? this.creditIndex),
      typeIndex: clearType ? null : (typeIndex ?? this.typeIndex),
      merchantIndex:
          clearMerchant ? null : (merchantIndex ?? this.merchantIndex),
      categoryIndex:
          clearCategory ? null : (categoryIndex ?? this.categoryIndex),
      accountIndex: clearAccount ? null : (accountIndex ?? this.accountIndex),
      paymentMethodIndex:
          clearPaymentMethod
              ? null
              : (paymentMethodIndex ?? this.paymentMethodIndex),
      referenceIndex:
          clearReference ? null : (referenceIndex ?? this.referenceIndex),
      notesIndex: clearNotes ? null : (notesIndex ?? this.notesIndex),
    );
  }
}

class CsvColumnMapper {
  CsvColumnMapper._();

  /// Automatically detect column indices from header names
  static CsvColumnMapping autoDetect(
    List<String> headers, {
    List<List<String>>? sampleRows,
  }) {
    int? dateIdx;
    int? timeIdx;
    int? amountIdx;
    int? debitIdx;
    int? creditIdx;
    int? typeIdx;
    int? merchantIdx;
    int? categoryIdx;
    int? accountIdx;
    int? paymentMethodIdx;
    int? referenceIdx;
    int? notesIdx;

    for (int i = 0; i < headers.length; i++) {
      final h = headers[i].trim().toLowerCase();
      final cleanH =
          h
              .replaceAll(RegExp(r'[^a-z0-9/]'), ' ')
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim();

      // 1. Date
      if (dateIdx == null &&
          (cleanH == 'date' ||
              cleanH == 'txn date' ||
              cleanH == 'trans date' ||
              cleanH == 'transaction date' ||
              cleanH == 'value date' ||
              cleanH == 'posting date' ||
              cleanH == 'booking date' ||
              cleanH.contains('date'))) {
        dateIdx = i;
        continue;
      }

      // 2. Time
      if (timeIdx == null &&
          (cleanH == 'time' ||
              cleanH == 'txn time' ||
              cleanH == 'trans time' ||
              cleanH == 'transaction time' ||
              cleanH.contains('time'))) {
        timeIdx = i;
        continue;
      }

      // 3. Debit / Withdrawal
      if (debitIdx == null &&
          (cleanH == 'debit' ||
              cleanH == 'dr' ||
              cleanH == 'dr amt' ||
              cleanH == 'dr amount' ||
              cleanH == 'withdrawal' ||
              cleanH == 'withdrawal amt' ||
              cleanH == 'withdrawal amount' ||
              cleanH == 'withdrawals' ||
              cleanH == 'paid out' ||
              cleanH == 'spent' ||
              cleanH.contains('withdrawal') ||
              cleanH.contains('debit'))) {
        debitIdx = i;
        continue;
      }

      // 4. Credit / Deposit
      if (creditIdx == null &&
          (cleanH == 'credit' ||
              cleanH == 'cr' ||
              cleanH == 'cr amt' ||
              cleanH == 'cr amount' ||
              cleanH == 'deposit' ||
              cleanH == 'deposit amt' ||
              cleanH == 'deposit amount' ||
              cleanH == 'deposits' ||
              cleanH == 'paid in' ||
              cleanH == 'received' ||
              cleanH.contains('deposit') ||
              cleanH.contains('credit'))) {
        creditIdx = i;
        continue;
      }

      // 5. Amount (Single column)
      if (amountIdx == null &&
          (cleanH == 'amount' ||
              cleanH == 'txn amount' ||
              cleanH == 'transaction amount' ||
              cleanH == 'net amount' ||
              cleanH == 'sum' ||
              cleanH == 'total' ||
              cleanH == 'amt')) {
        amountIdx = i;
        continue;
      }

      // 6. Type / Direction
      if (typeIdx == null &&
          (cleanH == 'type' ||
              cleanH == 'dr/cr' ||
              cleanH == 'cr/dr' ||
              cleanH == 'direction' ||
              cleanH == 'txn type' ||
              cleanH == 'transaction type')) {
        typeIdx = i;
        continue;
      }

      // 7. Merchant / Description / Particulars
      if (merchantIdx == null &&
          (cleanH == 'narration' ||
              cleanH == 'description' ||
              cleanH == 'particulars' ||
              cleanH == 'merchant' ||
              cleanH == 'payee' ||
              cleanH == 'beneficiary' ||
              cleanH == 'details' ||
              cleanH == 'party' ||
              cleanH == 'remarks' ||
              cleanH == 'transaction remarks' ||
              cleanH == 'name')) {
        merchantIdx = i;
        continue;
      }

      // 8. Category
      if (categoryIdx == null &&
          (cleanH == 'category' ||
              cleanH == 'sub category' ||
              cleanH == 'expense category' ||
              cleanH == 'cat')) {
        categoryIdx = i;
        continue;
      }

      // 9. Account
      if (accountIdx == null &&
          (cleanH == 'account' ||
              cleanH == 'a/c' ||
              cleanH == 'account no' ||
              cleanH == 'acc no' ||
              cleanH == 'account name' ||
              cleanH == 'bank account')) {
        accountIdx = i;
        continue;
      }

      // 10. Payment Method
      if (paymentMethodIdx == null &&
          (cleanH == 'mode' ||
              cleanH == 'payment mode' ||
              cleanH == 'payment method' ||
              cleanH == 'instrument' ||
              cleanH == 'channel')) {
        paymentMethodIdx = i;
        continue;
      }

      // 11. Reference / UTR / Txn ID
      if (referenceIdx == null &&
          (cleanH == 'ref' ||
              cleanH == 'reference' ||
              cleanH == 'ref no' ||
              cleanH == 'reference no' ||
              cleanH == 'reference number' ||
              cleanH == 'utr' ||
              cleanH == 'rrn' ||
              cleanH == 'txn id' ||
              cleanH == 'transaction id' ||
              cleanH == 'chq no' ||
              cleanH == 'cheque no' ||
              cleanH == 'chq/ref no' ||
              cleanH == 'cheque/ref no' ||
              cleanH.contains('ref') ||
              cleanH.contains('utr'))) {
        referenceIdx = i;
        continue;
      }

      // 12. Notes / Memo
      if (notesIdx == null &&
          (cleanH == 'notes' ||
              cleanH == 'note' ||
              cleanH == 'memo' ||
              cleanH == 'comment' ||
              cleanH == 'comments')) {
        notesIdx = i;
        continue;
      }
    }

    // Fallbacks if single amount isn't explicitly separated
    if (amountIdx == null && debitIdx == null && creditIdx == null) {
      // Look for any header containing 'amount' or 'rs' or 'inr'
      for (int i = 0; i < headers.length; i++) {
        final h = headers[i].toLowerCase();
        if (h.contains('amount') ||
            h.contains('amt') ||
            h.contains('inr') ||
            h.contains('₹')) {
          amountIdx = i;
          break;
        }
      }
    }

    // Fallback for merchant / description if not found
    if (merchantIdx == null) {
      for (int i = 0; i < headers.length; i++) {
        if (i != dateIdx &&
            i != timeIdx &&
            i != amountIdx &&
            i != debitIdx &&
            i != creditIdx) {
          merchantIdx = i;
          break;
        }
      }
    }

    return CsvColumnMapping(
      dateIndex: dateIdx,
      timeIndex: timeIdx,
      amountIndex: amountIdx,
      debitIndex: debitIdx,
      creditIndex: creditIdx,
      typeIndex: typeIdx,
      merchantIndex: merchantIdx,
      categoryIndex: categoryIdx,
      accountIndex: accountIdx,
      paymentMethodIndex: paymentMethodIdx,
      referenceIndex: referenceIdx,
      notesIndex: notesIdx,
    );
  }
}
