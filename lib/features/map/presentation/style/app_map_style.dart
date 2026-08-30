import 'dart:developer';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Ultra-Modern, High-Contrast Google Map styles designed for maximum
/// visual excellence, clear road hierarchy, and rich landmark visibility.
///
/// Features:
/// - Distinct & vibrant POI icons (Mosques, Hospitals, Malls, Schools, Restaurants, Parks, Gas Stations)
/// - Bold typography with high-contrast text strokes for readability
/// - Crisp road geometry (Highways, Arterials, Local streets) with clear borders
/// - 3D building outlines and city structures
/// - Vibrant water and natural park landmarks
class AppMapStyle {
  AppMapStyle._();

  /// Applies the professional branded style to a [GoogleMapController].
  static Future<void> applyStyle(
    GoogleMapController? controller, {
    bool isDark = false,
  }) async {
    if (controller == null) return;
    try {
      final style = isDark ? darkNavyStyle : lightNavyStyle;
      await controller.setMapStyle(style);
    } catch (e) {
      log('Failed to apply custom map style: $e', name: 'AppMapStyle');
    }
  }

  /// ── 1. Ultra-Rich Modern Light Map Style ──────────────────────────────────
  /// Features vibrant landmarks, high-visibility POI icons, and crisp road networks.
  static const String lightNavyStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      { "color": "#f8fafc" }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      { "visibility": "on" }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#1e293b" }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      { "color": "#ffffff" },
      { "weight": 3.5 }
    ]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [
      { "visibility": "on" }
    ]
  },
  {
    "featureType": "administrative.country",
    "elementType": "geometry.stroke",
    "stylers": [
      { "color": "#6366f1" },
      { "weight": 2.0 }
    ]
  },
  {
    "featureType": "administrative.province",
    "elementType": "geometry.stroke",
    "stylers": [
      { "color": "#818cf8" },
      { "weight": 1.2 }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#0f172a" },
      { "weight": "bold" }
    ]
  },
  {
    "featureType": "administrative.neighborhood",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#1e293b" },
      { "weight": "bold" }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "geometry.stroke",
    "stylers": [
      { "color": "#e2e8f0" },
      { "visibility": "on" }
    ]
  },
  {
    "featureType": "landscape.man_made",
    "elementType": "geometry.fill",
    "stylers": [
      { "color": "#f1f5f9" }
    ]
  },
  {
    "featureType": "landscape.man_made",
    "elementType": "geometry.stroke",
    "stylers": [
      { "color": "#cbd5e1" },
      { "weight": 1.0 },
      { "visibility": "on" }
    ]
  },
  {
    "featureType": "landscape.natural",
    "elementType": "geometry",
    "stylers": [
      { "color": "#f1f5f9" }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      { "color": "#eef2f6" },
      { "visibility": "on" }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.icon",
    "stylers": [
      { "visibility": "on" }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#1e293b" },
      { "weight": "bold" }
    ]
  },
  {
    "featureType": "poi.attraction",
    "elementType": "geometry",
    "stylers": [
      { "color": "#fef3c7" }
    ]
  },
  {
    "featureType": "poi.attraction",
    "elementType": "labels.icon",
    "stylers": [
      { "visibility": "on" }
    ]
  },
  {
    "featureType": "poi.attraction",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#b45309" },
      { "weight": "bold" }
    ]
  },
  {
    "featureType": "poi.business",
    "elementType": "geometry",
    "stylers": [
      { "color": "#ede9fe" }
    ]
  },
  {
    "featureType": "poi.business",
    "elementType": "labels.icon",
    "stylers": [
      { "visibility": "on" }
    ]
  },
  {
    "featureType": "poi.business",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#6d28d9" },
      { "weight": "bold" }
    ]
  },
  {
    "featureType": "poi.government",
    "elementType": "geometry",
    "stylers": [
      { "color": "#e0e7ff" }
    ]
  },
  {
    "featureType": "poi.government",
    "elementType": "labels.icon",
    "stylers": [
      { "visibility": "on" }
    ]
  },
  {
    "featureType": "poi.government",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#1e1b4b" },
      { "weight": "bold" }
    ]
  },
  {
    "featureType": "poi.medical",
    "elementType": "geometry",
    "stylers": [
      { "color": "#fee2e2" }
    ]
  },
  {
    "featureType": "poi.medical",
    "elementType": "labels.icon",
    "stylers": [
      { "visibility": "on" }
    ]
  },
  {
    "featureType": "poi.medical",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#b91c1c" },
      { "weight": "bold" }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      { "color": "#dcfce7" }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.icon",
    "stylers": [
      { "visibility": "on" }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#15803d" },
      { "weight": "bold" }
    ]
  },
  {
    "featureType": "poi.place_of_worship",
    "elementType": "geometry",
    "stylers": [
      { "color": "#fef9c3" }
    ]
  },
  {
    "featureType": "poi.place_of_worship",
    "elementType": "labels.icon",
    "stylers": [
      { "visibility": "on" }
    ]
  },
  {
    "featureType": "poi.place_of_worship",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#854d0e" },
      { "weight": "bold" }
    ]
  },
  {
    "featureType": "poi.school",
    "elementType": "geometry",
    "stylers": [
      { "color": "#e0e7ff" }
    ]
  },
  {
    "featureType": "poi.school",
    "elementType": "labels.icon",
    "stylers": [
      { "visibility": "on" }
    ]
  },
  {
    "featureType": "poi.school",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#3730a3" },
      { "weight": "bold" }
    ]
  },
  {
    "featureType": "poi.sports_complex",
    "elementType": "geometry",
    "stylers": [
      { "color": "#dbeafe" }
    ]
  },
  {
    "featureType": "poi.sports_complex",
    "elementType": "labels.icon",
    "stylers": [
      { "visibility": "on" }
    ]
  },
  {
    "featureType": "poi.sports_complex",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#1d4ed8" },
      { "weight": "bold" }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      { "color": "#ffffff" }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      { "color": "#cbd5e1" },
      { "weight": 1.4 }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.icon",
    "stylers": [
      { "visibility": "on" }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#1e293b" },
      { "weight": "bold" }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry",
    "stylers": [
      { "color": "#ffffff" }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry.stroke",
    "stylers": [
      { "color": "#94a3b8" },
      { "weight": 1.8 }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#0f172a" },
      { "weight": "bold" }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      { "color": "#e0e7ff" }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      { "color": "#6366f1" },
      { "weight": 2.2 }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#1e1b4b" },
      { "weight": "bold" }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "geometry",
    "stylers": [
      { "color": "#ffffff" }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "geometry.stroke",
    "stylers": [
      { "color": "#e2e8f0" },
      { "weight": 1.2 }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#475569" }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "all",
    "stylers": [
      { "visibility": "on" }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      { "color": "#818cf8" },
      { "weight": 2.5 }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      { "color": "#e0e7ff" }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.icon",
    "stylers": [
      { "visibility": "on" }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#1e1b4b" },
      { "weight": "bold" }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      { "color": "#bae6fd" }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#0369a1" },
      { "weight": "bold" }
    ]
  }
]
''';

  /// ── 2. Ultra-Rich Modern Dark Navy Map Style ──────────────────────────────
  static const String darkNavyStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      { "color": "#0b112c" }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      { "visibility": "on" }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#e2e8f0" }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      { "color": "#060919" },
      { "weight": 3.0 }
    ]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [
      { "visibility": "on" }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#c7d2fe" },
      { "weight": "bold" }
    ]
  },
  {
    "featureType": "landscape",
    "elementType": "geometry",
    "stylers": [
      { "color": "#10173b" }
    ]
  },
  {
    "featureType": "landscape.man_made",
    "elementType": "geometry.stroke",
    "stylers": [
      { "color": "#1e295d" },
      { "weight": 1.0 },
      { "visibility": "on" }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      { "color": "#151d45" },
      { "visibility": "on" }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.icon",
    "stylers": [
      { "visibility": "on" }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#c7d2fe" },
      { "weight": "bold" }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      { "color": "#062820" }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.icon",
    "stylers": [
      { "visibility": "on" }
    ]
  },
  {
    "featureType": "poi.place_of_worship",
    "elementType": "geometry",
    "stylers": [
      { "color": "#332608" }
    ]
  },
  {
    "featureType": "poi.place_of_worship",
    "elementType": "labels.icon",
    "stylers": [
      { "visibility": "on" }
    ]
  },
  {
    "featureType": "poi.medical",
    "elementType": "geometry",
    "stylers": [
      { "color": "#3b111a" }
    ]
  },
  {
    "featureType": "poi.medical",
    "elementType": "labels.icon",
    "stylers": [
      { "visibility": "on" }
    ]
  },
  {
    "featureType": "poi.business",
    "elementType": "geometry",
    "stylers": [
      { "color": "#28194d" }
    ]
  },
  {
    "featureType": "poi.business",
    "elementType": "labels.icon",
    "stylers": [
      { "visibility": "on" }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      { "color": "#1c2656" }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      { "color": "#131a3d" },
      { "weight": 1.2 }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.icon",
    "stylers": [
      { "visibility": "on" }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      { "color": "#312e81" }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      { "color": "#4338ca" },
      { "weight": 2.0 }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "all",
    "stylers": [
      { "visibility": "on" }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.icon",
    "stylers": [
      { "visibility": "on" }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      { "color": "#070e24" }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#818cf8" }
    ]
  }
]
''';
}
