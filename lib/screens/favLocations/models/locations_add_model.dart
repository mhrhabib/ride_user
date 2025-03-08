class LocationsAddModel {
  bool? success;
  Data? data;
  String? message;

  LocationsAddModel({this.success, this.data, this.message});

  LocationsAddModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = this.message;
    return data;
  }
}

class Data {
  int? id;
  int? userId;
  String? favouriteLocationName;
  double? longitude;
  double? latitude;
  String? timeZone;
  bool? status;
  String? createdAt;
  String? updatedAt;

  Data({this.id, this.userId, this.favouriteLocationName, this.longitude, this.latitude, this.timeZone, this.status, this.createdAt, this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    favouriteLocationName = json['favourite_location_name'];
    longitude = json['longitude'];
    latitude = json['latitude'];
    timeZone = json['timeZone'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['favourite_location_name'] = this.favouriteLocationName;
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    data['timeZone'] = this.timeZone;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
