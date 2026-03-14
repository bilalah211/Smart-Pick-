import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../models/onboarding_screen_model.dart';
import '../widgets/custom_button.dart';
import 'auth_screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  children: onBoardingItems.map((item) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(item.imageUrl),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          item.subTitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(fontSize: 15),
                        ),
                      ],
                    );
                  }).toList(),
                  onPageChanged: (index) {
                    currentIndex = index;
                    setState(() {});
                  },
                ),
              ),

              currentIndex == 2
                  ? CustomButton(
                      title: 'Get Started',
                      backgroundColor: Colors.blue,
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                    )
                  : AnimatedSmoothIndicator(
                      count: onBoardingItems.length,
                      activeIndex: currentIndex,
                      effect: ExpandingDotsEffect(
                        activeDotColor: Colors.indigoAccent,
                        dotWidth: 15,
                        dotHeight: 14,
                      ),
                    ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
