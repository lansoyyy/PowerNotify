import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

class LocationSearchService {
  static Future<List<LocationSuggestion>> searchPlaces(String query) async {
    try {
      // Use geocoding to search for places
      List<Location> locations = await locationFromAddress(query);

      List<LocationSuggestion> suggestions = [];

      for (Location location in locations) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          String description = _formatAddress(place);

          suggestions.add(LocationSuggestion(
            placeId: location.timestamp.toString(),
            description: description,
            latitude: location.latitude,
            longitude: location.longitude,
          ));
        }
      }

      return suggestions;
    } catch (e) {
      print('Error searching places: $e');
      return [];
    }
  }

  static Future<LatLng?> getPlaceDetails(String placeId) async {
    try {
      // For now, return a default location
      // In a real implementation, you'd use Google Places API
      return LatLng(14.5995, 120.9842); // Manila coordinates as default
    } catch (e) {
      print('Error getting place details: $e');
      return null;
    }
  }

  static Future<String?> getCurrentLocationAddress(LatLng coordinates) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        coordinates.latitude,
        coordinates.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return _formatAddress(place);
      }
      return null;
    } catch (e) {
      print('Error getting address from coordinates: $e');
      return null;
    }
  }

  static String _formatAddress(Placemark place) {
    String address = '';

    if (place.street?.isNotEmpty == true) {
      address += '${place.street}, ';
    }
    if (place.locality?.isNotEmpty == true) {
      address += '${place.locality}, ';
    }
    if (place.administrativeArea?.isNotEmpty == true) {
      address += '${place.administrativeArea}, ';
    }
    if (place.country?.isNotEmpty == true) {
      address += place.country!;
    }

    return address.isNotEmpty ? address : 'Unknown Location';
  }
}

class LocationSuggestion {
  final String placeId;
  final String description;
  final double latitude;
  final double longitude;

  LocationSuggestion({
    required this.placeId,
    required this.description,
    required this.latitude,
    required this.longitude,
  });
}

class PlaceDetails {
  final String placeId;
  final String name;
  final String? address;
  final LatLng? coordinates;
  final String? phoneNumber;
  final String? website;

  PlaceDetails({
    required this.placeId,
    required this.name,
    this.address,
    this.coordinates,
    this.phoneNumber,
    this.website,
  });

  factory PlaceDetails.fromGooglePlacesResult(dynamic result) {
    return PlaceDetails(
      placeId: result['place_id'] ?? '',
      name: result['name'] ?? '',
      address: result['formatted_address'],
      coordinates: result['geometry']?['location'] != null
          ? LatLng(
              result['geometry']['location']['lat'],
              result['geometry']['location']['lng'],
            )
          : null,
      phoneNumber: result['formatted_phone_number'],
      website: result['website'],
    );
  }
}
