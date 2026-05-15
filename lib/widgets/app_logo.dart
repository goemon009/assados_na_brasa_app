import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.width = 180,
  });

  final double width;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: width,
      fit: BoxFit.contain,
      semanticLabel: 'Logo Assados na Brasa',
      filterQuality: FilterQuality.high,
    );
  }
}
