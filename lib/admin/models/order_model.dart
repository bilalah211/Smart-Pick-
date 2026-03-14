import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_item.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final String shippingAddress;
  final DateTime createdAt;
  final DateTime? updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    required this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    print('=== PARSING ORDER $id ===');
    print('Raw data: $map');

    List<OrderItem> items = [];

    // OPTION 1: If items is a list of maps
    if (map['items'] != null && map['items'] is List) {
      print('Found items list: ${map['items']}');
      items = (map['items'] as List).map((item) {
        print('Processing item: $item');
        return OrderItem.fromMap(item);
      }).toList();
    }
    // OPTION 2: If products are stored as separate fields (common in Firestore)
    else if (map['productName'] != null || map['productId'] != null) {
      print('Found individual product fields');
      items = [OrderItem.fromMap(map)];
    }
    // OPTION 3: If using a different field name
    else if (map['products'] != null && map['products'] is List) {
      print('Found products list: ${map['products']}');
      items = (map['products'] as List)
          .map((item) => OrderItem.fromMap(item))
          .toList();
    }
    // OPTION 4: If using 'orderItems' or other field names
    else if (map['orderItems'] != null && map['orderItems'] is List) {
      print('Found orderItems list: ${map['orderItems']}');
      items = (map['orderItems'] as List)
          .map((item) => OrderItem.fromMap(item))
          .toList();
    }

    print('Final items count: ${items.length}');
    print('Items details: $items');

    return OrderModel(
      id: id,
      userId: map['userId'] ?? map['user_id'] ?? map['userID'] ?? 'unknown',
      items: items,
      totalAmount: _parseTotalAmount(map),
      status: map['status'] ?? 'Pending',
      shippingAddress:
          map['shippingAddress'] ?? map['address'] ?? 'Not specified',
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ??
          (map['timestamp'] as Timestamp?)?.toDate() ??
          (map['orderDate'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  static double _parseTotalAmount(Map<String, dynamic> map) {
    // Try different possible field names for total amount
    if (map['totalAmount'] != null)
      return (map['totalAmount'] as num).toDouble();
    if (map['total'] != null) return (map['total'] as num).toDouble();
    if (map['amount'] != null) return (map['amount'] as num).toDouble();
    if (map['price'] != null) return (map['price'] as num).toDouble();

    // Calculate from items if available
    if (map['items'] != null && map['items'] is List) {
      final items = (map['items'] as List)
          .map((item) => OrderItem.fromMap(item))
          .toList();
      return items.fold(
        0.0,
        (sum, item) => sum + ((item.price ?? 0) * (item.quantity ?? 0)),
      );
    }

    return 0.0;
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'shippingAddress': shippingAddress,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
