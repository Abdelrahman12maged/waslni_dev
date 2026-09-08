import 'package:car_app/features/trips/domain/entities/trip_driver.dart';
import 'package:car_app/features/trips/domain/entities/trip_passenger.dart';

/// Status of a driver's offer on a trip.
enum OfferStatus { pending, accepted, rejected, expired }

/// Pure Dart entity representing a driver's offer on a trip.
class Offer {
  final int id;
  final int tripId;
  final int driverId;
  final double price;
  final OfferStatus status;

  /// Typed driver entity attached to this offer.
  final TripDriver? driver;

  /// Typed passenger/creator entity attached to this offer.
  final TripPassenger? creator;

  /// Offer creation timestamp.
  final String? createdAt;

  /// UTC expiry time of this offer (from server: expires_at). May be null if
  /// the server does not yet return this field for all offer types.
  final DateTime? expiresAt;

  /// Whether the server considers this offer expired (from server: is_expired).
  final bool isExpired;

  /// The server-computed effective status string: "pending" | "accepted" | "rejected" | "expired".
  /// Prefer this over [status] when displaying UI strings.
  final String? effectiveStatus;

  const Offer({
    required this.id,
    required this.tripId,
    required this.driverId,
    required this.price,
    required this.status,
    this.driver,
    this.creator,
    this.createdAt,
    this.expiresAt,
    this.isExpired = false,
    this.effectiveStatus,
  });

  factory Offer.fromMap(Map<String, dynamic> json) {
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

    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    OfferStatus parseStatus(String? s) {
      switch (s?.toLowerCase()) {
        case 'accepted':
          return OfferStatus.accepted;
        case 'rejected':
          return OfferStatus.rejected;
        case 'expired':
          return OfferStatus.expired;
        default:
          return OfferStatus.pending;
      }
    }

    final int resolvedDriverId = parseInt(
      json['driver_id'] ??
          json['driverId'] ??
          json['user_id'] ??
          json['userId'] ??
          json['creator_id'] ??
          json['client_id'] ??
          (parsedDriver?.id) ??
          (parsedCreator?.id),
    );

    return Offer(
      id: parseInt(json['id']),
      tripId: parseInt(json['trip_id'] ?? json['tripId']),
      driverId: resolvedDriverId,
      price: parseDouble(
          json['price'] ?? json['approved_price'] ?? json['offer_price'] ?? json['fare']),
      status: parseStatus(json['status']?.toString()),
      driver: parsedDriver,
      creator: parsedCreator,
      createdAt: json['created_at']?.toString(),
      expiresAt: parsedExpiresAt,
      isExpired: json['is_expired'] == true || json['is_expired'] == 1,
      effectiveStatus: rawEffectiveStatus,
    );
  }

  String get createdAtFormatted =>
      createdAt?.contains('T') == true ? createdAt!.split('T')[0] : (createdAt ?? '');
  String get currentStatus => effectiveStatus ?? status.name;
  bool get isPending => currentStatus == 'pending';
  bool get isAccepted => currentStatus == 'accepted';
  bool get isRejected => currentStatus == 'rejected';
  bool get isEffectivelyExpired => currentStatus == 'expired' || isExpired;

  Offer copyWith({
    TripDriver? driver,
  }) {
    return Offer(
      id: id,
      tripId: tripId,
      driverId: driverId,
      price: price,
      status: status,
      driver: driver ?? this.driver,
      creator: creator,
      createdAt: createdAt,
      expiresAt: expiresAt,
      isExpired: isExpired,
      effectiveStatus: effectiveStatus,
    );
  }
}
