import 'package:flutter/material.dart';

class MySnackBar {
  static void showSnackBar(context, Widget content, Color colors) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: colors,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: content,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
        ),
      );
}
