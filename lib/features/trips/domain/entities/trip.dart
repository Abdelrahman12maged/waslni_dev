import 'package:car_app/features/trips/domain/entities/offer.dart';
import 'package:car_app/features/trips/domain/entities/trip_driver.dart';
import 'package:car_app/features/trips/domain/entities/trip_passenger.dart';

/// Represents the type of a trip.
enum TripType { private, shared }

/// Vehicle type for trip and fare calculation.
enum VehicleType { car, motorcycle, bicycle }

/// Represents the current status of a trip.
enum TripStatus { open, accepted, completed, canceled, suspended, closed }

/// Gender preference for a trip.
enum GenderPreference { male, female, noPreference }

/// Pure Dart entity representing a trip.
/// No JSON, no Flutter, no Dio.
class Trip {
  final int id;
  final int? driverId;
  final int createdBy;

  final double fromLatitude;
  final double fromLongitude;
  final double toLatitude;
  final double toLongitude;
  final String fromLocationName;
  final String toLocationName;

  final int numberOfSeats;
  final GenderPreference genderPreference;
  final String tripDatetime;

  final TripStatus status;
  final TripType type;

  final double minimumPrice;
  final double maximumPrice;
  final double? approvedPrice;
  final double? distance;

  final String? tripDetails;

  /// Typed driver entity — replaces the previous `Map<String, dynamic>? driver`.
  final TripDriver? driver;

  /// Typed creator entity — replaces the previous `Map<String, dynamic>? creator`.
  /// The creator is the passenger who created the trip (shared trips).
  final TripDriver? creator;

  final String? onGoingStatus;

  /// Typed passenger list — replaces the previous `List<dynamic>? passengers`.
  final List<TripPassenger> passengers;

  /// Typed offers list from API.
  final List<Offer> offers;

  // ─── Server-computed seat fields (never computed client-side) ──────────────
  /// Total number of seats in the vehicle (from server: total_seats).
  final int totalSeats;

  /// Number of passengers who have already joined (from server: joined_passengers_count).
  final int joinedPassengersCount;

  /// Seats reserved by the trip creator (from server: reserved_seats).
  final int reservedSeats;

  /// Seats still available for new joiners (from server: available_seats).
  final int availableSeats;

  /// Whether the server considers this trip stale/expired (from server: is_stale).
  final bool isStale;

  // ─── Nearby-search match distances (optional — only from nearby-shared endpoint) ─
  /// Distance in km between the passenger's origin and this trip's origin.
  final double? matchDistanceOriginKm;

  /// Distance in km between the passenger's destination and this trip's destination.
  final double? matchDistanceDestinationKm;

  const Trip({
    required this.id,
    this.driverId,
    required this.createdBy,
    required this.fromLatitude,
    required this.fromLongitude,
    required this.toLatitude,
    required this.toLongitude,
    required this.fromLocationName,
    required this.toLocationName,
    required this.numberOfSeats,
    required this.genderPreference,
    required this.tripDatetime,
    required this.status,
    required this.type,
    required this.minimumPrice,
    required this.maximumPrice,
    this.approvedPrice,
    this.distance,
    this.tripDetails,
    this.driver,
    this.creator,
    this.onGoingStatus,
    this.passengers = const [],
    this.offers = const [],
    this.totalSeats = 0,
    this.joinedPassengersCount = 0,
    this.reservedSeats = 0,
    this.availableSeats = 0,
    this.isStale = false,
    this.matchDistanceOriginKm,
    this.matchDistanceDestinationKm,
  });

  /// Convenience: is this trip currently active (open or accepted)?
  bool get isActive =>
      status == TripStatus.open || status == TripStatus.accepted;

  /// Convenience: is this trip finished (completed, canceled, suspended, closed)
  bool get isFinished => !isActive;

  /// Indicates if this shared trip is currently visible and joinable by other passengers.
  /// Uses server-provided fields only — never raw-map parsing.
  bool get isJoinable =>
      type == TripType.shared && driverId != null && availableSeats > 0;

