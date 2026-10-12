import 'package:flutter/material.dart';

class AppLoading extends StatelessWidget {
  final double size;
  final double strokeWidth;

  const AppLoading({super.key, this.size = 18, this.strokeWidth = 2});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(strokeWidth: strokeWidth),
    );
  }
}
