import 'package:get/get.dart';
import 'package:taxi_booking/utils/Extensions/app_common.dart';
import '../models/locations_model.dart';
import '../repository/fav_locations_repo.dart';

class LocationsController extends GetxController {
  var locationsList = <Locations>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    fetchLocations();
    super.onInit();
  }

  void fetchLocations() async {
    try {
      isLoading(true);
      var locations = await LocationsRepository().fetchLocations();
      if (locations.success == true) {
        locationsList.value = locations.data!;
      }
    } finally {
      isLoading(false);
    }
  }

  // Add a new favourite location
  Future<void> addFavouriteLocation({
    required int userId,
    required String favouriteLocationName,
    required double longitude,
    required double latitude,
    required String timeZone,
    required bool status,
  }) async {
    try {
      isLoading(true);
      var response = await LocationsRepository().addFavouriteLocation(
        userId: userId,
        favouriteLocationName: favouriteLocationName,
        longitude: longitude,
        latitude: latitude,
        timeZone: timeZone,
        status: status,
      );

      // If the location is added successfully, refresh the list
      if (response.success == true) {
        toast(response.message.toString());
        print("fav added");
        fetchLocations(); // Refresh the list
      }
    } finally {
      isLoading(false);
    }
  }

  // Update a location
  Future<void> updateLocation({
    required int id,
    required String favouriteLocationName,
    required double longitude,
    required double latitude,
    required String timeZone,
    required bool status,
  }) async {
    try {
      isLoading(true);
      var response = await LocationsRepository().updateLocation(
        id: id,
        favouriteLocationName: favouriteLocationName,
        longitude: longitude,
        latitude: latitude,
        timeZone: timeZone,
        status: status,
      );

      // If the location is updated successfully, refresh the list
      if (response != null) {
        fetchLocations(); // Refresh the list
      }
    } finally {
      isLoading(false);
    }
  }

  // Delete a location
  Future<void> deleteLocation(int? id) async {
    if (id == null) return;

    try {
      isLoading(true);
      var response = await LocationsRepository().deleteLocation(id);

      // If the location is deleted successfully, refresh the list
      if (response != null) {
        fetchLocations(); // Refresh the list
      }
    } finally {
      isLoading(false);
    }
  }
}
