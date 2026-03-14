// lib/admin/services/order_services.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/admin/models/order_model.dart';

import '../../user/models/cart_model.dart';

class OrderServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveOrder({
    required String userId,
    required List<CartItemModel> cartItems,
    required double totalPrice,
    required double subTotal,
    required double discount,
    required Map<String, dynamic> shippingDetails, // Changed to dynamic
  }) async {
    try {
      // Convert cart items to the exact structure shown in your screenshot
      List<Map<String, dynamic>> productsList = cartItems.map((item) {
        return {
          'productId': item.productId,
          'title': item.title,
          'imageUrl': item.imageUrl,
          'price': item.price, // Make sure this is not 0
          'quantity': item.quantity,
        };
      }).toList();

      await _firestore.collection('orders').add({
        'userId': userId,
        'products':
            productsList, // lowercase 'products' to match your structure
        'totalPrice': totalPrice,
        'subTotal': subTotal,
        'discount': discount,
        'shippingDetails': shippingDetails,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
        'createdAtReadable': DateTime.now()
            .toString(), // Add human readable timestamp
      });

      print('Order saved successfully with total: $totalPrice');
    } catch (e) {
      print('Error saving order: $e');
      throw Exception('Failed to save order: $e');
    }
  }

  Future<List<OrderModel>> getOrders() async {
    try {
      final snapshot = await _firestore.collection('orders').get();
      final orders = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();

      print('Fetched ${orders.length} orders from Firestore');
      return orders;
    } catch (e) {
      print('Error in getOrders: $e');
      rethrow;
    }
  }

  Future<List<OrderModel>> getOrdersByUser(String userId) async {
    final snapshot = await _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map(
          (doc) =>
              OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    if (!doc.exists) return null;
    return OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status,
    });
  }

  Future<void> deleteOrder(String orderId) async {
    await _firestore.collection('orders').doc(orderId).delete();
  }
}
