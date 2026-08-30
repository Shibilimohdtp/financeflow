package com.financeflow.app.financeflow

/**
 * Deliberately small, deterministic pre-filter for private Android events.
 *
 * This is not the transaction parser.  It only decides whether an event is
 * sufficiently likely to be a financial event to put on the private queue for
 * Flutter.  Keeping this permissive prevents a new bank wording from being
 * lost before the Dart review fallback can surface it, while the explicit
 * security and promotion checks keep OTP and marketing messages out.
 */
object FinancialEventGate {
    private val blockedPhrases = listOf(
        "otp",
        "one time password",
        "verification code",
        "login code",
        "mpin",
        "cvv",
        "promo code",
        "offer",
        "pre-approved",
        "apply now",
        "cashback offer",
        "limited time offer",
        "discount",
        "sale",
    )

    private val actionPattern = Regex(
        "\\b(debited|debit|credited|credit|spent|paid|payment|sent|received|" +
            "withdrawn|withdrawal|purchase|purchased|refunded|refund|deposited|" +
            "used|txn|transaction|upi transfer|upi mandate|mandate)\\b",
    )
    private val currencyAmountPattern = Regex(
        "(?:₹|rs\\.?|inr)\\s*:?\\s*[0-9][0-9,]*(?:\\.[0-9]{1,2})?(?:/-)?",
        RegexOption.IGNORE_CASE,
    )
    private val labelledAmountPattern = Regex(
        "(?:amount|amt)\\s*(?:of|:)?\\s*[0-9][0-9,]*(?:\\.[0-9]{1,2})?",
        RegexOption.IGNORE_CASE,
    )
    private val financialContextPattern = Regex(
        "\\b(upi|card|a/c|account|acct|bank|wallet|mandate|merchant|pos)\\b",
        RegexOption.IGNORE_CASE,
    )

    fun isFinancialCandidate(text: String): Boolean {
        val normalized = text.lowercase()
        if (blockedPhrases.any(normalized::contains)) return false

        val hasAction = actionPattern.containsMatchIn(normalized)
        if (!hasAction) return false

        val hasAmount = currencyAmountPattern.containsMatchIn(text) ||
            (labelledAmountPattern.containsMatchIn(text) &&
                financialContextPattern.containsMatchIn(text))
        return hasAmount
    }

    /**
     * Empty means the user has not opted into a narrow sender allow-list: all
     * financial candidates are accepted and unknown formats go to Needs Review.
     */
    fun senderMatches(selectedSenders: Set<String>, sender: String): Boolean {
        if (selectedSenders.isEmpty()) return true
        val normalizedSender = canonicalSender(sender)
        return selectedSenders.any { configured ->
            val canonicalConfigured = canonicalSender(configured)
            canonicalConfigured.length >= 4 && normalizedSender.contains(canonicalConfigured)
        }
    }

    fun canonicalSender(value: String): String =
        value.uppercase().replace(Regex("[^A-Z0-9]"), "")
}
