import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/services/payee_suggestion_service.dart';

void main() {
  final baseTime = DateTime(2026, 8, 23, 12, 0, 0);

  Transaction createTx({
    required String id,
    required String merchant,
    TransactionType type = TransactionType.expense,
    String categoryId = 'cat_food',
    String categoryName = 'Food & Dining',
    double amount = 100.0,
    DateTime? date,
  }) {
    final d = date ?? baseTime;
    return Transaction(
      id: id,
      amount: amount,
      type: type,
      categoryId: categoryId,
      categoryName: categoryName,
      categoryIcon: 'restaurant',
      categoryColor: 'clay',
      merchant: merchant,
      date: d,
      accountId: 'acc_1',
      createdAt: d,
      updatedAt: d,
    );
  }

  group('PayeeSuggestionService Normalization & Keying', () {
    test('normalizeKey trims, lowercases, and collapses internal spaces', () {
      expect(PayeeSuggestionService.normalizeKey('  Zomato  '), 'zomato');
      expect(
        PayeeSuggestionService.normalizeKey('Lulu   Hypermarket'),
        'lulu hypermarket',
      );
      expect(
        PayeeSuggestionService.normalizeKey('Bismi   CAFE  '),
        'bismi cafe',
      );
    });

    test('cleanDisplayName normalizes known brands and cleans casing', () {
      expect(PayeeSuggestionService.cleanDisplayName('  zomato  '), 'Zomato');
      expect(PayeeSuggestionService.cleanDisplayName('amzn pay'), 'Amazon');
      expect(
        PayeeSuggestionService.cleanDisplayName('  shahasad  '),
        'Shahasad',
      );
    });

    test(
      'deduplicates case and whitespace variants into a single canonical suggestion',
      () {
        final transactions = [
          createTx(
            id: '1',
            merchant: 'Zomato',
            date: baseTime.subtract(const Duration(days: 3)),
          ),
          createTx(
            id: '2',
            merchant: 'zomato',
            date: baseTime.subtract(const Duration(days: 2)),
          ),
          createTx(
            id: '3',
            merchant: '  Zomato  ',
            date: baseTime.subtract(const Duration(days: 1)),
          ),
        ];

        final suggestions = PayeeSuggestionService.getSuggestions(
          transactions: transactions,
          type: TransactionType.expense,
          now: baseTime,
        );

        expect(suggestions.length, 1);
        expect(suggestions.first.displayName, 'Zomato');
        expect(suggestions.first.totalCount, 3);
        expect(suggestions.first.normalizedKey, 'zomato');
      },
    );
  });

  group('Category-aware Suggestions', () {
    final transactions = [
      // Groceries category
      createTx(
        id: '1',
        merchant: 'Lulu Hypermarket',
        categoryId: 'cat_groceries',
        categoryName: 'Groceries',
        date: baseTime.subtract(const Duration(days: 1)),
      ),
      createTx(
        id: '2',
        merchant: 'Lulu Hypermarket',
        categoryId: 'cat_groceries',
        categoryName: 'Groceries',
        date: baseTime.subtract(const Duration(days: 2)),
      ),
      createTx(
        id: '3',
        merchant: 'Carrefour',
        categoryId: 'cat_groceries',
        categoryName: 'Groceries',
        date: baseTime.subtract(const Duration(days: 3)),
      ),

      // Food category
      createTx(
        id: '4',
        merchant: 'Swiggy',
        categoryId: 'cat_food',
        categoryName: 'Food & Dining',
        date: baseTime.subtract(const Duration(hours: 2)),
      ),
      createTx(
        id: '5',
        merchant: 'Swiggy',
        categoryId: 'cat_food',
        categoryName: 'Food & Dining',
        date: baseTime.subtract(const Duration(days: 1)),
      ),
      createTx(
        id: '6',
        merchant: 'Zomato',
        categoryId: 'cat_food',
        categoryName: 'Food & Dining',
        date: baseTime.subtract(const Duration(days: 2)),
      ),
      createTx(
        id: '7',
        merchant: 'Bismi CAFE',
        categoryId: 'cat_food',
        categoryName: 'Food & Dining',
        date: baseTime.subtract(const Duration(days: 4)),
      ),

      // Electronics category
      createTx(
        id: '8',
        merchant: 'Apple Store',
        categoryId: 'cat_electronics',
        categoryName: 'Electronics',
        date: baseTime.subtract(const Duration(days: 10)),
      ),
    ];

    test(
      'prioritizes category-specific payees when a category is selected',
      () {
        final grocerySuggestions = PayeeSuggestionService.getSuggestions(
          transactions: transactions,
          type: TransactionType.expense,
          categoryId: 'cat_groceries',
          limit: 4,
          now: baseTime,
        );

        expect(grocerySuggestions.isNotEmpty, isTrue);
        // Top results must be Groceries payees
        expect(grocerySuggestions[0].displayName, 'Lulu Hypermarket');
        expect(grocerySuggestions[0].isCategoryMatch, isTrue);
        expect(grocerySuggestions[0].reasonLabel, 'Used with Groceries');

        expect(grocerySuggestions[1].displayName, 'Carrefour');
        expect(grocerySuggestions[1].isCategoryMatch, isTrue);

        // Remaining slots filled with general frequent/recent fallbacks
        expect(grocerySuggestions.length, 4);
        expect(grocerySuggestions[2].isCategoryMatch, isFalse);
      },
    );

    test('prioritizes Food payees when Food category is selected', () {
      final foodSuggestions = PayeeSuggestionService.getSuggestions(
        transactions: transactions,
        type: TransactionType.expense,
        categoryId: 'cat_food',
        limit: 4,
        now: baseTime,
      );

      final names = foodSuggestions.map((s) => s.displayName).toList();
      expect(names.contains('Swiggy'), isTrue);
      expect(names.contains('Zomato'), isTrue);
      expect(names.contains('Bismi CAFE'), isTrue);
      expect(foodSuggestions.first.displayName, 'Swiggy');
      expect(foodSuggestions.first.isCategoryMatch, isTrue);
    });

    test(
      'returns general recent & frequent payees when no category is selected',
      () {
        final generalSuggestions = PayeeSuggestionService.getSuggestions(
          transactions: transactions,
          type: TransactionType.expense,
          categoryId: null,
          limit: 4,
          now: baseTime,
        );

        expect(generalSuggestions.length, 4);
        // Swiggy and Lulu are most frequent / recent
        final topNames = generalSuggestions.map((s) => s.displayName).toList();
        expect(topNames.contains('Swiggy'), isTrue);
        expect(topNames.contains('Lulu Hypermarket'), isTrue);
        expect(generalSuggestions.every((s) => !s.isCategoryMatch), isTrue);
      },
    );

    test(
      'falls back gracefully to general suggestions when category has no history',
      () {
        final suggestions = PayeeSuggestionService.getSuggestions(
          transactions: transactions,
          type: TransactionType.expense,
          categoryId: 'cat_travel_new',
          limit: 4,
          now: baseTime,
        );

        expect(suggestions.length, 4);
        expect(suggestions.every((s) => !s.isCategoryMatch), isTrue);
      },
    );
  });

  group('Transaction Type Awareness', () {
    final transactions = [
      createTx(
        id: '1',
        merchant: 'Swiggy',
        type: TransactionType.expense,
        categoryId: 'cat_food',
      ),
      createTx(
        id: '2',
        merchant: 'Amazon',
        type: TransactionType.expense,
        categoryId: 'cat_shopping',
      ),
      createTx(
        id: '3',
        merchant: 'Acme Corp Salary',
        type: TransactionType.income,
        categoryId: 'cat_salary',
        categoryName: 'Salary',
      ),
      createTx(
        id: '4',
        merchant: 'Freelance Client',
        type: TransactionType.income,
        categoryId: 'cat_freelance',
        categoryName: 'Freelance',
      ),
      createTx(
        id: '5',
        merchant: 'Emergency Fund Move',
        type: TransactionType.transfer,
        categoryId: 'cat_transfer',
        categoryName: 'Transfer',
      ),
    ];

    test('returns expense payees when type is expense', () {
      final suggestions = PayeeSuggestionService.getSuggestions(
        transactions: transactions,
        type: TransactionType.expense,
        now: baseTime,
      );

      final names = suggestions.map((s) => s.displayName).toList();
      expect(names.contains('Swiggy'), isTrue);
      expect(names.contains('Amazon'), isTrue);
      expect(names.contains('Acme Corp Salary'), isFalse);
      expect(names.contains('Emergency Fund Move'), isFalse);
    });

    test('returns income sources when type is income', () {
      final suggestions = PayeeSuggestionService.getSuggestions(
        transactions: transactions,
        type: TransactionType.income,
        now: baseTime,
      );

      final names = suggestions.map((s) => s.displayName).toList();
      expect(names.contains('Acme Corp Salary'), isTrue);
      expect(names.contains('Freelance Client'), isTrue);
      expect(names.contains('Swiggy'), isFalse);
    });

    test('returns transfer references when type is transfer', () {
      final suggestions = PayeeSuggestionService.getSuggestions(
        transactions: transactions,
        type: TransactionType.transfer,
        now: baseTime,
      );

      final names = suggestions.map((s) => s.displayName).toList();
      expect(names.contains('Emergency Fund Move'), isTrue);
      expect(names.contains('Swiggy'), isFalse);
    });
  });

  group('Autocomplete and Query Filtering', () {
    final transactions = [
      createTx(id: '1', merchant: 'Lulu Hypermarket', date: baseTime),
      createTx(id: '2', merchant: 'Lulu Express', date: baseTime),
      createTx(id: '3', merchant: 'BigBasket', date: baseTime),
      createTx(id: '4', merchant: 'Blinkit', date: baseTime),
      createTx(id: '5', merchant: 'Bismi CAFE', date: baseTime),
    ];

    test('filters suggestions as user types with prefix match priority', () {
      final luSuggestions = PayeeSuggestionService.getSuggestions(
        transactions: transactions,
        type: TransactionType.expense,
        query: 'lu',
        now: baseTime,
      );

      expect(luSuggestions.length, 2);
      final names = luSuggestions.map((s) => s.displayName).toList();
      expect(names.contains('Lulu Hypermarket'), isTrue);
      expect(names.contains('Lulu Express'), isTrue);
      expect(names.contains('BigBasket'), isFalse);
    });

    test('matches substring and word boundaries case-insensitively', () {
      final basketSuggestions = PayeeSuggestionService.getSuggestions(
        transactions: transactions,
        type: TransactionType.expense,
        query: 'basket',
        now: baseTime,
      );

      expect(basketSuggestions.length, 1);
      expect(basketSuggestions.first.displayName, 'BigBasket');
    });

    test('returns empty when no payees match typed query', () {
      final noMatches = PayeeSuggestionService.getSuggestions(
        transactions: transactions,
        type: TransactionType.expense,
        query: 'xyznonexistent',
        now: baseTime,
      );

      expect(noMatches, isEmpty);
    });
  });

  group('Edge Cases & Robustness', () {
    test('handles empty transaction list gracefully', () {
      final suggestions = PayeeSuggestionService.getSuggestions(
        transactions: [],
        type: TransactionType.expense,
      );
      expect(suggestions, isEmpty);
    });

    test('ignores blank and whitespace-only merchant names', () {
      final transactions = [
        createTx(id: '1', merchant: '   '),
        createTx(id: '2', merchant: ''),
        createTx(id: '3', merchant: 'Valid Payee'),
      ];

      final suggestions = PayeeSuggestionService.getSuggestions(
        transactions: transactions,
        type: TransactionType.expense,
      );

      expect(suggestions.length, 1);
      expect(suggestions.first.displayName, 'Valid Payee');
    });

    test('recency score decays gracefully with days elapsed', () {
      final scoreToday = PayeeSuggestionService.calculateRecencyScore(
        baseTime,
        baseTime,
      );
      final score7d = PayeeSuggestionService.calculateRecencyScore(
        baseTime.subtract(const Duration(days: 7)),
        baseTime,
      );
      final score30d = PayeeSuggestionService.calculateRecencyScore(
        baseTime.subtract(const Duration(days: 30)),
        baseTime,
      );
      final score100d = PayeeSuggestionService.calculateRecencyScore(
        baseTime.subtract(const Duration(days: 100)),
        baseTime,
      );

      expect(scoreToday > score7d, isTrue);
      expect(score7d > score30d, isTrue);
      expect(score30d > score100d, isTrue);
    });

    test(
      'ranks exact match > prefix match > substring match character by character',
      () {
        final transactions = [
          createTx(
            id: '1',
            merchant: 'Super Market',
            categoryId: 'cat_groceries',
            date: baseTime.subtract(const Duration(days: 5)),
          ),
          createTx(
            id: '2',
            merchant: 'Swiggy',
            categoryId: 'cat_dining',
            date: baseTime.subtract(const Duration(days: 2)),
          ),
          createTx(
            id: '3',
            merchant: 'Swiggy Instamart',
            categoryId: 'cat_groceries',
            date: baseTime.subtract(const Duration(days: 1)),
          ),
          createTx(
            id: '4',
            merchant: 'Best Sweet Shop',
            categoryId: 'cat_dining',
            date: baseTime.subtract(const Duration(days: 3)),
          ),
        ];

        // Typing 'Sw' should rank Swiggy and Swiggy Instamart at the top
        final swSuggestions = PayeeSuggestionService.getSuggestions(
          transactions: transactions,
          type: TransactionType.expense,
          query: 'Sw',
          now: baseTime,
        );

        expect(swSuggestions.first.displayName.startsWith('Swiggy'), isTrue);

        // Typing 'Swiggy' should rank exact match first
        final swiggySuggestions = PayeeSuggestionService.getSuggestions(
          transactions: transactions,
          type: TransactionType.expense,
          query: 'Swiggy',
          now: baseTime,
        );

        expect(swiggySuggestions.first.displayName, 'Swiggy');
      },
    );
  });
}
