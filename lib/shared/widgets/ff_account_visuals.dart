import 'package:flutter/material.dart';

import '../../models/account.dart';
import '../../theme/ff_hero.dart';

/// Central visual mapping for [AccountType] in Stillwater Bloom.
///
/// Maps account types to their hero tone (moss for everyday money/accounts,
/// dusk for debt/cards/investments, sand for cash/wallets) and iconography.
class FfAccountVisuals {
  const FfAccountVisuals._();

  /// Hero tone by what the account holds, never by bank or brand.
  static FfHeroTone toneFor(AccountType type) => switch (type) {
    AccountType.bank ||
    AccountType.upi ||
    AccountType.business => FfHeroTone.moss,
    AccountType.creditCard || AccountType.investment => FfHeroTone.dusk,
    AccountType.cash => FfHeroTone.sand,
  };

  /// Bloom icon for each account type.
  static IconData iconFor(AccountType type) => switch (type) {
    AccountType.bank => Icons.account_balance_outlined,
    AccountType.upi => Icons.qr_code_2_rounded,
    AccountType.business => Icons.storefront_outlined,
    AccountType.creditCard => Icons.credit_card_outlined,
    AccountType.investment => Icons.trending_up_rounded,
    AccountType.cash => Icons.account_balance_wallet_outlined,
  };
}
