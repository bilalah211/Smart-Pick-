import 'package:ecommerceapp/user/screens/checkout_screens/shipping_details_screen.dart';
import 'package:ecommerceapp/user/view_model/cart_view_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../../admin/models/products_model.dart';
import '../models/cart_model.dart';
import '../utils/my_snackbar.dart';

class DescriptionScreen extends StatefulWidget {
  final ProductModel products;

  const DescriptionScreen({super.key, required this.products});

  @override
  State<DescriptionScreen> createState() => _DescriptionScreenState();
}

class _DescriptionScreenState extends State<DescriptionScreen> {
  final CartViewModel _cartViewModel = CartViewModel();
  int _quantity = 1;

  Future<void> _addToCart() async {
    if (widget.products.id == null || widget.products.id.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Product ID is missing')));
      return;
    }

    try {
      final cartItem = CartItemModel(
        productId: widget.products.id,
        title: widget.products.title,
        price: widget.products.price,
        imageUrl: widget.products.imageUrl,
        quantity: _quantity,
        discount: widget.products.discount.toDouble(),
      );

      await _cartViewModel.addCart(cartItem);
      setState(() {});

      MySnackBar.showSnackBar(
        context,
        const Text('Added to Cart Successfully!!'),
        Colors.green,
      );
    } catch (e) {
      MySnackBar.showSnackBar(
        context,
        Text('Failed to add to cart: $e'),
        Colors.green,
      );
    }
  }

  void _shareProduct() async {
    try {
      final String shareText =
          '''

${widget.products.title}
Price: \$${_formatPrice(widget.products.price)}
 ${widget.products.description}

Product Image: ${widget.products.imageUrl}

Get yours today! 
''';

      final box = context.findRenderObject() as RenderBox?;

      await SharePlus.instance.share(
        ShareParams(
          text: shareText,
          subject: 'Check out ${widget.products.title}',
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (e) {
      // Copy to clipboard if sharing fails
      _copyToClipboard();
    }
  }

  void _copyToClipboard() {
    final String shareText =
        '''
Check out this amazing product! 🛍

 ${widget.products.title}
Price: \$${_formatPrice(widget.products.price)}
${widget.products.description}

Get yours today! 
''';

    Clipboard.setData(ClipboardData(text: shareText));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Product details copied to clipboard! '),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(
                    left: 5,
                    right: 5,
                    top: 60,
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            height: height * 0.040,
                            width: width * 0.09,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(-2, 0),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.arrow_back_ios_new, size: 16),
                          ),
                        ),
                      ),
                      Text(
                        'Details',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      // Share Button
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: _shareProduct,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            height: height * 0.040,
                            width: width * 0.09,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(-2, 0),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.share_outlined, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    Container(
                      height: height * 0.3,
                      width: width * 0.90,
                      margin: EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 25,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        boxShadow: [BoxShadow(color: Colors.black12)],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        height: height * 0.3,
                        width: width * 0.90,
                        margin: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Image.network(
                          widget.products.imageUrl,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      right: 8,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 10,
                        ),
                        height: height * 0.045,
                        width: width * 0.10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(-2, 0),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.favorite_border_outlined, size: 16),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: height * 0.5,
                  width: width,
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(40),
                      topLeft: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.products.title,
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            '\$${_formatPrice(widget.products.price)}',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Spacer(),
                          Container(
                            height: height * 0.05,
                            width: width * 0.28,
                            decoration: BoxDecoration(
                              color: Color(0xfff6f7fb),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5,
                                  offset: Offset(5, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (_quantity > 1) {
                                      setState(() {
                                        _quantity--;
                                      });
                                    }
                                  },
                                  child: Container(
                                    height: height * 0.045,
                                    width: width * 0.09,
                                    margin: EdgeInsets.symmetric(
                                      vertical: 5,
                                      horizontal: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xffffffff),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 2,
                                          offset: Offset(-2, -2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(Icons.remove, size: 16),
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  _quantity.toString(),
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Spacer(),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _quantity++;
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                      vertical: 5,
                                      horizontal: 7,
                                    ),
                                    height: height * 0.040,
                                    width: width * 0.09,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 2,
                                          offset: Offset(-2, -2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Description',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        widget.products.description,
                        textAlign: TextAlign.start,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(width: 20),
                SizedBox(
                  height: height * 0.06,
                  width: width * 0.43,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.065,
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.black26),
                    ),
                    child: InkWell(
                      onTap: _addToCart,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: height * 0.037,
                            width: width * 0.08,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(-2, 0),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Center(child: Icon(Icons.add, size: 20)),
                          ),
                          SizedBox(width: 7),
                          Center(
                            child: Text(
                              'Add to Cart',
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            label: '',
            icon: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                // Convert price from String to double
                final productPrice =
                    double.tryParse(widget.products.price.toString()) ?? 0.0;

                // Create a cart item from the current product
                final cartItem = CartItemModel(
                  productId: widget.products.id,
                  title: widget.products.title,
                  price: productPrice,
                  // Use the converted double
                  imageUrl: widget.products.imageUrl,
                  quantity: _quantity,
                  discount: widget.products.discount.toDouble(),
                );

                // Calculate prices - now using double
                final subTotal = productPrice * _quantity;
                final discount = 0.0;
                final totalPrice = subTotal - discount;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShippingDetailsScreen(
                      cartItems: [cartItem],
                      totalPrice: totalPrice,
                      subTotal: subTotal,
                      discount: discount,
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: height * 0.06,
                    width: width * 0.42,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.065,
                      width: MediaQuery.of(context).size.width * 0.6,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.black26),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.white,
                          ),
                          SizedBox(width: 5),
                          Center(
                            child: Text(
                              'Buy Now',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
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

  // Helper method to format price correctly
  String _formatPrice(dynamic price) {
    if (price == null) return '0.00';

    // Convert to double first
    double numericPrice;
    if (price is String) {
      numericPrice = double.tryParse(price) ?? 0.0;
    } else if (price is int) {
      numericPrice = price.toDouble();
    } else if (price is double) {
      numericPrice = price;
    } else {
      numericPrice = 0.0;
    }

    // Format to remove unnecessary decimal places
    if (numericPrice == numericPrice.truncateToDouble()) {
      return numericPrice.toStringAsFixed(2);
    } else {
      return numericPrice.toStringAsFixed(2);
    }
  }
}
