# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Flutter Play Store Split Application (deferred components)
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# AdMob — google_mobile_ads dep dropped in v1; restore this keep along
# with the package when ads return.

# Drift / SQLite
-keep class com.tekartik.sqflite.** { *; }
-keep class drift.** { *; }
-keep class * extends drift.DatabaseConnection { *; }

# JSON serialization / annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Riverpod generated code
-keep class **$*$* { *; }

# HTTP / Dio
-keep class com.fasterxml.jackson.** { *; }

# Suppress warnings for missing Play Core classes
-dontwarn com.google.android.play.core.**

# flutter_local_notifications — keep receivers + plugin code; without this,
# R8 strips internals referenced by AlarmManager via class-name strings, and
# scheduled notifications silently fail in release builds.
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# GSON (used internally by flutter_local_notifications to persist scheduled
# notification specs across process restarts; field-name stripping breaks
# the JSON round-trip when the receiver wakes after process death).
-dontwarn sun.misc.**
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken
