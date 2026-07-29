class User {
  final String id;
  final String email;
  final String name;
  final double distanceKm;
  final int points;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.distanceKm,
    required this.points,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 1240.0,
      points: json['points'] as int? ?? 4850,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'distance_km': distanceKm,
      'points': points,
    };
  }
}
