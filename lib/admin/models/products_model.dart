import '../../user/models/cart_model.dart';

class ProductModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  final double discount;
  final String category;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.discount,
    required this.category,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    // Handle price conversion
    double priceValue = _parseDouble(map['price']);

    // Handle discount conversion - this is the key fix
    double discountValue = _parseDouble(map['discount']);

    return ProductModel(
      id: id,
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      price: priceValue,
      discount: discountValue,
      category: map['category']?.toString() ?? '',
    );
  }

  // Helper method to safely convert any type to double
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;

    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    } else if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else {
      return 0.0;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'discount': discount,
      'category': category,
    };
  }

  double get discountedPrice {
    return price - (price * discount / 100);
  }

  bool get hasDiscount => discount > 0;

  CartItemModel toCartItemModel({int quantity = 1}) {
    return CartItemModel(
      productId: id,
      title: title,
      imageUrl: imageUrl,
      price: price,
      discount: discount,
      quantity: quantity,
    );
  }
}