  /// Creates a copy of this trip with specified fields replaced.
  Trip copyWith({
    int? id,
    int? driverId,
    int? createdBy,
    double? fromLatitude,
    double? fromLongitude,
    double? toLatitude,
    double? toLongitude,
    String? fromLocationName,
    String? toLocationName,
    int? numberOfSeats,
    GenderPreference? genderPreference,
    String? tripDatetime,
    TripStatus? status,
    TripType? type,
    double? minimumPrice,
    double? maximumPrice,
    double? approvedPrice,
    double? distance,
    String? tripDetails,
    TripDriver? driver,
    TripDriver? creator,
    String? onGoingStatus,
    List<TripPassenger>? passengers,
    List<Offer>? offers,
    int? totalSeats,
    int? joinedPassengersCount,
    int? reservedSeats,
    int? availableSeats,
    bool? isStale,
    double? matchDistanceOriginKm,
    double? matchDistanceDestinationKm,
  }) {
    return Trip(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      createdBy: createdBy ?? this.createdBy,
      fromLatitude: fromLatitude ?? this.fromLatitude,
      fromLongitude: fromLongitude ?? this.fromLongitude,
      toLatitude: toLatitude ?? this.toLatitude,
      toLongitude: toLongitude ?? this.toLongitude,
      fromLocationName: fromLocationName ?? this.fromLocationName,
      toLocationName: toLocationName ?? this.toLocationName,
      numberOfSeats: numberOfSeats ?? this.numberOfSeats,
      genderPreference: genderPreference ?? this.genderPreference,
      tripDatetime: tripDatetime ?? this.tripDatetime,
      status: status ?? this.status,
      type: type ?? this.type,
      minimumPrice: minimumPrice ?? this.minimumPrice,
      maximumPrice: maximumPrice ?? this.maximumPrice,
      approvedPrice: approvedPrice ?? this.approvedPrice,
      distance: distance ?? this.distance,
      tripDetails: tripDetails ?? this.tripDetails,
      driver: driver ?? this.driver,
      creator: creator ?? this.creator,
      onGoingStatus: onGoingStatus ?? this.onGoingStatus,
      passengers: passengers ?? this.passengers,
      offers: offers ?? this.offers,
      totalSeats: totalSeats ?? this.totalSeats,
      joinedPassengersCount: joinedPassengersCount ?? this.joinedPassengersCount,
      reservedSeats: reservedSeats ?? this.reservedSeats,
      availableSeats: availableSeats ?? this.availableSeats,
      isStale: isStale ?? this.isStale,
      matchDistanceOriginKm: matchDistanceOriginKm ?? this.matchDistanceOriginKm,
      matchDistanceDestinationKm: matchDistanceDestinationKm ?? this.matchDistanceDestinationKm,
    );
  }

  /// Serializes entity to map for router arguments and legacy screen compatibility.
  Map<String, dynamic> toJson() => {
        'id': id,
        'driver_id': driverId,
        'created_by': createdBy,
        'from_latitude': fromLatitude,
        'from_longitude': fromLongitude,
        'to_latitude': toLatitude,
        'to_longitude': toLongitude,
        'from_location_name': fromLocationName,
        'to_location_name': toLocationName,
        'seats': numberOfSeats,
        'number_of_seats': numberOfSeats,
        'gender_preference': genderPreference.name,
        'trip_datetime': tripDatetime,
        'created_at': tripDatetime.contains('T')
            ? tripDatetime
            : (tripDatetime.isNotEmpty
                ? '${tripDatetime.replaceAll(' ', 'T')}Z'
                : ''),
        'status': status.name,
        'type': type.name,
        'minimum_price': minimumPrice,
        'maximum_price': maximumPrice,
        'approved_price': approvedPrice,
        'distance': distance,
        'trip_details': tripDetails,
        'driver': driver?.toMap(),
        'creator': creator?.toMap(),
        'on_going_status': onGoingStatus,
        'passengers': passengers.map((p) => p.toMap()).toList(),
        'total_seats': totalSeats,
        'joined_passengers_count': joinedPassengersCount,
        'reserved_seats': reservedSeats,
        'available_seats': availableSeats,
        'is_stale': isStale,
        'match_distance_origin_km': matchDistanceOriginKm,
        'match_distance_destination_km': matchDistanceDestinationKm,
      };
}
