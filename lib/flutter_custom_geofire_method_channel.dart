import 'package:flutter/services.dart';

import 'flutter_custom_geofire_platform_interface.dart';

class MethodChannelFlutterCustomGeofire extends FlutterCustomGeofirePlatform {
  final MethodChannel _methodChannel =
      const MethodChannel('flutter_custom_geofire');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await _methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<Map<String, dynamic>?> getCurrentLocation() async {
    final location = await _methodChannel
        .invokeMethod<Map<String, dynamic>>('getCurrentLocation');
    return location;
  }

  @override
  Future<void> saveLocation(
      String userId, double latitude, double longitude) async {
    await _methodChannel.invokeMethod('saveLocation', {
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  @override
  Future<void> queryLocations(
      double latitude, double longitude, double radiusInKm) async {
    await _methodChannel.invokeMethod('queryLocations', {
      'latitude': latitude,
      'longitude': longitude,
      'radiusInKm': radiusInKm,
    });
  }

  @override
  Future<void> initialize(String node) async {
    await _methodChannel.invokeMethod('initialize', {'node': node});
  }

  @override
  Future<void> removeLocation(String userId) async {
    await _methodChannel.invokeMethod('removeLocation', {
      'userId': userId,
    });
  }

  @override
  Future<void> setLocation(
      String userId, double latitude, double longitude) async {
    await _methodChannel.invokeMethod('setLocation', {
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  @override
  Future<void> stopListener() async {
    await _methodChannel.invokeMethod('stopListener');
  }
}
