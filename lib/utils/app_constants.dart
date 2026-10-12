import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const primary = Color(0xFF38BDF8);
  static const surface = Color(0xFFF0F9FF);
  static const imageFallback = Color(0xFFF1F3F5);
  static const categoryOverlay = Color(0x9E000000);
}

class VehicleCategory {
  const VehicleCategory._();

  static const bike = "bike";
  static const scooter = "scooter";

  static const bikeLabel = "Bike";
  static const scooterLabel = "Scooter";
  static const bikesLabel = "Bikes";
  static const scootersLabel = "Scooters";

  static const scooterKeywords = [
    "scooter",
    "scooty",
    "vespa",
    "honda grazia",
    "grazia",
    "aprilia sr",
    "aprilia storm",
    "storm",
    "yamaha ray zr",
    "ray zr",
    "tvs jupiter",
    "jupiter",
    "ntorq",
  ];

  static bool getIsScooter(String category) => category == scooter;

  static String labelFor(String category) {
    return getIsScooter(category) ? scooterLabel : bikeLabel;
  }

  static IconData iconFor(String category) {
    return getIsScooter(category) ? Icons.electric_moped : Icons.two_wheeler;
  }
}

class AppText {
  const AppText._();

  static const pricePrefix = "Rs.";
}
