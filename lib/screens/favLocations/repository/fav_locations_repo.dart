import 'package:taxi_booking/screens/favLocations/models/locations_add_model.dart';

import '../../../service/base_client.dart';
import '../models/locations_model.dart';
import 'package:dio/dio.dart' as dio;

class LocationsRepository {
  final String _baseUrl = "https://ubar.marcuricit.org/api/favourite-locations";

  Future<FavLocationsModel> fetchLocations() async {
    try {
      // Use BaseClient to make the GET request
      dio.Response response = await BaseClient.get(url: _baseUrl);

      // Check if the response is successful
      if (response.statusCode == 200) {
        return FavLocationsModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load locations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load locations: $e');
    }
  }

  // Add a new favourite location (POST)
  Future<LocationsAddModel> addFavouriteLocation({
    required dynamic userId,
    required String favouriteLocationName,
    required double longitude,
    required double latitude,
    required String timeZone,
    required bool status,
  }) async {
    try {
      // Prepare the payload
      Map<String, dynamic> payload = {
        "user_id": userId,
        "favourite_location_name": favouriteLocationName,
        "longitude": longitude,
        "latitude": latitude,
        "timeZone": timeZone,
        "status": status,
      };

      // Make the POST request using BaseClient
      var response = await BaseClient.post(url: _baseUrl, payload: payload);

      // Check if the response is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        return LocationsAddModel.fromJson(response.data); // Return the response data
      } else {
        throw Exception('Failed to add location: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add location: $e');
    }
  }

  // Update a location (PUT)
  Future<dynamic> updateLocation({
    required int id,
    required String favouriteLocationName,
    required double longitude,
    required double latitude,
    required String timeZone,
    required bool status,
  }) async {
    try {
      // Prepare the payload
      Map<String, dynamic> payload = {
        "favourite_location_name": favouriteLocationName,
        "longitude": longitude,
        "latitude": latitude,
        "timeZone": timeZone,
        "status": status,
      };

      // Make the PUT request using BaseClient
      var response = await BaseClient.put(url: '$_baseUrl/$id', payload: payload);

      // Check if the response is successful
      if (response.statusCode == 200) {
        return response.data; // Return the response data
      } else {
        throw Exception('Failed to update location: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update location: $e');
    }
  }

  // Delete a location (DELETE)
  Future<dynamic> deleteLocation(int id) async {
    try {
      // Make the DELETE request using BaseClient
      var response = await BaseClient.delete(url: '$_baseUrl/$id');

      // Check if the response is successful
      if (response.statusCode == 200) {
        return response.data; // Return the response data
      } else {
        throw Exception('Failed to delete location: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete location: $e');
    }
  }
}
