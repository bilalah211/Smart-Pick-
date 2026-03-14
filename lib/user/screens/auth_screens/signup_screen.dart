import 'dart:io';
import 'package:ecommerceapp/user/services/cloudinary_services/cloudinary_services.dart';
import 'package:ecommerceapp/user/utils/my_snackbar.dart';
import 'package:ecommerceapp/user/view_model/auth_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/images_url.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_outline_button.dart';
import '../../widgets/custom_textfield.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? image;
  final AuthViewModel _authVM = AuthViewModel();
  final CloudinaryServices _cloudinaryServices = CloudinaryServices();
  bool isHideText = true;
  bool isHideConfirmText = true;
  bool agreeToTerms = false;

  Future<void> signUpUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!agreeToTerms) {
      MySnackBar.showSnackBar(
        context,
        const Text('Please agree to the terms and conditions'),
        Colors.red,
      );
      return;
    }

    if (image == null) {
      MySnackBar.showSnackBar(
        context,
        const Text('Please select your profile image'),
        Colors.red,
      );
      return;
    }

    setState(() {
      _authVM.setLoading(true);
    });

    try {
      final user = await _authVM.signUpWithEmailAndPassword(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
        image,
      );

      if (user != null) {
        MySnackBar.showSnackBar(
          context,
          const Text('Account created successfully!'),
          Colors.green,
        );

        // Navigate to login after success
        Future.delayed(const Duration(milliseconds: 1500), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        });
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage =
              'This email is already registered. Please log in instead.';
          break;
        case 'weak-password':
          errorMessage =
              'Password is too weak. Please choose a stronger password.';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address.';
          break;
        default:
          errorMessage = e.message ?? 'An error occurred during sign up.';
      }

      MySnackBar.showSnackBar(context, Text(errorMessage), Colors.red);
    } catch (e) {
      MySnackBar.showSnackBar(
        context,
        Text('Unexpected error: $e'),
        Colors.red,
      );
    } finally {
      setState(() {
        _authVM.setLoading(false);
      });
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade200, Color(0xFFEFF4FF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.03),

                  // Header Text
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Create Account',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Join us and start your shopping journey',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.025),

                  // Profile Image Picker
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.greenAccent.shade100,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: image != null
                                ? Image.file(image!, fit: BoxFit.cover)
                                : Container(
                                    color: Colors.grey[200],
                                    child: Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                          ),
                        ),

                        // Add/Edit Photo Button
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () async {
                                final pickedImage = await _cloudinaryServices
                                    .pickImage();
                                if (pickedImage != null) {
                                  setState(() {
                                    image = pickedImage;
                                  });
                                }
                              },
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),

                        // Remove Photo Button (only when image is selected)
                        if (image != null)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              height: 30,
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    image = null;
                                  });
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.025),

                  // Form
                  Form(
                    key: _formKey,
                    child: Card(
                      color: Color(0xfff5f6fb),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            CustomTextField(
                              controller: nameController,
                              hintText: 'Full Name',
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: Colors.grey[600],
                              ),
                              validator: _validateName,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                            ),
                            const SizedBox(height: 16),

                            CustomTextField(
                              controller: emailController,
                              hintText: 'Email Address',
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: Colors.grey[600],
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                            ),
                            const SizedBox(height: 16),

                            CustomTextField(
                              controller: passwordController,
                              hintText: 'Password',
                              isHide: isHideText,
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colors.grey[600],
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isHideText
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(() {
                                    isHideText = !isHideText;
                                  });
                                },
                              ),
                              validator: _validatePassword,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                            ),
                            const SizedBox(height: 16),

                            CustomTextField(
                              controller: cPasswordController,
                              hintText: 'Confirm Password',
                              isHide: isHideConfirmText,
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colors.grey[600],
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isHideConfirmText
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(() {
                                    isHideConfirmText = !isHideConfirmText;
                                  });
                                },
                              ),
                              validator: _validateConfirmPassword,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Terms and Conditions
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: agreeToTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      agreeToTerms = value!;
                                    });
                                  },
                                  activeColor: Colors.blue,
                                  checkColor: Colors.white,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w400,
                                      ),
                                      children: [
                                        const TextSpan(text: 'I agree to the '),
                                        TextSpan(
                                          text: 'Terms & Conditions',
                                          style: GoogleFonts.poppins(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const TextSpan(text: ' and '),
                                        TextSpan(
                                          text: 'Privacy Policy',
                                          style: GoogleFonts.poppins(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: size.height * 0.04),

                            // Sign Up Button
                            CustomButton(
                              isLoading: _authVM.isLoading,
                              title: 'Create Account',
                              onTap: signUpUser,
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              borderRadius: 12,
                              height: 56,
                            ),
                            SizedBox(height: size.height * 0.04),

                            // Or Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey[300],
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    'or continue with',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey[300],
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: size.height * 0.04),

                            // Social Login Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: CustomOutlineButton(
                                    title: 'Google',
                                    onTap: () {},
                                    image: ImageUrls.google,
                                    borderColor: Colors.grey[300]!,
                                    textColor: Colors.grey[700]!,
                                    borderRadius: 12,
                                    height: 54,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: CustomOutlineButton(
                                    title: 'Apple',
                                    onTap: () {},
                                    image: ImageUrls.apple,
                                    borderColor: Colors.grey[300]!,
                                    textColor: Colors.grey[700]!,
                                    borderRadius: 12,
                                    height: 54,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: size.height * 0.04),

                            // Login Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Sign In',
                                    style: GoogleFonts.poppins(
                                      color: Colors.blue,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
