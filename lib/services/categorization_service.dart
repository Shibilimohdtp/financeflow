import '../models/transaction.dart';

class CategorySuggestion {
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final String categoryColor;
  final double confidence; // 0.0 to 1.0
  final String reason;
  final bool isUserOverride;

  const CategorySuggestion({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.confidence,
    required this.reason,
    this.isUserOverride = false,
  });
}

class CategorizationRule {
  final List<String> keywords;
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final String categoryColor;
  final double defaultConfidence;

  const CategorizationRule({
    required this.keywords,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    this.defaultConfidence = 0.9,
  });
}

/// Offline deterministic rule-based merchant categorization engine
class CategorizationService {
  // In-memory or persisted map of user-learned overrides (normalized merchant -> category suggestion)
  static final Map<String, CategorySuggestion> _userOverrides = {};

  static void recordUserChoice({
    required String rawMerchant,
    required String categoryId,
    required String categoryName,
    required String categoryIcon,
    required String categoryColor,
  }) {
    final key = _normalizeKey(rawMerchant);
    if (key.isNotEmpty) {
      _userOverrides[key] = CategorySuggestion(
        categoryId: categoryId,
        categoryName: categoryName,
        categoryIcon: categoryIcon,
        categoryColor: categoryColor,
        confidence: 1.0,
        reason: 'Based on your previous choice for this merchant',
        isUserOverride: true,
      );
    }
  }

  static void clearUserOverrides() {
    _userOverrides.clear();
  }

