import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  int _selectedFilter = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;
  bool _isLoading = true;

  final List<String> _filters = [
    'All',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled',
  ];

  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (_user == null) {
        if (kDebugMode) {
          print('No user logged in');
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (kDebugMode) {
        print('Fetching orders for user: ${_user.uid}');
      }

      final List<QuerySnapshot<Map<String, dynamic>>> snapshots =
          await Future.wait([
            // Try Users/{uid}/orders
            _firestore
                .collection('Users')
                .doc(_user.uid)
                .collection('orders')
                .get(),
            // Try Users/{uid}/Orders (capital O)
            _firestore
                .collection('Users')
                .doc(_user.uid)
                .collection('Orders')
                .get(),
            _firestore
                .collection('orders')
                .where('userId', isEqualTo: _user.uid)
                .get(),
          ], eagerError: true);

      List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs = [];
      String collectionPath = '';

      for (int i = 0; i < snapshots.length; i++) {
        if (snapshots[i].docs.isNotEmpty) {
          allDocs = snapshots[i].docs;
          collectionPath = i == 0
              ? 'Users/orders'
              : i == 1
              ? 'Users/Orders'
              : 'orders';
          if (kDebugMode) {
            print('Found ${allDocs.length} orders in $collectionPath');
          }
          break;
        }
      }

      if (allDocs.isEmpty) {
        if (kDebugMode) {
          print('No orders found in any collection');
        }
        setState(() {
          _orders = [];
          _isLoading = false;
        });
        return;
      }

      // Sort manually on client side
      allDocs.sort((a, b) {
        final aDate = a.data()['createdAt'] as Timestamp?;
        final bDate = b.data()['createdAt'] as Timestamp?;
        if (aDate == null || bDate == null) return 0;
        return bDate.compareTo(aDate);
      });

      setState(() {
        _orders = allDocs.map((doc) {
          final data = doc.data();
          if (kDebugMode) {
            print('Order data for ${doc.id}: $data');
          }

          return {
            'id': doc.id,
            'orderId':
                data['orderId'] ??
                data['orderID'] ??
                '#ORD-${doc.id.substring(0, 8).toUpperCase()}',
            'date': _formatDate(
              data['createdAt'] ?? data['orderDate'] ?? data['timestamp'],
            ),
            'items': _getItemCount(data),
            'total': _getTotalAmount(data),
            'status': _getStatus(data),
            'statusColor': _getStatusColor(_getStatus(data)),
            'itemsList': _parseItems(data),
            'createdAt': data['createdAt'],
            'collectionPath': collectionPath,
          };
        }).toList();
        _isLoading = false;
      });

      if (kDebugMode) {
        print('Successfully loaded ${_orders.length} orders');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching orders: $e');
      }
      setState(() {
        _isLoading = false;
        _orders = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading orders: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int _getItemCount(Map<String, dynamic> data) {
    if (data['items'] != null && data['items'] is List) {
      return (data['items'] as List).length;
    }
    if (data['products'] != null && data['products'] is List) {
      return (data['products'] as List).length;
    }
    if (data['cartItems'] != null && data['cartItems'] is List) {
      return (data['cartItems'] as List).length;
    }
    return 0;
  }

  double _getTotalAmount(Map<String, dynamic> data) {
    if (data['totalAmount'] != null) {
      return (data['totalAmount'] as num).toDouble();
    }
    if (data['total'] != null) {
      return (data['total'] as num).toDouble();
    }
    if (data['grandTotal'] != null) {
      return (data['grandTotal'] as num).toDouble();
    }

    // Calculate total from items if available
    final items = _parseItems(data);
    if (items.isNotEmpty) {
      double calculatedTotal = 0.0;
      for (final item in items) {
        calculatedTotal += (item['price'] * item['quantity']);
      }
      return calculatedTotal;
    }

    return 0.0;
  }

  String _getStatus(Map<String, dynamic> data) {
    if (data['status'] != null) {
      return data['status'].toString();
    }
    if (data['orderStatus'] != null) {
      return data['orderStatus'].toString();
    }
    return 'Processing';
  }

  List<Map<String, dynamic>> _parseItems(Map<String, dynamic> data) {
    // Try different possible field names for items
    dynamic items = data['items'] ?? data['products'] ?? data['cartItems'];

    if (items == null) return [];

    if (items is List) {
      return items.map((item) {
        if (item is Map<String, dynamic>) {
          return {
            'name':
                item['title'] ??
                item['name'] ??
                item['productName'] ??
                'Unknown Product',
            'price':
                (item['price'] ??
                        item['productPrice'] ??
                        item['unitPrice'] ??
                        0)
                    .toDouble(),
            'quantity': item['quantity'] ?? item['qty'] ?? 1,
            'imageUrl':
                item['imageUrl'] ?? item['image'] ?? item['productImage'],
            'productId': item['productId'] ?? item['id'],
          };
        }
        return {'name': 'Unknown Product', 'price': 0.0, 'quantity': 1};
      }).toList();
    }
    return [];
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'shipped':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown Date';

    if (date is Timestamp) {
      final dateTime = date.toDate();
      return '${_getMonthName(dateTime.month)} ${dateTime.day}, ${dateTime.year}';
    }

    if (date is DateTime) {
      return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
    }

    if (date is String) {
      return date;
    }

    return 'Unknown Date';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  // Check if order can be cancelled
  bool _canCancelOrder(Map<String, dynamic> order) {
    final status = order['status'].toString().toLowerCase();
    // Allow cancellation only for processing and pending orders
    return status == 'processing' || status == 'pending';
  }

  List<Map<String, dynamic>> get _filteredOrders {
    if (_selectedFilter == 0) return _orders;
    final status = _filters[_selectedFilter];
    return _orders.where((order) => order['status'] == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(
              left: 5,
              right: 5,
              top: 55,
              bottom: 10,
            ),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: 5,
                  offset: Offset(0, 1),
                  color: Colors.black.withValues(alpha: 0.1),
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade200, Color(0xFFEFF5FF)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 38,
                      width: 38,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 20,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(width: 90),
                  Text(
                    'Order History',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filter Chips
          Container(
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.asMap().entries.map((entry) {
                  final index = entry.key;
                  final filter = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      backgroundColor: isDark ? Colors.grey[700] : Colors.white,
                      label: Text(
                        filter,
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      selected: _selectedFilter == index,
                      selectedColor: Colors.blue.withValues(alpha: 0.2),
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = index;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Orders List with loading state
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SpinKitFadingCircle(size: 40, color: Colors.blue),
                        SizedBox(height: 16),
                        Text(
                          'Loading orders...',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : _filteredOrders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No orders found',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Your order history will appear here',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _fetchOrders,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchOrders,
                    color: Colors.blue,
                    child: ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(16),
                      itemCount: _filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = _filteredOrders[index];
                        return _buildOrderCard(order, isDark);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, bool isDark) {
    final canCancel = _canCancelOrder(order);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Order Header
          ListTile(
            leading: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.shopping_bag, color: Colors.blue, size: 20),
            ),
            title: Text(
              order['orderId'],
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              order['date'],
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: order['statusColor'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                order['status'],
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: order['statusColor'],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Order Items
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: (order['itemsList'] as List).take(2).map<Widget>((
                item,
              ) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: item['imageUrl'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item['imageUrl'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.image,
                                      color: Colors.grey[400],
                                    );
                                  },
                                ),
                              )
                            : Icon(Icons.image, color: Colors.grey[400]),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Qty: ${item['quantity']}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // Show more items indicator
          if ((order['itemsList'] as List).length > 2)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '+ ${(order['itemsList'] as List).length - 2} more items',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          // Order Footer
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order['items']} items',
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
                Text(
                  '\$${order['total'].toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _viewOrderDetails(order);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('View Details'),
                  ),
                ),
                SizedBox(width: 12),
                if (order['status'] == 'Delivered')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _reorderItems(order);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Reorder'),
                    ),
                  ),
                if (canCancel)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _showCancelOrderDialog(order);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel Order',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _viewOrderDetails(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => OrderDetailsSheet(
        order: order,
        onCancelOrder: _canCancelOrder(order)
            ? () {
                Navigator.pop(context);
                _showCancelOrderDialog(order);
              }
            : null,
      ),
    );
  }

  void _showCancelOrderDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Cancel Order?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to cancel this order?'),
            SizedBox(height: 8),
            Text(
              'Order: ${order['orderId']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'This action cannot be undone.',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No, Keep Order'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelOrder(order);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Yes, Cancel Order'),
          ),
        ],
      ),
    );
  }

  void _cancelOrder(Map<String, dynamic> order) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final orderId = order['id'];
      final collectionPath = order['collectionPath'];

      if (kDebugMode) {
        print('Cancelling order $orderId from $collectionPath');
      }

      DocumentReference orderRef;
      if (collectionPath == 'Users/orders') {
        orderRef = _firestore
            .collection('Users')
            .doc(_user!.uid)
            .collection('orders')
            .doc(orderId);
      } else if (collectionPath == 'Users/Orders') {
        orderRef = _firestore
            .collection('Users')
            .doc(_user!.uid)
            .collection('Orders')
            .doc(orderId);
      } else {
        orderRef = _firestore.collection('orders').doc(orderId);
      }

      // Update order status to cancelled
      await orderRef.update({
        'status': 'Cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
        'cancelledBy': 'customer',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Restore product quantities if needed
      await _restoreProductQuantities(order);

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order cancelled successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Refresh orders list
      _fetchOrders();
    } catch (e) {
      if (kDebugMode) {
        print('Error cancelling order: $e');
      }
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _restoreProductQuantities(Map<String, dynamic> order) async {
    try {
      final items = order['itemsList'] as List;

      for (final item in items) {
        final productId = item['productId'];
        final quantity = item['quantity'];

        if (productId != null) {
          // Get current product quantity
          final productDoc = await _firestore
              .collection('products')
              .doc(productId.toString())
              .get();

          if (productDoc.exists) {
            final currentStock = productDoc.data()!['stockQuantity'] ?? 0;
            final newStock = currentStock + quantity;

            // Update product stock
            await _firestore
                .collection('products')
                .doc(productId.toString())
                .update({
                  'stockQuantity': newStock,
                  'updatedAt': FieldValue.serverTimestamp(),
                });

            if (kDebugMode) {
              print('Restored $quantity units for product $productId');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error restoring product quantities: $e');
      }
    }
  }

  void _reorderItems(Map<String, dynamic> order) {
    // TODO: Implement reorder functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reorder functionality coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class OrderDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback? onCancelOrder;

  const OrderDetailsSheet({super.key, required this.order, this.onCancelOrder});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canCancel = onCancelOrder != null;

    return Container(
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Details',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Order Info
          _buildDetailRow('Order ID', order['orderId']),
          _buildDetailRow('Order Date', order['date']),
          _buildDetailRow('Status', order['status']),
          _buildDetailRow('Items', '${order['items']} items'),
          _buildDetailRow(
            'Total Amount',
            '\$${order['total'].toStringAsFixed(2)}',
          ),

          SizedBox(height: 20),
          Divider(),
          SizedBox(height: 20),

          // Order Items
          Text(
            'Order Items',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 12),

          ...(order['itemsList'] as List).map((item) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: item['imageUrl'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item['imageUrl'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.image,
                                  color: Colors.grey[400],
                                );
                              },
                            ),
                          )
                        : Icon(Icons.image, color: Colors.grey[400]),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'],
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Qty: ${item['quantity']}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),

          SizedBox(height: 20),
          Divider(),
          SizedBox(height: 20),

          // Cancel Order Button (if applicable)
          if (canCancel)
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onCancelOrder,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cancel, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Cancel This Order',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'You can cancel this order as it\'s still being processed',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
              ],
            ),

          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.poppins(color: Colors.grey[600])),
          Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
