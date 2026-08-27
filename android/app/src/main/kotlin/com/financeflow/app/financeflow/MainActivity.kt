package com.financeflow.app.financeflow

import android.Manifest
import android.app.NotificationManager
import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.os.UserManager
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.renderer.FlutterUiDisplayListener
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity(), FlutterUiDisplayListener {
    private val startupLogTag = "FinanceFlowStartup"
    private val channelName = "com.financeflow.app/ingestion"
    private val smsRequestCode = 8841
    private var pendingSmsResult: MethodChannel.Result? = null
    private lateinit var ingestionChannel: MethodChannel

    companion object {
        @Volatile private var activeChannel: MethodChannel? = null

        fun notifyEventsAvailable() {
            Handler(Looper.getMainLooper()).post {
                activeChannel?.invokeMethod("eventsAvailable", null)
            }
        }
    }

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        Log.i(startupLogTag, "MainActivity.onCreate; savedInstanceState=${savedInstanceState != null}")
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        Log.i(startupLogTag, "configureFlutterEngine entered")
        super.configureFlutterEngine(flutterEngine)
        ingestionChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        activeChannel = ingestionChannel
        ingestionChannel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "getStatus" -> result.success(statusMap())
                    "requestSmsPermission" -> requestSmsPermission(result)
                    "openAppSettings" -> {
                        startActivity(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                            data = android.net.Uri.parse("package:$packageName")
                        })
                        result.success(null)
                    }
                    "openNotificationAccessSettings" -> {
                        startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS))
                        result.success(null)
                    }
                    "configure" -> {
                        val args = call.arguments as? Map<*, *> ?: emptyMap<String, Any>()
                        IngestionEventStore.configure(
                            this,
                            args["smsEnabled"] as? Boolean ?: false,
                            args["notificationEnabled"] as? Boolean ?: false,
                            (args["smsSenders"] as? List<*>)?.filterIsInstance<String>()?.toSet() ?: emptySet(),
                            (args["notificationPackages"] as? List<*>)?.filterIsInstance<String>()?.toSet() ?: emptySet(),
                        )
                        result.success(null)
                    }
                    "pendingEvents" -> result.success(IngestionEventStore.pending(this))
                    "acknowledgeEvents" -> {
                        val ids = (call.arguments as? List<*>)?.filterIsInstance<String>()?.toSet() ?: emptySet()
                        IngestionEventStore.acknowledge(this, ids)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        Log.i(startupLogTag, "configureFlutterEngine completed")
    }

    override fun onFlutterUiDisplayed() {
        Log.i(startupLogTag, "Flutter reported its first UI frame")
    }

    // FlutterFragment forwards display events to this interface; the activity
    // superclass has no display callback to call through to.
    override fun onFlutterUiNoLongerDisplayed() = Unit

    override fun onDestroy() {
        if (::ingestionChannel.isInitialized && activeChannel === ingestionChannel) {
            activeChannel = null
        }
        super.onDestroy()
    }

    private fun requestSmsPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M || hasSmsPermission()) {
            result.success(statusMap())
            return
        }
        pendingSmsResult = result
        getSharedPreferences("financeflow_ingestion", MODE_PRIVATE)
            .edit().putBoolean("sms_permission_requested", true).apply()
        ActivityCompat.requestPermissions(
            this,
            arrayOf(Manifest.permission.RECEIVE_SMS, Manifest.permission.READ_SMS),
            smsRequestCode,
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == smsRequestCode) {
            pendingSmsResult?.success(statusMap())
            pendingSmsResult = null
        }
    }

    private fun hasSmsPermission(): Boolean =
        ContextCompat.checkSelfPermission(this, Manifest.permission.RECEIVE_SMS) == PackageManager.PERMISSION_GRANTED &&
            ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED

    private fun notificationAccessEnabled(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            getSystemService(NotificationManager::class.java)
                .isNotificationListenerAccessGranted(
                    ComponentName(this, FinanceFlowNotificationListener::class.java),
                )
        } else {
            Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
                ?.contains(packageName) == true
        }
    }

    private fun statusMap(): Map<String, Any> {
        val granted = hasSmsPermission()
        val smsAvailable = packageManager.hasSystemFeature(PackageManager.FEATURE_TELEPHONY_MESSAGING)
        val smsRestricted = getSystemService(UserManager::class.java)
            ?.hasUserRestriction(UserManager.DISALLOW_SMS) == true
        val asked = getSharedPreferences("financeflow_ingestion", MODE_PRIVATE)
            .getBoolean("sms_permission_requested", false)
        val permanentlyDenied = !granted && asked &&
            !ActivityCompat.shouldShowRequestPermissionRationale(this, Manifest.permission.RECEIVE_SMS)
        return mapOf(
            "platform" to "android",
            "smsAvailable" to smsAvailable,
            "smsStatus" to when {
                granted -> "granted"
                smsRestricted -> "restricted"
                !smsAvailable -> "unavailable"
                permanentlyDenied -> "permanentlyDenied"
                else -> "denied"
            },
            "notificationAccess" to notificationAccessEnabled(),
        )
    }
}
