import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/Colors.dart';
import '../../../utils/Extensions/app_common.dart';
import '../controllers/locations_controller.dart';
import '../models/locations_model.dart';

class FavLocationScreen extends StatefulWidget {
  const FavLocationScreen({super.key});

  @override
  State<FavLocationScreen> createState() => _FavLocationScreenState();
}

class _FavLocationScreenState extends State<FavLocationScreen> {
  final LocationsController controller = Get.put(LocationsController());

  @override
  void initState() {
    Future.microtask(() => controller.fetchLocations());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite locations', style: boldTextStyle(color: appTextPrimaryColorWhite)),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else {
          return controller.locationsList.isEmpty
              ? Center(
                  child: Text('No favorite locations found.'),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: controller.locationsList.length,
                  itemBuilder: (context, index) {
                    var location = controller.locationsList[index];
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.only(bottom: 16),
                      color: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.sizeOf(context).width * .60,
                                    child: Text(
                                      location.favouriteLocationName ?? 'No Name',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: appTextPrimaryColorWhite,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () {
                                          // Handle update action
                                          _showUpdateDialog(location);
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          // Handle delete action
                                          _showDeleteDialog(location.id);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Latitude: ${location.latitude}',
                              style: TextStyle(
                                fontSize: 14,
                                color: appTextPrimaryColorWhite,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Longitude: ${location.longitude}',
                              style: TextStyle(
                                fontSize: 14,
                                color: appTextPrimaryColorWhite,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Time Zone: ${location.timeZone}',
                              style: TextStyle(
                                fontSize: 14,
                                color: appTextPrimaryColorWhite,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
        }
      }),
    );
  }

  // Show update dialog
  void _showUpdateDialog(Locations location) {
    TextEditingController nameController = TextEditingController(text: location.favouriteLocationName);
    TextEditingController latController = TextEditingController(text: location.latitude.toString());
    TextEditingController lonController = TextEditingController(text: location.longitude.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Location Name'),
              ),
              TextField(
                controller: latController,
                decoration: InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: lonController,
                decoration: InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Call the controller to update the location
                controller.updateLocation(
                  id: location.id!,
                  placeId: location.placeId,
                  favouriteLocationName: nameController.text,
                  longitude: double.parse(lonController.text),
                  latitude: double.parse(latController.text),
                  timeZone: 'Asia/Dhaka',
                  status: true,
                );
                Navigator.pop(context);
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  // Show delete confirmation dialog
  void _showDeleteDialog(int? id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Location'),
          content: Text('Are you sure you want to delete this location?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Call the controller to delete the location
                controller.deleteLocation(id);
                Navigator.pop(context);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
