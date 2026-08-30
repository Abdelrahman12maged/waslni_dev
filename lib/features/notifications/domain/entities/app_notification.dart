import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  final int? id;
  final int? tripId;
  final String? type;
  final String? titleAr;
  final String? titleEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? createdAt;
  final String? updatedAt;
  final bool isRead;
  final Map<String, dynamic>? data;

  const AppNotification({
    this.id,
    this.tripId,
    this.type,
    this.titleAr,
    this.titleEn,
    this.descriptionAr,
    this.descriptionEn,
    this.createdAt,
    this.updatedAt,
    this.isRead = false,
    this.data,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      tripId: tripId,
      type: type,
      titleAr: titleAr,
      titleEn: titleEn,
      descriptionAr: descriptionAr,
      descriptionEn: descriptionEn,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isRead: isRead ?? this.isRead,
      data: data,
    );
  }

  @override
  List<Object?> get props => [
        id,
        tripId,
        type,
        titleAr,
        titleEn,
        descriptionAr,
        descriptionEn,
        createdAt,
        updatedAt,
        isRead,
        data,
      ];
}
