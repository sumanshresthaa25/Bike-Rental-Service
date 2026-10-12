import 'package:flutter/material.dart';
import 'package:bike_rental_service/model/bike_model.dart';
import 'package:bike_rental_service/service/bike_service.dart';

class BikeProvider extends ChangeNotifier {
  BikeProvider({BikeService? apiService})
    : _apiService = apiService ?? BikeService();

  final BikeService _apiService;

  final List<BikeModel> _bikes = [];

  List<BikeModel> get bikes => List.unmodifiable(_bikes);

  List<BikeModel> get favouriteBikes =>
      _bikes.where((bike) => bike.isFavorite).toList();

  List<BikeModel> bikesByCategory(String category) =>
      _bikes.where((bike) => bike.category == category).toList();

  bool isLoading = false;
  String? errorMessage;

  /// GET -- refresh the full bike list.
  Future<void> getBikes() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final remoteBikes = await _apiService.fetchBikes();
      _bikes
        ..clear()
        ..addAll(remoteBikes);
    } catch (e) {
      errorMessage = e.toString();
      debugPrint(errorMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// POST -- create a new bike and add it to the local list.
  Future<bool> addBike(BikeModel bike) async {
    try {
      final created = await _apiService.createBike(bike);
      _bikes.add(created);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      debugPrint(errorMessage);
      notifyListeners();
      return false;
    }
  }

  /// PUT -- update an existing bike and reflect the change locally.
  Future<bool> updateBike(BikeModel bike) async {
    try {
      final updated = await _apiService.updateBike(bike);
      final index = _bikes.indexWhere((b) => b.id == updated.id);
      if (index != -1) {
        _bikes[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      errorMessage = e.toString();
      debugPrint(errorMessage);
      notifyListeners();
      return false;
    }
  }

  /// PUT -- favourite changes are persisted to the API immediately.
  Future<bool> toggleFavourite(BikeModel bike) async {
    return updateBike(bike.copyWith(isFavorite: !bike.isFavorite));
  }

  /// DELETE -- remove the bike remotely and then from local state.
  Future<bool> deleteBike(BikeModel bike) async {
    if (bike.id == null) {
      errorMessage = "Cannot delete a bike with no id.";
      notifyListeners();
      return false;
    }

    try {
      await _apiService.deleteBike(bike.id!);
      _bikes.removeWhere((item) => item.id == bike.id);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      debugPrint(errorMessage);
      notifyListeners();
      return false;
    }
  }
}
