import 'package:ecommerceapp/user/models/cart_model.dart';
import 'package:ecommerceapp/user/screens/checkout_screens/shipping_details_screen.dart';
import 'package:ecommerceapp/user/view_model/cart_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartViewModel _cartVM = CartViewModel();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Color(0xfff6f7fb),

      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 5, top: 55, bottom: 10),

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
              padding: const EdgeInsets.only(left: 18, top: 10),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: height * 0.040,
                      width: width * 0.09,
                      decoration: BoxDecoration(
                        color: Color(0xffffffff),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(-2, 0),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.arrow_back_ios_new, size: 22),
                    ),
                  ),
                  SizedBox(width: 105),
                  Text(
                    'My Cart',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<CartItemModel>?>(
              stream: _cartVM.getCart(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: SpinKitFadingCircle(
                      size: 40,
                      color: Colors.blue[700]!,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Something went wrong',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Your cart is empty',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add some items to get started',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final cartItems = snapshot.data!;
                final uid = FirebaseAuth.instance.currentUser!.uid;

                return Column(
                  children: [
                    // Cart Items List
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.all(16),
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 12),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return _buildCartItem(
                            item,
                            index,
                            uid,
                            height,
                            width,
                            isDark,
                          );
                        },
                      ),
                    ),

                    // Checkout Summary
                    _buildCheckoutSummary(cartItems, width, isDark),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
    CartItemModel item,
    int index,
    String uid,
    double height,
    double width,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Product Image
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.image, color: Colors.grey[400]),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 16),

                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '\$${item.price}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.blue[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Total: ',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Spacer(),
                          _buildQuantityControls(item, uid, isDark),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Delete Button
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              height: height * 0.040,
              width: width * 0.09,
              decoration: BoxDecoration(
                color: Color(0xffffffff),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(-2, 0),
                  ),
                ],
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: Icon(Iconsax.trash, size: 16, color: Colors.red),
                onPressed: () {
                  _cartVM.removeCart(item.productId);
                  setState(() {});
                },
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControls(CartItemModel item, String uid, bool isDark) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[700] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Decrease Button
          Container(
            width: 32,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[600] : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.remove, size: 16),
              onPressed: () async {
                if (item.quantity > 1) {
                  final updatedItem = CartItemModel(
                    productId: item.productId,
                    title: item.title,
                    price: item.price,
                    imageUrl: item.imageUrl,
                    quantity: item.quantity - 1,
                    discount: item.discount,
                  );
                  await _cartVM.updateCart(updatedItem, uid, item.productId);
                } else {
                  await _cartVM.removeCart(item.productId);
                }
                setState(() {});
              },
              padding: EdgeInsets.zero,
            ),
          ),

          // Quantity Display
          Container(
            width: 40,
            color: Colors.transparent,
            child: Center(
              child: Text(
                item.quantity.toString(),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),

          // Increase Button
          Container(
            width: 32,
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: IconButton(
              icon: Icon(Icons.add, size: 16, color: Colors.white),
              onPressed: () async {
                final updatedItem = CartItemModel(
                  productId: item.productId,
                  title: item.title,
                  price: item.price,
                  imageUrl: item.imageUrl,
                  quantity: item.quantity + 1,
                  discount: item.discount,
                );
                await _cartVM.updateCart(updatedItem, uid, item.productId);
                setState(() {});
              },
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSummary(
    List<CartItemModel> cartItems,
    double width,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Price Breakdown
          _buildPriceRow(
            label: 'Subtotal',
            value: _cartVM.subTotal(cartItems),
            isDark: isDark,
          ),
          SizedBox(height: 8),
          _buildPriceRow(
            label: 'Discount',
            value: -_cartVM.discount(cartItems),
            isDark: isDark,
            valueColor: Colors.green,
          ),
          SizedBox(height: 8),
          _buildPriceRow(
            label: 'Shipping',
            value: 10,
            isDark: isDark,
            valueColor: Colors.green,
          ),
          SizedBox(height: 12),
          Divider(color: isDark ? Colors.grey[600] : Colors.grey[300]),
          SizedBox(height: 12),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                '\$${_cartVM.totalPrice(cartItems)}',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Checkout Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShippingDetailsScreen(
                      totalPrice: _cartVM.totalPrice(cartItems),
                      cartItems: cartItems,
                      subTotal: _cartVM.subTotal(cartItems),
                      discount: _cartVM.discount(cartItems),
                    ),
                    // builder: (context) => CheckoutScreen(
                    //   totalPrice: _cartVM.totalPrice(cartItems),
                    //   cartItems: cartItems,
                    //   subTotal: _cartVM.subTotal(cartItems),
                    //   discount: _cartVM.discount(cartItems),
                    // ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.shopping_bag, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Proceed to Checkout',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow({
    required String label,
    required double value,
    required bool isDark,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        Text(
          value == 0 ? 'Free' : '\$${value.toStringAsFixed(2)}',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: valueColor ?? (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ],
    );
  }
}
