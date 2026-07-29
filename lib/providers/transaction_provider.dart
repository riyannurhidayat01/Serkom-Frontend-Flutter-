import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gowes_store/models/cart_item.dart';
import 'package:gowes_store/models/transaction.dart';
import 'package:gowes_store/services/api_service.dart';

class TransactionProvider with ChangeNotifier {
  String? _authToken;
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void updateToken(String? token) {
    final oldToken = _authToken;
    _authToken = token;
    if (_authToken != null && _authToken != oldToken) {
      fetchTransactionHistory();
    } else if (_authToken == null) {
      _transactions = [];
      notifyListeners();
    }
  }

  Future<void> fetchTransactionHistory() async {
    if (_authToken == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.getTransactionHistory(_authToken!);
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        _transactions = responseData.map((t) => Transaction.fromJson(t)).toList();
        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = "Failed to load order history";
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Connection error: $e";
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkout(CartResponse cart) async {
    if (_authToken == null || cart.items.isEmpty) return false;
    _isLoading = true;
    notifyListeners();

    try {
      // Map items to JSON transaction format
      final itemsJson = cart.items.map((item) => {
        'product_id': item.product.id,
        'name': item.product.name,
        'price': item.product.price,
        'quantity': item.quantity,
        'image_url': item.product.imageUrl,
      }).toList();

      final response = await ApiService.createTransaction(
        token: _authToken!,
        items: itemsJson,
        subtotal: cart.subtotal,
        shipping: cart.shipping,
        tax: cart.tax,
        totalAmount: cart.totalAmount,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Refresh local history
        await fetchTransactionHistory();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = "Checkout failed. Server returned error.";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "Connection error: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTransactionStatus(String transactionId, String status) async {
    if (_authToken == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.updateTransactionStatus(
        token: _authToken!,
        transactionId: transactionId,
        status: status,
      );

      if (response.statusCode == 200) {
        await fetchTransactionHistory();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = "Failed to update transaction status";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "Connection error: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
