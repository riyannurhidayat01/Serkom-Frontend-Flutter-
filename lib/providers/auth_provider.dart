import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gowes_store/models/user.dart';
import 'package:gowes_store/services/api_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  String? get token => _token;
  User? get user => _user;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return;
    }
    
    final extractedUserData = jsonDecode(prefs.getString('userData')!) as Map<String, dynamic>;
    _token = prefs.getString('token');
    _user = User.fromJson(extractedUserData);
    notifyListeners();
    
    // Silently refresh profile
    if (_token != null) {
      refreshProfile();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.register(name, email, password);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = responseData['detail'] ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendOtp(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.sendOtp(name: name, email: email, password: password);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = responseData['detail'] ?? 'Failed to send OTP code.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.verifyOtp(email: email, otp: otp);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = responseData['detail'] ?? 'OTP verification failed.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.login(email, password);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _token = responseData['access_token'];
        _user = User.fromJson(responseData['user']);
        
        // Save to cache
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('userData', jsonEncode(_user!.toJson()));

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = responseData['detail'] ?? 'Login failed. Check credentials.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshProfile() async {
    if (_token == null) return;
    try {
      final response = await ApiService.getProfile(_token!);
      if (response.statusCode == 200) {
        _user = User.fromJson(jsonDecode(response.body));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userData', jsonEncode(_user!.toJson()));
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error refreshing profile: $e");
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _errorMessage = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userData');
    notifyListeners();
  }
}
