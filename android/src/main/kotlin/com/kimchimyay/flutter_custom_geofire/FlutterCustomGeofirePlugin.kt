package com.kimchimyay.flutter_custom_geofire

import android.content.Context
import android.location.Location
import androidx.annotation.NonNull
import com.firebase.geofire.GeoFire
import com.firebase.geofire.GeoLocation
import com.firebase.geofire.GeoQuery
import com.firebase.geofire.GeoQueryEventListener
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationServices
import com.google.firebase.database.DatabaseError
import com.google.firebase.database.DatabaseReference
import com.google.firebase.database.FirebaseDatabase
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class FlutterCustomGeofirePlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private lateinit var geoFire: GeoFire

    // Variables to manage active GeoQuery and its listener
    private var currentGeoQuery: GeoQuery? = null
    private var geoQueryEventListener: GeoQueryEventListener? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_custom_geofire")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(context)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> initialize(call.arguments, result)
            "getCurrentLocation" -> getCurrentLocation(result)
            "saveLocation" -> saveLocation(call.arguments, result)
            "queryLocations" -> queryLocations(call.arguments, result)
            "removeLocation" -> removeLocation(call.arguments, result)
            "setLocation" -> setLocation(call.arguments, result)
            "stopListener" -> stopListener(result)
            else -> result.notImplemented()
        }
    }

    private fun initialize(arguments: Any, result: MethodChannel.Result) {
        val args = arguments as? Map<*, *>
        val node = args?.get("node") as? String

        if (node.isNullOrEmpty()) {
            result.error("INVALID_ARGUMENTS", "Node parameter is missing or invalid", null)
            return
        }

        // Firebase Database reference
        val databaseReference = FirebaseDatabase.getInstance().getReference(node)

        // Initialize GeoFire with the database reference
        geoFire = GeoFire(databaseReference)

        result.success(true)
    }

    private fun getCurrentLocation(result: MethodChannel.Result) {
        fusedLocationClient.lastLocation
            .addOnSuccessListener { location: Location? ->
                if (location != null) {
                    val loc = mapOf(
                        "latitude" to location.latitude,
                        "longitude" to location.longitude
                    )
                    result.success(loc)
                } else {
                    result.error("UNAVAILABLE", "Location data unavailable", null)
                }
            }
            .addOnFailureListener { exception ->
                result.error("ERROR", exception.localizedMessage, null)
            }
    }

    private fun saveLocation(arguments: Any, result: MethodChannel.Result) {
        val args = arguments as? Map<*, *>
        val userId = args?.get("userId") as? String
        val latitude = args?.get("latitude") as? Double
        val longitude = args?.get("longitude") as? Double

        if (userId.isNullOrEmpty() || latitude == null || longitude == null) {
            result.error("INVALID_ARGUMENTS", "Missing or invalid arguments", null)
            return
        }

        val ref: DatabaseReference = FirebaseDatabase.getInstance().getReference("locations").child(userId)
        val loc = mapOf(
            "latitude" to latitude,
            "longitude" to longitude,
            "timestamp" to System.currentTimeMillis()
        )

        ref.setValue(loc)
            .addOnCompleteListener { task ->
                if (task.isSuccessful) {
                    result.success(null)
                } else {
                    result.error("ERROR", task.exception?.message, null)
                }
            }
    }

    private fun queryLocations(arguments: Any, result: MethodChannel.Result) {
        // Stop any existing GeoQuery before starting a new one
        stopListenerInternal()

        val args = arguments as? Map<*, *>
        val latitude = args?.get("latitude") as? Double
        val longitude = args?.get("longitude") as? Double
        val radiusInKm = args?.get("radiusInKm") as? Double

        if (latitude == null || longitude == null || radiusInKm == null) {
            result.error("INVALID_ARGUMENTS", "Missing or invalid arguments", null)
            return
        }

        val center = GeoLocation(latitude, longitude)
        currentGeoQuery = geoFire.queryAtLocation(center, radiusInKm)

        val locations = mutableListOf<Map<String, Any>>()

        geoQueryEventListener = object : GeoQueryEventListener {
            override fun onKeyEntered(key: String, location: GeoLocation) {
                locations.add(
                    mapOf(
                        "key" to key,
                        "latitude" to location.latitude,
                        "longitude" to location.longitude
                    )
                )
            }

            override fun onKeyExited(key: String) {
                // Handle key exited if needed
            }

            override fun onKeyMoved(key: String, location: GeoLocation) {
                // Handle key moved if needed
            }

            override fun onGeoQueryReady() {
                result.success(locations)
            }

            override fun onGeoQueryError(error: DatabaseError) {
                result.error("ERROR", error.message, null)
            }
        }

        currentGeoQuery?.addGeoQueryEventListener(geoQueryEventListener)
    }

    private fun removeLocation(arguments: Any, result: MethodChannel.Result) {
        val args = arguments as? Map<*, *>
        val userId = args?.get("userId") as? String

        if (userId.isNullOrEmpty()) {
            result.error("INVALID_ARGUMENTS", "User ID is missing or invalid", null)
            return
        }

        val ref: DatabaseReference = FirebaseDatabase.getInstance().getReference("locations").child(userId)
        ref.removeValue()
            .addOnCompleteListener { task ->
                if (task.isSuccessful) {
                    result.success(true)
                } else {
                    result.error("ERROR", task.exception?.message, null)
                }
            }
    }

    private fun setLocation(arguments: Any, result: MethodChannel.Result) {
        val args = arguments as? Map<*, *>
        val userId = args?.get("userId") as? String
        val latitude = args?.get("latitude") as? Double
        val longitude = args?.get("longitude") as? Double

        if (userId.isNullOrEmpty() || latitude == null || longitude == null) {
            result.error("INVALID_ARGUMENTS", "Missing or invalid arguments", null)
            return
        }

        val ref: DatabaseReference = FirebaseDatabase.getInstance().getReference("locations").child(userId)
        val loc = mapOf(
            "latitude" to latitude,
            "longitude" to longitude,
            "timestamp" to System.currentTimeMillis()
        )

        ref.setValue(loc)
            .addOnCompleteListener { task ->
                if (task.isSuccessful) {
                    result.success(true)
                } else {
                    result.error("ERROR", task.exception?.message, null)
                }
            }
    }

    private fun stopListener(result: MethodChannel.Result) {
        stopListenerInternal()
        result.success(true)
    }

    /**
     * Internal method to stop any active GeoQuery and its listener.
     */
    private fun stopListenerInternal() {
        geoQueryEventListener?.let { listener ->
            currentGeoQuery?.removeGeoQueryEventListener(listener)
            geoQueryEventListener = null
        }
        currentGeoQuery = null
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        // Clean up resources
        stopListenerInternal()
        channel.setMethodCallHandler(null)
    }
}
