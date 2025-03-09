class FavLocationsModel {
  bool? success;
  List<Locations>? data;

  FavLocationsModel({this.success, this.data});

  FavLocationsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Locations>[];
      json['data'].forEach((v) {
        data!.add(new Locations.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Locations {
  dynamic id;
  dynamic userId;
  dynamic placeId;
  String? favouriteLocationName;
  double? longitude;
  double? latitude;
  String? timeZone;
  bool? status;
  String? createdAt;
  String? updatedAt;

  Locations({this.id, this.userId, this.placeId, this.favouriteLocationName, this.longitude, this.latitude, this.timeZone, this.status, this.createdAt, this.updatedAt});

  Locations.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    placeId = json['place_id'];
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
    data['place_id'] = this.placeId;
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
