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

# AdMob
-keep class com.google.android.gms.ads.** { *; }

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
