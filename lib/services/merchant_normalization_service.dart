/// Local merchant normalization engine for consistent analytics grouping and display
class MerchantNormalizationService {
  MerchantNormalizationService._();

  // Known merchant canonical map (lowercase pattern -> canonical name)
  static final Map<String, String> _canonicalMerchants = {
    // E-Commerce & Retail
    'amzn pay': 'Amazon',
    'amazon in': 'Amazon',
    'amzn mkt': 'Amazon',
    'amazon pay': 'Amazon',
    'amazon': 'Amazon',
    'flipkart': 'Flipkart',
    'myntra': 'Myntra',
    'ajio': 'Ajio',
    'nykaa': 'Nykaa',
    'tata cliq': 'Tata CLiQ',
    'meesho': 'Meesho',
    'ikea': 'IKEA',
    'decathlon': 'Decathlon',

    // Food & Groceries
    'swiggy instamart': 'Swiggy Instamart',
    'swiggy dinein': 'Swiggy',
    'swiggy': 'Swiggy',
    'bundl technologies': 'Swiggy',
    'zomato ltd': 'Zomato',
    'zomato online': 'Zomato',
    'zomato': 'Zomato',
    'blinkit commerce': 'Blinkit',
    'blinkit': 'Blinkit',
    'grofers': 'Blinkit',
    'zepto commerce': 'Zepto',
    'zepto': 'Zepto',
    'bigbasket': 'BigBasket',
    'supermarket grocery': 'BigBasket',
    'dmart': 'DMart',
    'avenue supermarts': 'DMart',
    'starbucks': 'Starbucks',
    'tata starbucks': 'Starbucks',
    'mcdonalds': "McDonald's",
    'hardcastle restaurants': "McDonald's",
    'dominos pizza': "Domino's Pizza",
    'dominos': "Domino's Pizza",
    'jubilant foodworks': "Domino's Pizza",
    'kfc': 'KFC',
    'burger king': 'Burger King',

    // Transport & Travel
    'uber india systems': 'Uber',
    'uber trip': 'Uber',
    'uber': 'Uber',
    'ola cabs': 'Ola',
    'ani technologies': 'Ola',
    'ola': 'Ola',
    'rapido': 'Rapido',
    'roppen transportation': 'Rapido',
    'irctc': 'IRCTC',
    'makemytrip': 'MakeMyTrip',
    'cleartrip': 'Cleartrip',
    'redbus': 'RedBus',
    'indigo': 'IndiGo',
    'interglobe aviation': 'IndiGo',
    'air india': 'Air India',

    // Fuel
    'iocl': 'Indian Oil',
    'indian oil corp': 'Indian Oil',
    'indian oil': 'Indian Oil',
    'bpcl': 'Bharat Petroleum',
    'bharat petroleum': 'Bharat Petroleum',
    'hpcl': 'Hindustan Petroleum',
    'hindustan petroleum': 'Hindustan Petroleum',
    'shell petrol': 'Shell',
    'shell': 'Shell',

    // Subscriptions & Tech
    'netflix india': 'Netflix',
    'netflix entertainment': 'Netflix',
    'netflix': 'Netflix',
    'spotify india': 'Spotify',
    'spotify ab': 'Spotify',
    'spotify': 'Spotify',
    'youtube premium': 'YouTube',
    'google play': 'Google',
    'google india': 'Google',
    'google services': 'Google',
    'google': 'Google',
    'apple services': 'Apple',
    'apple com': 'Apple',
    'apple': 'Apple',
    'chatgpt subscription': 'ChatGPT',
    'openai': 'OpenAI',
    'anthropic claude': 'Claude',
    'anthropic': 'Anthropic',
    'github': 'GitHub',
    'notion': 'Notion',

    // Telecom & Utilities
    'airtel prepaid': 'Airtel',
    'bharti airtel': 'Airtel',
    'airtel': 'Airtel',
    'jio prepaid': 'Jio',
    'reliance jio': 'Jio',
    'jio': 'Jio',
    'vodafone idea': 'Vi',
    'vi prepaid': 'Vi',
    'act fibernet': 'ACT Fibernet',
    'bescom': 'BESCOM',
    'tata play': 'Tata Play',

    // Banking & Financial
    'hdfc bank': 'HDFC Bank',
    'icici bank': 'ICICI Bank',
    'sbi': 'State Bank of India',
    'state bank of india': 'State Bank of India',
    'axis bank': 'Axis Bank',
    'zerodha': 'Zerodha',
    'groww': 'Groww',
  };

  /// Suffix patterns to strip during generic normalization
  static final List<RegExp> _suffixesToStrip = [
    RegExp(r'\b(pvt|private)\s+(ltd|limited)\b', caseSensitive: false),
    RegExp(r'\b(ltd|limited)\b', caseSensitive: false),
    RegExp(r'\b(inc|incorporated|corp|corporation)\b', caseSensitive: false),
    RegExp(
      r'\b(india|systems|services|technologies|solutions|commerce|enterprises)\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\b(pay|online|retail|store|digital|direct|pos|txn|billdesk|razorpay|payu)\b',
      caseSensitive: false,
    ),
  ];

  /// Normalize merchant name for clean display and aggregated analytics
  static String normalize(String rawMerchant) {
    if (rawMerchant.trim().isEmpty) return 'Unknown Payee';

    final lower = rawMerchant.toLowerCase().trim();

    // 1. Direct canonical lookup
    if (_canonicalMerchants.containsKey(lower)) {
      return _canonicalMerchants[lower]!;
    }

    // 2. Substring match against canonical dictionary
    for (final entry in _canonicalMerchants.entries) {
      if (lower.contains(entry.key) &&
          RegExp(r'\b' + RegExp.escape(entry.key) + r'\b').hasMatch(lower)) {
        return entry.value;
      }
    }

    // 3. Generic cleaning: strip corporate suffixes, symbols, excess whitespace
    var cleaned = rawMerchant;
    for (final reg in _suffixesToStrip) {
      cleaned = cleaned.replaceAll(reg, ' ');
    }

    cleaned =
        cleaned
            .replaceAll(RegExp(r'[*_#@!$%^&()=+\[\]{};:,.<>?/\\|`~]'), ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();

    if (cleaned.isEmpty) return rawMerchant.trim();

    // Convert to Title Case
    return _toTitleCase(cleaned);
  }

  static String _toTitleCase(String text) {
    return text
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) {
          if (word.length <= 1) return word.toUpperCase();
          // If word is an acronym like "UPI", keep uppercase
          if (word == word.toUpperCase() && word.length <= 4) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
