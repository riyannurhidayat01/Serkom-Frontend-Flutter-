import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gowes_store/models/cart_item.dart';
import 'package:gowes_store/models/product.dart';
import 'package:gowes_store/services/api_service.dart';

class CartProvider with ChangeNotifier {
  String? _authToken;
  CartResponse? _cart;
  bool _isLoading = false;
  String? _errorMessage;

  CartResponse? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get itemCount => _cart?.items.fold(0, (sum, item) => sum! + item.quantity) ?? 0;

  void updateToken(String? token) {
    final oldToken = _authToken;
    _authToken = token;
    // If token newly assigned or changed, fetch cart
    if (_authToken != null && _authToken != oldToken) {
      fetchCart();
    } else if (_authToken == null) {
      _cart = null;
      notifyListeners();
    }
  }

  Future<void> fetchCart() async {
    if (_authToken == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.getCart(_authToken!);
      if (response.statusCode == 200) {
        _cart = CartResponse.fromJson(jsonDecode(response.body));
        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = "Failed to load cart";
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Connection error: $e";
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addToCart(Product product, {int quantity = 1}) async {
    if (_authToken == null) return false;
    
    // Optimistic UI updates
    _isLoading = true;
    notifyListeners();

    try {
      // Check if product is already in cart to calculate new quantity
      int currentQty = 0;
      if (_cart != null) {
        final existingItemIndex = _cart!.items.indexWhere((i) => i.product.id == product.id);
        if (existingItemIndex >= 0) {
          currentQty = _cart!.items[existingItemIndex].quantity;
        }
      }
      
      final newQty = currentQty + quantity;
      final response = await ApiService.updateCartItem(_authToken!, product.id, newQty);
      
      if (response.statusCode == 200) {
        _cart = CartResponse.fromJson(jsonDecode(response.body));
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    if (_authToken == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.updateCartItem(_authToken!, productId, quantity);
      if (response.statusCode == 200) {
        _cart = CartResponse.fromJson(jsonDecode(response.body));
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String productId) async {
    if (_authToken == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.removeCartItem(_authToken!, productId);
      if (response.statusCode == 200) {
        _cart = CartResponse.fromJson(jsonDecode(response.body));
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    if (_authToken == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.clearCart(_authToken!);
      if (response.statusCode == 200) {
        _cart = CartResponse.fromJson(jsonDecode(response.body));
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }
}
