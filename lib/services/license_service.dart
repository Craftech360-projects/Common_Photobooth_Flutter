import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class LicenseService {
  static final LicenseService instance = LicenseService._internal();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  final String _secretKey = 'b7f8e2d1c9a4f6e3b2d7c8a9e1f4b6d2c3a8e7f1b5d9c2a6f3e8b1d4c7a2f9e5'; // ====> Use env here

  factory LicenseService() {
    return instance;
  }

  LicenseService._internal();

  /// Stores service details securely after successful validation.
  Future<void> storeServiceDetails(Map<String, dynamic> serviceDetails) async {
    try {
      if (serviceDetails['userId'] != null) {
        await _secureStorage.write(
            key: 'license_user_id', value: serviceDetails['userId']);
      }
      if (serviceDetails['serviceId'] != null) {
        await _secureStorage.write(
            key: 'license_service_id', value: serviceDetails['serviceId']);
      }
      if (serviceDetails['licenseSecurityKey'] != null) {
        await _secureStorage.write(
            key: 'license_security_key',
            value: serviceDetails['licenseSecurityKey']);
      }
      if (serviceDetails['licenseEndDateTime'] != null) {
        final expirationTimestamp =
            DateTime.parse(serviceDetails['licenseEndDateTime'])
                .millisecondsSinceEpoch;
        await _secureStorage.write(
            key: 'license_expiration', value: expirationTimestamp.toString());
      }
      if (serviceDetails['requestId'] != null) {
        await _secureStorage.write(
            key: 'license_request_id', value: serviceDetails['requestId']);
      }
      if (serviceDetails['deviceId'] != null) {
        await _secureStorage.write(
            key: 'license_device_id', value: serviceDetails['deviceId']);
      }
      if (serviceDetails['startDateTime'] != null) {
        await _secureStorage.write(
            key: 'license_start_date', value: serviceDetails['startDateTime']);
      }
      if (serviceDetails['licenseIssuedAt'] != null) {
        await _secureStorage.write(
            key: 'license_issued_at', value: serviceDetails['licenseIssuedAt']);
      }

      // Store last verification time
      await _secureStorage.write(
          key: 'last_verification_time',
          value: DateTime.now().millisecondsSinceEpoch.toString());

      // Store authentication flag
      await _secureStorage.write(key: 'is_authenticated', value: 'true');
    } on Exception catch (e) {
      debugPrint('Error storing service details in secure storage: $e');
    }
  }

  /// Verifies a license certificate (JWT).
  Future<LicenseVerificationResult> verifyLicense(String certificate) async {
    try {
      final parts = certificate.split('.');
      if (parts.length != 3) {
        return LicenseVerificationResult(
            isValid: false, message: 'Invalid certificate format');
      }

      final payload = json
          .decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));

      final signatureValid = _verifySignature(parts[0], parts[1], parts[2]);
      if (!signatureValid) {
        return LicenseVerificationResult(
            isValid: false, message: 'Invalid certificate signature');
      }

      final expiration = payload['exp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000)
          : payload['endDateTime'] != null
              ? DateTime.parse(payload['endDateTime'])
              : null;

      if (expiration == null) {
        return LicenseVerificationResult(
            isValid: false,
            message: 'Invalid license: missing expiration date');
      }

      final currentTime = await _getSecureTime();
      if (currentTime.isAfter(expiration)) {
        return LicenseVerificationResult(
            isValid: false, message: 'License has expired');
      }

      // Store license data securely
      await _storeLicenseData(payload, expiration.millisecondsSinceEpoch);

      return LicenseVerificationResult(
        isValid: true,
        message: 'License verified successfully',
        userId: payload['userId'],
        eventId: payload['serviceId'],
        expirationDate: expiration,
      );
    } on Exception catch (e) {
      debugPrint('License verification error: $e');
      return LicenseVerificationResult(
          isValid: false, message: 'Error verifying license: $e');
    }
  }

  /// Stores decoded license data into secure storage.
  Future<void> _storeLicenseData(
      Map<String, dynamic> payload, int expirationTimestamp) async {
    try {
      await _secureStorage.write(
          key: 'license_user_id', value: payload['userId']);
      await _secureStorage.write(
          key: 'license_service_id', value: payload['serviceId']);
      await _secureStorage.write(
          key: 'license_security_key', value: payload['securityKey']);
      await _secureStorage.write(
          key: 'license_expiration', value: expirationTimestamp.toString());

      if (payload['requestId'] != null) {
        await _secureStorage.write(
            key: 'license_request_id', value: payload['requestId']);
      }
      if (payload['deviceId'] != null) {
        await _secureStorage.write(
            key: 'license_device_id', value: payload['deviceId']);
      }
      if (payload['startDateTime'] != null) {
        await _secureStorage.write(
            key: 'license_start_date', value: payload['startDateTime']);
      }
      if (payload['issuedAt'] != null) {
        await _secureStorage.write(
            key: 'license_issued_at', value: payload['issuedAt']);
      }

      await _secureStorage.write(
          key: 'last_verification_time',
          value: DateTime.now().millisecondsSinceEpoch.toString());

      // Store authentication flag
      await _secureStorage.write(key: 'is_authenticated', value: 'true');
    } on Exception catch (e) {
      debugPrint('Error storing license data in secure storage: $e');
    }
  }

  /// Verifies the JWT signature against the secret key.
  bool _verifySignature(String header, String payload, String signature) {
    final key = utf8.encode(_secretKey);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(utf8.encode('$header.$payload'));
    final calculatedSignature = base64Url.encode(digest.bytes);

    // Compare signatures safely, ignoring padding differences
    return calculatedSignature.replaceAll('=', '') ==
        signature.replaceAll('=', '');
  }

  /// Checks if the currently stored license is valid and not expired.
  Future<bool> isLicenseValid() async {
    try {
      final isAuthenticatedStr =
          await _secureStorage.read(key: 'is_authenticated');
      final isAuthenticated = isAuthenticatedStr == 'true';

      if (!isAuthenticated) return false;

      final expirationStr =
          await _secureStorage.read(key: 'license_expiration');
      if (expirationStr == null) return false;

      final expiration = int.parse(expirationStr);
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(expiration);
      final currentTime = await _getSecureTime();

      if (currentTime.isAfter(expirationDate)) {
        await logout(); // License expired, so log out
        return false;
      }

      // Optionally perform a periodic check with your server
      await _performPeriodicServerCheck();

      return true;
    } on Exception catch (e) {
      debugPrint('Error checking license validity: $e');
      return false;
    }
  }

  /// Gets time from a reliable server to prevent device time manipulation.
  Future<DateTime> _getSecureTime() async {
    try {
      final response = await http
          .head(Uri.parse('https://google.com'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200 && response.headers['date'] != null) {
        return HttpDate.parse(response.headers['date']!);
      }
    } on Exception catch (e) {
      debugPrint('Failed to get server time, using device time: $e');
    }
    return DateTime.now();
  }

  /// A placeholder for periodically checking license status with a remote server.
  Future<void> _performPeriodicServerCheck() async {
    try {
      final lastVerificationStr =
          await _secureStorage.read(key: 'last_verification_time');
      if (lastVerificationStr == null) return;

      final lastVerificationTime =
          DateTime.fromMillisecondsSinceEpoch(int.parse(lastVerificationStr));

      // Example: If it's been more than 7 days, try to re-validate online
      if (DateTime.now().difference(lastVerificationTime).inDays > 7) {
        final serviceId = await _secureStorage.read(key: 'license_service_id');
        final securityKey =
            await _secureStorage.read(key: 'license_security_key');

        if (serviceId != null && securityKey != null) {
          // TODO: Implement an API call to your server to verify if the license
          // is still active or has been revoked. If verification fails,
          // you might want to call logout() or enter a grace period.
        }
      }
    } on Exception catch (e) {
      debugPrint('Error in periodic server check: $e');
    }
  }

  /// Clears all stored license and authentication data securely.
  Future<void> logout() async {
    // Delete all keys from secure storage
    await _secureStorage.deleteAll();
  }
}

/// A model to hold the result of a license verification attempt.
class LicenseVerificationResult {
  final bool isValid;
  final String message;
  final String? userId;
  final String? eventId;
  final DateTime? expirationDate;

  LicenseVerificationResult({
    required this.isValid,
    required this.message,
    this.userId,
    this.eventId,
    this.expirationDate,
  });
}
