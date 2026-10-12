import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'provider/auth_provider.dart';
import 'provider/bike_provider.dart';
import 'provider/rental_history_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BikeProvider()),
        ChangeNotifierProvider(create: (_) => RentalHistoryProvider()),
      ],
      child: const BikeRentalApp(),
    ),
  );
}
