# R8 rules for release builds (shrinking + obfuscation).
# Flutter's Gradle plugin adds the Flutter engine rules itself, and most
# plugins (Firebase, Google Mobile Ads, Play Billing, ExoPlayer/media3,
# Credential Manager, WebView) ship consumer rules inside their AARs. Only
# what those don't cover is listed here — keeping whole libraries would stop
# R8 optimising them and defeat the point.

# --- Flutter ---------------------------------------------------------------
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }
# Flutter references Play Core (deferred components), which this app doesn't use.
-dontwarn com.google.android.play.core.**

# --- App entry point and its MethodChannels (MainActivity) -----------------
-keep class com.example.storryca.** { *; }

# --- WorkManager / Room (pulled in by google_mobile_ads) -------------------
# Without this, R8 strips the generated WorkDatabase_Impl constructor and the
# app crashes with "Failed to create an instance of WorkDatabase".
-keep class * extends androidx.room.RoomDatabase { <init>(); }

# --- flutter_local_notifications -------------------------------------------
# Notification details are stored as JSON with Gson and read back by
# reflection, including generic type information.
-keep class com.dexterous.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

# --- WebView JavaScript bridges --------------------------------------------
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# --- Readable crash reports in Play Console --------------------------------
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
