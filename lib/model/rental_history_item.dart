import '../utils/app_constants.dart';

class RentalHistoryItem {
  final String id;
  final String userEmail;
  final String? vehicleId;
  final String vehicleName;
  final String vehicleModel;
  final String vehicleCategory;
  final String vehicleImage;
  final double pricePerDay;
  final double bookingCharge;
  final DateTime rentedAt;

  const RentalHistoryItem({
    required this.id,
    required this.userEmail,
    required this.vehicleId,
    required this.vehicleName,
    required this.vehicleModel,
    required this.vehicleCategory,
    required this.vehicleImage,
    required this.pricePerDay,
    required this.bookingCharge,
    required this.rentedAt,
  });

  double get totalForOneDay => pricePerDay + bookingCharge;

  String get categoryLabel => VehicleCategory.labelFor(vehicleCategory);

  factory RentalHistoryItem.fromJson(Map<String, dynamic> json) {
    return RentalHistoryItem(
      id: json["id"]?.toString() ?? "",
      userEmail: json["user_email"]?.toString() ?? "",
      vehicleId: json["vehicle_id"]?.toString(),
      vehicleName: json["vehicle_name"]?.toString() ?? "Unknown Vehicle",
      vehicleModel: json["vehicle_model"]?.toString() ?? "",
      vehicleCategory:
          json["vehicle_category"]?.toString() ?? VehicleCategory.bike,
      vehicleImage: json["vehicle_image"]?.toString() ?? "",
      pricePerDay: (json["price_per_day"] ?? 0).toDouble(),
      bookingCharge: (json["booking_charge"] ?? 0).toDouble(),
      rentedAt:
          DateTime.tryParse(json["rented_at"]?.toString() ?? "") ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user_email": userEmail,
      "vehicle_id": vehicleId,
      "vehicle_name": vehicleName,
      "vehicle_model": vehicleModel,
      "vehicle_category": vehicleCategory,
      "vehicle_image": vehicleImage,
      "price_per_day": pricePerDay,
      "booking_charge": bookingCharge,
      "rented_at": rentedAt.toIso8601String(),
    };
  }
}
