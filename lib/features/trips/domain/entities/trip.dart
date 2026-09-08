import 'dart:convert';
import 'package:car_app/core/utils/location_helper.dart';
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

  factory Trip.fromMap(Map<String, dynamic> json) {
    Map<String, dynamic>? parsedTripDetails;
    if (json['trip_details'] != null) {
      if (json['trip_details'] is Map) {
        parsedTripDetails = json['trip_details'] as Map<String, dynamic>;
      } else if (json['trip_details'] is String) {
        try {
          parsedTripDetails =
              jsonDecode(json['trip_details']) as Map<String, dynamic>;
        } catch (_) {}
      }
    }

    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    GenderPreference parseGender(String? value) {
      switch (value) {
        case 'male':
        case 'male_only':
          return GenderPreference.male;
        case 'female':
        case 'female_only':
          return GenderPreference.female;
        default:
          return GenderPreference.noPreference;
      }
    }

    TripStatus parseStatus(String? value) {
      switch (value) {
        case 'open':
          return TripStatus.open;
        case 'accepted':
          return TripStatus.accepted;
        case 'completed':
          return TripStatus.completed;
        case 'canceled':
          return TripStatus.canceled;
        case 'suspended':
          return TripStatus.suspended;
        case 'closed':
          return TripStatus.closed;
        default:
          return TripStatus.open;
      }
    }

    Map<String, dynamic>? rawDriver = json['driver'] as Map<String, dynamic>?;
    final rawCar = json['car'];
    if (rawDriver != null && rawCar is List && rawCar.isNotEmpty) {
      final firstCar = rawCar.first;
      if (firstCar is Map<String, dynamic>) {
        rawDriver = {...rawDriver, 'car': firstCar};
      }
    }
    final parsedDriver =
        rawDriver != null ? TripDriver.fromMap(rawDriver) : null;

    final rawCreator = json['creator'] is Map<String, dynamic>
        ? json['creator'] as Map<String, dynamic>
        : (parsedTripDetails?['creator'] is Map<String, dynamic>
            ? parsedTripDetails!['creator'] as Map<String, dynamic>
            : (json['user'] is Map<String, dynamic>
                ? json['user'] as Map<String, dynamic>
                : null));
    final parsedCreator =
        rawCreator != null ? TripDriver.fromMap(rawCreator) : null;

    final int resolvedDriverId = parseInt(json['driver_id'] ??
        json['driverId'] ??
        parsedDriver?.id ??
        (json['creation_type'] == 'driver' || json['user_type'] == 'driver'
            ? parsedCreator?.id
            : null));

    final rawPassengers = json['passengers'] as List? ??
        parsedTripDetails?['passengers'] as List?;
    final parsedPassengers = rawPassengers
            ?.whereType<Map>()
            .map((p) => TripPassenger.fromMap(Map<String, dynamic>.from(p)))
            .where((p) => resolvedDriverId == 0 || p.id != resolvedDriverId)
            .toList() ??
        [];

    final int resolvedRequestedSeats = parsedPassengers.isNotEmpty
        ? parsedPassengers.first.seats
        : parseInt(json['seats'] ?? 1);

    final int resolvedTotalSeats = parseInt(json['total_seats'] ??
        parsedDriver?.car?.seats ??
        (rawCar is List && rawCar.isNotEmpty && rawCar.first is Map
            ? rawCar.first['seats']
            : null) ??
        4);

    final int resolvedJoinedCount = parsedPassengers.length;

    final int resolvedReservedSeats = parsedPassengers.isNotEmpty
        ? parsedPassengers.fold<int>(
            0, (sum, p) => sum + (p.seats > 0 ? p.seats : 1))
        : 0;

    final int resolvedAvailableSeats = (resolvedTotalSeats - resolvedReservedSeats)
        .clamp(0, resolvedTotalSeats);

    final rawOffers = json['offers'] as List? ??
        json['driver_offers'] as List? ??
        json['user_offers'] as List? ??
        json['trip_offers'] as List? ??
        (json['offer'] is Map ? [json['offer']] : null) ??
        (json['accepted_offer'] is Map ? [json['accepted_offer']] : null) ??
        parsedTripDetails?['offers'] as List? ??
        parsedTripDetails?['driver_offers'] as List?;
    final parsedOffers = rawOffers
            ?.whereType<Map>()
            .map((o) => Offer.fromMap(Map<String, dynamic>.from(o)))
            .toList() ??
        [];

    final rawApproved = json['approved_price'] ??
        json['accepted_price'] ??
        json['price'] ??
        json['offer_price'] ??
        json['agreed_price'] ??
        json['fare'] ??
        json['total_fare'] ??
        json['driver_price'] ??
        json['accepted_offer_price'] ??
        (json['offer'] is Map ? (json['offer'] as Map)['price'] : null) ??
        (json['accepted_offer'] is Map ? (json['accepted_offer'] as Map)['price'] : null) ??
        (json['driver'] is Map ? (json['driver'] as Map)['price'] : null) ??
        (json['driver'] is Map ? (json['driver'] as Map)['offer_price'] : null) ??
        parsedTripDetails?['approved_price'] ??
        parsedTripDetails?['price'];

    double? resolvedApprovedPrice;
    if (rawApproved != null && parseDouble(rawApproved) > 0) {
      resolvedApprovedPrice = parseDouble(rawApproved);
    } else if (parsedOffers.isNotEmpty) {
      for (final o in parsedOffers) {
        if (o.status == OfferStatus.accepted ||
            o.effectiveStatus == 'accepted' ||
            o.effectiveStatus == 'approved') {
          resolvedApprovedPrice = o.price;
          break;
        }
      }
    }

    return Trip(
      id: parseInt(json['id']),
      driverId: json['driver_id'] != null ? parseInt(json['driver_id']) : null,
      createdBy: parseInt(json['created_by'] ??
          json['user_id'] ??
          json['creator_id'] ??
          json['client_id'] ??
          parsedCreator?.id),
      fromLatitude: parseDouble(json['from_latitude']),
      fromLongitude: parseDouble(json['from_longitude']),
      toLatitude: parseDouble(json['to_latitude']),
      toLongitude: parseDouble(json['to_longitude']),
      fromLocationName: cleanLocationName(json['from_location_name']?.toString() ?? ''),
      toLocationName: cleanLocationName(json['to_location_name']?.toString() ?? ''),
      numberOfSeats: resolvedRequestedSeats,
      genderPreference: parseGender(json['gender_preference']?.toString()),
      tripDatetime: json['trip_datetime']?.toString() ?? '',
      status: parseStatus(json['status']?.toString()),
      type: (json['type']?.toString().toLowerCase() == 'shared' ||
              parsedTripDetails?['type']?.toString().toLowerCase() == 'shared')
          ? TripType.shared
          : TripType.private,
      minimumPrice: parseDouble(json['minimum_price'] ??
          json['min_price'] ??
          parsedTripDetails?['minimum_price'] ??
          parsedTripDetails?['min_price'] ??
          json['price']),
      maximumPrice: parseDouble(json['maximum_price'] ??
          json['max_price'] ??
          parsedTripDetails?['maximum_price'] ??
          parsedTripDetails?['max_price'] ??
          json['price']),
      approvedPrice: resolvedApprovedPrice,
      distance:
          json['distance'] != null ? parseDouble(json['distance']) : null,
      tripDetails: json['trip_details']?.toString(),
      driver: parsedDriver,
      creator: parsedCreator,
      onGoingStatus: json['on_going_status']?.toString() ??
          parsedTripDetails?['on_going_status']?.toString(),
      passengers: parsedPassengers,
      offers: parsedOffers,
      totalSeats: resolvedTotalSeats,
      joinedPassengersCount: resolvedJoinedCount,
      reservedSeats: resolvedReservedSeats,
      availableSeats: resolvedAvailableSeats,
      isStale: json['is_stale'] == true || json['is_stale'] == 1,
      matchDistanceOriginKm: (json['match_distance_origin_km'] ??
              json['match_distance_origin'] ??
              json['distance_from_origin'] ??
              json['origin_distance'] ??
              json['distance_origin'] ??
              json['distance_km'] ??
              json['distance']) !=
          null
          ? parseDouble(json['match_distance_origin_km'] ??
              json['match_distance_origin'] ??
              json['distance_from_origin'] ??
              json['origin_distance'] ??
              json['distance_origin'] ??
              json['distance_km'] ??
              json['distance'])
          : null,
      matchDistanceDestinationKm: (json['match_distance_destination_km'] ??
              json['match_distance_destination'] ??
              json['distance_from_destination'] ??
              json['destination_distance'] ??
              json['distance_destination'] ??
              json['to_distance']) !=
          null
          ? parseDouble(json['match_distance_destination_km'] ??
              json['match_distance_destination'] ??
              json['distance_from_destination'] ??
              json['destination_distance'] ??
              json['distance_destination'] ??
              json['to_distance'])
          : null,
    );
  }

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
