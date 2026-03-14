class OrderItem {
  final String? productId;
  final String? title;
  final double? price;
  final int? quantity;
  final String? imageUrl;

  OrderItem({
    this.productId,
    this.title,
    this.price,
    this.quantity,
    this.imageUrl,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    print('Parsing OrderItem with map: $map');

    return OrderItem(
      productId: map['productId'] ?? map['productID'] ?? map['id'] ?? '',
      title:
          map['title'] ??
          map['productName'] ??
          map['name'] ??
          map['productTitle'] ??
          'Unknown Product',
      price: _parsePrice(map),
      quantity: _parseQuantity(map),
      imageUrl: map['imageUrl'] ?? map['image'] ?? map['productImage'] ?? '',
    );
  }

  static double _parsePrice(Map<String, dynamic> map) {
    if (map['price'] != null) return (map['price'] as num).toDouble();
    if (map['unitPrice'] != null) return (map['unitPrice'] as num).toDouble();
    if (map['productPrice'] != null)
      return (map['productPrice'] as num).toDouble();
    return 0.0;
  }

  static int _parseQuantity(Map<String, dynamic> map) {
    if (map['quantity'] != null) return (map['quantity'] as num).toInt();
    if (map['qty'] != null) return (map['qty'] as num).toInt();
    if (map['count'] != null) return (map['count'] as num).toInt();
    return 1;
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }

  @override
  String toString() {
    return 'OrderItem{title: $title, price: $price, quantity: $quantity}';
  }
}
