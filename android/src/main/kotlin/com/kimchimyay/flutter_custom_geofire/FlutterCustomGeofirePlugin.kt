package com.kimchimyay.flutter_custom_geofire

import android.content.Context
import android.location.Location
import androidx.annotation.NonNull
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationServices
import com.google.firebase.database.DatabaseReference
import com.google.firebase.database.FirebaseDatabase
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class FlutterCustomGeofirePlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var fusedLocationClient: FusedLocationProviderClient

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_custom_geofire")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(context)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getCurrentLocation" -> getCurrentLocation(result)
            "saveLocation" -> saveLocation(call.arguments, result)
            "queryLocations" -> queryLocations(call.arguments, result)
            "initialize" -> initialize(result)
            "removeLocation" -> removeLocation(call.arguments, result)
            "setLocation" -> setLocation(call.arguments, result)
            "stopListener" -> stopListener(result)
            else -> result.notImplemented()
        }
    }

    private fun getCurrentLocation(result: Result) {
        fusedLocationClient.lastLocation.addOnSuccessListener { location: Location? ->
            if (location != null) {
                val loc = mapOf("latitude" to location.latitude, "longitude" to location.longitude)
                result.success(loc)
            } else {
                result.error("UNAVAILABLE", "Location data unavailable", null)
            }
        }
    }

    private fun saveLocation(arguments: Any, result: Result) {
        val args = arguments as Map<String, Any>
        val userId = args["userId"] as String
        val latitude = args["latitude"] as Double
        val longitude = args["longitude"] as Double

        val ref: DatabaseReference = FirebaseDatabase.getInstance().getReference("locations").child(userId)
        val loc = mapOf("latitude" to latitude, "longitude" to longitude, "timestamp" to System.currentTimeMillis())

        ref.setValue(loc).addOnCompleteListener { task ->
            if (task.isSuccessful) {
                result.success(null)
            } else {
                result.error("ERROR", task.exception?.message, null)
            }
        }
    }

    private fun queryLocations(arguments: Any, result: Result) {
        // Similar implementation as iOS
    }

    private fun initialize(result: Result) {
        // Initialization logic here
        result.success(true)
    }

    private fun removeLocation(arguments: Any, result: Result) {
        val args = arguments as Map<String, Any>
        val userId = args["userId"] as String

        val ref: DatabaseReference = FirebaseDatabase.getInstance().getReference("locations").child(userId)
        ref.removeValue().addOnCompleteListener { task ->
            if (task.isSuccessful) {
                result.success(true)
            } else {
                result.error("ERROR", task.exception?.message, null)
            }
        }
    }

    private fun setLocation(arguments: Any, result: Result) {
        val args = arguments as Map<String, Any>
        val userId = args["userId"] as String
        val latitude = args["latitude"] as Double
        val longitude = args["longitude"] as Double

        val ref: DatabaseReference = FirebaseDatabase.getInstance().getReference("locations").child(userId)
        val loc = mapOf("latitude" to latitude, "longitude" to longitude, "timestamp" to System.currentTimeMillis())

        ref.setValue(loc).addOnCompleteListener { task ->
            if (task.isSuccessful) {
                result.success(true)
            } else {
                result.error("ERROR", task.exception?.message, null)
            }
        }
    }

    private fun stopListener(result: Result) {
        // Stop listener logic here
        result.success(true)
    }
}
