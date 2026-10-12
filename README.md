# Bike Rental Service (Flutter)

A simple Flutter app that lists bikes from an API and lets you view, add, and edit them.

## What's included
- `lib/model/bike_model.dart` — Bike data model (fromJson / toJson / copyWith)
- `lib/service/bike_service.dart` — GET, POST, PUT calls to the MockAPI backend
- `lib/provider/bike_provider.dart` — state management: getBikes, addBike, updateBike
- `lib/screens/home_screen.dart` — bike list + "Add Bike" floating action button
- `lib/screens/add_bike_screen.dart` — form to create a new bike (POST)
- `lib/screens/bike_detail_screen.dart` — bike details, Rent Now, and an edit icon to update pricing (PUT)
- `lib/widgets/bike_card.dart` — list item card

## Setup
This only contains the Dart source + `pubspec.yaml`, not the native android/ios scaffolding.
To run it:

1. Create a fresh Flutter project:
   ```
   flutter create bike_rental_service
   ```
2. Replace the generated `pubspec.yaml` and `lib/` folder with the ones from this package.
3. Install dependencies and run:
   ```
   flutter pub get
   flutter run
   ```
No API token needed — see below.

## Note on the API
The app talks to a real, hosted REST backend on MockAPI.io — full CRUD, real persistence:
```
Base URL: https://6a806e0aec7a640e63abc1f5.mockapi.io/api/v1/bikes
```
- **GET** `/bikes` — fetch the full bike list (shown on the home screen)
- **POST** `/bikes` — create a new bike (the "Add Bike" floating button)
- **PUT** `/bikes/:id` — update an existing bike's pricing (the edit ✏️ icon on the detail screen)

Schema: `id` (assigned by MockAPI), `name`, `model`, `price_per_day`, `booking_charge`, `image`.

No token needed — MockAPI's free tier is open by default. Since it's a real hosted server with
proper CORS support, this also works fine on Flutter Web (unlike our earlier DummyJSON
custom-response attempt).
