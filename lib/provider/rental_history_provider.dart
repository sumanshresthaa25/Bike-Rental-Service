import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/bike_model.dart';
import '../model/rental_history_item.dart';

class RentalHistoryProvider extends ChangeNotifier {
  static const _historyKey = "rental_history";

  final List<RentalHistoryItem> _history = [];
  bool _isLoading = true;

  RentalHistoryProvider() {
    _loadHistory();
  }

  bool get isLoading => _isLoading;
  List<RentalHistoryItem> get history => List.unmodifiable(_history);

  List<RentalHistoryItem> historyFor(String? email) {
    if (email == null || email.trim().isEmpty) return [];

    final normalizedEmail = email.trim().toLowerCase();
    return _history
        .where((item) => item.userEmail == normalizedEmail)
        .toList(growable: false);
  }

  Future<void> addRental({
    required String userEmail,
    required BikeModel bike,
  }) async {
    final rental = RentalHistoryItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      userEmail: userEmail.trim().toLowerCase(),
      vehicleId: bike.id,
      vehicleName: bike.name,
      vehicleModel: bike.model,
      vehicleCategory: bike.category,
      vehicleImage: bike.image,
      pricePerDay: bike.pricePerDay,
      bookingCharge: bike.bookingCharge,
      rentedAt: DateTime.now(),
    );

    _history.insert(0, rental);
    await _saveHistory();
    notifyListeners();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawHistory = prefs.getString(_historyKey);
      if (rawHistory != null && rawHistory.trim().isNotEmpty) {
        final data = jsonDecode(rawHistory);
        if (data is List) {
          _history
            ..clear()
            ..addAll(
              data.whereType<Map<String, dynamic>>().map(
                RentalHistoryItem.fromJson,
              ),
            );
        }
      }
    } catch (error) {
      debugPrint("Failed to load rental history: $error");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _history.map((item) => item.toJson()).toList();
    await prefs.setString(_historyKey, jsonEncode(data));
  }
}
