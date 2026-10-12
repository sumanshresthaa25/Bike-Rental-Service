import 'package:flutter/material.dart';

import '../utils/app_constants.dart';

class VehicleCategorySelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  final String bikeLabel;
  final String scooterLabel;

  const VehicleCategorySelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.bikeLabel = VehicleCategory.bikeLabel,
    this.scooterLabel = VehicleCategory.scooterLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: [
        ButtonSegment(
          value: VehicleCategory.bike,
          icon: const Icon(Icons.two_wheeler),
          label: Text(bikeLabel),
        ),
        ButtonSegment(
          value: VehicleCategory.scooter,
          icon: const Icon(Icons.electric_moped),
          label: Text(scooterLabel),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
