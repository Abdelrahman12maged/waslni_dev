import 'package:equatable/equatable.dart';

class SavedLocation extends Equatable {
  final int? id;
  final int? userId;
  final String? name;
  final String? latitude;
  final String? longitude;
  final String? createdAt;
  final String? updatedAt;

  const SavedLocation({
    this.id,
    this.userId,
    this.name,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        latitude,
        longitude,
        createdAt,
        updatedAt,
      ];
}
