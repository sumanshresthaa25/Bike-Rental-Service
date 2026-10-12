import 'package:flutter/material.dart';

class ImageActionButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const ImageActionButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(20),
      child: IconButton(
        tooltip: tooltip,
        visualDensity: VisualDensity.compact,
        iconSize: 20,
        color: color,
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }
}
