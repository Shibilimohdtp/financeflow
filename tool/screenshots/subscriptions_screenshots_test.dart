// Screenshot capture of Subscriptions (DS-B15), not part of the test suite.
// Uses only APIs that exist before and after DS-B15, so compare.py can
// capture both commits.
//
//   flutter test tool/screenshots/subscriptions_screenshots_test.dart --update-goldens
import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/features/subscriptions/add_edit_subscription_sheet.dart';
import 'package:financeflow/features/subscriptions/recurring_suggestions_sheet.dart';
import 'package:financeflow/features/subscriptions/subscription_detail_screen.dart';
import 'package:financeflow/features/subscriptions/subscriptions_screen.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/models/subscription.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/repositories/subscription_repository.dart';
import 'package:financeflow/shared/widgets/ff_sheet.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/helpers/app_fonts.dart';
import '../../test/helpers/fake_repositories.dart';

final _refDate = DateTime(2026, 11, 6);

final _accountHdfc = Account(
  id: 'acc_hdfc',
  name: 'HDFC Salary',
  type: AccountType.bank,
  currency: 'INR',
  createdAt: _refDate,
  updatedAt: _refDate,
);

final _accountIcici = Account(
  id: 'acc_icici',
  name: 'ICICI Amazon Pay',
  type: AccountType.creditCard,
  currency: 'INR',
  createdAt: _refDate,
  updatedAt: _refDate,
);

final _subNetflix = Subscription(
  id: 'sub_netflix',
  merchant: 'Netflix',
  normalizedMerchant: 'netflix',
  amount: 649.0,
  currency: 'INR',
  billingFrequency: SubscriptionFrequency.monthly,
  nextRenewalDate: _refDate.add(const Duration(days: 3)),
  lastPaymentDate: _refDate.subtract(const Duration(days: 27)),
  accountId: 'acc_hdfc',
  category: 'Entertainment',
  status: SubscriptionStatus.active,
  reminderDaysBefore: 3,
  isReminderEnabled: true,
  createdAt: _refDate.subtract(const Duration(days: 90)),
  updatedAt: _refDate,
);

final _subSpotify = Subscription(
  id: 'sub_spotify',
  merchant: 'Spotify',
  normalizedMerchant: 'spotify',
  amount: 119.0,
  currency: 'INR',
  billingFrequency: SubscriptionFrequency.monthly,
  nextRenewalDate: _refDate.add(const Duration(days: 12)),
  lastPaymentDate: _refDate.subtract(const Duration(days: 18)),
  accountId: 'acc_icici',
  category: 'Music',
  status: SubscriptionStatus.active,
  reminderDaysBefore: 1,
  isReminderEnabled: true,
  createdAt: _refDate.subtract(const Duration(days: 60)),
  updatedAt: _refDate,
);

final _subAirtel = Subscription(
  id: 'sub_airtel',
  merchant: 'Airtel Broadband',
  normalizedMerchant: 'airtel broadband',
  amount: 999.0,
  currency: 'INR',
  billingFrequency: SubscriptionFrequency.monthly,
  nextRenewalDate: _refDate, // Renews today!
  lastPaymentDate: _refDate.subtract(const Duration(days: 30)),
  accountId: 'acc_hdfc',
  category: 'Utilities',
  status: SubscriptionStatus.active,
  reminderDaysBefore: 2,
  isReminderEnabled: true,
  createdAt: _refDate.subtract(const Duration(days: 120)),
  updatedAt: _refDate,
);

final _subGoogle = Subscription(
  id: 'sub_google',
  merchant: 'Google One',
  normalizedMerchant: 'google one',
  amount: 1300.0,
  currency: 'INR',
  billingFrequency: SubscriptionFrequency.yearly,
  nextRenewalDate: _refDate.add(const Duration(days: 45)),
  lastPaymentDate: _refDate.subtract(const Duration(days: 320)),
  accountId: 'acc_hdfc',
  category: 'Cloud and apps',
  status: SubscriptionStatus.active,
  reminderDaysBefore: 7,
  isReminderEnabled: true,
  createdAt: _refDate.subtract(const Duration(days: 320)),
  updatedAt: _refDate,
);

