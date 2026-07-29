class ProductSpecs {
  final String frame;
  final String gears;

  ProductSpecs({required this.frame, required this.gears});

  factory ProductSpecs.fromJson(Map<String, dynamic> json) {
    return ProductSpecs(
      frame: json['frame'] ?? '',
      gears: json['gears'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'frame': frame,
      'gears': gears,
    };
  }
}

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final double rating;
  final int reviewsCount;
  final String description;
  final ProductSpecs specifications;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    required this.reviewsCount,
    required this.description,
    required this.specifications,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: json['reviews_count'] as int? ?? 0,
      description: json['description'] ?? '',
      specifications: ProductSpecs.fromJson(json['specifications'] ?? {}),
      imageUrl: json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'rating': rating,
      'reviews_count': reviewsCount,
      'description': description,
      'specifications': specifications.toJson(),
      'image_url': imageUrl,
    };
  }
}
