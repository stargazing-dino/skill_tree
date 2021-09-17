import 'package:flutter/material.dart';

class TriangleClipper extends CustomClipper<Path> {
  const TriangleClipper({required this.axisDirection});

  final AxisDirection axisDirection;

  @override
  Path getClip(Size size) {
    final path = Path();

    switch (axisDirection) {
      case AxisDirection.up:
        path.moveTo(size.width / 2, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        break;
      case AxisDirection.right:
        path.moveTo(size.width, size.height / 2);
        path.lineTo(0, size.height);
        path.lineTo(0, 0);
        break;
      case AxisDirection.down:
        path.lineTo(size.width / 2, size.height);
        path.lineTo(size.width, 0);
        path.lineTo(0, 0);
        break;
      case AxisDirection.left:
        path.moveTo(0, size.height / 2);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        break;
    }

    return path;
  }

  @override
  bool shouldReclip(TriangleClipper oldClipper) => false;
}
