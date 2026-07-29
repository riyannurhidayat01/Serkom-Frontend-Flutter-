import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Dynamically resolve backend base URL: 10.0.2.2 for Android Emulator, localhost for Web/Desktop
  static String get baseUrl {
    if (kIsWeb) {
      final host = Uri.base.host.isNotEmpty ? Uri.base.host : "localhost";
      return "http://$host:8000";
    } else {
      return "http://10.0.2.2:8000";
    }
  }

  static Map<String, String> _headers([String? token]) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // --- AUTH ENDPOINTS ---
  static Future<http.Response> register(String name, String email, String password) async {
    final url = Uri.parse("$baseUrl/api/auth/register");
    return await http.post(
      url,
      headers: _headers(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
  }

  static Future<http.Response> sendOtp({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/api/auth/register/send-otp");
    return await http.post(
      url,
      headers: _headers(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
  }

  static Future<http.Response> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final url = Uri.parse("$baseUrl/api/auth/register/verify-otp");
    return await http.post(
      url,
      headers: _headers(),
      body: jsonEncode({
        'email': email,
        'otp': otp,
      }),
    );
  }

  static Future<http.Response> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/api/auth/login");
    return await http.post(
      url,
      headers: _headers(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
  }

  static Future<http.Response> getProfile(String token) async {
    final url = Uri.parse("$baseUrl/api/auth/profile");
    return await http.get(url, headers: _headers(token));
  }

  // --- PRODUCT ENDPOINTS ---
  static Future<http.Response> getProducts({String? category, String? search}) async {
    var queryParams = <String, String>{};
    if (category != null && category.isNotEmpty && category != "Semua") {
      queryParams['category'] = category;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final uri = Uri.parse("$baseUrl/api/products").replace(queryParameters: queryParams);
    return await http.get(uri, headers: _headers());
  }

  static Future<http.Response> getProductDetail(String id) async {
    final url = Uri.parse("$baseUrl/api/products/$id");
    return await http.get(url, headers: _headers());
  }

  // --- CART ENDPOINTS ---
  static Future<http.Response> getCart(String token) async {
    final url = Uri.parse("$baseUrl/api/cart");
    return await http.get(url, headers: _headers(token));
  }

  static Future<http.Response> updateCartItem(String token, String productId, int quantity) async {
    final url = Uri.parse("$baseUrl/api/cart");
    return await http.post(
      url,
      headers: _headers(token),
      body: jsonEncode({
        'product_id': productId,
        'quantity': quantity,
      }),
    );
  }

  static Future<http.Response> removeCartItem(String token, String productId) async {
    final url = Uri.parse("$baseUrl/api/cart/item/$productId");
    return await http.delete(url, headers: _headers(token));
  }

  static Future<http.Response> clearCart(String token) async {
    final url = Uri.parse("$baseUrl/api/cart/clear");
    return await http.delete(url, headers: _headers(token));
  }

  // --- TRANSACTION ENDPOINTS ---
  static Future<http.Response> createTransaction({
    required String token,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double shipping,
    required double tax,
    required double totalAmount,
  }) async {
    final url = Uri.parse("$baseUrl/api/transactions");
    return await http.post(
      url,
      headers: _headers(token),
      body: jsonEncode({
        'items': items,
        'subtotal': subtotal,
        'shipping': shipping,
        'tax': tax,
        'total_amount': totalAmount,
      }),
    );
  }

  static Future<http.Response> getTransactionHistory(String token) async {
    final url = Uri.parse("$baseUrl/api/transactions");
    return await http.get(url, headers: _headers(token));
  }

  static Future<http.Response> updateTransactionStatus({
    required String token,
    required String transactionId,
    required String status,
  }) async {
    final url = Uri.parse("$baseUrl/api/transactions/$transactionId/status?status=$status");
    return await http.put(url, headers: _headers(token));
  }
}
