import '../utils/app_constants.dart';

class BikeModel {
  // MockAPI assigns ids as strings (e.g. "1", "2", ...).
  final String? id;
  final String name;
  final String model;
  final String category;
  final double pricePerDay;
  final double bookingCharge;
  final String image;
  final bool isFavorite;

  BikeModel({
    this.id,
    required this.name,
    required this.model,
    this.category = VehicleCategory.bike,
    required this.pricePerDay,
    required this.bookingCharge,
    required this.image,
    this.isFavorite = false,
  });

  factory BikeModel.fromJson(Map<String, dynamic> json) {
    final name = json["name"] ?? "Unknown Bike";
    final model = json["model"] ?? "";

    return BikeModel(
      id: json["id"]?.toString(),
      name: name,
      model: model,
      category: _normalizedCategory(json["category"], name, model),
      pricePerDay: (json["price_per_day"] ?? 0).toDouble(),
      bookingCharge: (json["booking_charge"] ?? 0).toDouble(),
      image: json["image"] ?? "",
      isFavorite: json["is_favorite"] == true,
    );
  }

  // Used for POST (create) / PUT (update) request bodies.
  // "id" is intentionally omitted -- MockAPI assigns/keeps it via the URL.
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "model": model,
      "category": category,
      "price_per_day": pricePerDay,
      "booking_charge": bookingCharge,
      "image": image,
      "is_favorite": isFavorite,
    };
  }

  BikeModel copyWith({
    String? name,
    String? model,
    String? category,
    double? pricePerDay,
    double? bookingCharge,
    String? image,
    bool? isFavorite,
  }) {
    return BikeModel(
      id: id,
      name: name ?? this.name,
      model: model ?? this.model,
      category: category ?? this.category,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      bookingCharge: bookingCharge ?? this.bookingCharge,
      image: image ?? this.image,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  static String _normalizedCategory(dynamic value, String name, String model) {
    final raw = value?.toString().toLowerCase().trim();
    if (raw == VehicleCategory.scooter || raw == "scooters") {
      return VehicleCategory.scooter;
    }
    if (raw == VehicleCategory.bike || raw == "bikes") {
      return VehicleCategory.bike;
    }

    final searchable = "$name $model".toLowerCase();
    final isScooter = VehicleCategory.scooterKeywords.any(searchable.contains);

    if (isScooter) {
      return VehicleCategory.scooter;
    }

    return VehicleCategory.bike;
  }
}
