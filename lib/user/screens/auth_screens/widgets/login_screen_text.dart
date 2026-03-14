import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginText extends StatelessWidget {
  final String text;
  const LoginText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.bold),
      ),
    );
  }
}
