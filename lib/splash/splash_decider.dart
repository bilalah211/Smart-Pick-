import 'package:ecommerceapp/user/screens/auth_screens/login_screen.dart';
import 'package:ecommerceapp/user/screens/home_screen.dart';
import 'package:ecommerceapp/user/screens/onboarding_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashDecider extends StatefulWidget {
  const SplashDecider({super.key});

  @override
  State<SplashDecider> createState() => _SplashDeciderState();
}

class _SplashDeciderState extends State<SplashDecider> {
  late Widget _screen = Scaffold(
    body: Center(child: SpinKitFadingCircle(size: 50, color: Colors.white)),
  );
  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final _sp = await SharedPreferences.getInstance();
    final _auth = FirebaseAuth.instance;
    final isFirstTime = _sp.getBool('isFirstTime') ?? true;
    User? user = _auth.currentUser;
    if (isFirstTime) {
      _sp.setBool('isFirstTime', false);
      setState(() {
        _screen = OnboardingScreen();
      });
    } else if (user != null) {
      setState(() {
        _screen = HomeScreen();
      });
    } else {
      setState(() {
        _screen = LoginScreen();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _screen;
  }
}
