// lib/admin/viewModel/order_view_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/admin/models/order_model.dart';
import 'package:ecommerceapp/admin/services/order_services.dart';

class OrderViewModel {
  final OrderServices _orderServices = OrderServices();

  List<OrderModel> orders = [];

  // In your OrderViewModel
  Future<void> fetchOrders() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      orders = snapshot.docs.map((doc) {
        print('Processing document: ${doc.id}');
        final order = OrderModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        print('Parsed order: ${order.id} with ${order.items.length} items');
        return order;
      }).toList();

      print('Total orders fetched: ${orders.length}');
    } catch (e) {
      print('Error fetching orders: $e');
      throw e;
    }
  }

  Future<List<OrderModel>> fetchOrdersByUser(String userId) async {
    orders = await _orderServices.getOrdersByUser(userId);
    return orders;
  }

  Future<OrderModel?> fetchOrderById(String id) async {
    return await _orderServices.getOrderById(id);
  }

  Future<void> updateOrderStatus(String id, String status) async {
    await _orderServices.updateOrderStatus(id, status);
    // refresh local list
    await fetchOrders();
  }

  Future<void> deleteOrder(String id) async {
    await _orderServices.deleteOrder(id);
    await fetchOrders();
  }
}
