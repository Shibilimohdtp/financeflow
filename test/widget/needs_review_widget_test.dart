import 'package:financeflow/features/accounts/accounts_controller.dart';
import 'package:financeflow/features/categories/categories_controller.dart';
import 'package:financeflow/features/ingestion/needs_review_screen.dart';
import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/models/category.dart';
import 'package:financeflow/models/ingestion/parsed_transaction.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/repositories/pending_transaction_repository.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'NeedsReviewScreen displays pending review transactions and actions',
    (WidgetTester tester) async {
      final now = DateTime.now();

      final testAccount = Account(
        id: 'acc_1',
        name: 'Main Bank',
        type: AccountType.bank,
        createdAt: now,
        updatedAt: now,
      );

      final testCategory = Category(
        id: 'cat_food',
        name: 'Food & Dining',
        iconIdentifier: 'restaurant',
        colorTokenIdentifier: 'clay',
        createdAt: now,
        updatedAt: now,
      );

      final pendingTx = ParsedTransaction(
        tempId: 'temp_1',
        source: TransactionSource.sms,
        sourceName: 'HDFC Bank',
        amount: 430.0,
        type: TransactionType.expense,
        rawMerchant: 'SWIGGY BANGALORE',
        normalizedMerchant: 'Swiggy',
        date: now,
        accountId: 'acc_1',
        categoryId: 'cat_food',
        categoryName: 'Food & Dining',
        categoryIcon: 'restaurant',
        categoryColor: 'clay',
        fingerprint: 'fp_1',
        duplicateStatus: DuplicateMatchLevel.exact,
        duplicateReasons: ['Same amount and canonical merchant on same day'],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStreamProvider.overrideWith(
              (ref) => Stream.value(const AppSettings()),
            ),
            rawAccountsStreamProvider.overrideWith(
              (ref) => Stream.value([testAccount]),
            ),
            categoriesStreamProvider.overrideWith(
              (ref) => Stream.value([testCategory]),
            ),
            pendingTransactionsStreamProvider.overrideWith(
              (ref) => Stream.value([pendingTx]),
            ),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: const NeedsReviewScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Screen Title & Pending Items
      expect(
        find.text('Needs Review Queue', skipOffstage: false),
        findsOneWidget,
      );
      expect(find.text('All (1)', skipOffstage: false), findsOneWidget);
      expect(find.text('Duplicates (1)', skipOffstage: false), findsOneWidget);
      expect(find.text('Swiggy', skipOffstage: false), findsOneWidget);
      expect(find.text('Dismiss', skipOffstage: false), findsOneWidget);
      expect(find.text('Edit', skipOffstage: false), findsOneWidget);
      expect(find.text('Approve', skipOffstage: false), findsOneWidget);
    },
  );
}
