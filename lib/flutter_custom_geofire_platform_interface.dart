import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_custom_geofire_method_channel.dart';

abstract class FlutterCustomGeofirePlatform extends PlatformInterface {
  FlutterCustomGeofirePlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterCustomGeofirePlatform _instance =
      MethodChannelFlutterCustomGeofire();

  static FlutterCustomGeofirePlatform get instance => _instance;

  static set instance(FlutterCustomGeofirePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('getPlatformVersion() has not been implemented.');
  }

  Future<Map<String, dynamic>?> getCurrentLocation() {
    throw UnimplementedError('getCurrentLocation() has not been implemented.');
  }

  Future<void> saveLocation(String userId, double latitude, double longitude) {
    throw UnimplementedError('saveLocation() has not been implemented.');
  }

  Future<void> queryLocations(
      double latitude, double longitude, double radiusInKm) {
    throw UnimplementedError('queryLocations() has not been implemented.');
  }

  Future<void> initialize() {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<void> removeLocation(String userId) {
    throw UnimplementedError('removeLocation() has not been implemented.');
  }

  Future<void> setLocation(String userId, double latitude, double longitude) {
    throw UnimplementedError('setLocation() has not been implemented.');
  }

  Future<void> stopListener() {
    throw UnimplementedError('stopListener() has not been implemented.');
  }
}
