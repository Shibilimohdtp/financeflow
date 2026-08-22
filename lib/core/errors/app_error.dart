/// Calm, non-alarmist, user-actionable error hierarchy for FinanceFlow
abstract class AppError implements Exception {
  final String title;
  final String message;
  final String? actionableStep;

  const AppError({
    required this.title,
    required this.message,
    this.actionableStep,
  });

  @override
  String toString() => '$title: $message';
}

class DatabaseError extends AppError {
  const DatabaseError({
    required super.message,
    super.title = 'Storage Notice',
    super.actionableStep = 'Your local data is safe. Try restarting the app.',
  });
}

class ValidationError extends AppError {
  const ValidationError({
    required super.message,
    super.title = 'Please check this field',
    super.actionableStep,
  });
}

class AccountNotFoundError extends AppError {
  const AccountNotFoundError({
    super.title = 'Account not selected',
    super.message = 'Please select a valid account for this transaction.',
    super.actionableStep =
        'Choose an existing account or create a new one first.',
  });
}

class SecurityError extends AppError {
  const SecurityError({
    required super.message,
    super.title = 'Security Notice',
    super.actionableStep =
        'You can verify your PIN or biometric settings in Security.',
  });
}

class ActionFailedError extends AppError {
  const ActionFailedError({
    required super.message,
    super.title = 'Could not complete action',
    super.actionableStep = 'Please try again.',
  });
}
