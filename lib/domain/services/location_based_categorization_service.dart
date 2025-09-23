import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../domain/entities/category.dart';

class LocationBasedCategorizationService {
  /// Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      // Check location permission
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requestedPermission = await Geolocator.requestPermission();
        if (requestedPermission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Open app settings to allow location permission
        await Geolocator.openAppSettings();
        return null;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition();
      return position;
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  /// Get place information from coordinates
  Future<PlaceInfo?> getPlaceInfo(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return PlaceInfo(
          name: place.name ?? '',
          street: place.street ?? '',
          locality: place.locality ?? '',
          administrativeArea: place.administrativeArea ?? '',
          country: place.country ?? '',
          postalCode: place.postalCode ?? '',
        );
      }
    } catch (e) {
      print('Error getting place info: $e');
    }
    return null;
  }

  /// Suggest category based on location
  Future<int?> suggestCategoryByLocation(Position position) async {
    try {
      final placeInfo = await getPlaceInfo(position.latitude, position.longitude);
      if (placeInfo != null) {
        // In a real implementation, this would use a more sophisticated matching algorithm
        // For now, we'll use simple keyword matching
        return _matchCategoryByKeywords(placeInfo);
      }
    } catch (e) {
      print('Error suggesting category by location: $e');
    }
    return null;
  }

  /// Match category by keywords in place information
  int? _matchCategoryByKeywords(PlaceInfo placeInfo) {
    final keywords = [
      placeInfo.name.toLowerCase(),
      placeInfo.street.toLowerCase(),
      placeInfo.locality.toLowerCase(),
      placeInfo.administrativeArea.toLowerCase(),
    ].join(' ');

    // Define keyword mappings to category IDs
    // In a real implementation, these would come from a database or configuration
    final keywordMappings = {
      2: ['grocery', 'supermarket', 'food', 'market'], // Food category
      3: ['gas', 'fuel', 'petrol', 'diesel', 'station'], // Gas category
      4: ['rent', 'mortgage', 'housing', 'apartment', 'home'], // Housing category
      5: ['electricity', 'water', 'utilities', 'internet', 'phone', 'utility'], // Utilities category
      6: ['entertainment', 'movie', 'concert', 'show', 'cinema', 'theater'], // Entertainment category
      7: ['shopping', 'clothing', 'retail', 'mall', 'store'], // Shopping category
      8: ['health', 'medical', 'doctor', 'hospital', 'clinic'], // Health category
      9: ['transport', 'bus', 'train', 'taxi', 'uber', 'public transport'], // Transportation category
      10: ['restaurant', 'dining', 'meal', 'lunch', 'dinner', 'cafe'], // Dining category
    };

    // Check each category for matching keywords
    for (final entry in keywordMappings.entries) {
      final categoryId = entry.key;
      final categoryKeywords = entry.value;

      for (final keyword in categoryKeywords) {
        if (keywords.contains(keyword)) {
          return categoryId;
        }
      }
    }

    // Return default category if no match found
    return null;
  }

  /// Get nearby places (for manual selection)
  Future<List<NearbyPlace>> getNearbyPlaces(Position position) async {
    // In a real implementation, this would call a places API like Google Places
    // For now, we'll return mock data
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      NearbyPlace(
        name: 'Grocery Store',
        address: '123 Main St',
        latitude: position.latitude + 0.001,
        longitude: position.longitude + 0.001,
        suggestedCategoryId: 2,
      ),
      NearbyPlace(
        name: 'Gas Station',
        address: '456 Oak Ave',
        latitude: position.latitude - 0.002,
        longitude: position.longitude - 0.001,
        suggestedCategoryId: 3,
      ),
      // Add more mock places
    ];
  }
}

class PlaceInfo {
  final String name;
  final String street;
  final String locality;
  final String administrativeArea;
  final String country;
  final String postalCode;

  PlaceInfo({
    required this.name,
    required this.street,
    required this.locality,
    required this.administrativeArea,
    required this.country,
    required this.postalCode,
  });
}

class NearbyPlace {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int? suggestedCategoryId;

  NearbyPlace({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.suggestedCategoryId,
  });
}