import 'package:financeflow/features/subscriptions/subscription_detail_screen.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/models/subscription.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/repositories/subscription_repository.dart';
import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testDate = DateTime(2026, 9, 10);

  final testSub = Subscription(
    id: 'sub_netflix',
    merchant: 'Netflix',
    normalizedMerchant: 'netflix',
    amount: 649.0,
    currency: 'INR',
    billingFrequency: SubscriptionFrequency.monthly,
    nextRenewalDate: testDate.add(const Duration(days: 15)),
    lastPaymentDate: testDate,
    accountId: 'acc_1',
    category: 'Entertainment',
    createdAt: testDate,
    updatedAt: testDate,
  );

  final testAccount = Account(
    id: 'acc_1',
    name: 'HDFC Bank',
    type: AccountType.bank,
    createdAt: testDate,
    updatedAt: testDate,
  );

  final testPayment = Transaction(
    id: 'tx_pay_1',
    amount: 649.0,
    type: TransactionType.expense,
    purpose: TransactionPurpose.subscriptionPayment,
    categoryId: 'cat_ent',
    categoryName: 'Entertainment',
    categoryIcon: 'movie',
    categoryColor: '#FF0000',
    merchant: 'Netflix',
    date: testDate,
    accountId: 'acc_1',
    linkedSubscriptionId: 'sub_netflix',
    createdAt: testDate,
    updatedAt: testDate,
  );

  testWidgets(
    'SubscriptionDetailScreen renders Payment History section and Record payment button',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStreamProvider.overrideWith(
              (ref) => Stream.value(const AppSettings()),
            ),
            allSubscriptionsStreamProvider.overrideWith(
              (ref) => Stream.value([testSub]),
            ),
            allAccountsStreamProvider.overrideWith(
              (ref) => Stream.value([testAccount]),
            ),
            subscriptionPaymentsStreamProvider('sub_netflix').overrideWith(
              (ref) => Stream.value([testPayment]),
            ),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: SubscriptionDetailScreen(subscription: testSub),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify header and basic subscription info
      expect(find.text('Netflix'), findsWidgets);

      // Verify Payment History section
      expect(find.text('Payment History'), findsOneWidget);
      expect(find.text('Record payment'), findsOneWidget);

      // Verify payment details in the card
      expect(find.textContaining('Total paid'), findsOneWidget);
      expect(find.text('Last paid'), findsOneWidget);
    },
  );
}
