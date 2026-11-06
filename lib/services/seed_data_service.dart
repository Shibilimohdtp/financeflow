import '../models/account.dart';
import '../models/investment.dart';
import '../models/loan.dart';
import '../models/subscription.dart';
import '../models/transaction.dart';
import '../repositories/account_repository.dart';
import '../repositories/investment_repository.dart';
import '../repositories/loan_repository.dart';
import '../repositories/subscription_repository.dart';
import '../repositories/transaction_repository.dart';

/// Seed data service for development and demo mode testing
class SeedDataService {
  final AccountRepository _accountRepo;
  final TransactionRepository _transactionRepo;
  final SubscriptionRepository? _subscriptionRepo;
  final LoanRepository? _loanRepo;
  final InvestmentRepository? _investmentRepo;

  SeedDataService({
    required AccountRepository accountRepo,
    required TransactionRepository transactionRepo,
    SubscriptionRepository? subscriptionRepo,
    LoanRepository? loanRepo,
    InvestmentRepository? investmentRepo,
  }) : _accountRepo = accountRepo,
       _transactionRepo = transactionRepo,
       _subscriptionRepo = subscriptionRepo,
       _loanRepo = loanRepo,
       _investmentRepo = investmentRepo;

  Future<void> seedDemoData() async {
    final now = DateTime.now();

    // 1. Seed Demo Accounts
    final hdfc = Account(
      id: 'acc_demo_hdfc',
      name: 'HDFC Salary Account',
      type: AccountType.bank,
      institutionName: 'HDFC Bank',
      maskedIdentifier: '••4321',
      openingBalance: 45000.0,
      currentBalance: 45000.0,
      currency: 'INR',
      createdAt: now.subtract(const Duration(days: 60)),
      updatedAt: now,
    );

    final sbi = Account(
      id: 'acc_demo_sbi',
      name: 'SBI Savings',
      type: AccountType.bank,
      institutionName: 'State Bank of India',
      maskedIdentifier: '••8812',
      openingBalance: 18500.0,
      currentBalance: 18500.0,
      currency: 'INR',
      createdAt: now.subtract(const Duration(days: 60)),
      updatedAt: now,
    );

    final cash = Account(
      id: 'acc_demo_cash',
      name: 'Cash Wallet',
      type: AccountType.cash,
      institutionName: 'Cash',
      openingBalance: 3200.0,
      currentBalance: 3200.0,
      currency: 'INR',
      createdAt: now.subtract(const Duration(days: 60)),
      updatedAt: now,
    );

    final upi = Account(
      id: 'acc_demo_upi',
      name: 'Google Pay UPI',
      type: AccountType.upi,
      institutionName: 'GPay / HDFC',
      maskedIdentifier: '••4321',
      openingBalance: 1500.0,
      currentBalance: 1500.0,
      currency: 'INR',
      createdAt: now.subtract(const Duration(days: 60)),
      updatedAt: now,
    );

    await _accountRepo.saveAccount(hdfc);
    await _accountRepo.saveAccount(sbi);
    await _accountRepo.saveAccount(cash);
    await _accountRepo.saveAccount(upi);

    // 2. Seed Demo Transactions
    final demoTransactions = [
      Transaction(
        id: 'tx_demo_1',
        amount: 75000.0,
        type: TransactionType.income,
        categoryId: 'cat_salary',
        categoryName: 'Salary',
        categoryIcon: 'account_balance_wallet',
        categoryColor: 'grove',
        merchant: 'Acme Corp Salary',
        date: DateTime(now.year, now.month, 1, 9, 30),
        notes: 'Monthly credited salary',
        source: TransactionSource.manual,
        paymentMethod: 'Direct Deposit',
        accountId: hdfc.id,
        createdAt: now,
        updatedAt: now,
      ),
      Transaction(
        id: 'tx_demo_2',
        amount: 18500.0,
        type: TransactionType.loanEmi,
        categoryId: 'cat_emi',
        categoryName: 'EMI',
        categoryIcon: 'payments',
        categoryColor: 'plum',
        merchant: 'HDFC Home Loan EMI',
        date: DateTime(now.year, now.month, 5, 11, 0),
        notes: 'Auto-debit for home loan',
        source: TransactionSource.manual,
        paymentMethod: 'Auto Debit',
        accountId: hdfc.id,
        createdAt: now,
        updatedAt: now,
      ),
      Transaction(
        id: 'tx_demo_3',
        amount: 2450.0,
        type: TransactionType.expense,
        categoryId: 'cat_groceries',
        categoryName: 'Groceries',
        categoryIcon: 'shopping_cart',
        categoryColor: 'grove',
        merchant: 'Nature Basket',
        date: DateTime(now.year, now.month, 8, 17, 45),
        notes: 'Weekly fresh vegetables and organic items',
        source: TransactionSource.manual,
        paymentMethod: 'UPI',
        accountId: upi.id,
        createdAt: now,
        updatedAt: now,
      ),
      Transaction(
        id: 'tx_demo_4',
        amount: 430.0,
        type: TransactionType.expense,
        categoryId: 'cat_food',
        categoryName: 'Food',
        categoryIcon: 'restaurant',
        categoryColor: 'clay',
        merchant: 'Swiggy',
        date: DateTime(now.year, now.month, 12, 14, 14),
        notes: 'Lunch biryani order',
        source: TransactionSource.manual,
        paymentMethod: 'UPI',
        accountId: upi.id,
        createdAt: now,
        updatedAt: now,
      ),
      Transaction(
        id: 'tx_demo_5',
        amount: 2000.0,
        type: TransactionType.expense,
        categoryId: 'cat_fuel',
        categoryName: 'Fuel',
        categoryIcon: 'local_gas_station',
        categoryColor: 'marigold',
        merchant: 'Indian Oil Petrol Pump',
        date: DateTime(now.year, now.month, 15, 18, 30),
        notes: 'Full tank fuel for car',
        source: TransactionSource.manual,
        paymentMethod: 'Card',
        accountId: hdfc.id,
        createdAt: now,
        updatedAt: now,
      ),
      Transaction(
        id: 'tx_demo_6',
        amount: 649.0,
        type: TransactionType.expense,
        categoryId: 'cat_subscriptions',
        categoryName: 'Subscriptions',
        categoryIcon: 'sync',
        categoryColor: 'marigold',
        merchant: 'Netflix',
        date: DateTime(now.year, now.month, 18, 20, 0),
        notes: 'Premium 4K monthly plan',
        source: TransactionSource.manual,
        paymentMethod: 'Credit Card',
        accountId: hdfc.id,
        createdAt: now,
        updatedAt: now,
      ),
      Transaction(
        id: 'tx_demo_7',
        amount: 25000.0,
        type: TransactionType.income,
        categoryId: 'cat_freelance',
        categoryName: 'Freelance',
        categoryIcon: 'laptop_mac',
        categoryColor: 'teal',
        merchant: 'Mobile App Consulting',
        date: DateTime(now.year, now.month, 20, 15, 10),
        notes: 'Phase 1 Flutter deliverables milestone payment',
        source: TransactionSource.manual,
        paymentMethod: 'IMPS',
        accountId: sbi.id,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    for (final tx in demoTransactions) {
      await _transactionRepo.saveTransaction(tx);
    }

    // 3. Seed Demo Subscriptions
    if (_subscriptionRepo != null) {
      await _subscriptionRepo.saveSubscription(
        Subscription(
          id: 'sub_demo_netflix',
          merchant: 'Netflix',
          normalizedMerchant: 'netflix',
          amount: 649.0,
          billingFrequency: SubscriptionFrequency.monthly,
          nextRenewalDate: DateTime(now.year, now.month + 1, 18),
          accountId: hdfc.id,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await _subscriptionRepo.saveSubscription(
        Subscription(
          id: 'sub_demo_spotify',
          merchant: 'Spotify Premium',
          normalizedMerchant: 'spotify',
          amount: 119.0,
          billingFrequency: SubscriptionFrequency.monthly,
          nextRenewalDate: DateTime(now.year, now.month + 1, 25),
          accountId: hdfc.id,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    // 4. Seed Demo Loan
    if (_loanRepo != null) {
      await _loanRepo.saveLoan(
        Loan(
          id: 'loan_demo_hdfc',
          name: 'HDFC Home Loan',
          lender: 'HDFC Bank',
          loanType: LoanType.homeLoan,
          accountId: hdfc.id,
          principalAmount: 2500000.0,
          interestRate: 8.5,
          interestType: InterestType.reducingBalance,
          tenureMonths: 240,
          startDate: DateTime(now.year - 2, 1, 5),
          expectedEndDate: DateTime(now.year + 18, 1, 5),
          emiAmount: 21696.0,
          paymentDay: 5,
          totalPrincipalPaid: 150000.0,
          totalInterestPaid: 370000.0,
          outstandingPrincipal: 2350000.0,
          nextDueDate: DateTime(now.year, now.month + 1, 5),
          status: LoanStatus.active,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    // 5. Seed Demo Investments
    if (_investmentRepo != null) {
      await _investmentRepo.saveInvestment(
        Investment(
          id: 'inv_demo_nifty',
          name: 'UTI Nifty 50 Index Fund',
          assetType: AssetType.mutualFunds,
          quantityOrUnits: 250.0,
          purchasePrice: 120.0,
          purchaseDate: DateTime(now.year - 1, 6, 15),
          currentValue: 36500.0,
          investedAmount: 30000.0,
          unrealizedProfitLoss: 6500.0,
          lastValuationDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await _investmentRepo.saveInvestment(
        Investment(
          id: 'inv_demo_gold',
          name: 'Sovereign Gold Bond 2023',
          assetType: AssetType.gold,
          quantityOrUnits: 10.0,
          purchasePrice: 5900.0,
          purchaseDate: DateTime(now.year - 1, 9, 20),
          currentValue: 68500.0,
          investedAmount: 59000.0,
          unrealizedProfitLoss: 9500.0,
          lastValuationDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  }
}
