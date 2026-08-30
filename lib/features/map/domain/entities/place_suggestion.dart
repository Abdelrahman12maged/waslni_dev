/// Represents a single autocomplete place suggestion returned by the Places API.
class PlaceSuggestion {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  const PlaceSuggestion({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  @override
  String toString() => description;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaceSuggestion &&
          runtimeType == other.runtimeType &&
          placeId == other.placeId;

  @override
  int get hashCode => placeId.hashCode;
}
