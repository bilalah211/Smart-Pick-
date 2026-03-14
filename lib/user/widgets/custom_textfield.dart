import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final dynamic controller;
  final Icon? prefixIcon;
  final Widget? suffixIcon;
  final bool? filled;
  final Color? fillColor;
  final InputBorder? border;
  final int? maxLines;
  final bool isHide;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final EdgeInsetsGeometry? contentPadding;
  final bool? enabled;
  final String? Function(String?)? validator;
  final ValueChanged? onFieldSubmitted;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.filled,
    this.fillColor,
    this.border,
    this.maxLines,
    this.isHide = false,
    this.onTap,
    this.keyboardType,
    this.contentPadding,
    this.enabled,
    this.validator,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        onFieldSubmitted: onFieldSubmitted,
        maxLines: maxLines ?? 1,
        obscureText: isHide,
        keyboardType: keyboardType,
        enabled: enabled ?? true,
        validator: validator,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: Colors.grey[800],
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          filled: filled ?? true,
          hintText: hintText,
          fillColor: fillColor ?? Colors.white,
          hintStyle: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[500],
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon != null
              ? InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(20),
                  child: suffixIcon,
                )
              : null,
          contentPadding:
              contentPadding ??
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          border:
              border ??
              OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
          enabledBorder:
              border ??
              OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
        ),
      ),
    );
  }
}
