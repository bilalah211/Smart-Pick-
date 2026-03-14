import 'package:flutter/material.dart';

class SquareContainer extends StatelessWidget {
  const SquareContainer({
    super.key,
    required this.height,
    required this.width,
    this.child,
  });

  final double height;
  final double width;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,

      decoration: BoxDecoration(
        color: Color(0xfff6f7fb),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(20),
        child: child,
      ),
    );
  }
}
