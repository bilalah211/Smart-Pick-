import 'package:ecommerceapp/user/screens/checkout_screens/checkout_screen.dart';
import 'package:ecommerceapp/user/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../admin/services/order_services.dart';
import '../../models/cart_model.dart';

class ShippingDetailsScreen extends StatefulWidget {
  final List<CartItemModel> cartItems;
  final double totalPrice;
  final double subTotal;
  final double discount;
  final Map<String, String>? shippingDetails;

  const ShippingDetailsScreen({
    super.key,
    required this.cartItems,
    required this.totalPrice,
    required this.subTotal,
    required this.discount,
    this.shippingDetails,
  });

  @override
  State<ShippingDetailsScreen> createState() => _ShippingDetailsScreenState();
}

class _ShippingDetailsScreenState extends State<ShippingDetailsScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();

  bool _isLoading = false;

  final OrderServices _orderServices = OrderServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(context),
            SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildPersonalInformationSection(),
            ),

            SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildShippingAddressDetails(),
            ),
            SizedBox(height: 35),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  height: 50,
                  child: CustomButton(
                    backgroundColor: Colors.blue,
                    title: _isLoading ? 'Processing...' : 'Checkout',
                    onTap: _isLoading
                        ? null
                        : () async {
                            if (_validateForm()) {
                              await _handleCheckout();
                            }
                          },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateForm() {
    if (_fullNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _zipCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  Map<String, String> _getShippingDetails() {
    return {
      'fullName': _fullNameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'address': _addressController.text,
      'city': _cityController.text,
      'zipCode': _zipCodeController.text,
    };
  }

  Future<void> _handleCheckout() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Please log in to continue.')));
        setState(() => _isLoading = false);
        return;
      }

      final shippingDetails = _getShippingDetails();

      await _orderServices.saveOrder(
        userId: user.uid,
        cartItems: widget.cartItems,
        totalPrice: widget.totalPrice,
        subTotal: widget.subTotal,
        discount: widget.discount,
        shippingDetails: shippingDetails,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order placed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutScreen(
            cartItems: widget.cartItems,
            totalPrice: widget.totalPrice,
            subTotal: widget.subTotal,
            discount: widget.discount,
            shippingDetails: shippingDetails,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ----- UI COMPONENTS -----

  Widget _buildPersonalInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Your basic contact details',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
        ),
        SizedBox(height: 20),
        _buildTextField(
          prefixIcon: Iconsax.user,
          controller: _fullNameController,
          label: 'Full Name *',
          hintText: 'Enter Your Full Name',
        ),
        SizedBox(height: 8),
        _buildTextField(
          prefixIcon: Iconsax.sms,
          controller: _emailController,
          label: 'Email Address *',
          hintText: 'your.email@example.com',
        ),
        SizedBox(height: 8),
        _buildTextField(
          prefixIcon: Iconsax.call,
          controller: _phoneController,
          label: 'Phone Number *',
          hintText: '+1 234 567 8900',
        ),
      ],
    );
  }

  Widget _buildShippingAddressDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shipping Address',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Where should we deliver your order?',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
        ),
        SizedBox(height: 20),
        _buildTextField(
          label: 'Street Address *',
          controller: _addressController,
          prefixIcon: Icons.home,
          hintText: '123 Main Street, Apt 4B',
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildTextField(
                label: 'City *',
                controller: _cityController,
                prefixIcon: Icons.location_city,
                hintText: 'Abu Dhabi',
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: _buildTextField(
                label: 'ZIP Code *',
                controller: _zipCodeController,
                prefixIcon: Icons.numbers,
                hintText: '10001',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required IconData prefixIcon,
    required TextEditingController controller,
    required String label,
    String hintText = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
        SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.poppins(color: Colors.black87, fontSize: 16),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
              prefixIcon: Icon(prefixIcon, color: Colors.blue[700], size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection(context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Column(
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
              colors: [Colors.blue.shade200, Color(0xFFEFF5FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => Navigator.pop(context),
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
                    child: Icon(Icons.arrow_back_ios_new),
                  ),
                ),
                SizedBox(width: 50),
                Text(
                  'Shipping Details',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue[100]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Complete Your Order',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  'Please provide your shipping details to proceed with checkout. '
                  'We need this information to deliver your order to the right address '
                  'and contact you if needed.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.blue[800],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
