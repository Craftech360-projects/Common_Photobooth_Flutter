import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photobooth_flutter/models/auth_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService instance = AuthService._internal();

  factory AuthService() {
    return instance;
  }

  AuthService._internal();

  bool _isInitialized = false;
  String? _apiUrl;

  bool get isInitialized => _isInitialized;

  Future<void> initialize({
    required String apiUrl,
  }) async {
    _apiUrl = apiUrl;
    _isInitialized = true;
    debugPrint('Auth service initialized with URL: $_apiUrl');
  }

  Future<AuthResponse> verifyAuthCode({
    required String eventId,
    required String authCode,
  }) async {
    if (!_isInitialized) {
      throw Exception('Auth service not initialized');
    }

    try {
      // Calculate timestamp the same way as in the React app
      final timestamp = (DateTime.now().millisecondsSinceEpoch / 30000).floor();

      final response = await http.post(
        Uri.parse('$_apiUrl/api/verify'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'eventId': eventId,
          'authCode': authCode,
          'timestamp': timestamp,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data);

        if (authResponse.success) {
          // Store the authenticated event ID
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('authenticated_event_id', eventId);
          await prefs.setBool('is_authenticated', true);
        }

        return authResponse;
      } else {
        debugPrint('Error verifying auth code: ${response.body}');
        return AuthResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Exception verifying auth code: $e');
      return AuthResponse(
        success: false,
        message: 'Connection error: $e',
      );
    }
  }

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_authenticated') ?? false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authenticated_event_id');
    await prefs.setBool('is_authenticated', false);
  }
}
