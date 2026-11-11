package com.example.storryca

import android.content.Intent
import android.media.MediaMetadataRetriever
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
        // Reads a picked trailer's container type, duration and DISPLAYED
        // size — a phone held upright often stores 1920x1080 plus a 90°
        // rotation flag, which plays portrait and the server refuses, so
        // the rotation is applied here before the app checks 16:9.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "storryca/video")
            .setMethodCallHandler { call, result ->
                if (call.method != "metadata") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val path = call.argument<String>("path")
                val retriever = MediaMetadataRetriever()
                try {
                    retriever.setDataSource(path)
                    fun key(k: Int) = retriever.extractMetadata(k)
                    var width = key(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)?.toIntOrNull() ?: 0
                    var height = key(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT)?.toIntOrNull() ?: 0
                    val rotation = key(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION)?.toIntOrNull() ?: 0
                    if (rotation % 180 != 0) {
                        val w = width
                        width = height
                        height = w
                    }
                    result.success(
                        mapOf(
                            "width" to width,
                            "height" to height,
                            "durationMs" to (key(MediaMetadataRetriever.METADATA_KEY_DURATION)?.toLongOrNull() ?: 0L),
                            "mime" to (key(MediaMetadataRetriever.METADATA_KEY_MIMETYPE) ?: ""),
                        )
                    )
                } catch (e: Exception) {
                    // Unreadable here — let the server, which checks the
                    // same things, have the final word.
                    result.success(null)
                } finally {
                    try {
                        retriever.release()
                    } catch (_: Exception) {
                    }
                }
            }
    }
}
