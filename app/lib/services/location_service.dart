import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/services.dart';

/// A service class to handle location fetching and reverse geocoding.
class LocationService {
  /// Checks for and requests location permissions.
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled on the device.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return false;
    }

    // Check for location permissions.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied.');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied, we cannot request.');
      return false;
    }

    return true;
  }

  /// Gets the current state from the device's location using geocoding.
  Future<String> getCurrentState() async {
    try {
      // First, check for location permissions.
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) {
        return 'Permission Denied';
      }

      // Get the current position.
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Perform reverse geocoding to get the address from coordinates.
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Check if we found a place and return the administrative area (state).
      if (placemarks.isNotEmpty) {
        return placemarks.first.locality ?? 'Unknown State';
      }

      return 'State Not Found';

    } on PlatformException catch (e) {
      print("Location service error: ${e.message}");
      return 'Unknown';
    } catch (e) {
      print("Geocoding error: $e");
      return 'Unknown';
    }
  }
}
