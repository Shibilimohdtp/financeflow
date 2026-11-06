import 'package:financeflow/features/transactions/transaction_form.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/category.dart';
import 'package:financeflow/models/money_record.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 5, 12);
  final wallet = Account(
    id: 'wallet',
    name: 'Cash Wallet',
    type: AccountType.cash,
    createdAt: now,
    updatedAt: now,
  );
  final savings = Account(
    id: 'savings',
    name: 'Savings',
    type: AccountType.bank,
    createdAt: now,
    updatedAt: now,
  );
  final food = Category(
    id: 'cat_food',
    name: 'Food',
    iconIdentifier: 'restaurant',
    colorTokenIdentifier: 'clay',
    createdAt: now,
    updatedAt: now,
  );

  TransactionFormValues expense({
    String amount = '200',
    String payee = '',
    Category? category,
    Account? account,
  }) => TransactionFormValues(
    amountText: amount,
    payeeText: payee,
    type: TransactionType.expense,
    purpose: TransactionPurpose.expense,
    category: category ?? food,
    account: account ?? wallet,
    date: now,
  );

  group('validation', () {
    test('amount, account and category are required; payee is not', () {
      expect(validateTransactionForm(expense()).isValid, isTrue);
      expect(validateTransactionForm(expense(amount: '')).amount, isNotNull);
      expect(validateTransactionForm(expense(amount: '0')).amount, isNotNull);
      expect(
        validateTransactionForm(
          TransactionFormValues(
            amountText: '10',
            payeeText: '',
            type: TransactionType.expense,
            purpose: TransactionPurpose.expense,
            account: wallet,
            date: now,
          ),
        ).category,
        isNotNull,
      );
      expect(
        validateTransactionForm(
          TransactionFormValues(
            amountText: '10',
            payeeText: '',
            type: TransactionType.expense,
            purpose: TransactionPurpose.expense,
            category: food,
            date: now,
          ),
        ).account,
        isNotNull,
      );
    });

    test('transfers need two different accounts and no category', () {
      TransactionFormValues transfer(Account? to) => TransactionFormValues(
        amountText: '500',
        payeeText: '',
        type: TransactionType.transfer,
        purpose: TransactionPurpose.internalTransfer,
        account: wallet,
        toAccount: to,
        date: now,
      );
      expect(validateTransactionForm(transfer(null)).toAccount, isNotNull);
      expect(validateTransactionForm(transfer(wallet)).toAccount, isNotNull);
      expect(validateTransactionForm(transfer(savings)).isValid, isTrue);
    });

    test('lending needs the person', () {
      final v = TransactionFormValues(
        amountText: '1000',
        payeeText: '',
        type: TransactionType.expense,
        purpose: TransactionPurpose.lending,
        category: food,
        account: wallet,
        date: now,
      );
      expect(validateTransactionForm(v).payee, isNotNull);
    });
  });

  group('build', () {
    test('a blank payee is saved under the category name', () {
      final tx =
          buildTransactionFromForm(expense(), id: 't1', now: now).transaction;
      expect(tx.merchant, 'Food');
      expect(tx.amount, 200);
      expect(tx.categoryId, 'cat_food');
      expect(tx.accountId, 'wallet');
      expect(() => tx.validate(), returnsNormally);
    });

    test('a typed payee is kept and normalized', () {
      final tx =
          buildTransactionFromForm(
            expense(payee: '  Swiggy  '),
            id: 't1',
            now: now,
          ).transaction;
      expect(tx.merchant, 'Swiggy');
      expect(tx.normalizedMerchant, isNotEmpty);
    });

    test('a blank transfer is named after the destination', () {
      final tx =
          buildTransactionFromForm(
            TransactionFormValues(
              amountText: '500',
              payeeText: '',
              type: TransactionType.transfer,
              purpose: TransactionPurpose.internalTransfer,
              category: food,
              account: wallet,
              toAccount: savings,
              date: now,
            ),
            id: 't2',
            now: now,
          ).transaction;
      expect(tx.merchant, 'To Savings');
      expect(tx.toAccountId, 'savings');
      // Transfers never carry a spending category.
      expect(tx.categoryId, 'cat_transfer');
      expect(tx.consumptionExpenseAmount, 0);
    });

    test('tags are split and trimmed; amounts accept symbols and commas', () {
      final tx =
          buildTransactionFromForm(
            TransactionFormValues(
              amountText: '₹1,234.50',
              payeeText: 'Store',
              tagsText: ' trip, , office ',
              type: TransactionType.expense,
              purpose: TransactionPurpose.expense,
              category: food,
              account: wallet,
              date: now,
            ),
            id: 't3',
            now: now,
          ).transaction;
      expect(tx.amount, 1234.5);
      expect(tx.tags, ['trip', 'office']);
    });

    test('editing keeps id, createdAt and import provenance', () {
      final original = Transaction(
        id: 'orig',
        amount: 99,
        type: TransactionType.expense,
        categoryId: 'cat_food',
        categoryName: 'Food',
        categoryIcon: 'restaurant',
        categoryColor: 'clay',
        merchant: 'Old',
        date: now,
        accountId: 'wallet',
        source: TransactionSource.sms,
        fingerprint: 'fp',
        sourceName: 'HDFC',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      final tx =
          buildTransactionFromForm(
            expense(payee: 'New'),
            id: original.id,
            now: now,
            initial: original,
          ).transaction;
      expect(tx.id, 'orig');
      expect(tx.createdAt, DateTime(2026, 1, 1));
      expect(tx.updatedAt, now);
      expect(tx.source, TransactionSource.sms);
      expect(tx.fingerprint, 'fp');
      expect(tx.sourceName, 'HDFC');
    });

    test('lending adds to an open debt with the same person', () {
      final existing = MoneyRecord(
        id: 'debt_existing',
        type: MoneyRecordType.lent,
        personName: 'Muneer',
        originalAmount: 500,
        transactionDate: DateTime(2026, 10, 1),
        dueDate: DateTime(2026, 11, 1),
        createdAt: now,
        updatedAt: now,
      );
      final built = buildTransactionFromForm(
        TransactionFormValues(
          amountText: '300',
          payeeText: '',
          counterpartyText: ' muneer ',
          type: TransactionType.expense,
          purpose: TransactionPurpose.lending,
          account: wallet,
          date: now,
        ),
        id: 't4',
        now: now,
        existingDebts: [existing],
      );
      expect(built.transaction.linkedMoneyRecordId, 'debt_existing');
      expect(built.debt?.id, 'debt_existing');
      expect(built.transaction.merchant, 'muneer');
      // Lending is not spending.
      expect(built.transaction.consumptionExpenseAmount, 0);
    });

    test('lending can open a separate debt', () {
      final built = buildTransactionFromForm(
        TransactionFormValues(
          amountText: '300',
          payeeText: '',
          counterpartyText: 'Muneer',
          type: TransactionType.expense,
          purpose: TransactionPurpose.lending,
          account: wallet,
          date: now,
          createAsSeparateDebt: true,
        ),
        id: 't5',
        now: now,
      );
      expect(built.debt?.id, 'debt_t5');
      expect(built.debt?.isCustomSeparateObligation, isTrue);
      expect(built.debt?.dueDate, DateTime(2026, 12, 5));
    });
  });

  group('helpers', () {
    test('defaultPaymentFor returns sensible default by type', () {
      expect(
        TransactionFormValues.defaultPaymentFor(TransactionType.cash),
        'Cash',
      );
      expect(
        TransactionFormValues.defaultPaymentFor(TransactionType.loanEmi),
        'Auto Debit',
      );
      expect(
        TransactionFormValues.defaultPaymentFor(TransactionType.transfer),
        'IMPS / NEFT',
      );
      expect(
        TransactionFormValues.defaultPaymentFor(TransactionType.expense),
        'UPI',
      );
    });

    test('paymentMethodsFor filters allowed methods by type', () {
      expect(TransactionFormValues.paymentMethodsFor(TransactionType.cash), [
        'Cash',
        'Other',
      ]);
      expect(TransactionFormValues.paymentMethodsFor(TransactionType.loanEmi), [
        'Auto Debit',
        'UPI',
        'Net Banking',
        'Other',
      ]);
      expect(
        TransactionFormValues.paymentMethodsFor(TransactionType.expense),
        TransactionFormValues.allPaymentMethods,
      );
    });

    test('typeForPurpose maps purposes accurately to transaction types', () {
      expect(
        TransactionFormValues.typeForPurpose(TransactionPurpose.income),
        TransactionType.income,
      );
      expect(
        TransactionFormValues.typeForPurpose(TransactionPurpose.borrowing),
        TransactionType.income,
      );
      expect(
        TransactionFormValues.typeForPurpose(
          TransactionPurpose.internalTransfer,
        ),
        TransactionType.transfer,
      );
      expect(
        TransactionFormValues.typeForPurpose(TransactionPurpose.loanRepayment),
        TransactionType.loanEmi,
      );
      expect(
        TransactionFormValues.typeForPurpose(
          TransactionPurpose.investmentPurchase,
        ),
        TransactionType.investment,
      );
      expect(
        TransactionFormValues.typeForPurpose(TransactionPurpose.legacyCash),
        TransactionType.cash,
      );
      expect(
        TransactionFormValues.typeForPurpose(TransactionPurpose.expense),
        TransactionType.expense,
      );
    });

    test('formatInitialAmount preserves decimals only when fractional', () {
      expect(TransactionFormValues.formatInitialAmount(250.0), '250');
      expect(TransactionFormValues.formatInitialAmount(250.5), '250.50');
      expect(TransactionFormValues.formatInitialAmount(0.0), '0');
    });
  });
}
