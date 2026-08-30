import 'package:car_app/features/settings/domain/entities/saved_location.dart';

class SavedLocationModel extends SavedLocation {
  const SavedLocationModel({
    super.id,
    super.userId,
    super.name,
    super.latitude,
    super.longitude,
    super.createdAt,
    super.updatedAt,
  });

  factory SavedLocationModel.fromJson(Map<String, dynamic> json) {
    return SavedLocationModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      name: json['name'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
