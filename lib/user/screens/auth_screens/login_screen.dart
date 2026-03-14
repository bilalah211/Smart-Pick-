import 'package:ecommerceapp/admin/screens/admin_home_screen.dart';
import 'package:ecommerceapp/admin/screens/admin_login_screen.dart';
import 'package:ecommerceapp/user/screens/auth_screens/signup_screen.dart';
import 'package:ecommerceapp/user/utils/my_snackbar.dart';
import 'package:ecommerceapp/user/view_model/auth_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/images_url.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_outline_button.dart';
import '../../widgets/custom_textfield.dart';
import '../home_screen.dart';
import 'reset_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthViewModel _authVM = AuthViewModel();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isHideText = true;
  bool rememberMe = false;

  // Form validation methods
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }

    // Email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    return null;
  }

  Future<void> loginUser() async {
    // Validate form before proceeding
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _authVM.setLoading(true);
    });

    try {
      final user = await _authVM.loginWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {
        MySnackBar.showSnackBar(
          context,
          const Text('Login Successful! Welcome back!'),
          Colors.green,
        );

        // Navigate after a short delay to show success message
        Future.delayed(const Duration(milliseconds: 1500), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        });
      }
    } on FirebaseAuthException catch (e) {
      //Handle Firebase-specific errors
      String message;
      switch (e.code) {
        case "user-not-found":
          message = "No account found with this email address.";
          break;
        case "wrong-password":
          message = "Incorrect password. Please try again.";
          break;
        case "invalid-credential":
          message =
              "Invalid login credentials. Please check your email and password.";
          break;
        case "invalid-email":
          message = "The email address is badly formatted.";
          break;
        case "user-disabled":
          message = "This user account has been disabled.";
          break;
        case "too-many-requests":
          message = "Too many login attempts. Please try again later.";
          break;
        case "network-request-failed":
          message = "Network error. Please check your internet connection.";
          break;
        default:
          message = e.message ?? "Login failed. Please try again.";
      }

      MySnackBar.showSnackBar(context, Text(message), Colors.red);
    } catch (e) {
      //Handle unexpected errors
      MySnackBar.showSnackBar(
        context,
        const Text("An unexpected error occurred. Please try again."),
        Colors.red,
      );
    } finally {
      setState(() {
        _authVM.setLoading(false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Header Text
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome Back!',
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to continue your shopping journey',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.black45,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.05),

                    // Form Fields
                    Card(
                      color: Color(0xfff5f6fb),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            // Email Field
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
                            const SizedBox(height: 20),

                            // Password Field
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
                              onFieldSubmitted: (_) => loginUser(),
                            ),
                            const SizedBox(height: 20),

                            // Remember Me & Forgot Password
                            Row(
                              children: [
                                // Remember Me Checkbox
                                Checkbox(
                                  value: rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      rememberMe = value!;
                                    });
                                  },
                                  activeColor: Colors.blue,
                                  checkColor: Colors.white,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),

                                const SizedBox(width: 12),
                                Text(
                                  'Remember me',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                const Spacer(),

                                // Forgot Password
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ResetPasswordScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: const Color(0xFF1A237E),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: size.height * 0.05),

                            // Login Button
                            CustomButton(
                              isLoading: _authVM.isLoading,
                              title: 'Sign In',
                              onTap: loginUser,
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
                            SizedBox(height: size.height * 0.06),

                            // Sign Up Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Don\'t have an account? ',
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
                                            const SignupScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Sign Up',
                                    style: GoogleFonts.poppins(
                                      color: Colors.blue,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdminLoginScreen(),
                                ),
                              ),
                              child: Text(
                                'Admin Login →',
                                style: GoogleFonts.poppins(
                                  color: Colors.black45,
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
          ),
        ),
      ),
    );
  }
}
