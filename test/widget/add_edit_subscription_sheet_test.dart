import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/features/subscriptions/add_edit_subscription_sheet.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/models/subscription.dart';
import 'package:financeflow/repositories/subscription_repository.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/helpers/fake_repositories.dart';

void main() {
  final refDate = DateTime(2026, 11, 6);

  final testAccount = Account(
    id: 'acc_hdfc',
    name: 'HDFC Salary',
    type: AccountType.bank,
    createdAt: refDate,
    updatedAt: refDate,
  );

  final existingSub = Subscription(
    id: 'sub_netflix',
    merchant: 'Netflix',
    normalizedMerchant: 'netflix',
    amount: 649,
    billingFrequency: SubscriptionFrequency.monthly,
    nextRenewalDate: refDate.add(const Duration(days: 3)),
    accountId: 'acc_hdfc',
    category: 'Entertainment',
    createdAt: refDate,
    updatedAt: refDate,
  );

  Widget createSubject({
    Subscription? initialSub,
    List<Subscription> existingSubs = const [],
    List<Account> accounts = const [],
  }) {
    return ProviderScope(
      overrides: [
        settingsStreamProvider.overrideWith(
          (ref) => Stream.value(const AppSettings()),
        ),
        allAccountsStreamProvider.overrideWith((ref) => Stream.value(accounts)),
        accountRepositoryProvider.overrideWithValue(
          FakeAccountRepository(accounts),
        ),
        allSubscriptionsStreamProvider.overrideWith(
          (ref) => Stream.value(existingSubs),
        ),
        subscriptionRepositoryProvider.overrideWithValue(
          FakeSubscriptionRepository(existingSubs),
        ),
      ],
      child: MaterialApp(
        theme: StillwaterTheme.daylight,
        home: Scaffold(
          body: AddEditSubscriptionSheet(initialSubscription: initialSub),
        ),
      ),
    );
  }

  testWidgets(
    'renders live preview card and updates on typing merchant & amount',
    (tester) async {
      tester.view.physicalSize = const Size(390, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(createSubject(accounts: [testAccount]));
      await tester.pumpAndSettle();

      expect(find.text('New Subscription'), findsWidgets); // header + preview
      expect(
        find.text('Enter amount'),
        findsOneWidget,
      ); // primary button initial

      // Enter merchant
      await tester.enterText(
        find.widgetWithText(TextField, 'Service or Merchant Name'),
        'Spotify',
      );
      await tester.pump();

      expect(find.text('Spotify'), findsWidgets); // in textfield and in preview
      expect(find.text('SP'), findsOneWidget); // monogram tile in preview

      // Enter amount
      await tester.enterText(
        find.widgetWithText(TextField, 'Recurring Amount'),
        '119',
      );
      await tester.pump();

      expect(find.text('Create Subscription'), findsOneWidget); // primary ready
      expect(find.text('/mo'), findsOneWidget); // preview cadence suffix
    },
  );

  testWidgets(
    'type tile selection prefills category and merchant suggestions',
    (tester) async {
      tester.view.physicalSize = const Size(390, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(createSubject(accounts: [testAccount]));
      await tester.pumpAndSettle();

      // Tap Music category tile
      await tester.tap(find.text('Music'));
      await tester.pumpAndSettle();

      // Popular suggestions chips appear
      expect(find.text('Spotify'), findsOneWidget);
      expect(find.text('Apple Music'), findsOneWidget);

      // Tap suggestion chip
      await tester.tap(find.text('Apple Music'));
      await tester.pumpAndSettle();

      expect(find.text('AM'), findsOneWidget); // monogram
    },
  );

  testWidgets('frequency change updates consequence line dynamically', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(createSubject(accounts: [testAccount]));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Recurring Amount'),
      '200',
    );
    await tester.pump();

    // Default monthly: 200 * 12 = 2,400/yr
    expect(find.textContaining('₹2,400 a year'), findsOneWidget);

    // Switch to Yearly
    await tester.tap(find.text('Yearly'));
    await tester.pumpAndSettle();

    // Yearly: 200 / 12 = 16.67/mo
    expect(find.textContaining('a month'), findsOneWidget);
  });

  testWidgets(
    'duplicate warning banner appears when typing existing merchant',
    (tester) async {
      tester.view.physicalSize = const Size(390, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        createSubject(existingSubs: [existingSub], accounts: [testAccount]),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Service or Merchant Name'),
        'netflix',
      );
      await tester.pump();

      expect(find.text('Duplicate Plan Detected'), findsOneWidget);
    },
  );

  testWidgets(
    'progressive disclosure reveals payment account, reminder, and notes',
    (tester) async {
      tester.view.physicalSize = const Size(390, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(createSubject(accounts: [testAccount]));
      await tester.pumpAndSettle();

      expect(find.text('PAYMENT ACCOUNT'), findsNothing);

      // Tap expander
      await tester.tap(find.text('More options (Account, Reminder, Notes)'));
      await tester.pumpAndSettle();

      expect(find.text('PAYMENT ACCOUNT'), findsOneWidget);
      expect(find.text('RENEWAL REMINDER'), findsOneWidget);
      expect(find.text('HDFC Salary'), findsOneWidget);
    },
  );

  testWidgets(
    'edit mode prefills values and shows Delete Subscription button',
    (tester) async {
      tester.view.physicalSize = const Size(390, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        createSubject(
          initialSub: existingSub,
          existingSubs: [existingSub],
          accounts: [testAccount],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Subscription'), findsOneWidget);
      expect(find.text('649'), findsOneWidget);
      expect(find.text('Netflix'), findsWidgets);
      expect(find.text('Save Changes'), findsOneWidget);
      expect(find.text('Delete Subscription'), findsOneWidget);
    },
  );
}
