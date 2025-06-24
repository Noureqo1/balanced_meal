class Ingredient {
  final String id;
  final String name;
  final String category; // 'meat', 'vegetable', or 'carbs'
  final double calories;
  final double price;
  final String imageUrl;
  int quantity;

  Ingredient({
    required this.id,
    required this.name,
    required this.category,
    required this.calories,
    required this.price,
    required this.imageUrl,
    this.quantity = 0,
  });

  factory Ingredient.fromMap(String id, Map<String, dynamic> data) {
    return Ingredient(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      calories: (data['calories'] ?? 0.0).toDouble(),
      price: (data['price'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'calories': calories,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  Ingredient copyWith({
    String? id,
    String? name,
    String? category,
    double? calories,
    double? price,
    String? imageUrl,
    int? quantity,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      calories: calories ?? this.calories,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
    );
  }
}
