import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/features/subscriptions/subscription_detail_screen.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/models/subscription.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/repositories/subscription_repository.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_fonts.dart';
import '../helpers/fake_repositories.dart';

void main() {
  setUpAll(loadAppFonts);

  final refDate = DateTime(2026, 11, 6);

  final testAccount = Account(
    id: 'acc_hdfc',
    name: 'HDFC Salary',
    type: AccountType.bank,
    currency: 'INR',
    createdAt: refDate,
    updatedAt: refDate,
  );

  final activeSub = Subscription(
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
    status: SubscriptionStatus.active,
    reminderDaysBefore: 1,
    isReminderEnabled: true,
    createdAt: refDate.subtract(const Duration(days: 90)),
    updatedAt: refDate,
  );

  final pausedSub = Subscription(
    id: 'sub_gym',
    merchant: 'Cult Fit',
    normalizedMerchant: 'cult fit',
    amount: 4500.0,
    currency: 'INR',
    billingFrequency: SubscriptionFrequency.quarterly,
    nextRenewalDate: refDate.add(const Duration(days: 20)),
    lastPaymentDate: refDate.subtract(const Duration(days: 70)),
    accountId: 'acc_hdfc',
    category: 'Fitness',
    status: SubscriptionStatus.paused,
    reminderDaysBefore: 3,
    isReminderEnabled: false,
    notes: 'Paused for monsoon',
    createdAt: refDate.subtract(const Duration(days: 150)),
    updatedAt: refDate,
  );

  final paymentsWithPriceChange = [
    Transaction(
      id: 'tx_pay_old',
      amount: 499.0,
      type: TransactionType.expense,
      purpose: TransactionPurpose.subscriptionPayment,
      categoryId: 'cat_ent',
      categoryName: 'Entertainment',
      categoryIcon: 'movie',
      categoryColor: '#E50914',
      merchant: 'Netflix',
      date: refDate.subtract(const Duration(days: 57)),
      accountId: 'acc_hdfc',
      linkedSubscriptionId: 'sub_netflix',
      createdAt: refDate.subtract(const Duration(days: 57)),
      updatedAt: refDate.subtract(const Duration(days: 57)),
    ),
    Transaction(
      id: 'tx_pay_new',
      amount: 649.0,
      type: TransactionType.expense,
      purpose: TransactionPurpose.subscriptionPayment,
      categoryId: 'cat_ent',
      categoryName: 'Entertainment',
      categoryIcon: 'movie',
      categoryColor: '#E50914',
      merchant: 'Netflix',
      date: refDate.subtract(const Duration(days: 27)),
      accountId: 'acc_hdfc',
      linkedSubscriptionId: 'sub_netflix',
      createdAt: refDate.subtract(const Duration(days: 27)),
      updatedAt: refDate.subtract(const Duration(days: 27)),
    ),
  ];

  Widget createSubject({
    required Subscription subscription,
    List<Transaction> transactions = const [],
  }) {
    final fakeSubRepo = FakeSubscriptionRepository([subscription]);
    final fakeTxRepo = FakeTransactionRepository(transactions);
    final fakeAccountRepo = FakeAccountRepository([testAccount]);

    return ProviderScope(
      overrides: [
        settingsStreamProvider.overrideWith(
          (ref) => Stream.value(const AppSettings()),
        ),
        subscriptionRepositoryProvider.overrideWithValue(fakeSubRepo),
        allSubscriptionsStreamProvider.overrideWith(
          (ref) => Stream.value([subscription]),
        ),
        accountRepositoryProvider.overrideWithValue(fakeAccountRepo),
        allAccountsStreamProvider.overrideWith(
          (ref) => Stream.value([testAccount]),
        ),
        transactionRepositoryProvider.overrideWithValue(fakeTxRepo),
        subscriptionPaymentsStreamProvider(subscription.id).overrideWith(
          (ref) => Stream.value(transactions),
        ),
      ],
      child: MaterialApp(
        theme: StillwaterTheme.daylight,
        home: SubscriptionDetailScreen(subscription: subscription),
      ),
    );
  }

  testWidgets(
    'SubscriptionDetailScreen renders Sand Hero with renewal countdown and metrics',
    (tester) async {
      tester.view.physicalSize = const Size(390, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        createSubject(
          subscription: activeSub,
          transactions: paymentsWithPriceChange,
        ),
      );
      await tester.pumpAndSettle();

      // Check merchant name in app bar and hero
      expect(find.text('Netflix'), findsWidgets);
      expect(find.text('MONTHLY PLAN'), findsOneWidget);
      expect(find.textContaining('Renews in 3 days'), findsOneWidget);

      // Hero figures
      expect(find.text('Monthly equiv'), findsOneWidget);
      expect(find.text('Annual pace'), findsOneWidget);
      expect(find.text('Total paid'), findsOneWidget);
    },
  );

  testWidgets('SubscriptionDetailScreen renders inline reminder chips and responds to taps', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      createSubject(subscription: activeSub),
    );
    await tester.pumpAndSettle();

    expect(find.text('Renewal Reminder'), findsOneWidget);
    expect(find.text('1 day before'), findsOneWidget);
    expect(find.text('3 days before'), findsOneWidget);
    expect(find.text('7 days before'), findsOneWidget);
    expect(find.text('Off'), findsOneWidget);

    // Tap 3 days before
    await tester.tap(find.text('3 days before'));
    await tester.pumpAndSettle();

    // Tap Off
    await tester.tap(find.text('Off'));
    await tester.pumpAndSettle();
  });

  testWidgets('SubscriptionDetailScreen detects and displays price change note', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      createSubject(
        subscription: activeSub,
        transactions: paymentsWithPriceChange,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Price changed from'), findsOneWidget);
  });

  testWidgets('SubscriptionDetailScreen handles paused status gracefully', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      createSubject(subscription: pausedSub),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cult Fit'), findsWidgets);
    expect(find.text('QUARTERLY PLAN'), findsOneWidget);
    expect(find.text('Paused · Next renewal postponed'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Resume Plan'), 200);
    expect(find.text('Resume Plan'), findsOneWidget);
  });
}
