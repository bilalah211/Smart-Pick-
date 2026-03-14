import 'package:ecommerceapp/admin/screens/admin_order_history_screen.dart';
import 'package:ecommerceapp/admin/screens/user_screen.dart';
import 'package:ecommerceapp/admin/screens/widgets/custom_drawer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_login_screen.dart';
import 'all_product_screen.dart';
import 'categories_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _userCount = 0;
  int _productCount = 0;
  int _orderCount = 0;
  int _categoryCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _loadCurrentAdmin();
  }

  Future<void> _loadCurrentAdmin() async {
    setState(() {});
  }

  Future<void> _loadDashboardData() async {
    try {
      final usersSnapshot = await _firestore.collection('Users').get();

      final productsSnapshot = await _firestore.collection('Products').get();

      final categoriesSnapshot = await _firestore
          .collection('Categories')
          .get();

      final ordersSnapshot = await _firestore.collection('orders').get();

      setState(() {
        _userCount = usersSnapshot.docs.length;
        _productCount = productsSnapshot.docs.length;
        _categoryCount = categoriesSnapshot.docs.length;
        _orderCount = ordersSnapshot.docs.length;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading dashboard data: $e');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _logoutAdmin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      key: _scaffoldKey,
      drawer: CustomDrawer(),
      body: Column(
        children: [
          // Header
          _buildHeader(context),

          // Stats Overview
          _buildStatsOverview(),
          // Dashboard Grid
          Expanded(child: _buildDashboardGrid()),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(
            left: 20,
            right: 5,
            top: 65,
            bottom: 10,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue, Color(0xFFEFF5FF)],
            ),
          ),
          child: Row(
            children: [
              // Menu Button
              _buildMenuButton(),
              SizedBox(width: 50),
              // Title and Admin Info
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Dashboard',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // User Count Badge
              // _buildUserCountBadge(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton() {
    return GestureDetector(
      onTap: () => _scaffoldKey.currentState!.openDrawer(),
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(-2, 0),
            ),
          ],
        ),
        child: Icon(Icons.menu, size: 20, color: Colors.blue),
      ),
    );
  }

  // Widget _buildUserCountBadge() {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //     decoration: BoxDecoration(
  //       color: Colors.blue,
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: _isLoading
  //         ? SizedBox(
  //             width: 16,
  //             height: 16,
  //             child: CircularProgressIndicator(
  //               strokeWidth: 2,
  //               color: Colors.white,
  //             ),
  //           )
  //         : Text(
  //             '$_userCount users',
  //             style: GoogleFonts.poppins(
  //               color: Colors.white,
  //               fontSize: 12,
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //   );
  // }

  Widget _buildStatsOverview() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),

          child: Column(
            children: [
              Text(
                'Store Overview',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Users',
                    _userCount,
                    Icons.people,
                    Colors.blue,
                  ),
                  _buildStatItem(
                    'Products',
                    _productCount,
                    Icons.shopping_bag,
                    Colors.green,
                  ),
                  _buildStatItem(
                    'Categories',
                    _categoryCount,
                    Icons.category,
                    Colors.orange,
                  ),
                  _buildStatItem(
                    'Orders',
                    _orderCount,
                    Icons.shopping_cart,
                    Colors.purple,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, int count, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        SizedBox(height: 8),
        Text(
          _isLoading ? '...' : count.toString(),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildDashboardGrid() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildDashboardCard(
            'Products',
            Icons.shopping_bag,
            Colors.blue,
            'Manage store products',
            '$_productCount products',
            () {
              // Navigate to ProductsScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductsScreen()),
              );
            },
          ),
          _buildDashboardCard(
            'Categories',
            Icons.category,
            Colors.green,
            'Manage categories',
            '$_categoryCount categories',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategoriesScreen()),
              );
            },
          ),
          _buildDashboardCard(
            'Users',
            Icons.people,
            Colors.purple,
            'Manage users',
            '$_userCount users',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UsersScreen()),
              );
            },
          ),
          _buildDashboardCard(
            'Orders',
            Icons.shopping_cart,
            Colors.orange,
            'View all orders',
            '$_orderCount orders',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminOrderHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    String title,
    IconData icon,
    Color color,
    String subtitle,
    String countText,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon with count
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 30, color: color),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Title
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),

              // Count
              Text(
                countText,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),

              // Subtitle
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoonSnackbar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
