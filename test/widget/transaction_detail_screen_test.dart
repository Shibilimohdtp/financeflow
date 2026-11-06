import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/features/transactions/transaction_detail_screen.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/models/loan.dart';
import 'package:financeflow/models/subscription.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/repositories/loan_repository.dart';
import 'package:financeflow/repositories/subscription_repository.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_fonts.dart';
import '../helpers/fake_repositories.dart';

void main() {
  setUpAll(loadAppFonts);

  final refDate = DateTime(2026, 11, 6, 14, 30);

  final testAccountA = Account(
    id: 'acc_hdfc',
    name: 'HDFC Salary',
    type: AccountType.bank,
    currency: 'INR',
    maskedIdentifier: '••4012',
    createdAt: refDate,
    updatedAt: refDate,
  );

  final testAccountB = Account(
    id: 'acc_icici',
    name: 'ICICI Amazon Pay',
    type: AccountType.creditCard,
    currency: 'INR',
    maskedIdentifier: '••9821',
    createdAt: refDate,
    updatedAt: refDate,
  );

  final expenseTx = Transaction(
    id: 'tx_swiggy',
    amount: 540.0,
    type: TransactionType.expense,
    categoryId: 'cat_food',
    categoryName: 'Food & Dining',
    categoryIcon: 'restaurant',
    categoryColor: '#FF9800',
    merchant: 'Swiggy',
    date: refDate,
    accountId: 'acc_hdfc',
    paymentMethod: 'UPI',
    sourceReference: 'UPI/32910481029/SWIGGY',
    originalMerchant: 'SWIGGY-BANGALORE-IN',
    notes: 'Office lunch team treat',
    tags: const ['lunch', 'treat'],
    mergedSources: const ['SMS (HDFC)', 'Notification (GPay)'],
    isReviewed: true,
    createdAt: refDate,
    updatedAt: refDate,
  );

  final incomeTx = Transaction(
    id: 'tx_salary',
    amount: 125000.0,
    type: TransactionType.income,
    categoryId: 'cat_salary',
    categoryName: 'Salary',
    categoryIcon: 'work',
    categoryColor: '#4CAF50',
    merchant: 'Acme Corp',
    date: refDate,
    accountId: 'acc_hdfc',
    paymentMethod: 'NEFT',
    sourceReference: 'NEFT/ACME/9918231',
    createdAt: refDate,
    updatedAt: refDate,
  );

  final transferTx = Transaction(
    id: 'tx_transfer',
    amount: 15000.0,
    type: TransactionType.transfer,
    categoryId: 'cat_transfer',
    categoryName: 'Transfer',
    categoryIcon: 'swap_horiz',
    categoryColor: '#607D8B',
    merchant: 'Card Repayment',
    date: refDate,
    accountId: 'acc_hdfc',
    toAccountId: 'acc_icici',
    createdAt: refDate,
    updatedAt: refDate,
  );

  final subNetflix = Subscription(
    id: 'sub_netflix',
    merchant: 'Netflix',
    normalizedMerchant: 'netflix',
    amount: 649.0,
    currency: 'INR',
    billingFrequency: SubscriptionFrequency.monthly,
    nextRenewalDate: refDate.add(const Duration(days: 3)),
    lastPaymentDate: refDate.subtract(const Duration(days: 27)),
    accountId: 'acc_hdfc',
    category: 'Entertainment',
    createdAt: refDate,
    updatedAt: refDate,
  );

  final subTx = Transaction(
    id: 'tx_sub',
    amount: 649.0,
    type: TransactionType.expense,
    purpose: TransactionPurpose.subscriptionPayment,
    categoryId: 'cat_ent',
    categoryName: 'Entertainment',
    categoryIcon: 'movie',
    categoryColor: '#E50914',
    merchant: 'Netflix',
    date: refDate,
    accountId: 'acc_hdfc',
    linkedSubscriptionId: 'sub_netflix',
    createdAt: refDate,
    updatedAt: refDate,
  );

  final sampleLoan = Loan(
    id: 'loan_car',
    name: 'Car Loan',
    lender: 'HDFC Bank',
    loanType: LoanType.vehicleLoan,
    principalAmount: 800000.0,
    interestRate: 8.5,
    interestType: InterestType.reducingBalance,
    tenureMonths: 48,
    startDate: refDate.subtract(const Duration(days: 300)),
    expectedEndDate: refDate.add(const Duration(days: 1100)),
    emiAmount: 19700.0,
    paymentDay: 5,
    totalPrincipalPaid: 150000.0,
    totalInterestPaid: 45000.0,
    outstandingPrincipal: 650000.0,
    nextDueDate: refDate.add(const Duration(days: 10)),
    createdAt: refDate,
    updatedAt: refDate,
  );

  final loanTx = Transaction(
    id: 'tx_loan',
    amount: 19700.0,
    type: TransactionType.expense,
    purpose: TransactionPurpose.loanRepayment,
    categoryId: 'cat_loan',
    categoryName: 'Loan EMI',
    categoryIcon: 'account_balance',
    categoryColor: '#3F51B5',
    merchant: 'HDFC Car EMI',
    date: refDate,
    accountId: 'acc_hdfc',
    linkedLoanId: 'loan_car',
    principalComponent: 14500.0,
    interestComponent: 5000.0,
    feeComponent: 200.0,
    createdAt: refDate,
    updatedAt: refDate,
  );

  Widget createSubject({
    required Transaction transaction,
    List<Subscription> subscriptions = const [],
    List<Loan> loans = const [],
  }) {
    final fakeSubRepo = FakeSubscriptionRepository(subscriptions);
    final fakeAccountRepo = FakeAccountRepository([testAccountA, testAccountB]);
    final fakeTxRepo = FakeTransactionRepository([transaction]);

    return ProviderScope(
      overrides: [
        settingsStreamProvider.overrideWith(
          (ref) => Stream.value(const AppSettings()),
        ),
        accountRepositoryProvider.overrideWithValue(fakeAccountRepo),
        allAccountsStreamProvider.overrideWith(
          (ref) => Stream.value([testAccountA, testAccountB]),
        ),
        subscriptionRepositoryProvider.overrideWithValue(fakeSubRepo),
        allSubscriptionsStreamProvider.overrideWith(
          (ref) => Stream.value(subscriptions),
        ),
        allLoansStreamProvider.overrideWith((ref) => Stream.value(loans)),
        transactionRepositoryProvider.overrideWithValue(fakeTxRepo),
      ],
      child: MaterialApp(
        theme: StillwaterTheme.daylight,
        home: TransactionDetailScreen(transaction: transaction),
      ),
    );
  }

  testWidgets('TransactionDetailScreen renders Expense Hero and Fact Groups', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(createSubject(transaction: expenseTx));
    await tester.pumpAndSettle();

    // Verify merchant and overline
    expect(find.text('Swiggy'), findsWidgets);
    expect(find.textContaining('EXPENSE · FOOD & DINING'), findsOneWidget);

    // Verify figures
    expect(find.text('HDFC Salary ••4012'), findsWidgets);
    expect(find.text('Food & Dining'), findsWidgets);
    expect(find.text('Verified'), findsOneWidget);

    // Verify facts group
    expect(find.text('Payment Details'), findsOneWidget);
    expect(find.text('UPI'), findsOneWidget);
    expect(find.text('Office lunch team treat'), findsOneWidget);
    expect(find.text('lunch, treat'), findsOneWidget);

    // Verify provenance card
    expect(find.text('Provenance & Audit'), findsOneWidget);
    expect(find.text('UPI/32910481029/SWIGGY'), findsOneWidget);
    expect(find.text('SWIGGY-BANGALORE-IN'), findsOneWidget);
    expect(find.text('SMS (HDFC)'), findsOneWidget);
  });

  testWidgets('TransactionDetailScreen renders Income Hero with plus amount', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(createSubject(transaction: incomeTx));
    await tester.pumpAndSettle();

    expect(find.text('Acme Corp'), findsWidgets);
    expect(find.textContaining('INCOME · SALARY'), findsOneWidget);
    expect(find.text('NEFT'), findsOneWidget);
  });

  testWidgets('TransactionDetailScreen renders Transfer Hero with flow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(createSubject(transaction: transferTx));
    await tester.pumpAndSettle();

    expect(find.text('ACCOUNT TRANSFER'), findsOneWidget);
    expect(find.text('Destination Account'), findsOneWidget);
    expect(find.text('ICICI Amazon Pay ••9821'), findsWidgets);
  });

  testWidgets('TransactionDetailScreen renders Linked Subscription Bridge', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      createSubject(transaction: subTx, subscriptions: [subNetflix]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Linked Plan'), findsOneWidget);
    expect(find.text('Netflix'), findsWidgets);
    expect(find.textContaining('Billed monthly'), findsOneWidget);
    expect(find.text('in 3d'), findsOneWidget);
  });

  testWidgets(
    'TransactionDetailScreen renders Linked Loan Bridge with Split Band',
    (tester) async {
      tester.view.physicalSize = const Size(390, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        createSubject(transaction: loanTx, loans: [sampleLoan]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Linked Loan'), findsOneWidget);
      expect(find.text('Car Loan'), findsOneWidget);
      expect(find.textContaining('HDFC Bank'), findsOneWidget);

      // Verify split slices
      expect(find.text('Principal'), findsOneWidget);
      expect(find.text('Interest'), findsOneWidget);
      expect(find.text('Fees'), findsOneWidget);
    },
  );
}
