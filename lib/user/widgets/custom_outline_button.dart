import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/images_url.dart';

class CustomOutlineButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final String image;
  final Color borderColor;
  final Color textColor;
  final double borderRadius;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final double elevation;

  const CustomOutlineButton({
    super.key,
    required this.title,
    required this.onTap,
    required this.image,
    this.borderColor = Colors.grey,
    this.textColor = Colors.grey,
    this.borderRadius = 12,
    this.height,
    this.width,
    this.backgroundColor,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 54,
      width: width ?? MediaQuery.of(context).size.width * 0.4,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          if (elevation > 0)
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: elevation,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: Colors.grey.withOpacity(0.1),
          highlightColor: Colors.grey.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  image,
                  height: 24,
                  width: 24,
                  color: image == ImageUrls.apple ? textColor : null,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
