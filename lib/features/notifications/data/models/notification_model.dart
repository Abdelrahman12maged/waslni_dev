import 'package:car_app/features/notifications/domain/entities/app_notification.dart';

class NotificationModel extends AppNotification {
  const NotificationModel({
    super.id,
    super.tripId,
    super.type,
    super.titleAr,
    super.titleEn,
    super.descriptionAr,
    super.descriptionEn,
    super.createdAt,
    super.updatedAt,
    super.isRead,
    super.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? parsedData;
    if (json['data'] is Map) {
      parsedData = Map<String, dynamic>.from(json['data'] as Map);
    }

    final rawTripId = json['trip_id'] ??
        json['tripId'] ??
        json['trip_ID'] ??
        parsedData?['trip_id'] ??
        parsedData?['tripId'] ??
        parsedData?['id'];
    final tripId = int.tryParse(rawTripId?.toString() ?? '');

    final rawType = json['type'] ??
        json['action'] ??
        json['event'] ??
        parsedData?['type'] ??
        parsedData?['action'];

    return NotificationModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      tripId: tripId,
      type: rawType?.toString(),
      titleAr: json['title_ar']?.toString() ?? json['title']?.toString(),
      titleEn: json['title_en']?.toString() ?? json['title']?.toString(),
      descriptionAr: json['description_ar']?.toString() ??
          json['description']?.toString() ??
          json['body']?.toString(),
      descriptionEn: json['description_en']?.toString() ??
          json['description']?.toString() ??
          json['body']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      isRead: json['is_read'] == 1 ||
          json['is_read'] == true ||
          json['read'] == true ||
          json['is_read'] == '1',
      data: parsedData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_id': tripId,
      'type': type,
      'title_ar': titleAr,
      'title_en': titleEn,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_read': isRead,
      'data': data,
    };
  }
}
