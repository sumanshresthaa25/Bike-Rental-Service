import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/bike_model.dart';
import '../model/rental_history_item.dart';
import '../provider/auth_provider.dart';
import '../provider/bike_provider.dart';
import '../provider/rental_history_provider.dart';
import '../utils/app_constants.dart';
import '../widgets/bike_card.dart';
import '../widgets/bike_image.dart';
import '../widgets/profile_stat_tile.dart';
import '../widgets/vehicle_category_selector.dart';
import 'add_bike_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedSection = 0;
  String _selectedCategory = VehicleCategory.bike;
  final _sectionTitles = const [
    "Bike Rental Service",
    "Categories",
    "Favourites",
    "Profile",
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<BikeProvider>().getBikes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<BikeProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.bikes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.bikes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 40,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    const Text("Couldn't load bikes."),
                    const SizedBox(height: 8),
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.getBikes(),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.getBikes,
            child: _buildSection(provider),
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedSection,
        onDestinationSelected: (index) {
          setState(() => _selectedSection = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category),
            label: "Category",
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: "Favourites",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AddBikeScreen()));
          if (!context.mounted) return;
          context.read<BikeProvider>().getBikes();
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Bike"),
      ),
    );
  }

  String get _title {
    return _sectionTitles[_selectedSection];
  }

  Widget _buildSection(BikeProvider provider) {
    if (_selectedSection == 1) {
      return _categorySection(provider);
    }

    if (_selectedSection == 2) {
      return _bikeGrid(
        provider.favouriteBikes,
        emptyMessage: "No favourite bikes yet.",
      );
    }

    if (_selectedSection == 3) {
      return _profileSection(provider);
    }

    return _bikeGrid(
      provider.bikes,
      emptyMessage: "No bikes available right now.",
    );
  }

  Widget _categorySection(BikeProvider provider) {
    final bikes = provider.bikesByCategory(_selectedCategory);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: VehicleCategorySelector(
              selected: _selectedCategory,
              bikeLabel: VehicleCategory.bikesLabel,
              scooterLabel: VehicleCategory.scootersLabel,
              onChanged: (category) {
                setState(() => _selectedCategory = category);
              },
            ),
          ),
        ),
        ..._gridSlivers(
          bikes,
          emptyMessage: "No ${_selectedCategory}s available.",
        ),
      ],
    );
  }

  Widget _bikeGrid(List<BikeModel> bikes, {required String emptyMessage}) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: _gridSlivers(bikes, emptyMessage: emptyMessage),
    );
  }

  List<Widget> _gridSlivers(
    List<BikeModel> bikes, {
    required String emptyMessage,
  }) {
    if (bikes.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: Text(emptyMessage)),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.all(12),
        sliver: SliverGrid.builder(
          itemCount: bikes.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 240,
            mainAxisExtent: 244,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) => BikeCard(bike: bikes[index]),
        ),
      ),
    ];
  }

  Widget _profileSection(BikeProvider provider) {
    final auth = context.watch<AuthProvider>();
    final rentalHistory = context.watch<RentalHistoryProvider>();
    final history = rentalHistory.historyFor(auth.email);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        const CircleAvatar(radius: 42, child: Icon(Icons.person, size: 42)),
        const SizedBox(height: 14),
        const Center(
          child: Text(
            "Rental Manager",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ),
        if (auth.email != null) ...[
          const SizedBox(height: 6),
          Center(
            child: Text(
              auth.email!,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ],
        const SizedBox(height: 24),
        ProfileStatTile(
          icon: Icons.two_wheeler,
          label: "Total vehicles",
          value: provider.bikes.length.toString(),
        ),
        ProfileStatTile(
          icon: Icons.electric_moped,
          label: "Scooters",
          value: provider
              .bikesByCategory(VehicleCategory.scooter)
              .length
              .toString(),
        ),
        ProfileStatTile(
          icon: Icons.favorite,
          label: "Favourites",
          value: provider.favouriteBikes.length.toString(),
        ),
        ProfileStatTile(
          icon: Icons.history,
          label: "Rented",
          value: history.length.toString(),
        ),
        const SizedBox(height: 18),
        const Text(
          "History",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        if (rentalHistory.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          )
        else if (history.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black12),
            ),
            child: Text(
              "No rented vehicles yet.",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          )
        else
          ...history.map(_historyTile),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _confirmLogout,
          icon: const Icon(Icons.logout),
          label: const Text("Logout"),
        ),
      ],
    );
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Logout?"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !mounted) return;
    await context.read<AuthProvider>().logout();
  }

  Widget _historyTile(RentalHistoryItem item) {
    final rentalDate = MaterialLocalizations.of(
      context,
    ).formatShortDate(item.rentedAt);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.black12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 72,
                height: 58,
                child: BikeImage(image: item.vehicleImage),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.vehicleName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "${item.vehicleModel} • ${item.categoryLabel}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Rented on $rentalDate",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "${AppText.pricePrefix} ${item.totalForOneDay.toStringAsFixed(0)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
