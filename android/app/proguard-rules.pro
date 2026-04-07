# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Dart/Flutter SSL & HTTP — prevents handshake errors in release mode
-keep class javax.net.ssl.** { *; }
-keepattributes *Annotation*
-dontwarn javax.net.ssl.**

# OkHttp (used internally by Flutter HTTP)
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# Dart HTTP package
-keep class org.conscrypt.** { *; }
-dontwarn org.conscrypt.**

# Keep SSL/TLS provider classes
-keep class com.android.org.conscrypt.** { *; }
-keep class sun.security.** { *; }
-dontwarn sun.security.**
