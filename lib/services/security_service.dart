import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../core/constants/app_constants.dart';

/// Handles Biometric Authentication and Salted Hash PIN Storage
class SecurityService {
  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _secureStorage;

  SecurityService({
    LocalAuthentication? localAuth,
    FlutterSecureStorage? secureStorage,
  }) : _localAuth = localAuth ?? LocalAuthentication(),
       _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const String _keyPinHash = 'ff_pin_hash_v2';
  static const String _keyPinSalt = 'ff_pin_salt_v2';

  /// Check if device hardware supports biometric authentication
  Future<bool> isBiometricsAvailable() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported) return false;
      final canCheck = await _localAuth.canCheckBiometrics;
      return canCheck;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Get list of available biometric types (fingerprint, face, etc.)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// Trigger biometric authentication prompt
  Future<bool> authenticateWithBiometrics({
    String reason = 'Authenticate to access FinanceFlow',
  }) async {
    try {
      final available = await isBiometricsAvailable();
      if (!available) return false;

      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Check if a security PIN is set
  Future<bool> hasPin() async {
    try {
      final hash = await _secureStorage.read(key: _keyPinHash);
      if (hash != null && hash.isNotEmpty) return true;
      final legacy = await _secureStorage.read(key: AppConstants.keyAppPin);
      return legacy != null && legacy.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Store security PIN as salted SHA-256 hash
  Future<void> setPin(String pin) async {
    final salt = DateTime.now().microsecondsSinceEpoch.toString();
    final hash = sha256.convert(utf8.encode('$pin:$salt')).toString();

    await _secureStorage.write(key: _keyPinSalt, value: salt);
    await _secureStorage.write(key: _keyPinHash, value: hash);
    // Delete legacy plain text key if present
    await _secureStorage.delete(key: AppConstants.keyAppPin);
  }

  /// Verify entered PIN against stored salted hash
  Future<bool> verifyPin(String enteredPin) async {
    try {
      final storedHash = await _secureStorage.read(key: _keyPinHash);
      final storedSalt = await _secureStorage.read(key: _keyPinSalt);

      if (storedHash != null && storedSalt != null) {
        final computed =
            sha256.convert(utf8.encode('$enteredPin:$storedSalt')).toString();
        return storedHash == computed;
      }

      // Legacy fallback
      final legacyPin = await _secureStorage.read(key: AppConstants.keyAppPin);
      if (legacyPin != null && legacyPin == enteredPin) {
        // Upgrade to hash
        await setPin(enteredPin);
        return true;
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  /// Remove stored PIN
  Future<void> removePin() async {
    await _secureStorage.delete(key: _keyPinHash);
    await _secureStorage.delete(key: _keyPinSalt);
    await _secureStorage.delete(key: AppConstants.keyAppPin);
  }
}