final _subGym = Subscription(
  id: 'sub_gym',
  merchant: 'Cult Fit',
  normalizedMerchant: 'cult fit',
  amount: 4500.0,
  currency: 'INR',
  billingFrequency: SubscriptionFrequency.quarterly,
  nextRenewalDate: _refDate.add(const Duration(days: 20)),
  lastPaymentDate: _refDate.subtract(const Duration(days: 70)),
  accountId: 'acc_hdfc',
  category: 'Fitness',
  status: SubscriptionStatus.paused,
  reminderDaysBefore: 3,
  isReminderEnabled: false,
  notes: 'Paused for monsoon season',
  createdAt: _refDate.subtract(const Duration(days: 150)),
  updatedAt: _refDate,
);

final _sampleSubscriptions = [
  _subAirtel,
  _subNetflix,
  _subSpotify,
  _subGym,
  _subGoogle,
];

final _netflixPayments = [
  Transaction(
    id: 'tx_pay_1',
    amount: 649.0,
    type: TransactionType.expense,
    purpose: TransactionPurpose.subscriptionPayment,
    categoryId: 'cat_ent',
    categoryName: 'Entertainment',
    categoryIcon: 'movie',
    categoryColor: '#E50914',
    merchant: 'Netflix',
    date: _refDate.subtract(const Duration(days: 27)),
    accountId: 'acc_hdfc',
    linkedSubscriptionId: 'sub_netflix',
    notes: 'Premium monthly',
    createdAt: _refDate.subtract(const Duration(days: 27)),
    updatedAt: _refDate.subtract(const Duration(days: 27)),
  ),
  Transaction(
    id: 'tx_pay_2',
    amount: 649.0,
    type: TransactionType.expense,
    purpose: TransactionPurpose.subscriptionPayment,
    categoryId: 'cat_ent',
    categoryName: 'Entertainment',
    categoryIcon: 'movie',
    categoryColor: '#E50914',
    merchant: 'Netflix',
    date: _refDate.subtract(const Duration(days: 57)),
    accountId: 'acc_hdfc',
    linkedSubscriptionId: 'sub_netflix',
    createdAt: _refDate.subtract(const Duration(days: 57)),
    updatedAt: _refDate.subtract(const Duration(days: 57)),
  ),
  Transaction(
    id: 'tx_pay_3',
    amount: 649.0,
    type: TransactionType.expense,
    purpose: TransactionPurpose.subscriptionPayment,
    categoryId: 'cat_ent',
    categoryName: 'Entertainment',
    categoryIcon: 'movie',
    categoryColor: '#E50914',
    merchant: 'Netflix',
    date: _refDate.subtract(const Duration(days: 87)),
    accountId: 'acc_hdfc',
    linkedSubscriptionId: 'sub_netflix',
    createdAt: _refDate.subtract(const Duration(days: 87)),
    updatedAt: _refDate.subtract(const Duration(days: 87)),
  ),
];

// Transactions to trigger recurring suggestions (e.g. YouTube Premium)
final _recurringHistoryTxs = [
  Transaction(
    id: 'tx_yt_1',
    amount: 149.0,
    type: TransactionType.expense,
    categoryId: 'cat_ent',
    categoryName: 'Entertainment',
    categoryIcon: 'movie',
    categoryColor: '#FF0000',
    merchant: 'YouTube Premium',
    date: _refDate.subtract(const Duration(days: 62)),
    accountId: 'acc_hdfc',
    createdAt: _refDate.subtract(const Duration(days: 62)),
    updatedAt: _refDate.subtract(const Duration(days: 62)),
  ),
  Transaction(
    id: 'tx_yt_2',
    amount: 149.0,
    type: TransactionType.expense,
    categoryId: 'cat_ent',
    categoryName: 'Entertainment',
    categoryIcon: 'movie',
    categoryColor: '#FF0000',
    merchant: 'YouTube Premium',
    date: _refDate.subtract(const Duration(days: 31)),
    accountId: 'acc_hdfc',
    createdAt: _refDate.subtract(const Duration(days: 31)),
    updatedAt: _refDate.subtract(const Duration(days: 31)),
  ),
  Transaction(
    id: 'tx_yt_3',
    amount: 149.0,
    type: TransactionType.expense,
    categoryId: 'cat_ent',
    categoryName: 'Entertainment',
    categoryIcon: 'movie',
    categoryColor: '#FF0000',
    merchant: 'YouTube Premium',
    date: _refDate,
    accountId: 'acc_hdfc',
    createdAt: _refDate,
    updatedAt: _refDate,
  ),
];

