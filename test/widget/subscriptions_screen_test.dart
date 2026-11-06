import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/features/subscriptions/subscriptions_screen.dart';
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

  final subAirtel = Subscription(
    id: 'sub_airtel',
    merchant: 'Airtel Broadband',
    normalizedMerchant: 'airtel broadband',
    amount: 999.0,
    currency: 'INR',
    billingFrequency: SubscriptionFrequency.monthly,
    nextRenewalDate: refDate, // Renews today
    lastPaymentDate: refDate.subtract(const Duration(days: 30)),
    accountId: 'acc_hdfc',
    category: 'Utilities',
    status: SubscriptionStatus.active,
    createdAt: refDate.subtract(const Duration(days: 120)),
    updatedAt: refDate,
  );

  final subNetflix = Subscription(
    id: 'sub_netflix',
    merchant: 'Netflix',
    normalizedMerchant: 'netflix',
    amount: 649.0,
    currency: 'INR',
    billingFrequency: SubscriptionFrequency.monthly,
    nextRenewalDate: refDate.add(const Duration(days: 3)), // This week
    lastPaymentDate: refDate.subtract(const Duration(days: 27)),
    accountId: 'acc_hdfc',
    category: 'Entertainment',
    status: SubscriptionStatus.active,
    createdAt: refDate.subtract(const Duration(days: 90)),
    updatedAt: refDate,
  );

  final subSpotify = Subscription(
    id: 'sub_spotify',
    merchant: 'Spotify',
    normalizedMerchant: 'spotify',
    amount: 119.0,
    currency: 'INR',
    billingFrequency: SubscriptionFrequency.monthly,
    nextRenewalDate: refDate.add(const Duration(days: 12)), // Later this month
    lastPaymentDate: refDate.subtract(const Duration(days: 18)),
    accountId: 'acc_hdfc',
    category: 'Music',
    status: SubscriptionStatus.active,
    createdAt: refDate.subtract(const Duration(days: 60)),
    updatedAt: refDate,
  );

  final subGym = Subscription(
    id: 'sub_gym',
    merchant: 'Cult Fit',
    normalizedMerchant: 'cult fit',
    amount: 4500.0,
    currency: 'INR',
    billingFrequency: SubscriptionFrequency.quarterly,
    nextRenewalDate: refDate.add(const Duration(days: 20)),
    accountId: 'acc_hdfc',
    category: 'Fitness',
    status: SubscriptionStatus.paused,
    createdAt: refDate.subtract(const Duration(days: 150)),
    updatedAt: refDate,
  );

  Widget createSubject({
    List<Subscription> subscriptions = const [],
    List<Transaction> transactions = const [],
  }) {
    final fakeSubRepo = FakeSubscriptionRepository(subscriptions);
    final fakeTxRepo = FakeTransactionRepository(transactions);
    final fakeAccountRepo = FakeAccountRepository([testAccount]);

    return ProviderScope(
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
          (ref) => Stream.value([testAccount]),
        ),
        transactionRepositoryProvider.overrideWithValue(fakeTxRepo),
      ],
      child: MaterialApp(
        theme: StillwaterTheme.daylight,
        home: const SubscriptionsScreen(),
      ),
    );
  }

  testWidgets('SubscriptionsScreen renders Sand Hero with monthly commitment', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      createSubject(subscriptions: [subAirtel, subNetflix, subSpotify, subGym]),
    );
    await tester.pumpAndSettle();

    expect(find.text('MONTHLY COMMITMENT'), findsOneWidget);
    expect(find.text('3 active plans'), findsOneWidget);
    expect(find.text('Annual pace'), findsOneWidget);
    expect(find.text('Next up'), findsOneWidget);
  });

  testWidgets(
    'SubscriptionsScreen groups active subscriptions by urgency and has paused group',
    (tester) async {
      tester.view.physicalSize = const Size(390, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        createSubject(
          subscriptions: [subAirtel, subNetflix, subSpotify, subGym],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('This Week'), findsOneWidget);
      expect(find.text('Later This Month'), findsOneWidget);
      expect(find.textContaining('Paused & Cancelled'), findsOneWidget);

      // Verify merchants appear
      expect(find.text('Airtel Broadband'), findsOneWidget);
      expect(find.text('Netflix'), findsOneWidget);
      expect(find.text('Spotify'), findsOneWidget);

      // Tap to expand paused
      await tester.tap(find.textContaining('Paused & Cancelled'));
      await tester.pumpAndSettle();
      expect(find.text('Cult Fit'), findsOneWidget);
    },
  );

  testWidgets('SubscriptionsScreen renders Empty State when no subscriptions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(createSubject(subscriptions: const []));
    await tester.pumpAndSettle();

    expect(find.text('No subscriptions tracked'), findsOneWidget);
    expect(find.text('Add subscription'), findsWidgets);
    expect(find.text('Find from my transactions'), findsOneWidget);
  });

  testWidgets('SubscriptionsScreen switches sort pills without error', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      createSubject(subscriptions: [subAirtel, subNetflix, subSpotify]),
    );
    await tester.pumpAndSettle();

    // Tap By cost pill
    await tester.tap(find.text('By cost'), warnIfMissed: false);
    await tester.pumpAndSettle();

    // Tap By category pill
    await tester.tap(find.text('By category'), warnIfMissed: false);
    await tester.pumpAndSettle();

    // Tap By date pill
    await tester.tap(find.text('By date'), warnIfMissed: false);
    await tester.pumpAndSettle();
  });
}