  static String _normalizeKey(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static final List<CategorizationRule> _defaultRules = [
    // 1. Food & Dining
    const CategorizationRule(
      keywords: [
        'swiggy',
        'zomato',
        'mcdonalds',
        'kfc',
        'starbucks',
        'dominos',
        'pizza hut',
        'burger king',
        'subway',
        'chai point',
        'blue tokai',
        'cafe coffee day',
        'ccd',
        'haldiram',
        'barbeque nation',
        'behrouz',
        'faasos',
        'eatclub',
        'rebel foods',
        'bikanervala',
        'dunkin',
        'restaurant',
        'cafe',
        'dhaba',
        'bakery',
        'tiffin',
        'biryani',
        'sweet',
      ],
      categoryId: 'cat_dining',
      categoryName: 'Dining',
      categoryIcon: 'restaurant',
      categoryColor: 'clay',
      defaultConfidence: 0.92,
    ),

    // 2. Groceries
    const CategorizationRule(
      keywords: [
        'instamart',
        'bigbasket',
        'blinkit',
        'zepto',
        'dunzo',
        'dmart',
        'nature basket',
        'reliance fresh',
        'more retail',
        'spencers',
        'milkbasket',
        'country delight',
        'bb daily',
        'supermarket',
        'grocery',
        'provision',
        'vegetables',
        'fruits',
        'kirana',
      ],
      categoryId: 'cat_groceries',
      categoryName: 'Groceries',
      categoryIcon: 'shopping_basket',
      categoryColor: 'moss',
      defaultConfidence: 0.95,
    ),

    // 3. Transport
    const CategorizationRule(
      keywords: [
        'uber',
        'ola',
        'rapido',
        'metro',
        'namma metro',
        'delhi metro',
        'fastag',
        'toll',
        'irctc',
        'redbus',
        'abhibus',
        'makemytrip',
        'cleartrip',
        'yatra',
        'indigo',
        'air india',
        'spicejet',
        'vistara',
        'akasa',
        'auto',
        'cab',
        'taxi',
        'chalo',
        'dtc',
        'best',
        'railway',
      ],
      categoryId: 'cat_transport',
      categoryName: 'Transport',
      categoryIcon: 'directions_car',
      categoryColor: 'slate',
      defaultConfidence: 0.90,
    ),

    // 4. Fuel
    const CategorizationRule(
      keywords: [
        'petrol',
        'diesel',
        'fuel',
        'hpcl',
        'iocl',
        'bpcl',
        'shell',
        'indian oil',
        'bharat petroleum',
        'hindustan petroleum',
        'cng',
        'nayara',
      ],
      categoryId: 'cat_fuel',
      categoryName: 'Fuel',
      categoryIcon: 'local_gas_station',
      categoryColor: 'clay',
      defaultConfidence: 0.95,
    ),

    // 5. Shopping
    const CategorizationRule(
      keywords: [
        'amazon',
        'amzn',
        'flipkart',
        'myntra',
        'ajio',
        'nykaa',
        'tata cliq',
        'meesho',
        'zara',
        'h&m',
        'uniqlo',
        'decathlon',
        'westside',
        'reliance trends',
        'pantaloons',
        'shoppers stop',
        'max fashion',
        'croma',
        'reliance digital',
        'ikea',
        'lifestyle',
      ],
      categoryId: 'cat_shopping',
      categoryName: 'Shopping',
      categoryIcon: 'shopping_bag',
      categoryColor: 'marigold',
      defaultConfidence: 0.88,
    ),

    // 6. Subscriptions
    const CategorizationRule(
      keywords: [
        'netflix',
        'spotify',
        'youtube',
        'prime video',
        'disney',
        'hotstar',
        'apple',
        'google one',
        'icloud',
        'sonyliv',
        'zee5',
        'audible',
        'kindle',
        'chatgpt',
        'openai',
        'anthropic',
        'claude',
        'midjourney',
        'canva',
        'github',
        'notion',
        'figma',
        'coursera',
        'udemy',
      ],
      categoryId: 'cat_subscriptions',
      categoryName: 'Subscriptions',
      categoryIcon: 'subscriptions',
      categoryColor: 'marigold',
      defaultConfidence: 0.95,
    ),

    // 7. Bills & Utilities
    const CategorizationRule(
      keywords: [
        'electricity',
        'bescom',
        'tata power',
        'adani electricity',
        'bses',
        'water board',
        'bwssb',
        'gas bill',
        'igl',
        'mgl',
        'indane',
        'hp gas',
        'bharat gas',
        'airtel',
        'jio',
        'vi',
        'vodafone',
        'bsnl',
        'act fibernet',
        'broadband',
        'wifi',
        'tata play',
        'dish tv',
        'dth',
        'recharge',
        'utility',
      ],
      categoryId: 'cat_bills',
      categoryName: 'Bills',
      categoryIcon: 'receipt',
      categoryColor: 'damson',
      defaultConfidence: 0.92,
    ),

    // 8. Healthcare
    const CategorizationRule(
      keywords: [
        'apollo',
        'netmeds',
        '1mg',
        'tata 1mg',
        'pharmeasy',
        'medplus',
        'fortis',
        'max healthcare',
        'manipal',
        'hospital',
        'clinic',
        'pharmacy',
        'chemist',
        'doctor',
        'diagnostic',
        'lal pathlabs',
        'srl',
        'dentist',
        'dental',
        'opticals',
        'lenskart',
      ],
      categoryId: 'cat_healthcare',
      categoryName: 'Healthcare',
      categoryIcon: 'medical_services',
      categoryColor: 'terracotta',
      defaultConfidence: 0.90,
    ),

    // 9. Loans & EMI
    const CategorizationRule(
      keywords: [
        'hdfc loan',
        'sbi loan',
        'icici loan',
        'axis loan',
        'emi',
        'loan emi',
        'bajaj finance',
        'home credit',
        'krazybee',
        'moneytap',
        'kreditbee',
        'earlysalary',
        'zestmoney',
        'simpl',
        'lazypay',
        'home loan',
        'car loan',
        'personal loan',
        'education loan',
      ],
      categoryId: 'cat_emi',
      categoryName: 'EMI',
      categoryIcon: 'account_balance',
      categoryColor: 'damson',
      defaultConfidence: 0.92,
    ),

    // 10. Investments
    const CategorizationRule(
      keywords: [
        'zerodha',
        'groww',
        'kuvera',
        'coin',
        'indmoney',
        'smallcase',
        'upstox',
        'angel one',
        'et money',
        'mf central',
        'cams',
        'karvy',
        'mutual fund',
        'uti mf',
        'nippon',
        'hdfc mf',
        'icici pru',
        'sbi mf',
        'parag parikh',
        'mirae',
        'axis mf',
        'ppf',
        'nps',
        'sovereign gold',
        'sgb',
        'fixed deposit',
        'recurring deposit',
      ],
      categoryId: 'cat_investments',
      categoryName: 'Investments',
      categoryIcon: 'trending_up',
      categoryColor: 'indigo',
      defaultConfidence: 0.95,
    ),

    // 11. Salary / Income
    const CategorizationRule(
      keywords: [
        'salary',
        'payroll',
        'direct deposit',
        'monthly wage',
        'stipend',
        'employer',
        'infosys',
        'tcs',
        'wipro',
        'google payroll',
        'amazon salary',
      ],
      categoryId: 'cat_salary',
      categoryName: 'Salary',
      categoryIcon: 'payments',
      categoryColor: 'grove',
      defaultConfidence: 0.95,
    ),

    // 12. Freelance
    const CategorizationRule(
      keywords: [
        'upwork',
        'fiverr',
        'toptal',
        'freelance',
        'consulting',
        'invoice payment',
        'client payout',
        'stripe payout',
        'paypal payout',
      ],
      categoryId: 'cat_freelance',
      categoryName: 'Freelance',
      categoryIcon: 'work',
      categoryColor: 'grove',
      defaultConfidence: 0.90,
    ),

    // 13. Education
    const CategorizationRule(
      keywords: [
        'school',
        'college',
        'university',
        'tuition',
        'coaching',
        'allen',
        'byjus',
        'unacademy',
        'physics wallah',
        'book store',
        'textbook',
      ],
      categoryId: 'cat_education',
      categoryName: 'Education',
      categoryIcon: 'school',
      categoryColor: 'slate',
      defaultConfidence: 0.90,
    ),

    // 14. Entertainment
    const CategorizationRule(
      keywords: [
        'bookmyshow',
        'pvr',
        'inox',
        'cinepolis',
        'movie',
        'concert',
        'amusement',
        'gaming',
        'playstation',
        'steam',
        'xbox',
      ],
      categoryId: 'cat_entertainment',
      categoryName: 'Entertainment',
      categoryIcon: 'movie',
      categoryColor: 'marigold',
      defaultConfidence: 0.90,
    ),

    // 15. General Transaction / Transfer / Lending / Advance
    const CategorizationRule(
      keywords: [
        'transfer',
        'p2p',
        'upi transfer',
        'sent to',
        'advance',
        'lending',
        'peer to peer',
      ],
      categoryId: 'cat_transaction',
      categoryName: 'Transaction',
      categoryIcon: 'swap_horiz',
      categoryColor: 'slate',
      defaultConfidence: 0.85,
    ),
  ];

  /// Returns the most recent non-miscellaneous category used for this merchant from transaction history
  static CategorySuggestion? getHistoricalCategoryForMerchant(
    String rawMerchant, {
    required Iterable<Transaction> history,
  }) {
    if (rawMerchant.trim().isEmpty) return null;
    final normalized = _normalizeKey(rawMerchant);
    if (normalized.isEmpty) return null;

    final matches = history.where((tx) {
      if (tx.categoryId.isEmpty ||
          tx.categoryId == 'cat_miscellaneous' ||
          tx.categoryName.toLowerCase() == 'miscellaneous') {
        return false;
      }
      final txNorm = _normalizeKey(tx.merchant);
      return txNorm == normalized ||
          (txNorm.length > 2 &&
              normalized.length > 2 &&
              (txNorm.contains(normalized) || normalized.contains(txNorm)));
    }).toList();

    if (matches.isEmpty) return null;

    // Sort by date descending (most recently used first)
    matches.sort((a, b) => b.date.compareTo(a.date));
    final recentTx = matches.first;

    return CategorySuggestion(
      categoryId: recentTx.categoryId,
      categoryName: recentTx.categoryName,
      categoryIcon: recentTx.categoryIcon,
      categoryColor: recentTx.categoryColor,
      confidence: 0.95,
      reason: 'Most recent category used for "$rawMerchant"',
      isUserOverride: true,
    );
  }

  /// Suggest a category based on the merchant name, checking user overrides and transaction history first, then on-device rules
  static CategorySuggestion? suggestCategory(
    String rawMerchant, {
    Iterable<Transaction>? history,
  }) {
    if (rawMerchant.trim().isEmpty) return null;

    final normalized = _normalizeKey(rawMerchant);
    if (normalized.isEmpty) return null;

    // 1. Check exact user override first
    if (_userOverrides.containsKey(normalized)) {
      return _userOverrides[normalized];
    }

    // 2. Check transaction history for most recent category for this merchant
    if (history != null) {
      final historicalMatch = getHistoricalCategoryForMerchant(
        rawMerchant,
        history: history,
      );
      if (historicalMatch != null) {
        return historicalMatch;
      }
    }

    // 3. Check if user override matches any substring
    for (final entry in _userOverrides.entries) {
      if (normalized.contains(entry.key) || entry.key.contains(normalized)) {
        return entry.value;
      }
    }

    // 4. Match against default deterministic rules
    for (final rule in _defaultRules) {
      for (final keyword in rule.keywords) {
        final normKw = _normalizeKey(keyword);
        if (normKw.isNotEmpty && normalized.contains(normKw)) {
          return CategorySuggestion(
            categoryId: rule.categoryId,
            categoryName: rule.categoryName,
            categoryIcon: rule.categoryIcon,
            categoryColor: rule.categoryColor,
            confidence: rule.defaultConfidence,
            reason: 'Matched keyword "$keyword" on this device',
            isUserOverride: false,
          );
        }
      }
    }

    return null;
  }
}
