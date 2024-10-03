import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_custom_geofire/flutter_custom_geofire.dart';
import 'package:flutter_custom_geofire/flutter_custom_geofire_platform_interface.dart';
import 'package:flutter_custom_geofire/flutter_custom_geofire_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterCustomGeofirePlatform
    with MockPlatformInterfaceMixin
    implements FlutterCustomGeofirePlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<Map<String, dynamic>?> getCurrentLocation() => Future.value({
        'latitude': 37.7749,
        'longitude': -122.4194,
      });

  @override
  Future<void> saveLocation(String userId, double latitude, double longitude) {
    return Future.value();
  }

  @override
  Future<void> queryLocations(
      double latitude, double longitude, double radiusInKm) {
    return Future.value();
  }

  @override
  Future<void> initialize() {
    return Future.value();
  }

  @override
  Future<void> removeLocation(String userId) {
    return Future.value();
  }

  @override
  Future<void> setLocation(String userId, double latitude, double longitude) {
    return Future.value();
  }

  @override
  Future<void> stopListener() {
    return Future.value();
  }
}

void main() {
  final FlutterCustomGeofirePlatform initialPlatform =
      FlutterCustomGeofirePlatform.instance;

  test('$MethodChannelFlutterCustomGeofire is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterCustomGeofire>());
  });

  test('getPlatformVersion', () async {
    FlutterCustomGeofire flutterCustomGeofirePlugin = FlutterCustomGeofire();
    MockFlutterCustomGeofirePlatform fakePlatform =
        MockFlutterCustomGeofirePlatform();
    FlutterCustomGeofirePlatform.instance = fakePlatform;

    expect(await flutterCustomGeofirePlugin.getPlatformVersion(), '42');
  });

  test('getCurrentLocation', () async {
    FlutterCustomGeofire flutterCustomGeofirePlugin = FlutterCustomGeofire();
    MockFlutterCustomGeofirePlatform fakePlatform =
        MockFlutterCustomGeofirePlatform();
    FlutterCustomGeofirePlatform.instance = fakePlatform;

    final location = await flutterCustomGeofirePlugin.getCurrentLocation();
    expect(location, {
      'latitude': 37.7749,
      'longitude': -122.4194,
    });
  });
}
