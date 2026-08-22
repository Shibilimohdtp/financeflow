import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/database/default_categories.dart';
import 'package:financeflow/models/category_colors.dart';
import 'package:financeflow/models/category_icons.dart';

void main() {
  group('Default Categories & Mappings Tests', () {
    test('Contains exactly 23 default categories from PRD', () {
      final list = DefaultCategories.list;
      expect(list.length, 23);

      final names = list.map((c) => c.name).toSet();
      expect(names.contains('Food'), isTrue);
      expect(names.contains('Dining'), isTrue);
      expect(names.contains('Groceries'), isTrue);
      expect(names.contains('Transport'), isTrue);
      expect(names.contains('Fuel'), isTrue);
      expect(names.contains('Shopping'), isTrue);
      expect(names.contains('Bills'), isTrue);
      expect(names.contains('Utilities'), isTrue);
      expect(names.contains('Healthcare'), isTrue);
      expect(names.contains('Insurance'), isTrue);
      expect(names.contains('Education'), isTrue);
      expect(names.contains('Travel'), isTrue);
      expect(names.contains('Entertainment'), isTrue);
      expect(names.contains('Subscriptions'), isTrue);
      expect(names.contains('Investments'), isTrue);
      expect(names.contains('Salary'), isTrue);
      expect(names.contains('Freelance'), isTrue);
      expect(names.contains('Business'), isTrue);
      expect(names.contains('Loans'), isTrue);
      expect(names.contains('EMI'), isTrue);
      expect(names.contains('Taxes'), isTrue);
      expect(names.contains('Savings'), isTrue);
      expect(names.contains('Miscellaneous'), isTrue);
    });

    test('All categories have valid icon mappings', () {
      final list = DefaultCategories.list;
      for (final cat in list) {
        final iconData = CategoryIcons.getIcon(cat.iconIdentifier);
        expect(iconData, isA<IconData>());
        expect(iconData, isNot(equals(Icons.help_outline)));
      }
    });

    test('All categories have valid Stillwater color mappings', () {
      final list = DefaultCategories.list;
      for (final cat in list) {
        final color = CategoryColors.getColor(cat.colorTokenIdentifier);
        expect(color, isA<Color>());
      }
    });
  });
}
