import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final currentPositionProvider = FutureProvider<Position>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  try {
    return await locationService.getPosition();
  } catch (e) {
    print("Error getting initial position: $e");
    rethrow;
  }
});

class LocationService {
  Future<Position> getPosition() async {
    // Check if location services are enabled
    final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      throw LocationServiceDisabledException();
    }

    // Check and handle permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationPermissionDeniedException();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationPermissionPermanentlyDeniedException();
    }

    // Retrieve position with error handling
    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      throw LocationRetrievalException(e.toString());
    }
  }
}

// Custom Exception Classes
class LocationServiceDisabledException implements Exception {
  @override
  String toString() => 'Location services are disabled. Please enable them.';
}

class LocationPermissionDeniedException implements Exception {
  @override
  String toString() => 'Location permission was denied.';
}

class LocationPermissionPermanentlyDeniedException implements Exception {
  @override
  String toString() =>
      'Location permissions are permanently denied. Please enable them in app settings.';
}

class LocationRetrievalException implements Exception {
  final String message;
  LocationRetrievalException(this.message);

  @override
  String toString() => 'Error retrieving location: $message';
}