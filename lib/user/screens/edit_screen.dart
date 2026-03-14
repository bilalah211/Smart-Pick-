import 'dart:io';

import 'package:ecommerceapp/user/screens/payment_method.dart';
import 'package:ecommerceapp/user/services/cloudinary_services/cloudinary_services.dart';
import 'package:ecommerceapp/user/view_model/auth_view_model.dart';
import 'package:ecommerceapp/user/widgets/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class EditScreen extends StatefulWidget {
  final String fullName;
  final String email;
  final dynamic image;

  const EditScreen({
    super.key,
    required this.image,
    required this.email,
    required this.fullName,
  });

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  bool _isLoading = false;
  final CloudinaryServices _cloudinaryServices = CloudinaryServices();
  final AuthViewModel _authViewModel = AuthViewModel();

  final id = FirebaseAuth.instance.currentUser!.uid;
  File? image;

  void _pickImage() async {
    final pickedFile = await _cloudinaryServices.pickImage();
    if (pickedFile != null) {
      setState(() {
        image = pickedFile;
      });
    }
  }

  void updateProfile() async {
    // Validate name and email
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Name and email can't be empty"),
        ),
      );
      return;
    }

    // Check if user selected a new image
    if (image == null && widget.image.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orange,
          content: Text("Please select a profile image"),
        ),
      );
      return;
    }

    // Start loading
    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl = widget.image;

      // Upload new image if selected
      if (image != null) {
        imageUrl = await _cloudinaryServices.uploadImageToCloudinary(image!);
      }

      // Check if image upload failed
      if (imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text("Image upload failed!"),
          ),
        );
        return;
      }

      // Update Firestore
      await _authViewModel.updateUserProfile(name: name, imageUrl: imageUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Profile updated successfully!",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Error updating profile: $error"),
        ),
      );
    } finally {
      // Stop loading
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.fullName ?? '';
    _emailController.text = widget.email ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Color(0xfff6f7fb),
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              _buildHeader(context, height, width, isDark),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      SizedBox(height: 15),
                      // Profile Picture
                      _buildProfilePicture(height, width, isDark),

                      SizedBox(height: 24),

                      // Personal Information Section
                      _buildPersonalInfoSection(isDark),

                      SizedBox(height: 32),

                      // Update Button
                      CustomButton(
                        title: 'Update Profile',
                        onTap: updateProfile,
                        backgroundColor: Colors.blue,
                        // Disable when loading
                      ),

                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SpinKitFadingCircle(color: Colors.blue[700]!, size: 50.0),
                      SizedBox(height: 16),
                      Text(
                        'Updating Profile...',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    double height,
    double width,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.only(left: 5, right: 10, top: 55, bottom: 10),
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
              onTap: _isLoading ? null : () => Navigator.pop(context),
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
              'Edit Profile',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            // Spacer(),
            // Container(
            //   height: 38,
            //   width: 38,
            //   decoration: BoxDecoration(
            //     color: isDark ? Colors.grey[700] : Colors.white,
            //     borderRadius: BorderRadius.circular(12),
            //     boxShadow: [
            //       BoxShadow(
            //         color: Colors.black.withValues(alpha: 0.1),
            //         blurRadius: 6,
            //         offset: Offset(0, 2),
            //       ),
            //     ],
            //   ),
            //   child: Icon(
            //     Iconsax.setting,
            //     size: 20,
            //     color: isDark ? Colors.white : Colors.black87,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicture(double height, double width, bool isDark) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue[700]!, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: image != null
                    ? Image.file(image!, fit: BoxFit.cover)
                    : (widget.image.isNotEmpty
                          ? Image.network(widget.image, fit: BoxFit.cover)
                          : Container(
                              color: Colors.blue[100],
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.blue[700],
                              ),
                            )),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _isLoading
                    ? null
                    : _showImagePickerDialog, // Disable when loading
                child: Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.grey[900]! : Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.camera, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Text(
          'Tap to change photo',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Update your personal details',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
        ),
        SizedBox(height: 24),

        // Name Field
        _buildTextField(
          label: 'Full Name',
          controller: _nameController,
          prefixIcon: Icons.person,
          isDark: isDark,
          enabled: !_isLoading, // Disable when loading
        ),

        // // Email Field
        // _buildTextField(
        //   label: 'Email Address',
        //   controller: _emailController,
        //   prefixIcon: Icons.sms,
        //   isDark: isDark,
        //   keyboardType: TextInputType.emailAddress,
        //   enabled: !_isLoading, // Disable when loading
        // ),
        //
        // SizedBox(height: 16),
        //
        // // Old Password Field
        // _buildPasswordField(
        //   label: 'Old Password',
        //   controller: _oldPasswordController,
        //   isDark: isDark,
        //   obscureText: _obscureOldPassword,
        //   onToggle: _isLoading
        //       ? null
        //       : () {
        //           setState(() {
        //             _obscureOldPassword = !_obscureOldPassword;
        //           });
        //         },
        //   enabled: !_isLoading, // Disable when loading
        // ),
        //
        // SizedBox(height: 16),
        //
        // // New Password Field
        // _buildPasswordField(
        //   label: 'New Password',
        //   controller: _newPasswordController,
        //   isDark: isDark,
        //   obscureText: _obscureNewPassword,
        //   onToggle: _isLoading
        //       ? null
        //       : () {
        //           setState(() {
        //             _obscureNewPassword = !_obscureNewPassword;
        //           });
        //         },
        //   enabled: !_isLoading,
        // ),
        SizedBox(height: 24),

        // Additional Options
        // _buildAdditionalOptions(isDark),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData prefixIcon,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
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
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        style: GoogleFonts.poppins(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.grey[500]),
          prefixIcon: Container(
            margin: EdgeInsets.only(left: 16, right: 12),
            child: Icon(prefixIcon, color: Colors.blue[700], size: 22),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isDark,
    required bool obscureText,
    required VoidCallback? onToggle,
    bool enabled = true,
  }) {
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
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        enabled: enabled,
        style: GoogleFonts.poppins(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.grey[500]),
          prefixIcon: Container(
            margin: EdgeInsets.only(left: 16, right: 12),
            child: Icon(Icons.lock, color: Colors.blue[700], size: 22),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off_outlined : Icons.visibility,
              color: Colors.grey[500],
              size: 20,
            ),
            onPressed: onToggle,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  // Widget _buildAdditionalOptions(bool isDark) {
  //   final options = [
  //     {
  //       'title': 'Payment Methods',
  //       'icon': Icons.wallet,
  //       'color': Colors.green,
  //       'onTap': () {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => PaymentMethodScreen()),
  //         );
  //       },
  //     },
  //     {'title': 'Privacy Settings', 'icon': Icons.lock, 'color': Colors.orange},
  //     {
  //       'title': 'Notification Preferences',
  //       'icon': Icons.notification_add,
  //       'color': Colors.purple,
  //       'onTap': () {},
  //     },
  //   ];
  //
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'More Settings',
  //         style: GoogleFonts.poppins(
  //           fontSize: 18,
  //           fontWeight: FontWeight.w600,
  //           color: isDark ? Colors.white : Colors.black87,
  //         ),
  //       ),
  //       SizedBox(height: 16),
  //       ...options.map((option) {
  //         return Container(
  //           margin: EdgeInsets.only(bottom: 12),
  //           decoration: BoxDecoration(
  //             color: isDark ? Colors.grey[800] : Colors.white,
  //             borderRadius: BorderRadius.circular(16),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.black.withValues(alpha: 0.05),
  //                 blurRadius: 8,
  //                 offset: Offset(0, 2),
  //               ),
  //             ],
  //           ),
  //           child: ListTile(
  //             leading: Container(
  //               height: 40,
  //               width: 40,
  //               decoration: BoxDecoration(
  //                 color: (option['color'] as Color).withValues(alpha: 0.1),
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               child: Icon(
  //                 option['icon'] as IconData,
  //                 color: option['color'] as Color,
  //                 size: 20,
  //               ),
  //             ),
  //             title: Text(
  //               option['title'] as String,
  //               style: GoogleFonts.poppins(
  //                 fontWeight: FontWeight.w500,
  //                 color: isDark ? Colors.white : Colors.black87,
  //               ),
  //             ),
  //             trailing: Container(
  //               height: 32,
  //               width: 32,
  //               decoration: BoxDecoration(
  //                 color: isDark ? Colors.grey[700] : Colors.grey[100],
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               child: Icon(
  //                 Icons.arrow_forward_ios,
  //                 size: 16,
  //                 color: isDark ? Colors.grey[400] : Colors.grey[600],
  //               ),
  //             ),
  //             onTap: _isLoading ? null : () {},
  //           ),
  //         );
  //       }),
  //     ],
  //   );
  // }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Change Profile Photo',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageOption(
                    icon: Icons.camera,
                    text: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      // Add camera functionality
                    },
                  ),
                  _buildImageOption(
                    icon: Icons.browse_gallery,
                    text: 'Gallery',
                    onTap: () async {
                      Navigator.pop(context);
                      _pickImage();
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.blue[700], size: 30),
          ),
          SizedBox(height: 8),
          Text(text, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
