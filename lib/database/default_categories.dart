import 'schemas/category_entity.dart';

/// Seed list of 23 default categories from PRD Section 8
class DefaultCategories {
  DefaultCategories._();

  static List<CategoryEntity> get list {
    final now = DateTime.now();

    final rawCategories = [
      // Expenses
      {
        'id': 'cat_food',
        'name': 'Food',
        'icon': 'restaurant',
        'color': 'clay',
        'types': ['expense'],
      },
      {
        'id': 'cat_dining',
        'name': 'Dining',
        'icon': 'local_dining',
        'color': 'clay',
        'types': ['expense'],
      },
      {
        'id': 'cat_groceries',
        'name': 'Groceries',
        'icon': 'shopping_cart',
        'color': 'grove',
        'types': ['expense'],
      },
      {
        'id': 'cat_transport',
        'name': 'Transport',
        'icon': 'directions_car',
        'color': 'slate',
        'types': ['expense'],
      },
      {
        'id': 'cat_fuel',
        'name': 'Fuel',
        'icon': 'local_gas_station',
        'color': 'marigold',
        'types': ['expense'],
      },
      {
        'id': 'cat_shopping',
        'name': 'Shopping',
        'icon': 'shopping_bag',
        'color': 'plum',
        'types': ['expense'],
      },
      {
        'id': 'cat_bills',
        'name': 'Bills',
        'icon': 'receipt_long',
        'color': 'slate',
        'types': ['expense'],
      },
      {
        'id': 'cat_utilities',
        'name': 'Utilities',
        'icon': 'power',
        'color': 'marigold',
        'types': ['expense'],
      },
      {
        'id': 'cat_healthcare',
        'name': 'Healthcare',
        'icon': 'medical_services',
        'color': 'teal',
        'types': ['expense'],
      },
      {
        'id': 'cat_insurance',
        'name': 'Insurance',
        'icon': 'health_and_safety',
        'color': 'teal',
        'types': ['expense'],
      },
      {
        'id': 'cat_education',
        'name': 'Education',
        'icon': 'school',
        'color': 'indigo',
        'types': ['expense'],
      },
      {
        'id': 'cat_travel',
        'name': 'Travel',
        'icon': 'flight',
        'color': 'teal',
        'types': ['expense'],
      },
      {
        'id': 'cat_entertainment',
        'name': 'Entertainment',
        'icon': 'movie',
        'color': 'plum',
        'types': ['expense'],
      },
      {
        'id': 'cat_subscriptions',
        'name': 'Subscriptions',
        'icon': 'sync',
        'color': 'marigold',
        'types': ['expense'],
      },
      {
        'id': 'cat_investments',
        'name': 'Investments',
        'icon': 'trending_up',
        'color': 'indigo',
        'types': ['expense', 'investment'],
      },
      {
        'id': 'cat_loans',
        'name': 'Loans',
        'icon': 'credit_card',
        'color': 'plum',
        'types': ['expense', 'loan_emi'],
      },
      {
        'id': 'cat_emi',
        'name': 'EMI',
        'icon': 'payments',
        'color': 'plum',
        'types': ['expense', 'loan_emi'],
      },
      {
        'id': 'cat_taxes',
        'name': 'Taxes',
        'icon': 'description',
        'color': 'slate',
        'types': ['expense'],
      },
      // Income
      {
        'id': 'cat_salary',
        'name': 'Salary',
        'icon': 'account_balance_wallet',
        'color': 'grove',
        'types': ['income'],
      },
      {
        'id': 'cat_freelance',
        'name': 'Freelance',
        'icon': 'laptop_mac',
        'color': 'teal',
        'types': ['income'],
      },
      {
        'id': 'cat_business',
        'name': 'Business',
        'icon': 'store',
        'color': 'shore',
        'types': ['income', 'expense'],
      },
      {
        'id': 'cat_savings',
        'name': 'Savings',
        'icon': 'savings',
        'color': 'teal',
        'types': ['income', 'expense', 'transfer'],
      },
      {
        'id': 'cat_transaction',
        'name': 'Transaction',
        'icon': 'swap_horiz',
        'color': 'slate',
        'types': ['expense', 'income', 'transfer'],
      },
      {
        'id': 'cat_miscellaneous',
        'name': 'Miscellaneous',
        'icon': 'more_horiz',
        'color': 'slate',
        'types': ['expense', 'income', 'transfer'],
      },
    ];

    var order = 0;
    return rawCategories.map((raw) {
      final entity =
          CategoryEntity()
            ..uuid = raw['id'] as String
            ..name = raw['name'] as String
            ..iconIdentifier = raw['icon'] as String
            ..colorTokenIdentifier = raw['color'] as String
            ..typeCompatibility = List<String>.from(raw['types'] as List)
            ..isDefault = true
            ..isArchived = false
            ..sortOrder = order++
            ..createdAt = now
            ..updatedAt = now;
      return entity;
    }).toList();
  }
}
