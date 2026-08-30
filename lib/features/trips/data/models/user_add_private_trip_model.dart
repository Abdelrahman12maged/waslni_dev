class UserAddPrivateTripModel {
  String? message;
  CreatedTripResponse? trip;

  UserAddPrivateTripModel({this.message, this.trip});

  UserAddPrivateTripModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    trip = json['trip'] != null ? CreatedTripResponse.fromJson(json['trip']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (trip != null) {
      data['trip'] = trip!.toJson();
    }
    return data;
  }
}

/// Response shape for a newly created private trip.
/// Named [CreatedTripResponse] to avoid confusion with the domain [Trip] entity.
class CreatedTripResponse {
  double? fromLatitude;
  double? fromLongitude;
  double? toLatitude;
  double? toLongitude;
  int? numberOfSeats;
  String? genderPreference;
  String? tripDatetime;
  int? createdBy;
  String? status;
  String? fromLocationName;
  String? toLocationName;
  String? updatedAt;
  String? createdAt;
  int? id;

  CreatedTripResponse(
      {this.fromLatitude,
      this.fromLongitude,
      this.toLatitude,
      this.toLongitude,
      this.numberOfSeats,
      this.genderPreference,
      this.tripDatetime,
      this.createdBy,
      this.status,
      this.fromLocationName,
      this.toLocationName,
      this.updatedAt,
      this.createdAt,
      this.id});

  CreatedTripResponse.fromJson(Map<String, dynamic> json) {
    fromLatitude = json['from_latitude'] != null
        ? double.tryParse(json['from_latitude'].toString())
        : null;
    fromLongitude = json['from_longitude'] != null
        ? double.tryParse(json['from_longitude'].toString())
        : null;
    toLatitude = json['to_latitude'] != null
        ? double.tryParse(json['to_latitude'].toString())
        : null;
    toLongitude = json['to_longitude'] != null
        ? double.tryParse(json['to_longitude'].toString())
        : null;
    numberOfSeats = json['number_of_seats'] != null
        ? int.tryParse(json['number_of_seats'].toString())
        : null;
    genderPreference = json['gender_preference'];
    tripDatetime = json['trip_datetime'];
    createdBy = json['created_by'] != null
        ? int.tryParse(json['created_by'].toString())
        : null;
    status = json['status'];
    fromLocationName = json['from_location_name'];
    toLocationName = json['to_location_name'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'] != null ? int.tryParse(json['id'].toString()) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['from_latitude'] = fromLatitude;
    data['from_longitude'] = fromLongitude;
    data['to_latitude'] = toLatitude;
    data['to_longitude'] = toLongitude;
    data['number_of_seats'] = numberOfSeats;
    data['gender_preference'] = genderPreference;
    data['trip_datetime'] = tripDatetime;
    data['created_by'] = createdBy;
    data['status'] = status;
    data['from_location_name'] = fromLocationName;
    data['to_location_name'] = toLocationName;
    data['updated_at'] = updatedAt;
    data['created_at'] = createdAt;
    data['id'] = id;
    return data;
  }
}
