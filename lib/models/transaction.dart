class TransactionItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;

  TransactionItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      productId: json['product_id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] as int? ?? 1,
      imageUrl: json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'image_url': imageUrl,
    };
  }
}

class Transaction {
  final String id;
  final String orderId;
  final String userId;
  final String date;
  final String status; // "Selesai", "Dikirim", "Dibatalkan"
  final List<TransactionItem> items;
  final double subtotal;
  final double shipping;
  final double tax;
  final double totalAmount;

  Transaction({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.date,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.totalAmount,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    List<TransactionItem> parsedItems = itemsList
        .map((i) => TransactionItem.fromJson(i as Map<String, dynamic>))
        .toList();

    return Transaction(
      id: json['id'] ?? '',
      orderId: json['order_id'] ?? '',
      userId: json['user_id'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? 'Dikirim',
      items: parsedItems,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      shipping: (json['shipping'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
