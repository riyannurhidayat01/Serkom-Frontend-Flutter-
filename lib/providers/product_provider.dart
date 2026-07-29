import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gowes_store/models/product.dart';
import 'package:gowes_store/services/api_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = "Semua";
  String _searchQuery = "";

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  // Horizontal list matching categories in the Home mockup screen:
  // "Mountain", "Road", "BMX", "Electric", "Lainnya"
  final List<String> categories = ["Semua", "Mountain", "Road", "BMX", "Electric", "Lainnya"];

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.getProducts(
        category: _selectedCategory,
        search: _searchQuery,
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        _products = responseData.map((p) => Product.fromJson(p)).toList();
        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = "Failed to load products";
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Connection error: $e";
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    fetchProducts();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    fetchProducts();
  }
}
