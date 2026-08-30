/// Represents a resolved geographic location with coordinates and a human-readable name.
class LocationResult {
  final double latitude;
  final double longitude;
  final String address;
  final String? subLocality;
  final String? street;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.subLocality,
    this.street,
  });

  /// Returns a user-friendly display name.
  String get displayName {
    if (subLocality != null && street != null) {
      return '$subLocality, $street';
    }
    return address;
  }

  @override
  String toString() => displayName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationResult &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}
