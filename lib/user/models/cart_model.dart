class CartItemModel {
  final String productId;
  final String title;
  final String imageUrl;
  final double price;
  final double discount;
  final int quantity;

  CartItemModel({
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.discount,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'title': title,
      'imageUrl': imageUrl,
      'price': price,
      'discount': discount,
      'quantity': quantity,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      productId: map['productId']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      price: _parseDouble(map['price']),
      discount: _parseDouble(map['discount']), // Use the same helper
      quantity: (map['quantity'] is int) ? map['quantity'] : 1,
    );
  }

  // Helper method for CartItemModel
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

  double get discountedPrice {
    return price - (price * discount / 100);
  }

  double get itemTotal {
    return discountedPrice * quantity;
  }

  double get originalTotal {
    return price * quantity;
  }

  double get discountAmount {
    return (price * discount / 100) * quantity;
  }
}
