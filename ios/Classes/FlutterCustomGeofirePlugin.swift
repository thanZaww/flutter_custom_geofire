import Flutter
import UIKit
import CoreLocation
import Firebase

public class SwiftFlutterCustomGeofirePlugin: NSObject, FlutterPlugin, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager
    private var channel: FlutterMethodChannel

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_custom_geofire", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterCustomGeofirePlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    init(channel: FlutterMethodChannel) {
        self.channel = channel
        self.locationManager = CLLocationManager()
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getCurrentLocation":
            getCurrentLocation(result: result)
        case "saveLocation":
            saveLocation(arguments: call.arguments, result: result)
        case "queryLocations":
            queryLocations(arguments: call.arguments, result: result)
        case "initialize":
            initialize(result: result)
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

    private func getCurrentLocation(result: @escaping FlutterResult) {
        if let location = locationManager.location {
            result([
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude
            ])
        } else {
            result(FlutterError(code: "UNAVAILABLE", message: "Location data unavailable", details: nil))
        }
    }

    private func saveLocation(arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let userId = args["userId"] as? String,
              let latitude = args["latitude"] as? Double,
              let longitude = args["longitude"] as? Double else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        let ref = Database.database().reference(withPath: "locations/\(userId)")
        let loc: [String: Any] = [
            "latitude": latitude,
            "longitude": longitude,
            "timestamp": Date().timeIntervalSince1970 * 1000
        ]

        ref.setValue(loc) { error, _ in
            if let error = error {
                result(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
            } else {
                result(nil)
            }
        }
    }

    private func queryLocations(arguments: Any?, result: @escaping FlutterResult) {
        // Similar implementation as Android
    }

    private func initialize(result: @escaping FlutterResult) {
        // Initialization logic here
        result(true)
    }

    private func removeLocation(arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let userId = args["userId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        let ref = Database.database().reference(withPath: "locations/\(userId)")
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

        let ref = Database.database().reference(withPath: "locations/\(userId)")
        let loc: [String: Any] = [
            "latitude": latitude,
            "longitude": longitude,
            "timestamp": Date().timeIntervalSince1970 * 1000
        ]

        ref.setValue(loc) { error, _ in
            if let error = error {
                result(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
            } else {
                result(true