Future<void> _capture(
  WidgetTester tester,
  String name,
  ThemeData theme,
  Widget child, {
  List<Subscription> subscriptions = const [],
  List<Transaction> transactions = const [],
  double height = 900,
  Future<void> Function(WidgetTester tester)? act,
}) async {
  tester.view.physicalSize = Size(390, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final fakeSubRepo = FakeSubscriptionRepository(subscriptions);
  final fakeTxRepo = FakeTransactionRepository([
    ...transactions,
    ..._netflixPayments,
  ]);
  final fakeAccountRepo = FakeAccountRepository([_accountHdfc, _accountIcici]);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsStreamProvider.overrideWith(
          (ref) => Stream.value(const AppSettings()),
        ),
        subscriptionRepositoryProvider.overrideWithValue(fakeSubRepo),
        allSubscriptionsStreamProvider.overrideWith(
          (ref) => Stream.value(subscriptions),
        ),
        accountRepositoryProvider.overrideWithValue(fakeAccountRepo),
        allAccountsStreamProvider.overrideWith(
          (ref) => Stream.value([_accountHdfc, _accountIcici]),
        ),
        transactionRepositoryProvider.overrideWithValue(fakeTxRepo),
        subscriptionPaymentsStreamProvider('sub_netflix').overrideWith(
          (ref) => Stream.value(_netflixPayments),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: child,
      ),
    ),
  );

  await tester.pumpAndSettle();
  if (act != null) {
    await act(tester);
    await tester.pumpAndSettle();
  }

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$name.png'),
  );
}

Widget _sheetHost(Widget Function(BuildContext) builder) => Scaffold(
  body: Builder(
    builder:
        (context) => Center(
          child: TextButton(
            onPressed: () => showFfSheet(context, builder: builder),
            child: const Text('open'),
          ),
        ),
  ),
);

void main() {
  setUpAll(loadAppFonts);

  for (final (mode, theme) in [
    ('light', StillwaterTheme.daylight),
    ('dark', StillwaterTheme.deepWater),
  ]) {
    testWidgets('b15_list_normal, $mode', (tester) async {
      await _capture(
        tester,
        'b15_list_normal_$mode',
        theme,
        const SubscriptionsScreen(),
        subscriptions: _sampleSubscriptions,
        height: 1000,
      );
    });

    testWidgets('b15_list_empty, $mode', (tester) async {
      await _capture(
        tester,
        'b15_list_empty_$mode',
        theme,
        const SubscriptionsScreen(),
        subscriptions: const [],
        height: 900,
      );
    });

    testWidgets('b15_list_suggestions, $mode', (tester) async {
      await _capture(
        tester,
        'b15_list_suggestions_$mode',
        theme,
        const SubscriptionsScreen(),
        subscriptions: _sampleSubscriptions,
        transactions: _recurringHistoryTxs,
        height: 1050,
      );
    });

    testWidgets('b15_detail_active, $mode', (tester) async {
      await _capture(
        tester,
        'b15_detail_active_$mode',
        theme,
        SubscriptionDetailScreen(subscription: _subNetflix),
        subscriptions: _sampleSubscriptions,
        transactions: _netflixPayments,
        height: 1100,
      );
    });

    testWidgets('b15_detail_paused, $mode', (tester) async {
      await _capture(
        tester,
        'b15_detail_paused_$mode',
        theme,
        SubscriptionDetailScreen(subscription: _subGym),
        subscriptions: _sampleSubscriptions,
        height: 1000,
      );
    });

    testWidgets('b15_sheet_new, $mode', (tester) async {
      await _capture(
        tester,
        'b15_sheet_new_$mode',
        theme,
        _sheetHost((_) => const AddEditSubscriptionSheet()),
        subscriptions: _sampleSubscriptions,
        height: 900,
        act: (tester) => tester.tap(find.text('open')),
      );
    });

    testWidgets('b15_sheet_edit, $mode', (tester) async {
      await _capture(
        tester,
        'b15_sheet_edit_$mode',
        theme,
        _sheetHost(
          (_) => AddEditSubscriptionSheet(initialSubscription: _subNetflix),
        ),
        subscriptions: _sampleSubscriptions,
        height: 900,
        act: (tester) => tester.tap(find.text('open')),
      );
    });

    testWidgets('b15_suggestions_sheet, $mode', (tester) async {
      await _capture(
        tester,
        'b15_suggestions_sheet_$mode',
        theme,
        _sheetHost((_) => const RecurringSuggestionsSheet()),
        subscriptions: _sampleSubscriptions,
        transactions: _recurringHistoryTxs,
        height: 900,
        act: (tester) => tester.tap(find.text('open')),
      );
    });
  }
}
