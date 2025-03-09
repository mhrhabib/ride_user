class ProfileModel {
  Data? data;

  ProfileModel({this.data});

  ProfileModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  String? firstName;
  String? lastName;
  String? displayName;
  String? email;
  String? username;
  String? status;
  String? userType;
  dynamic address;
  String? contactNumber;
  dynamic gender;
  String? profileImage;
  dynamic loginType;
  String? latitude;
  String? longitude;
  dynamic uid;
  String? playerId;
  int? isOnline;
  int? isAvailable;
  String? timezone;
  dynamic fcmToken;
  dynamic userDetail;
  dynamic lastNotificationSeen;
  String? createdAt;
  String? updatedAt;
  int? rating;
  dynamic userBankAccount;
  dynamic otpVerifyAt;
  int? isKycEnabled;
  dynamic nidFront;
  dynamic nidBack;

  Data(
      {this.id,
      this.firstName,
      this.lastName,
      this.displayName,
      this.email,
      this.username,
      this.status,
      this.userType,
      this.address,
      this.contactNumber,
      this.gender,
      this.profileImage,
      this.loginType,
      this.latitude,
      this.longitude,
      this.uid,
      this.playerId,
      this.isOnline,
      this.isAvailable,
      this.timezone,
      this.fcmToken,
      this.userDetail,
      this.lastNotificationSeen,
      this.createdAt,
      this.updatedAt,
      this.rating,
      this.userBankAccount,
      this.otpVerifyAt,
      this.isKycEnabled,
      this.nidFront,
      this.nidBack});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    displayName = json['display_name'];
    email = json['email'];
    username = json['username'];
    status = json['status'];
    userType = json['user_type'];
    address = json['address'];
    contactNumber = json['contact_number'];
    gender = json['gender'];
    profileImage = json['profile_image'];
    loginType = json['login_type'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    uid = json['uid'];
    playerId = json['player_id'];
    isOnline = json['is_online'];
    isAvailable = json['is_available'];
    timezone = json['timezone'];
    fcmToken = json['fcm_token'];
    userDetail = json['user_detail'];
    lastNotificationSeen = json['last_notification_seen'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    rating = json['rating'];
    userBankAccount = json['user_bank_account'];
    otpVerifyAt = json['otp_verify_at'];
    isKycEnabled = json['is_kyc_enabled'];
    nidFront = json['nid_front'];
    nidBack = json['nid_back'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['display_name'] = this.displayName;
    data['email'] = this.email;
    data['username'] = this.username;
    data['status'] = this.status;
    data['user_type'] = this.userType;
    data['address'] = this.address;
    data['contact_number'] = this.contactNumber;
    data['gender'] = this.gender;
    data['profile_image'] = this.profileImage;
    data['login_type'] = this.loginType;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['uid'] = this.uid;
    data['player_id'] = this.playerId;
    data['is_online'] = this.isOnline;
    data['is_available'] = this.isAvailable;
    data['timezone'] = this.timezone;
    data['fcm_token'] = this.fcmToken;
    data['user_detail'] = this.userDetail;
    data['last_notification_seen'] = this.lastNotificationSeen;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['rating'] = this.rating;
    data['user_bank_account'] = this.userBankAccount;
    data['otp_verify_at'] = this.otpVerifyAt;
    data['is_kyc_enabled'] = this.isKycEnabled;
    data['nid_front'] = this.nidFront;
    data['nid_back'] = this.nidBack;
    return data;
  }
}
