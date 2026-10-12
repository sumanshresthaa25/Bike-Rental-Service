import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:bike_rental_service/model/bike_model.dart';

class BikeService {
  static const String baseUrl =
      "https://6a806e0aec7a640e63abc1f5.mockapi.io/api/v1/bikes";

  /// GET /bikes -- fetch the full list.
  Future<List<BikeModel>> fetchBikes() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => BikeModel.fromJson(e)).toList();
    }

    throw Exception(
      "Failed to load bikes: ${response.statusCode} ${response.body}",
    );
  }

  /// POST /bikes -- create a new bike, returns it with the id MockAPI assigned.
  Future<BikeModel> createBike(BikeModel bike) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(bike.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return BikeModel.fromJson(jsonDecode(response.body));
    }

    throw Exception(
      "Failed to create bike: ${response.statusCode} ${response.body}",
    );
  }

  /// PUT /bikes/:id -- update an existing bike.
  Future<BikeModel> updateBike(BikeModel bike) async {
    if (bike.id == null) {
      throw Exception("Cannot update a bike with no id.");
    }

    final response = await http.put(
      Uri.parse("$baseUrl/${bike.id}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(bike.toJson()),
    );

    if (response.statusCode == 200) {
      return BikeModel.fromJson(jsonDecode(response.body));
    }

    throw Exception(
      "Failed to update bike: ${response.statusCode} ${response.body}",
    );
  }

  /// DELETE /bikes/:id -- remove a bike from MockAPI.
  Future<void> deleteBike(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));

    if (response.statusCode == 200) return;

    throw Exception(
      "Failed to delete bike: ${response.statusCode} ${response.body}",
    );
  }
}
