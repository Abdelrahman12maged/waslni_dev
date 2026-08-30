/// Represents the car (vehicle) attached to a driver on a trip.
/// Parsed from the API's `driver.car` nested object or top-level `car[0]`.
class TripCar {
  /// Car make/brand (e.g. "BMW", "Toyota").
  final String type;

  /// Car model identifier (e.g. "m12", "Corolla").
  final String model;

  /// Total number of passenger seats in the car.
  final int seats;

  /// License plate number.
  final String plateNumber;

  /// Vehicle color (e.g. "White", "Black").
  final String? color;

  /// Model year (e.g. 2022).
  final int? year;

  /// URL of the inside photo of the car.
  final String? insidePicture;

  /// URL of the outside photo of the car.
  final String? outsidePicture;

  /// URL of the driver's license.
  final String? drivingLic;

  const TripCar({
    required this.type,
    required this.model,
    required this.seats,
    required this.plateNumber,
    this.color,
    this.year,
    this.insidePicture,
    this.outsidePicture,
    this.drivingLic,
  });

  factory TripCar.fromMap(Map<String, dynamic> map) {
    return TripCar(
      type: map['car_type_text']?.toString() ??
          map['car_type']?.toString() ??
          map['type']?.toString() ??
          map['car']?.toString() ??
          '',
      model: map['car_model_text']?.toString() ??
          map['car_model']?.toString() ??
          map['model']?.toString() ??
          '',
      seats: _parseInt(map['seats'] ?? map['car_seats_text'] ?? map['number_of_seats']),
      plateNumber: map['car_plate_text']?.toString() ??
          map['plate_number']?.toString() ??
          map['plateNumber']?.toString() ??
          '',
      color: map['color']?.toString(),
      year: _parseIntOpt(map['year']),
      insidePicture: map['inside_picture']?.toString() ?? map['insidePicture']?.toString(),
      outsidePicture: map['outside_picture']?.toString() ?? map['outsidePicture']?.toString(),
      drivingLic: map['driving_lic']?.toString() ?? map['driving_license']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'car_type': type,
        'type': type,
        'car_model': model,
        'model': model,
        'seats': seats,
        'plate_number': plateNumber,
        'color': color,
        'year': year,
        'inside_picture': insidePicture,
        'outside_picture': outsidePicture,
        'driving_lic': drivingLic,
      };

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static int? _parseIntOpt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
