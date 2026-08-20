import 'package:geolocator/geolocator.dart';

class LocationService {
  LocationService._internal();
  static final LocationService instance = LocationService._internal();

  Future<bool> ensurePermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return false;
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  Future<Position?> getCurrentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    if (!await ensurePermission()) return null;
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
    } catch (_) {
      return null;
    }
  }

  /// Stream of position updates - use for geofence-style "arrive/leave" checks.
  /// For production geofencing that works while the app is backgrounded/killed,
  /// pair this with a platform geofencing plugin (e.g. geofence_service) since
  /// plain Dart streams pause when the app isn't in the foreground.
  Stream<Position> get positionStream => Geolocator.getPositionStream(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 25),
      );

  double distanceMeters(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
}
