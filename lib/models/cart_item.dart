import 'package:gowes_store/models/product.dart';

class CartItemDetail {
  final Product product;
  int quantity;

  CartItemDetail({required this.product, required this.quantity});

  factory CartItemDetail.fromJson(Map<String, dynamic> json) {
    return CartItemDetail(
      product: Product.fromJson(json['product'] ?? {}),
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }
}

class CartResponse {
  final List<CartItemDetail> items;
  final double subtotal;
  final double shipping;
  final double tax;
  final double totalAmount;

  CartResponse({
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.totalAmount,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    List<CartItemDetail> parsedItems = itemsList
        .map((i) => CartItemDetail.fromJson(i as Map<String, dynamic>))
        .toList();

    return CartResponse(
      items: parsedItems,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      shipping: (json['shipping'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
