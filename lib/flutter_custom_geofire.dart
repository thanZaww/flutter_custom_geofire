import 'flutter_custom_geofire_platform_interface.dart';

class FlutterCustomGeofire {
  static FlutterCustomGeofirePlatform get _platform =>
      FlutterCustomGeofirePlatform.instance;

  Future<String?> getPlatformVersion() {
    return _platform.getPlatformVersion();
  }

  Future<Map<String, dynamic>?> getCurrentLocation() {
    return _platform.getCurrentLocation();
  }

  Future<void> saveLocation(String userId, double latitude, double longitude) {
    return _platform.saveLocation(userId, latitude, longitude);
  }

  Future<void> queryLocations(
      double latitude, double longitude, double radiusInKm) {
    return _platform.queryLocations(latitude, longitude, radiusInKm);
  }

  Future<void> initialize() {
    return _platform.initialize();
  }

  Future<void> removeLocation(String userId) {
    return _platform.removeLocation(userId);
  }

  Future<void> setLocation(String userId, double latitude, double longitude) {
    return _platform.setLocation(userId, latitude, longitude);
  }

  Future<void> stopListener() {
    return _platform.stopListener();
  }
}
