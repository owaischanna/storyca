package com.example.storryca

import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Content protection for novel chapters only: the reader turns this
        // on while it is open and off when it closes. While on, screenshots
        // are refused, recordings and casts show black, and the recent-apps
        // thumbnail is blank. The rest of the app stays capturable. Can't
        // stop a camera pointed at the screen; rooted devices can bypass it.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "storryca/secure")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "enable" -> {
                        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        result.success(null)
                    }
                    "disable" -> {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        // Once notifications are denied twice Android stops showing the
        // permission prompt, so the only way back is the app's notification
        // settings page — opened from Dart through this channel.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "storryca/notifications")
            .setMethodCallHandler { call, result ->
                if (call.method == "openSettings") {
                    val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                            .putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                    } else {
                        Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                            .setData(android.net.Uri.parse("package:$packageName"))
                    }
                    startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }
}
