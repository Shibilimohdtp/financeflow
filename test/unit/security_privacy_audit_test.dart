import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:financeflow/core/constants/app_constants.dart';
import 'package:financeflow/services/gemini_service.dart';
import 'package:financeflow/services/security_service.dart';
import '../helpers/fake_repositories.dart';

class MockSecureStorage implements FlutterSecureStorage {
  final Map<String, String> _storage = {};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _storage[key] = value;
    } else {
      _storage.remove(key);
    }
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _storage[key];
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
    WebOptions? webOptions,
  }) async {
    _storage.clear();
  }

  @override
  Future<bool> containsKey({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
    WebOptions? webOptions,
  }) async {
    return _storage.containsKey(key);
  }

  @override
  Future<Map<String, String>> readAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
    WebOptions? webOptions,
  }) async {
    return Map.from(_storage);
  }
}

class MockLocalAuthentication implements LocalAuthentication {
  bool supported = true;
  bool canCheck = true;
  bool authResult = true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<bool> get canCheckBiometrics async => canCheck;

  @override
  Future<bool> isDeviceSupported() async => supported;

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async => [BiometricType.fingerprint];

  @override
  Future<bool> authenticate({
    required String localizedReason,
    Iterable<dynamic>? authMessages,
    AuthenticationOptions options = const AuthenticationOptions(),
  }) async => authResult;

  @override
  Future<bool> stopAuthentication() async => true;
}

void main() {
  group('Security and Privacy Audit Tests', () {
    late MockSecureStorage mockStorage;
    late MockLocalAuthentication mockAuth;
    late SecurityService securityService;

    setUp(() {
      mockStorage = MockSecureStorage();
      mockAuth = MockLocalAuthentication();
      securityService = SecurityService(
        localAuth: mockAuth,
        secureStorage: mockStorage,
      );
    });

    test('PIN is stored as salted SHA-256 hash, never in plain text', () async {
      const pin = '4829';
      await securityService.setPin(pin);

      // Verify that plain text PIN does not exist in storage
      final storedHash = await mockStorage.read(key: 'ff_pin_hash_v2');
      final storedSalt = await mockStorage.read(key: 'ff_pin_salt_v2');
      final legacyPin = await mockStorage.read(key: AppConstants.keyAppPin);

      expect(storedHash, isNotNull);
      expect(storedSalt, isNotNull);
      expect(storedHash, isNot(pin)); // Must be hashed
      expect(legacyPin, isNull); // Legacy plain-text must be deleted

      // Correct PIN verifies
      final verified = await securityService.verifyPin(pin);
      expect(verified, isTrue);

      // Wrong PIN fails
      final wrongVerified = await securityService.verifyPin('1234');
      expect(wrongVerified, isFalse);
    });

    test('Legacy PIN automatically upgrades to salted SHA-256 on successful login', () async {
      const legacyPin = '9912';
      await mockStorage.write(key: AppConstants.keyAppPin, value: legacyPin);

      expect(await securityService.hasPin(), isTrue);

      // Verify legacy PIN
      final isValid = await securityService.verifyPin(legacyPin);
      expect(isValid, isTrue);

      // Verify upgrade happened
      final newHash = await mockStorage.read(key: 'ff_pin_hash_v2');
      final legacyAfter = await mockStorage.read(key: AppConstants.keyAppPin);
      expect(newHash, isNotNull);
      expect(legacyAfter, isNull);
    });

    test('PIN removal completely clears secure storage keys', () async {
      await securityService.setPin('123456');
      expect(await securityService.hasPin(), isTrue);

      await securityService.removePin();
      expect(await securityService.hasPin(), isFalse);
      expect(await mockStorage.read(key: 'ff_pin_hash_v2'), isNull);
      expect(await mockStorage.read(key: 'ff_pin_salt_v2'), isNull);
    });

    test('Biometric authentication respects hardware availability and device support', () async {
      mockAuth.supported = true;
      mockAuth.canCheck = true;
      expect(await securityService.isBiometricsAvailable(), isTrue);

      mockAuth.supported = false;
      expect(await securityService.isBiometricsAvailable(), isFalse);

      mockAuth.supported = true;
      mockAuth.authResult = true;
      expect(await securityService.authenticateWithBiometrics(), isTrue);

      mockAuth.authResult = false;
      expect(await securityService.authenticateWithBiometrics(), isFalse);
    });

    test('GeminiDataSanitizer redacts account numbers and phone numbers from user queries', () {
      const queryWithAccount = 'How much did I send to account 987654321098 last month?';
      final sanitized = GeminiDataSanitizer.sanitizeForQuery(
        query: queryWithAccount,
        contextSummary: 'Context with 2 transactions',
      );

      expect(sanitized['query'].contains('987654321098'), isFalse);
      expect(sanitized['query'].contains('[REDACTED_NUMBER]'), isTrue);
    });

    test('GeminiDataSanitizer normalizes merchant before sending categorization request', () {
      final sanitized = GeminiDataSanitizer.sanitizeForCategorization(
        rawMerchant: 'UPI-SWIGGY-swiggy@icici-42352345',
        amount: 450.0,
        availableCategoryNames: ['Dining', 'Groceries', 'Transport'],
      );

      expect(sanitized['merchant'], 'Swiggy');
      expect(sanitized['amount'], 450.0);
      expect(sanitized['availableCategories'], contains('Dining'));
    });

    test('Privacy settings toggle privacy blur and dense mode safely', () async {
      final settingsRepo = FakeSettingsRepository();
      var settings = await settingsRepo.getSettings();
      expect(settings.isPrivacyBlurEnabled, isFalse);

      await settingsRepo.setPrivacyBlurEnabled(true);
      settings = await settingsRepo.getSettings();
      expect(settings.isPrivacyBlurEnabled, isTrue);

      await settingsRepo.setDenseMode(true);
      settings = await settingsRepo.getSettings();
      expect(settings.isDenseMode, isTrue);
    });
  });
}
