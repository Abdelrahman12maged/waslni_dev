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
