import 'package:flutter/material.dart';

/// Stable mapping between string identifiers and Material Icons
/// This avoids storing platform-dependent IconData directly in the database.
class CategoryIcons {
  CategoryIcons._();

  static const Map<String, IconData> _iconMap = {
    'restaurant': Icons.restaurant_rounded,
    'local_dining': Icons.local_dining_rounded,
    'shopping_cart': Icons.shopping_cart_rounded,
    'directions_car': Icons.directions_car_rounded,
    'local_gas_station': Icons.local_gas_station_rounded,
    'shopping_bag': Icons.shopping_bag_rounded,
    'receipt_long': Icons.receipt_long_rounded,
    'power': Icons.power_rounded,
    'medical_services': Icons.medical_services_rounded,
    'health_and_safety': Icons.health_and_safety_rounded,
    'school': Icons.school_rounded,
    'flight': Icons.flight_rounded,
    'movie': Icons.movie_rounded,
    'sync': Icons.sync_rounded,
    'trending_up': Icons.trending_up_rounded,
    'account_balance_wallet': Icons.account_balance_wallet_rounded,
    'laptop_mac': Icons.laptop_mac_rounded,
    'store': Icons.store_rounded,
    'credit_card': Icons.credit_card_rounded,
    'payments': Icons.payments_rounded,
    'description': Icons.description_rounded,
    'savings': Icons.savings_rounded,
    'more_horiz': Icons.more_horiz_rounded,
    'account_balance': Icons.account_balance_rounded,
    'coffee': Icons.coffee_rounded,
    'fitness_center': Icons.fitness_center_rounded,
    'home': Icons.home_rounded,
    'phone_android': Icons.phone_android_rounded,
    'wifi': Icons.wifi_rounded,
    'pets': Icons.pets_rounded,
  };

  static IconData getIcon(String? iconIdentifier) {
    if (iconIdentifier == null) return Icons.category_rounded;
    return _iconMap[iconIdentifier.toLowerCase()] ?? Icons.category_rounded;
  }

  static List<String> get availableIconKeys => _iconMap.keys.toList();
}
