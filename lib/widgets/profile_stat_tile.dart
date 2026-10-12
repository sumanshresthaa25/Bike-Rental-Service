import 'package:flutter/material.dart';

class ProfileStatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileStatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: Text(
        value,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
