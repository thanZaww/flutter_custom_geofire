import Flutter
import UIKit
import CoreLocation
import FirebaseDatabase

public class SwiftFlutterCustomGeofirePlugin: NSObject, FlutterPlugin, CLLocationManagerDelegate {
    private var geoFire: GeoFire?
    private var locationManager: CLLocationManager?
    private var currentLocation: CLLocation?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_custom_geofire", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterCustomGeofirePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            initialize(arguments: call.arguments, result: result)
        case "getCurrentLocation":
            getCurrentLocation(result: result)
        case "saveLocation":
            saveLocation(arguments: call.arguments, result: result)
        case "queryLocations":
            queryLocations(arguments: call.arguments, result: result)
        case "removeLocation":
            removeLocation(arguments: call.arguments, result: result)
        case "setLocation":
            setLocation(arguments: call.arguments, result: result)
        case "stopListener":
            stopListener(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func initialize(arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let node = args["node"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        // Firebase Database reference
        let databaseReference = Database.database().reference(withPath: node)

        // Initialize Geofire with the database reference
        geoFire = GeoFire(firebaseRef: databaseReference)

        // Initialize CLLocationManager
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()

        result(true)
    }

    private func getCurrentLocation(result: @escaping FlutterResult) {
        guard CLLocationManager.locationServicesEnabled() else {
            result(FlutterError(code: "LOCATION_SERVICES_DISABLED", message: "Location services are disabled", details: nil))
            return
        }

        locationManager?.startUpdatingLocation()

        // After getting the location, we stop updating to preserve battery
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.locationManager?.stopUpdatingLocation()

            if let currentLocation = self.currentLocation {
                let locationData: [String: Any] = [
                    "latitude": currentLocation.coordinate.latitude,
                    "longitude": currentLocation.coordinate.longitude
                ]
                result(locationData)
            } else {
                result(FlutterError(code: "LOCATION_ERROR", message: "Unable to retrieve location", details: nil))
            }
        }
    }

    // CLLocationManagerDelegate method to get updated locations
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with error: \(error.localizedDescription)")
    }

    private func saveLocation(arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let userId = args["userId"] as? String,
              let latitude = args["latitude"] as? Double,
              let longitude = args["longitude"] as? Double else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        let ref = Database.database().reference(withPath: "locations").child(userId)
        let loc = ["latitude": latitude, "longitude": longitude, "timestamp": Date().timeIntervalSince1970] as [String : Any]

        ref.setValue(loc) { error, _ in
            if let error = error {
                result(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
            } else {
                result(nil)
            }
        }
    }

    private func queryLocations(arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let latitude = args["latitude"] as? Double,
              let longitude = args["longitude"] as? Double,
              let radiusInKm = args["radiusInKm"] as? Double else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        let center = CLLocation(latitude: latitude, longitude: longitude)
        let circleQuery = geoFire?.query(at: center, withRadius: radiusInKm)

        var locations = [[String: Any]]()

        circleQuery?.observe(.keyEntered, with: { (key: String?, location: CLLocation?) in
            if let key = key, let location = location {
                locations.append([
                    "key": key,
                    "latitude": location.coordinate.latitude,
                    "longitude": location.coordinate.longitude
                ])
            } })

        circleQuery?.observeReady {
            result(locations)
        }
    }

    private func removeLocation(arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let userId = args["userId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        let ref = Database.database().reference(withPath: "locations").child(userId)
        ref.removeValue { error, _ in
            if let error = error {
                result(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
            } else {
                result(true)
            }
        }
    }

    private func setLocation(arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let userId = args["userId"] as? String,
              let latitude = args["latitude"] as? Double,
              let longitude = args["longitude"] as? Double else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        let ref = Database.database().reference(withPath: "locations").child(userId)
        let loc = ["latitude": latitude, "longitude": longitude, "timestamp": Date().timeIntervalSince1970] as [String : Any]

        ref.setValue(loc) { error, _ in
            if let error = error {
                result(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
            } else {
                result(true)
            }
        }
    }

    private func stopListener(result: @escaping FlutterResult) {
        locationManager?.stopUpdatingLocation()
        result(true)
    }
}
