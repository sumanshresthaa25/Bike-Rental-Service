import 'package:flutter/material.dart';

Future<bool> confirmDeleteBike(BuildContext context, String bikeName) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Delete bike?"),
      content: Text("Are you sure you want to delete $bikeName?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text("Delete"),
        ),
      ],
    ),
  );

  return shouldDelete == true;
}
