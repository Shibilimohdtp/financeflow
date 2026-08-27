/// Deterministic, on-device extraction shared by SMS and notifications.
class CounterpartyExtractor {
  CounterpartyExtractor._();

  static const unknown = 'Bank Transaction';

  static final _security = RegExp(
    r'\b(?:not\s+you|if\s+not\s+you|cust(?:omer)?\s*id|sms\s+blockupi|to\s+block|do\s+not\s+share|call\s+(?:us|on))\b',
    caseSensitive: false,
  );
  static final _end = RegExp(
    r'\b(?:not\s+you|cust(?:omer)?\s*id|sms\s+blockupi|available\s+balance|avl\s*bal|balance|bal|upi\s*ref|ref(?:erence)?|rrn|utr|txn\s*id|on|using|via|successfully|successful|done)\b|\b(?:axis|hdfc|icici|federal|canara|union|kotak)\s+bank\b|\b(?:sbi|state\s+bank\s+of\s+india)\b',
    caseSensitive: false,
  );
  static final _upi = RegExp(
    r'\bUPI\s*/\s*P2[AM]\s*/\s*([A-Za-z0-9]+)\s*/\s*([^/]+)',
    caseSensitive: false,
  );
  static final _genericFooter = RegExp(
    r'\b(?:available\s+balance|avl\s*bal|balance|bal|upi\s*ref|ref(?:erence)?|rrn|utr)\b',
    caseSensitive: false,
  );

  static String _beforeSecurity(String text) => text.split(_security).first;

  static String? structuredReference(String text) =>
      _upi.firstMatch(_beforeSecurity(text))?.group(1);

  static String extract(String text) {
    final safeText = _beforeSecurity(text);
    // The merchant is the segment immediately after the reference. Trailing
    // slash fields are bank metadata, never an alternative payee.
    for (final match in _upi.allMatches(safeText)) {
      final candidate = validate(match.group(2)!);
      if (candidate != null) return candidate;
    }

    // Legacy bank narration: Info: UPI/SWIGGY/423524.
    final legacy = RegExp(r'\bUPI\s*/\s*([^/]+)\s*/', caseSensitive: false);
    for (final match in legacy.allMatches(safeText)) {
      final candidate = validate(match.group(1)!);
      if (candidate != null) return candidate;
    }

    final phrases = RegExp(
      r'(?=\b(?:to|at|from|towards|for|by|info|vpa)\b\s*:?\s+([^\n.;]+))',
      caseSensitive: false,
    );
    for (final match in phrases.allMatches(
      safeText.split(_genericFooter).first,
    )) {
      final candidate = validate(match.group(1)!);
      if (candidate != null) return candidate;
    }
    return unknown;
  }

  /// Returns cleaned evidence, not a normalized brand/display name.
  static String? validate(String text) {
    final candidate =
        text
            .split(_end)
            .first
            .replaceAll(RegExp(r'\s+'), ' ')
            .replaceAll(RegExp(r'^[\s:,.\-]+|[\s:,.\-]+$'), '')
            .trim();
    if (candidate.isEmpty ||
        !RegExp(r'[A-Za-z\u0080-\uFFFF]').hasMatch(candidate)) {
      return null;
    }
    if (RegExp(r'^(?:\+?91[\s-]?)?[6-9](?:[\s-]?\d){9}$').hasMatch(candidate) ||
        RegExp(r'^[\d\s+()./-]+$').hasMatch(candidate) ||
        RegExp(r'^[xX*]+$').hasMatch(candidate) ||
        RegExp(
          r'(?:[xX*]{2,}\s*\d|\b[xX]\d{3,}\b|\d\s*[*]{2,})',
        ).hasMatch(candidate) ||
        RegExp(r'\b\d{6,}\b').hasMatch(candidate) ||
        RegExp(
          r'\b\d{1,2}[-/]\w+[-/]\d{2,4}\b|\b\d{1,2}:\d{2}|^\d{1,2}[- /]?[A-Za-z]{3,9}[- /]?\d{2,4}$',
        ).hasMatch(candidate) ||
        RegExp(
          r'^(?:a/c|acct|account|card|ending|transfer\b|rs\b|inr\b|upi\b|p2[am]\b|utr\b|rrn\b|ref\b|txn\b|bank transaction\b|unknown payee\b|payer\b)',
          caseSensitive: false,
        ).hasMatch(candidate) ||
        RegExp(r'^(?=[A-Za-z0-9]*\d{4})[A-Za-z0-9]{8,}$').hasMatch(candidate) ||
        RegExp(
          r'\b(?:bank|cust(?:omer)?\s*id|blockupi|balance)\b',
          caseSensitive: false,
        ).hasMatch(candidate)) {
      return null;
    }
    return candidate;
  }
}
