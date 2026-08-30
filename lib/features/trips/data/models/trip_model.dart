import 'dart:convert';
import 'package:car_app/core/utils/location_helper.dart';
import 'package:car_app/features/trips/data/models/offer_model.dart';
import 'package:car_app/features/trips/domain/entities/offer.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/domain/entities/trip_driver.dart';
import 'package:car_app/features/trips/domain/entities/trip_passenger.dart';

/// Data model for [Trip]. Handles JSON deserialization.
/// Extends [Trip] so it can be used anywhere [Trip] is expected.
class TripModel extends Trip {
  const TripModel({
    required super.id,
    super.driverId,
    required super.createdBy,
    required super.fromLatitude,
    required super.fromLongitude,
    required super.toLatitude,
    required super.toLongitude,
    required super.fromLocationName,
    required super.toLocationName,
    required super.numberOfSeats,
    required super.genderPreference,
    required super.tripDatetime,
    required super.status,
    required super.type,
    required super.minimumPrice,
    required super.maximumPrice,
    super.approvedPrice,
    super.distance,
    super.tripDetails,
    super.driver,
    super.creator,
    super.onGoingStatus,
    super.passengers,
    super.offers,
    super.totalSeats,
    super.joinedPassengersCount,
    super.reservedSeats,
    super.availableSeats,
    super.isStale,
    super.matchDistanceOriginKm,
    super.matchDistanceDestinationKm,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
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

    // ── Parse driver ──────────────────────────────────────────────────────────
    // The API merges the top-level `car` array into `driver.car`.
    // We do the same merge here before constructing TripDriver.
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

    // ── Parse creator ─────────────────────────────────────────────────────────
    final rawCreator = json['creator'] is Map<String, dynamic>
        ? json['creator'] as Map<String, dynamic>
        : (parsedTripDetails?['creator'] is Map<String, dynamic>
            ? parsedTripDetails!['creator'] as Map<String, dynamic>
            : (json['user'] is Map<String, dynamic>
                ? json['user'] as Map<String, dynamic>
                : null));
    final parsedCreator =
        rawCreator != null ? TripDriver.fromMap(rawCreator) : null;

    // ── Parse driver / creator ID ─────────────────────────────────────────────
    final int resolvedDriverId = _parseInt(json['driver_id'] ??
        json['driverId'] ??
        parsedDriver?.id ??
        (json['creation_type'] == 'driver' || json['user_type'] == 'driver'
            ? parsedCreator?.id
            : null));

    // ── Parse passengers ──────────────────────────────────────────────────────
    // Use whereType<Map>() to accept both Map<String,dynamic> and raw Map.
    // Filter out the driver so that the driver is never treated as a passenger
    // or deducted from vehicle seats.
    final rawPassengers = json['passengers'] as List? ??
        parsedTripDetails?['passengers'] as List?;
    final parsedPassengers = rawPassengers
            ?.whereType<Map>()
            .map((p) => TripPassenger.fromMap(Map<String, dynamic>.from(p)))
            .where((p) => resolvedDriverId == 0 || p.id != resolvedDriverId)
            .toList() ??
        [];

    // numberOfSeats = seats requested by the current passenger (from pivot.seats).
    // For a trip created by a driver, it defaults to 1 until a passenger joins.
    // We use the first passenger's seats if available; otherwise fall back to 'seats'
    // from the request body (sent when creating a trip as a passenger).
    // We never read 'number_of_seats' — that field reflects vehicle capacity on the server
    // and is unreliable for passenger intent.
    final int resolvedRequestedSeats = parsedPassengers.isNotEmpty
        ? parsedPassengers.first.seats
        : _parseInt(json['seats'] ?? 1);

    // totalSeats = vehicle capacity (from server: total_seats or driver.car.seats).
    final int resolvedTotalSeats = _parseInt(json['total_seats'] ??
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

    // ── Parse offers ──────────────────────────────────────────────────────────
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
            .map((o) => OfferModel.fromJson(Map<String, dynamic>.from(o)))
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
    if (rawApproved != null && _parseDouble(rawApproved) > 0) {
      resolvedApprovedPrice = _parseDouble(rawApproved);
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

    return TripModel(
      id: _parseInt(json['id']),
      driverId: json['driver_id'] != null ? _parseInt(json['driver_id']) : null,
      createdBy: _parseInt(json['created_by'] ??
          json['user_id'] ??
          json['creator_id'] ??
          json['client_id'] ??
          parsedCreator?.id),
      fromLatitude: _parseDouble(json['from_latitude']),
      fromLongitude: _parseDouble(json['from_longitude']),
      toLatitude: _parseDouble(json['to_latitude']),
      toLongitude: _parseDouble(json['to_longitude']),
      fromLocationName: cleanLocationName(json['from_location_name']?.toString() ?? ''),
      toLocationName: cleanLocationName(json['to_location_name']?.toString() ?? ''),
      // numberOfSeats = passenger's requested seats (pivot.seats), not vehicle capacity.
      numberOfSeats: resolvedRequestedSeats,
      genderPreference: _parseGender(json['gender_preference']?.toString()),
      tripDatetime: json['trip_datetime']?.toString() ?? '',
      status: _parseStatus(json['status']?.toString()),
      type: (json['type']?.toString().toLowerCase() == 'shared' ||
              parsedTripDetails?['type']?.toString().toLowerCase() == 'shared')
          ? TripType.shared
          : TripType.private,
      minimumPrice: _parseDouble(json['minimum_price'] ??
          json['min_price'] ??
          parsedTripDetails?['minimum_price'] ??
          parsedTripDetails?['min_price'] ??
          json['price']),
      maximumPrice: _parseDouble(json['maximum_price'] ??
          json['max_price'] ??
          parsedTripDetails?['maximum_price'] ??
          parsedTripDetails?['max_price'] ??
          json['price']),
      approvedPrice: resolvedApprovedPrice,
      distance:
          json['distance'] != null ? _parseDouble(json['distance']) : null,
      tripDetails: json['trip_details']?.toString(),
      driver: parsedDriver,
      creator: parsedCreator,
      onGoingStatus: json['on_going_status']?.toString() ??
          parsedTripDetails?['on_going_status']?.toString(),
      passengers: parsedPassengers,
      offers: parsedOffers,
      // Server-computed seat fields
      totalSeats: resolvedTotalSeats,
      joinedPassengersCount: resolvedJoinedCount,
      reservedSeats: resolvedReservedSeats,
      availableSeats: resolvedAvailableSeats,
      isStale: json['is_stale'] == true || json['is_stale'] == 1,
      // Nearby-shared match distances (optional — only present from /nearby-shared)
      matchDistanceOriginKm: (json['match_distance_origin_km'] ??
              json['match_distance_origin'] ??
              json['distance_from_origin'] ??
              json['origin_distance'] ??
              json['distance_origin'] ??
              json['distance_km'] ??
              json['distance']) !=
          null
          ? _parseDouble(json['match_distance_origin_km'] ??
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
          ? _parseDouble(json['match_distance_destination_km'] ??
              json['match_distance_destination'] ??
              json['distance_from_destination'] ??
              json['destination_distance'] ??
              json['distance_destination'] ??
              json['to_distance'])
          : null,
    );
  }

  /// Serializes this model to a raw map (delegates to Trip.toJson()).
  @override
  Map<String, dynamic> toJson() => super.toJson();

  // ─── Safe parsers ──────────────────────────────────────────────────────────

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static GenderPreference _parseGender(String? value) {
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

  static TripStatus _parseStatus(String? value) {
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
}
