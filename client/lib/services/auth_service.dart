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
  String? _serviceId;
  bool _isAuthenticated = false;
  DateTime? _lastAuthTime;
  String? _authToken; // Add this to store the token

  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _isAuthenticated;
  String? get authToken => _authToken; // Add getter for the token

  Future<void> initialize({
    required String apiUrl,
  }) async {
    _apiUrl = apiUrl;
    _isInitialized = true;
    debugPrint('Auth service initialized with URL: $_apiUrl');

    // Check if we have a stored authentication
    await _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
      final lastAuthTimeStr = prefs.getString('lastAuthTime');
      if (lastAuthTimeStr != null) {
        _lastAuthTime = DateTime.parse(lastAuthTimeStr);

        // Check if authentication has expired (24 hours)
        if (DateTime.now().difference(_lastAuthTime!).inHours > 24) {
          _isAuthenticated = false;
          await _saveAuthState();
        }
      }
      _serviceId = prefs.getString('serviceId');
      _authToken = prefs.getString('authToken'); // Load the token
    } on Exception catch (e) {
      debugPrint('Error loading auth state: $e');
      _isAuthenticated = false;
    }
  }

  Future<void> _saveAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', _isAuthenticated);
      if (_lastAuthTime != null) {
        await prefs.setString('lastAuthTime', _lastAuthTime!.toIso8601String());
      }
      if (_serviceId != null) {
        await prefs.setString('serviceId', _serviceId!);
      }
      if (_authToken != null) {
        await prefs.setString('authToken', _authToken!); // Save the token
      }
    } on Exception catch (e) {
      debugPrint('Error saving auth state: $e');
    }
  }

  Future<AuthResponse> verifyAuthCode({
    required String serviceId,
    required String authCode,
  }) async {
    if (!_isInitialized) {
      throw Exception('Auth service not initialized');
    }

    try {
      // Calculate timestamp the same way as in the React app
      final timestamp = (DateTime.now().millisecondsSinceEpoch / 30000).floor();

      final response = await http.post(
        Uri.parse('$_apiUrl/api/services/verify-auth-code'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'serviceId': serviceId,
          'authCode': authCode,
          'timestamp': timestamp,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        // Store authentication state
        _isAuthenticated = true;
        _lastAuthTime = DateTime.now();
        _serviceId = serviceId;

        // Store the token if it's in the response
        if (responseData['token'] != null) {
          _authToken = responseData['token'];
        }

        await _saveAuthState();

        return AuthResponse(
          success: true,
          message: responseData['message'] ?? 'Authentication successful',
        );
      } else {
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Authentication failed',
        );
      }
    } on Exception catch (e) {
      debugPrint('Error verifying auth code: $e');
      return AuthResponse(
        success: false,
        message: 'Error connecting to server: $e',
      );
    }
  }

  // Add a method to get headers for authenticated requests
  Map<String, String> getAuthHeaders() {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authenticated_event_id');
    await prefs.setBool('is_authenticated', false);
    await prefs.remove('authToken'); // Clear the token
    _authToken = null;
    _isAuthenticated = false;
  }
}
