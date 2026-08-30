import 'package:car_app/features/trips/domain/entities/offer.dart';
import 'package:car_app/features/trips/domain/entities/trip_driver.dart';
import 'package:car_app/features/trips/domain/entities/trip_passenger.dart';

/// Data model for [Offer]. Handles JSON deserialization from the API.
class OfferModel extends Offer {
  const OfferModel({
    required super.id,
    required super.tripId,
    required super.driverId,
    required super.price,
    required super.status,
    super.driver,
    super.creator,
    super.createdAt,
    super.expiresAt,
    super.isExpired,
    super.effectiveStatus,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    final rawDriver = json['driver'] ??
        (json['creator'] is Map &&
                ((json['creator'] as Map)['user_type']?.toString() == 'driver' ||
                    (json['creator'] as Map)['role_id'] == 3)
            ? json['creator']
            : null) ??
        json['user'];
    TripDriver? parsedDriver;
    if (rawDriver is Map) {
      parsedDriver = TripDriver.fromMap(Map<String, dynamic>.from(rawDriver));
    }

    final rawCreator = json['creator'] ?? json['passenger'] ?? json['user'];
    TripPassenger? parsedCreator;
    if (rawCreator is Map) {
      parsedCreator = TripPassenger.fromMap(Map<String, dynamic>.from(rawCreator));
    }

    // Parse expires_at from ISO-8601 or space-separated datetime string.
    DateTime? parsedExpiresAt;
    final rawExpiresAt = json['expires_at']?.toString();
    if (rawExpiresAt != null && rawExpiresAt.isNotEmpty) {
      parsedExpiresAt = DateTime.tryParse(
        rawExpiresAt.contains('T') ? rawExpiresAt : rawExpiresAt.replaceAll(' ', 'T'),
      );
    }

    final rawEffectiveStatus = json['effective_status']?.toString() ??
        json['status']?.toString() ??
        json['state']?.toString() ??
        'pending';

    final int resolvedDriverId = _parseInt(
      json['driver_id'] ??
          json['driverId'] ??
          json['user_id'] ??
          json['userId'] ??
          json['creator_id'] ??
          json['client_id'] ??
          (parsedDriver?.id) ??
          (parsedCreator?.id),
    );

    return OfferModel(
      id: _parseInt(json['id']),
      tripId: _parseInt(json['trip_id'] ?? json['tripId']),
      driverId: resolvedDriverId,
      price: _parseDouble(
          json['price'] ?? json['approved_price'] ?? json['offer_price'] ?? json['fare']),
      status: _parseStatus(json['status']?.toString()),
      driver: parsedDriver,
      creator: parsedCreator,
      createdAt: json['created_at']?.toString(),
      expiresAt: parsedExpiresAt,
      isExpired: json['is_expired'] == true || json['is_expired'] == 1,
      effectiveStatus: rawEffectiveStatus,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'trip_id': tripId,
        'driver_id': driverId,
        'price': price,
        'status': status.name,
        'effective_status': effectiveStatus,
        'is_expired': isExpired,
        'expires_at': expiresAt?.toIso8601String(),
        'driver': driver?.toMap(),
      };

  // ─── Safe parsers ──────────────────────────────────────────────────────────

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static OfferStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'accepted':
        return OfferStatus.accepted;
      case 'rejected':
      case 'canceled':
        return OfferStatus.rejected;
      case 'expired':
        return OfferStatus.expired;
      case 'pending':
      default:
        return OfferStatus.pending;
    }
  }
}
