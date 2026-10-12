import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/bike_model.dart';
import '../provider/auth_provider.dart';
import '../provider/bike_provider.dart';
import '../provider/rental_history_provider.dart';
import '../utils/app_constants.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/bike_image.dart';
import '../widgets/confirm_delete_dialog.dart';
import 'edit_bike_screen.dart';

class BikeDetailScreen extends StatefulWidget {
  final BikeModel bike;

  const BikeDetailScreen({super.key, required this.bike});

  @override
  State<BikeDetailScreen> createState() => _BikeDetailScreenState();
}

class _BikeDetailScreenState extends State<BikeDetailScreen> {
  late BikeModel _bike;

  @override
  void initState() {
    super.initState();
    _bike = widget.bike;
  }

  void _showRentConfirmation() {
    final total = _bike.pricePerDay + _bike.bookingCharge;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Rent this bike?"),
        content: Text(
          "You're about to rent the ${_bike.name} (${_bike.model}) at "
          "${AppText.pricePrefix} ${_bike.pricePerDay.toStringAsFixed(0)}/day plus a one-time "
          "booking charge of ${AppText.pricePrefix} ${_bike.bookingCharge.toStringAsFixed(0)}.\n\n"
          "Estimated total for 1 day: ${AppText.pricePrefix} ${total.toStringAsFixed(0)}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final email = context.read<AuthProvider>().email;
              if (email == null) {
                showAppSnackBar(context, "Please log in before renting.");
                return;
              }

              final historyProvider = context.read<RentalHistoryProvider>();
              final bikeName = _bike.name;
              await historyProvider.addRental(userEmail: email, bike: _bike);
              if (!mounted) return;
              showAppSnackBar(context, "$bikeName reserved!");
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditScreen() async {
    final updatedBike = await Navigator.of(context).push<BikeModel>(
      MaterialPageRoute(builder: (_) => EditBikeScreen(bike: _bike)),
    );

    if (updatedBike != null && mounted) {
      setState(() => _bike = updatedBike);
      showAppSnackBar(context, "Bike details updated.");
    }
  }

  Future<void> _toggleFavourite() async {
    final updatedBike = _bike.copyWith(isFavorite: !_bike.isFavorite);
    final success = await context.read<BikeProvider>().updateBike(updatedBike);
    if (!mounted) return;

    if (success) {
      setState(() => _bike = updatedBike);
    } else {
      showAppSnackBar(context, "Failed to update favourite.");
    }
  }

  Future<void> _deleteBike() async {
    final shouldDelete = await confirmDeleteBike(context, _bike.name);
    if (!shouldDelete || !mounted) return;

    final success = await context.read<BikeProvider>().deleteBike(_bike);
    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
    } else {
      showAppSnackBar(context, "Failed to delete bike. Try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(
                  _bike.isFavorite ? Icons.favorite : Icons.favorite_border,
                ),
                tooltip: _bike.isFavorite
                    ? "Remove from favourites"
                    : "Add to favourites",
                onPressed: _toggleFavourite,
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: "Edit bike",
                onPressed: _openEditScreen,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: "Delete",
                onPressed: _deleteBike,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: BikeImage(image: _bike.image),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _bike.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(_bike.model),
                        visualDensity: VisualDensity.compact,
                      ),
                      Chip(
                        avatar: Icon(
                          VehicleCategory.iconFor(_bike.category),
                          size: 16,
                        ),
                        label: Text(VehicleCategory.labelFor(_bike.category)),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${AppText.pricePrefix} ${_bike.pricePerDay.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          "/ day",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "+ ${AppText.pricePrefix} ${_bike.bookingCharge.toStringAsFixed(0)} one-time booking charge",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _showRentConfirmation,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("Rent Now"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
