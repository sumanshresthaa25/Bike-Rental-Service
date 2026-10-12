import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/bike_model.dart';
import '../provider/bike_provider.dart';
import '../screens/bike_detail_screen.dart';
import '../utils/app_constants.dart';
import 'app_snack_bar.dart';
import 'bike_image.dart';
import 'confirm_delete_dialog.dart';
import 'image_action_button.dart';

class BikeCard extends StatelessWidget {
  final BikeModel bike;

  const BikeCard({super.key, required this.bike});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => BikeDetailScreen(bike: bike)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  BikeImage(image: bike.image),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: ImageActionButton(
                      tooltip: bike.isFavorite
                          ? "Remove from favourites"
                          : "Add to favourites",
                      icon: bike.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: bike.isFavorite
                          ? Colors.redAccent
                          : Colors.black87,
                      onPressed: () async {
                        final success = await context
                            .read<BikeProvider>()
                            .toggleFavourite(bike);
                        if (!context.mounted || success) return;
                        showAppSnackBar(context, "Failed to update favourite.");
                      },
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.categoryOverlay,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        VehicleCategory.labelFor(bike.category),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bike.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    bike.model,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${AppText.pricePrefix} ${bike.pricePerDay.toStringAsFixed(0)}/day",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: "Delete",
                        visualDensity: VisualDensity.compact,
                        iconSize: 18,
                        onPressed: () => _deleteBike(context),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteBike(BuildContext context) async {
    final shouldDelete = await confirmDeleteBike(context, bike.name);
    if (!shouldDelete || !context.mounted) return;

    final success = await context.read<BikeProvider>().deleteBike(bike);
    if (!context.mounted || success) return;

    showAppSnackBar(context, "Failed to delete bike. Try again.");
  }
}
